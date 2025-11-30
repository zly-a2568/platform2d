extends AnimatedSprite2D

func _ready():
	# 连接信号，确保在动画或帧更新时调用更新函数
	animation_changed.connect(_on_animation_or_frame_changed)
	frame_changed.connect(_on_animation_or_frame_changed)
	
	var shader_material := material as ShaderMaterial
	# 初始化
	_update_shader_params()

func _on_animation_or_frame_changed():
	_update_shader_params()

func _update_shader_params():
	if !material is ShaderMaterial:
		return
		
	var shader_material := material as ShaderMaterial
	
	# 获取当前动画名和帧索引
	var current_anim := animation
	var current_frame := frame
	
	# 从SpriteFrames资源中获取当前帧的纹理和区域
	var current_texture := sprite_frames.get_frame_texture(current_anim, current_frame)
	shader_material.set_shader_parameter("current_frame_texture",current_texture)
