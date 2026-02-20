class_name AndroidNativeFileDialog extends RefCounted
## Prompts the user to select one or more files using the native Android dialog and copies the selection into the user directory.
##
## [b]AndroidNativeFileDialog[/b] is a static class and should not be instantiated.[br][br]
## The files are copied asynchronously, without blocking the main thread. If you want to await the result, you should emit your own signal from the [param callback]. For example:
## [codeblock]
## signal file_selected()
##
## # Note: Using type int for brevity. It represents the AndroidNativeFileDialog.Error enum in all cases.
##
## func _ready():
##     var error: int = AndroidNativeFileDialog.open(AndroidNativeFileDialog.Mode.COPY_FILE, _callback)
##     if error:
##         printerr(AndroidNativeFileDialog.get_error_string(error))
##         return
##     await file_selected 
##
##
## func _callback(error: int, file_list: Dictionary[String, int]):
##     file_selected.emit()
## [/codeblock][br]
## The directory where the files are copied (see [method get_dir]) should ideally be considered temporary and cleared at the start of every session.
##
##

enum Mode {
	COPY_FILE, ## Allows selecting a single file. If it already exists in the user directory, it [b]WILL NOT[/b] be overwritten.
	COPY_FILE_OVERWRITE, ## Allows selecting a single file. If it already exists in the user directory, it [b]WILL[/b] be overwritten.
	COPY_FILES, ## Allows selecting multiple files. Files that already exist in the user directory [b]WILL NOT[/b] be overwritten.
	COPY_FILES_OVERWRITE, ## Allows selecting multiple files. Files that already exist in the user directory [b]WILL[/b] be overwritten.
}

enum Error {
	OK,
	FAILED,
	PARTIAL,
	CANCELED,
	ALREADY_IN_USE,
	SECURITY_EXCEPTION,
	FILE_DATA_INVALID,
	FILE_EXTENSION_INVALID,
	FILE_SIZE_LIMIT_EXCEEDED,
	FILE_ALREADY_EXISTS,
	FILE_COPY_FAILED,
	DIR_PATH_INVALID,
	DIR_CREATE_FAILED,
	OUTPUT_STREAM_EXCEPTION,
	INPUT_STREAM_EXCEPTION,
	INPUT_STREAM_NULL,
	RESULT_DATA_INVALID,
	MIME_TYPE_INVALID,
	ACTIVITY_NULL,
	ACTIVITY_EXCEPTION,
	CALLBACK_INVALID,
	INSTANCE_INVALID,
}

static var _error_strings: PackedStringArray = AndroidNativeFileDialog.Error.keys()

static var _instance: JNISingleton = Engine.get_singleton(&"AndroidNativeFileDialogJNI") if Engine.has_singleton(&"AndroidNativeFileDialogJNI") else null
static var _is_valid: bool = false


static func _static_init() -> void:
	if _instance:
		_is_valid = true


## Displays the Android native dialog and returns an error code. See [method get_error_string][br][br]
## [param callback] has the following arguments: [code]error: AndroidNativeFileDialog.Error, file_list: Dictionary[String, AndroidNativeFileDialog.Error][/code][br]
## [param mime_type] allows wildcards: [code]"image/*"[/code] will enable the selection of any image.[br]
## [param allowed_extensions] should not be prefixed with a dot. Example: [code][txt, jpeg, png][/code][br]
## [param max_file_size] uses [b]bytes[/b] and is [b]inclusive[/b].
static func open(mode: Mode, callback: Callable, mime_type: String = "*/*",
		allowed_extensions: PackedStringArray = PackedStringArray(), max_file_size: int = 0) -> AndroidNativeFileDialog.Error:
	if not _is_valid:
		return AndroidNativeFileDialog.Error.INSTANCE_INVALID
	if not _is_valid_callback(callback):
		return AndroidNativeFileDialog.Error.CALLBACK_INVALID
	if not _instance.open(mode, mime_type, allowed_extensions, max_file_size):
		return _instance.getOpenError() as AndroidNativeFileDialog.Error
	_callback_on_request_processed(callback)
	return AndroidNativeFileDialog.Error.OK


## Returns a human-readable name for the given [enum AndroidNativeFileDialog.Error] code.
static func get_error_string(error: AndroidNativeFileDialog.Error) -> String:
	if error < 0 or error >= _error_strings.size():
		return "(invalid error code)"
	return _error_strings[error]


## Returns the virtual path of the directory where selected files are copied. By default, this is [code]user://[/code]
static func get_dir() -> String:
	if not _is_valid:
		return ""
	return "user://" + _instance.getDirName()


## Sets the directory where files are copied. Returns an error code. See [method get_error_string][br][br]
## The path must begin with [code]user://[/code], may only contain letters, digits and underscored, and must not exceed 255 characters.[br]
## Nested directories are supported, and the restrictions apply for each directory individually. Example: [code]"user://tmp/android_native_file_dialog"[/code] is valid.
static func set_dir(path: String) -> AndroidNativeFileDialog.Error:
	if not _is_valid:
		return AndroidNativeFileDialog.Error.INSTANCE_INVALID
	if not _is_valid_path(path):
		return AndroidNativeFileDialog.Error.DIR_PATH_INVALID
	return _instance.setDirName(path.replace("user://", "")) as AndroidNativeFileDialog.Error


static func _is_valid_callback(callback: Callable) -> bool:
	if not callback.is_valid() or not callback.is_standard():
		return false
	
	var object: Object = callback.get_object()
	if not object:
		return false
	var callback_name: StringName = callback.get_method()
	var callback_data: Dictionary
	for method: Dictionary in object.get_method_list():
		if method["name"] == callback_name:
			callback_data = method
			break
	if callback_data.is_empty():
		return false
	
	const ARGUMENT_COUNT: int = 2
	var callback_args: Array[Dictionary] = callback_data["args"]
	if callback_args.size() != ARGUMENT_COUNT:
		return false
	var error: Dictionary = callback_args[0]
	var file_list: Dictionary = callback_args[1]
	
	const HINT_STRINGS: PackedStringArray = ["String;AndroidNativeFileDialog.Error", "String;int"]
	return error["type"] == TYPE_INT and file_list["type"] == TYPE_DICTIONARY and file_list["hint_string"] in HINT_STRINGS


static func _callback_on_request_processed(callback: Callable) -> void:
	var typed_file_list: Dictionary[String, AndroidNativeFileDialog.Error]
	var error: AndroidNativeFileDialog.Error = _get_typed_result(await _instance.requestProcessed, typed_file_list)
	callback.call_deferred(error, typed_file_list)


static func _get_typed_result(request_result: Array,
		typed_file_list: Dictionary[String, AndroidNativeFileDialog.Error]) -> AndroidNativeFileDialog.Error:
	var error: int = request_result[0]
	var file_list: Dictionary = request_result[1]
	for file: String in file_list:
		typed_file_list[file] = file_list[file] as AndroidNativeFileDialog.Error
	return error as AndroidNativeFileDialog.Error


static func _is_valid_path(path: String) -> bool:
	var regex: RegEx = RegEx.create_from_string(r"^user:\/\/(?:(?<=\/)[a-zA-Z0-9_]{1,255}\/?)*$")
	if regex.is_valid():
		return true if regex.search(path) else false
	return false
