@icon("res://addons/locker/icons/storage_accessor.svg")
@tool
## The [LokStorageAccessor] is a node specialized in saving,
## loading and removing data.
## 
## This class uses different [member versions] to handle data saving
## and loading accross different game versions. [br]
## In order to do the job of managing the data it receives, this class
## must have at least one [LokStorageAccessorVersion] set in its
## [member versions] and point to it through the [member version_number]
## property. [br]
## Such version should define the logic of how the data is gathered to be
## saved and how it is used when loaded. [br]
## See more about it here [LokStorageAccessorVersion]. [br]
## [br]
## [b]Version[/b]: 1.0.0[br]
## [b]Author[/b]: [url]github.com/nadjiel[/url]
class_name LokStorageAccessor
extends Node

## The [signal saving_started] is emitted when a save operation was started
## by this [LokStorageAccessor].
signal saving_started()

## The [signal loading_started] is emitted when a load operation was started
## by this [LokStorageAccessor].
signal loading_started()

## The [signal removing_started] is emitted when a remove operation was started
## by this [LokStorageAccessor].
signal removing_started()

## The [signal saving_finished] is emitted when a save operation was finished
## by this [LokStorageAccessor]. [br]
## This signal brings a [Dictionary] representing the result of the operation.
## This [Dictionary] has a [code]"status"[/code] key, with a
## [enum @GlobalScope.Error] code and a [code]"data"[/code] key, with the data
## saved.
signal saving_finished(result: Dictionary)

## The [signal loading_finished] is emitted when a load operation was finished
## by this [LokStorageAccessor]. [br]
## This signal brings a [Dictionary] representing the result of the operation.
## This [Dictionary] has a [code]"status"[/code] key, with a
## [enum @GlobalScope.Error] code and a [code]"data"[/code] key, with the data
## loaded.
signal loading_finished(result: Dictionary)

## The [signal removing_finished] is emitted when a remove operation was
## finished by this [LokStorageAccessor]. [br]
## This signal brings a [Dictionary] representing the result of the operation.
## This [Dictionary] has a [code]"status"[/code] key, with a
## [enum @GlobalScope.Error] code; a [code]"data"[/code] key, with the data
## removed; and a [code]"updated_data"[/code] key, with the data
## that wasn't removed.
signal removing_finished(result: Dictionary)

## The [member id] property specifies what is the unique id of this
## [LokStorageAccessor]. [br]
## You should always plan your save system to make sure your
## [LokStorageAccessor]'s ids don't crash when saving data. [br]
## If they do, there may arise data inconsistency issues or even
## loss of data. [br]
## Multiple [LokStorageAccessor]s with same [member id] is fine, though,
## with the [method load_data] operation, or in the case those
## [LokStorageAccessor]s belong to different save files.
@export var id: String = "":
	set = set_id,
	get = get_id

## The [member file] property specifies from what file the
## data of this [LokStorageAccessor] belongs to. [br]
## If left empty, it is considered as being the default file. [br]
## This [member file] property is only used by the operations
## of this [LokStorageAccessor] as the default file, not in general
## operations that include multiple [LokStorageAccessor]s. [br]
## This is useful when in need of implementing something like a file
## selection screen.
@export var file: String = "":
	set = set_file,
	get = get_file

## The [member partition] property specifies in what partition the
## data of this [LokStorageAccessor] should be stored. [br]
## If left empty, it means it is stored in the default partition. [br]
## The separation in partitions is useful when a [LokStorageAccessor] or
## group of [LokStorageAccessor]s have data that has to be loaded often
## by itself, like the data from a player that needs to be loaded whenever
## it logs in the game.
@export var partition: String = "":
	set = set_partition,
	get = get_partition

## The [member version_number] property stores a [String] that points
## to one of the [member versions]' [member LokStorageAccessorVersion.number].
## [br]
## To work properly, this [LokStorageAccessor] needs to point to a
## version number existent in the [member versions] list, which is already
## done by default if the list has at least one [LokStorageAccessorVersion]
## that hadn't had its [member LokStorageAccessorVersion.number] altered.
@export var version_number: String = "1.0.0":
	set = set_version_number,
	get = get_version_number

## The [member versions] property stores a list of [LokStorageAccessorVersion]s
## with which this [LokStorageAccessor] is able to save and load data. [br]
## Different versions can be useful if the game needs to change its data
## organization accross different versions, with the addition of features,
## for example. [br]
## To actually do something, this [LokStorageAccessor] needs at least one
## [LokStorageAccessorVersion] to save and load data. [br]
## In order for this [LokStorageAccessor] to correctly find new versions,
## they should be added to this [Array] through a new [Array], so that
## this property's setter gets triggered. Alternatively, you can use
## a method like [method Array.append], but make sure to call the
## [method _update_version] method next.
@export var versions: Array[LokStorageAccessorVersion] = []:
	set = set_versions,
	get = get_versions

