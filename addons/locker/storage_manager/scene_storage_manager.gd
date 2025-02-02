## The [LokSceneStorageManager] class is just an intermediate to access
## the [LokGlobalStorageManager] class through the scene nodes, if necessary.
## 
## This class is useful when it is desired to trigger the
## [LokGlobalStorageManager] methods through signal emissions, for example.
class_name LokSceneStorageManager
extends LokStorageManager

func save_data(file_id: int) -> Dictionary:
	return LokGlobalStorageManager.save_data(file_id)

func load_data(file_id: int) -> Dictionary:
	return LokGlobalStorageManager.load_data(file_id)
