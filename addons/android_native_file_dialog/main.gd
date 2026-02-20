@tool extends EditorPlugin

var _export_plugin: AndroidExportPlugin


func _enter_tree() -> void:
	_export_plugin = AndroidExportPlugin.new()
	add_export_plugin(_export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(_export_plugin)
	_export_plugin = null


class AndroidExportPlugin extends EditorExportPlugin:
	
	const _NAME: String = "AndroidNativeFileDialog"
	const _EXTENSION: String = "aar"
	
	
	func _get_name() -> String:
		return _NAME
	
	
	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid
	
	
	func _get_android_libraries(_platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return ["{path}.{type}.{extension}".format({
			"path": _NAME.to_snake_case().path_join(_NAME),
			"type": "debug" if debug else "release",
			"extension": _EXTENSION,
		})]
