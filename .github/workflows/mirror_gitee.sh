#!/bin/bash

# Gitee配置信息
GITEE_TOKEN="82384ae209bfec9e5b73ba8bee055d28"
OWNER="zly-k"
REPO="platformer2d"
RELEASE_TAG="v1.0.2"


# 颜色输出函数
log_info() {
    echo -e "\033[32m[INFO] $1\033[0m"
}

log_warning() {
    echo -e "\033[33m[WARNING] $1\033[0m"
}

log_error() {
    echo -e "\033[31m[ERROR] $1\033[0m"
}

# 检查必要工具
check_dependencies() {
    local missing=()
    
    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "缺少必要工具: ${missing[*]}"
        log_info "安装: sudo apt-get install ${missing[*]}"
        apt-get install curl jq
        exit 1
    fi
}

# 获取Release ID
get_release_id() {
    local url="https://gitee.com/api/v5/repos/$OWNER/$REPO/releases/tags/$RELEASE_TAG"
    local response
    
    response=$(curl -s -H "Authorization: Bearer $GITEE_TOKEN" "$url")
    
    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        echo "$response" | jq -r '.id'
    else
        log_error "获取Release失败: $response"
        exit 1
    fi
}

# 获取附件列表
get_attachments() {
    local release_id=$1
    local url="https://gitee.com/api/v5/repos/$OWNER/$REPO/releases/$release_id/attach_files"
    
    curl -s -H "Authorization: Bearer $GITEE_TOKEN" "$url?per_page=100"
}

# 删除单个附件
delete_attachment() {
    local attachment_id=$1
    local attachment_name=$2
    local url="https://gitee.com/api/v5/repos/$OWNER/$REPO/releases/$release_id/attach_files/$attachment_id"
    
    local response
    response=$(curl -s -X DELETE -H "Authorization: Bearer $GITEE_TOKEN" "$url")
    
    if [ $? -eq 0 ]; then
        log_info "已删除: $attachment_name"
    else
        log_error "删除失败: $attachment_name - $response"
    fi
}

# 清理现有附件
clean_attachments() {
    local release_id=$1
    log_info "开始清理现有附件..."
    
    local attachments
    attachments=$(get_attachments "$release_id")
    
    local count
    count=$(echo "$attachments" | jq length)
    
    if [ "$count" -gt 0 ]; then
        log_info "找到 $count 个附件需要清理"
        
        echo "$attachments" | jq -c '.[]' | while read -r attachment; do
            local attach_id attach_name
            attach_id=$(echo "$attachment" | jq -r '.id')
            attach_name=$(echo "$attachment" | jq -r '.name')
            
            delete_attachment "$attach_id" "$attach_name"
            sleep 0.3  # 避免API限流
        done
    else
        log_info "没有找到需要清理的附件"
    fi
}

# 上传文件
upload_file() {
    local release_id=$1
    local file_path=$2
    local url="https://gitee.com/api/v5/repos/$OWNER/$REPO/releases/$release_id/attach_files"
    
    if [ ! -f "$file_path" ]; then
        log_warning "文件不存在: $file_path"
        return 1
    fi
    
    log_info "正在上传: $(basename "$file_path")"
    
    local response
    response=$(curl -s -X POST \
        -H "Authorization: Bearer $GITEE_TOKEN" \
        -F "file=@$file_path" \
        "$url")
    
    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        log_info "✅ 上传成功: $(basename "$file_path")"
        return 0
    else
        log_error "上传失败: $(basename "$file_path") - $response"
        return 1
    fi
}

# 主函数
main() {
    log_info "开始Gitee Releases上传流程..."
    # 处理命令行参数
    if [ $# -eq 0 ]; then
        log_error "请提供要上传的文件路径作为参数"
        log_info "用法: $0 <文件1> <文件2> ..."
        exit 1
    fi
    
    # 将参数转换为文件数组
    FILES_TO_UPLOAD=("$@")
    
    log_info "开始Gitee Releases上传流程..."
    log_info "待上传文件: ${FILES_TO_UPLOAD[*]}"
    
    # 检查依赖
    check_dependencies
    
    # 获取Release ID
    log_info "获取Release信息: $RELEASE_TAG"
    RELEASE_ID=$(get_release_id)
    log_info "Release ID: $RELEASE_ID"
    
    # 清理现有附件
    clean_attachments "$RELEASE_ID"
    
    # 上传新文件
    log_info "开始上传新文件..."
    local success_count=0
    local fail_count=0
    
    for file in "${FILES_TO_UPLOAD[@]}"; do
        if upload_file "$RELEASE_ID" "$file"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
        sleep 0.5  # 避免API限流
    done
    
    # 输出结果
    log_info "上传完成! 成功: $success_count, 失败: $fail_count"
    
    if [ "$fail_count" -eq 0 ]; then
        log_info "🎉 所有文件上传成功!"
    else
        log_warning "有 $fail_count 个文件上传失败"
        exit 1
    fi
}

# 执行主函数
main "$@"