## The [member dependency_paths] property stores a [Dictionary] that helps
## with keeping track of dependencies that this [LokStorageAccessor] needs
## to get or send data to. [br]
## This property stores keys and values that
## are sent to the active [LokStorageAccessorVersion] so that it can manipulate
## the data accordingly. [br]
## If the keys are [NodePath]s, before being sent to a
## [LokStorageAccessorVersion], the [NodePath]s are
## converted into [Node]s, so that the [LokStorageAccessorVersion] can
## have their references, despite it being a [Resource].
@export var dependency_paths: Dictionary = {}:
	set = set_dependency_paths,
	get = get_dependency_paths

## The [member active] property is a flag that tells whether this
## [LokStorageAccessor] should operate its data when its
## [method save_data], [method load_data] or [method remove_data]
## methods try to. [br]
## By default it is set to [code]true[/code] so that this
## [LokStorageAccessor] can do its tasks as expected.
@export var active: bool = true:
	set = set_active,
	get = is_active

## The [member _storage_manager] property is just a reference to the
## [LokGlobalStorageManager] autoload. [br]
## Its reference is stored in this property so it can be more easily
## mocked in unit tests. [br]
## The value of this property shouldn't be altered. Doing so may
## cause the saving and loading system to not work properly.
var _storage_manager: LokStorageManager = LokGlobalStorageManager:
	set = _set_storage_manager,
	get = _get_storage_manager

## The [member _version] property stores the current [LokStorageAccessorVersion]
## selected by the [member version_number]. [br]
## This is the [LokStorageAccessorVersion] that's used when saving and loading
## data through this [LokStorageAccessor].
var _version: LokStorageAccessorVersion:
	set = _set_version,
	get = _get_version

#region Setters & Getters

func set_id(new_id: String) -> void:
	var old_id: String = id
	
	id = new_id
	
	if old_id != new_id:
		update_configuration_warnings()

func get_id() -> String:
	return id

func set_file(new_file: String) -> void:
	file = new_file

func get_file() -> String:
	return file

func set_partition(new_partition: String) -> void:
	partition = new_partition

func get_partition() -> String:
	return partition

func set_versions(new_versions: Array[LokStorageAccessorVersion]) -> void:
	versions = new_versions
	
	_update_version()

func get_versions() -> Array[LokStorageAccessorVersion]:
	return versions

func set_version_number(new_number: String) -> void:
	var old_number: String = version_number
	
	version_number = new_number
	
	_update_version()

func get_version_number() -> String:
	return version_number

func set_dependency_paths(new_paths: Dictionary) -> void:
	dependency_paths = new_paths

func get_dependency_paths() -> Dictionary:
	return dependency_paths

func set_active(new_state: bool) -> void:
	active = new_state

func is_active() -> bool:
	return active

func _set_storage_manager(new_manager: LokStorageManager) -> void:
	_storage_manager = new_manager

func _get_storage_manager() -> LokStorageManager:
	return _storage_manager

func _set_version(new_version: LokStorageAccessorVersion) -> void:
	var old_version: LokStorageAccessorVersion = _version
	
	_version = new_version
	
	if old_version != new_version:
		update_configuration_warnings()

func _get_version() -> LokStorageAccessorVersion:
	return _version

#endregion

#region Methods

# Adds this StorageAccessor to the GlobalStorageManager
func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	if _storage_manager == null:
		_push_error_no_manager()
		return
	
	_storage_manager.add_accessor(self)

# Removes this StorageAccessor from the GlobalStorageManager
func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	if _storage_manager == null:
		_push_error_no_manager()
		return
	
	_storage_manager.remove_accessor(self)

# Returns warnings of the configuration of this StorageAccessor
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if _version == null:
		warnings.append("Set a valid version for this Accessor to use.")
	if get_id() == "":
		warnings.append("Set a unique id to this Storage Accessor.")
	
	return warnings

## The [method create] method is a utility to create a new
## [LokStorageAccessor] with its properties already
## set to the desired values.
static func create(
	_versions: Array[LokStorageAccessorVersion],
	_version_number: String
) -> LokStorageAccessor:
	var result := LokStorageAccessor.new()
	result.versions = _versions
	result.version_number = _version_number
	
	return result

## The [method select_version] method looks through all the
## [member versions] and sets the current [member _version] to be
## the one with number matching the [param number] parameter. [br]
## If no such version is found, [code]false[/code] is returned
## and the [member _version] is set to [code]null[/code], else
## [code]true[/code] is returned.
func select_version(number: String) -> bool:
	set_version_number(number)
	
	var found_version: bool = _version != null
	
	return found_version

## The [method save_data] method uses the
## [LokStorageManager] to save the data of this
## [LokStorageAccessor]. [br]
## By default, the version used is the [code]latest[/code],
## but that can be defined in the [param version_number]
## parameter.
func save_data(
	file_id: String = file,
	version_number: String = ""
) -> Dictionary:
	if file_id == "" and file != "":
		file_id = file
	
	if not is_active():
		_push_error_unactive_accessor()
		return {}
	if _storage_manager == null:
		_push_error_no_manager()
		return {}
	
	saving_started.emit()
	
	var result: Dictionary = await _storage_manager.save_data(
		file_id, version_number, [ self ], false
	)
	
	saving_finished.emit(result)
	
	return result

