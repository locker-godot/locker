
extends Node2D

var access_strategy: LokAccessStrategy = LokEncryptedAccessStrategy.new()

func load_partition() -> void:
	var result: Dictionary = access_strategy.load_partition(
		"res://saves/file2/partition1.sav",
		false
	)
	
	print(result)

func save_partition() -> void:
	var result: Dictionary = access_strategy.save_partition(
		"res://saves/file2/partition1.sav",
		{
			"triangle": {
				"version": "1.0.0",
				"points": 3,
				"faces": 3
			}
		},
		true,
		true
	)
	
	print(result)

func save_data() -> void:
	var result: Dictionary = access_strategy.save_data(
		"res://saves/file2",
		"sav",
		{
			"partition1": {
				"square": {
					"version": "1.0.0",
					"points": 4,
					"faces": 4
				},
				"cube": {
					"version": "1.0.0",
					"points": 8,
					"faces": 6
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
		"res://saves/file2",
		"sav",
		[  ],
		false
	)
	
	print(result)

func _ready() -> void:
	load_data()
