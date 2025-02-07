extends Node

var version := LokStorageAccessorVersion.create(
	"v1", "1"
)

func compare_minor_versions() -> void:
	var result: int = LokStorageAccessorVersion.compare_minor_versions(
		version, LokStorageAccessorVersion.create("v2", "1")
	)
	
	print(result)

func _ready() -> void:
	#compare_minor_versions()
	print("3.".get_slice(".", 1))
