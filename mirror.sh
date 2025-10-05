#!/bin/bash

# Gitee配置信息
OWNER="zly-k"
REPO="platformer2d"

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
        log_info "请安装: sudo apt-get install ${missing[*]}"
        exit 1
    fi
}

# 创建Release
create_release() {
    local url="https://gitee.com/api/v5/repos/$OWNER/$REPO/releases"
    
    log_info "创建新的Release: $RELEASE_TAG"
    
    local response
    response=$(curl -s -X POST \
        -F "access_token=$GITEE_TOKEN" \
        -F "tag_name=$RELEASE_TAG" \
        -F "name=Release $RELEASE_TAG" \
        -F "body=Automatically released from CI/CD pipeline" \
        -F "target_commitish=master" \
        -F "prerelease=false" \
        "$url")
    
    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        local new_release_id=$(echo "$response" | jq -r '.id')
        log_info "✅ Release创建成功, ID: $new_release_id"
        echo "$new_release_id"
    else
        log_error "创建Release失败: $response"
        exit 1
    fi
}

# 获取Release ID，如果不存在则创建
get_release_id() {
    local url="https://gitee.com/api/v5/repos/$OWNER/$REPO/releases/tags/$RELEASE_TAG"
    local response
    
    response=$(curl -s -X GET \
        -F "access_token=$GITEE_TOKEN" \
        "$url")
    
    # 检查是否获取到有效的Release ID
    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        local release_id=$(echo "$response" | jq -r '.id')
        log_info "找到现有Release, ID: $release_id"
        echo "$release_id"
    else
        log_warning "Release '$RELEASE_TAG' 不存在，尝试创建..."
        create_release
    fi
}

# 获取附件列表
get_attachments() {
    local release_id=$1
    local url="https://gitee.com/api/v5/repos/$OWNER/$REPO/releases/$release_id/attach_files"
    
    curl -s -X GET \
        -F "access_token=$GITEE_TOKEN" \
        "$url?per_page=100"
}

# 删除单个附件
delete_attachment() {
    local attachment_id=$1
    local attachment_name=$2
    local url="https://gitee.com/api/v5/repos/$OWNER/$REPO/releases/attach_files/$attachment_id"
    
    local response
    response=$(curl -s -X DELETE \
        -F "access_token=$GITEE_TOKEN" \
        "$url")
    
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
    
    # 修复：检查 attachments 是否为空或无效
    if [ -z "$attachments" ] || [ "$attachments" = "null" ] || [ "$attachments" = "[]" ]; then
        log_info "没有找到需要清理的附件"
        return 0
    fi
    
    local count
    count=$(echo "$attachments" | jq 'length' 2>/dev/null || echo "0")
    
    if [ "$count" -gt 0 ] 2>/dev/null; then
        log_info "找到 $count 个附件需要清理"
        
        echo "$attachments" | jq -c '.[]' | while read -r attachment; do
            local attach_id attach_name
            attach_id=$(echo "$attachment" | jq -r '.id')
            attach_name=$(echo "$attachment" | jq -r '.name')
            
            if [ -n "$attach_id" ] && [ "$attach_id" != "null" ]; then
                delete_attachment "$attach_id" "$attach_name"
                sleep 0.3  # 避免API限流
            fi
        done
    else
        log_info "没有找到需要清理的附件"
    fi
}

# 上传文件 - 根据API文档修正
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
        -F "access_token=$GITEE_TOKEN" \
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
    # 处理命令行参数
    if [ $# -lt 3 ]; then
        log_error "参数不足"
        log_info "用法: $0 <gitee_token> <release_tag> <文件1> <文件2> ..."
        log_info "示例: $0 your_token v1.0.0 file1.zip file2.exe"
        log_info "示例: $0 your_token v1.2.3 platform2d-win64.zip platform2d-mac.zip"
        exit 1
    fi
    
    # 第一个参数是token
    GITEE_TOKEN="$1"
    shift  # 移除第一个参数
    
    # 第二个参数是release tag
    RELEASE_TAG="$1"
    shift  # 移除第二个参数
    
    # 将剩余参数转换为文件数组
    FILES_TO_UPLOAD=("$@")
    
    # 检查参数是否提供
    if [ -z "$GITEE_TOKEN" ]; then
        log_error "Gitee Token 不能为空"
        exit 1
    fi
    
    if [ -z "$RELEASE_TAG" ]; then
        log_error "Release Tag 不能为空"
        exit 1
    fi
    
    if [ ${#FILES_TO_UPLOAD[@]} -eq 0 ]; then
        log_error "请提供要上传的文件"
        exit 1
    fi
    
    log_info "开始Gitee Releases上传流程..."
    log_info "Release标签: $RELEASE_TAG"
    log_info "待上传文件: ${FILES_TO_UPLOAD[*]}"
    
    # 检查依赖
    check_dependencies
    
    # 获取Release ID（如果不存在会自动创建）
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

# 执行主函数，传递所有参数
main "$@"