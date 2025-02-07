extends Node

@onready var accessor: LokStorageAccessor = $Accessor

func find_latest_version() -> void:
	var result: String
	
	accessor.versions.append(LokStorageAccessorVersion.create("2.1.2"))
	accessor.versions.append(LokStorageAccessorVersion.create("1.0.0"))
	accessor.versions.append(LokStorageAccessorVersion.create("2.1.1"))
	accessor.versions.append(LokStorageAccessorVersion.create("1.1.0"))
	accessor.versions.append(LokStorageAccessorVersion.create("1.1.1"))
	
	result = accessor.find_latest_version().number
	
	print(result)

func _ready() -> void:
	find_latest_version()
