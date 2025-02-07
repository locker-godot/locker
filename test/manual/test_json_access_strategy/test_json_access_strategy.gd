
extends Node2D

var access_strategy: LokAccessStrategy = LokJSONAccessStrategy.new()

func read_directory() -> void:
	var result: PackedStringArray = LokAccessStrategy.read_directory(
		"res://saves/file1",
		[""]
	)
	
	print(result)

func get_file_name() -> void:
	var result: String = LokAccessStrategy.get_file_name(
		"/test.png"
	)
	
	print(result)

func get_file_format() -> void:
	var result: String = LokAccessStrategy.get_file_format(
		"e.e"
	)
	
	print(result)

func get_file_prefix() -> void:
	var result: String = LokAccessStrategy.get_file_prefix(
		"1.env"
	)
	
	print(result)

func load_partition() -> void:
	var result: Dictionary = access_strategy.load_partition(
		"res://saves/file1/partition1.sav",
		false
	)
	
	print(result)

func save_partition() -> void:
	var result: Dictionary = access_strategy.save_partition(
		"res://saves/file1/partition1..sav",
		{
			"cube": {
				"version": "1.0.0",
				"points": 8,
				"faces": 6
			}
		},
		true,
		false
	)
	
	print(result)

func save_data() -> void:
	var result: Dictionary = access_strategy.save_data(
		"res://saves/file1",
		"sav",
		{
			"partition1": {
				"square": {
					"version": "1.0.0",
					"points": 4,
					"faces": 4
				},
				"triangle": {
					"version": "1.0.0",
					"points": 3,
					"faces": 3
				}
			},
			"partition2": {
				"circle": {
					"version": "1.0.0",
					"points": 0,
					"faces": 1
				}
			}
		},
		true,
		false
	)
	
	print(result)

func load_data() -> void:
	var result: Dictionary = access_strategy.load_data(
		"res://saves/file1",
		"sav",
		[  ],
		false
	)
	
	print(result)

func _ready() -> void:
	load_data()
