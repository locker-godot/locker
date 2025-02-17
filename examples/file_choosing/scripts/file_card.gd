
class_name FileCard
extends PanelContainer

@onready var storage_accessor: LokStorageAccessor = $StorageAccessor
@onready var title: Label = %Title
@onready var status: VBoxContainer = %Status
@onready var create_button: Button = %CreateButton
@onready var lives_amount_label: Label = %Status/Lives/Amount
@onready var progress_amount_label: Label = %Status/Progress/Amount

func set_file_id(file_id: String) -> void:
	title.text = "File " + file_id
	storage_accessor.file = file_id

func setup_as_new_file() -> void:
	status.visible = false
	create_button.visible = true

func setup_as_used_file(lives_amount: int, progress: float) -> void:
	status.visible = true
	create_button.visible = false
	lives_amount_label.text = str(lives_amount)
	progress_amount_label.text = "%.2f%%" % (progress * 100)