## The [method load_data] method uses the
## [LokStorageManager] to load the data of this
## [LokStorageAccessor].
func load_data(file_id: String = file) -> Dictionary:
	if file_id == "" and file != "":
		file_id = file
	
	if not is_active():
		_push_error_unactive_accessor()
		return {}
	if _storage_manager == null:
		_push_error_no_manager()
		return {}
	
	loading_started.emit()
	
	var result: Dictionary = await _storage_manager.load_data(
		file_id, [ self ], [ partition ], []
	)
	
	loading_finished.emit(result)
	
	return result

## The [method remove_data] method uses the
## [LokStorageManager] to remove the data of this
## [LokStorageAccessor].
func remove_data(file_id: String = file) -> Dictionary:
	if file_id == "" and file != "":
		file_id = file
	
	if not is_active():
		_push_error_unactive_accessor()
		return {}
	if _storage_manager == null:
		_push_error_no_manager()
		return {}
	
	removing_started.emit()
	
	var result: Dictionary = await _storage_manager.remove_data(
		file_id, [ self ], [ partition ], []
	)
	
	removing_finished.emit(result)
	
	return result

## The [method retrieve_data] method uses the
## [method LokStorageAccessorVersion._retrieve_data]
## to collect the data that should be saved
## by the [method LokStorageAccessor.save_data] method.
func retrieve_data() -> Dictionary:
	if _version == null:
		return {}
	if not is_active():
		return {}
	
	return await _version._retrieve_data(_get_dependencies())

## The [method consume_data] method uses the
## [method LokStorageAccessorVersion._consume_data]
## to use the data that was loaded
## by the [method LokStorageAccessor.load_data] method.
func consume_data(data: Dictionary) -> void:
	if _version == null:
		return
	if not is_active():
		return
	
	await _version._consume_data(data, _get_dependencies())

## The [method _find_version] method looks through all the
## [member versions] and returns the one that has same
## [member LokStorageAccessorVersion.number] as the passed in
## the [param number] parameter. [br]
## If no such version is found, [code]null[/code] is returned.
func _find_version(number: String) -> LokStorageAccessorVersion:
	for version_i: LokStorageAccessorVersion in versions:
		if version_i == null:
			continue
		if version_i.number != number:
			continue
		
		return version_i
	
	return null

## The [method _find_latest_version] method looks through all the
## [member versions] and returns the one that has the latest
## [member LokStorageAccessorVersion.number]. [br]
## If no such version is found, [code]null[/code] is returned.
func _find_latest_version() -> LokStorageAccessorVersion:
	var reducer: Callable = func(
		prev: LokStorageAccessorVersion,
		next: LokStorageAccessorVersion
	) -> LokStorageAccessorVersion:
		if prev == null:
			return next
		if next == null:
			return prev
		
		if LokStorageAccessorVersion.compare_versions(prev, next) == 1:
			return prev
		else:
			return next
	
	return versions.reduce(reducer)

## The [method _update_version] method serves to make the [member _version]
## property properly store the current version that the [member version_number]
## points to.
func _update_version() -> void:
	# Uses latest version for empty version_numbers
	if version_number == "":
		_version = _find_latest_version()
		
		# Conforms version_number to latest version
		if _version != null:
			version_number = _version.number
	# Searches corresponding version for other version_numbers
	else:
		_version = _find_version(version_number)

## The [method _get_dependencies] method returns a copy of the
## [member dependency_paths] [Dictionary], but with
## [Node]s as values, instead of the original [NodePath]s. [br]
## This is useful when passing their reference to the
## [method LokStorageAccessorVersion._retrieve_data] and
## [method LokStorageAccessorVersion._consume_data] methods.
func _get_dependencies() -> Dictionary:
	var result: Dictionary = {}
	
	for dependency_name: Variant in dependency_paths:
		var dependency_path: Variant = dependency_paths[dependency_name]
		
		if dependency_path is NodePath:
			result[dependency_name] = get_node(dependency_path)
		else:
			result[dependency_name] = dependency_path
	
	return result

#endregion

#region Debug Methods

## The [method _get_readable_name] method is a way of getting a more
## user friendly name for this [LokStorageAccessor], for use in debugging.
func _get_readable_name() -> String:
	if is_inside_tree():
		return str(get_path())
	if not name == "":
		return name
	
	return str(self)

## The [method _push_error_no_manager] method pushes an error
## warning that there's no [member _storage_manager] set in this
## [LokStorageAccessor].
func _push_error_no_manager() -> void:
	push_error(
		"No StorageManager found in Accessor '%s'" % _get_readable_name()
	)

## The [method _push_error_unactive_accessor] method pushes an error
## warning that an operation was tried in an unactive [LokStorageAccessor].
func _push_error_unactive_accessor() -> void:
	push_error(
		"Tried saving or loading unactive Accessor '%s'" % _get_readable_name()
	)

#endregion
