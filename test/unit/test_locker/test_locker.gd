
extends GutTest

var JSONAccessStrategy: GDScript = preload("res://addons/locker/scripts/access_strategy/json_access_strategy.gd")
var EncryptedAccessStrategy: GDScript = preload("res://addons/locker/scripts/access_strategy/encrypted_access_strategy.gd")

func after_all() -> void:
	queue_free()

func test_get_strategy_scripts_returns_existent_scripts() -> void:
	LockerPlugin.available_strategy_paths = [
		"res://addons/locker/scripts/access_strategy/json_access_strategy.gd",
		"res://addons/locker/scripts/access_strategy/encrypted_access_strategy.gd",
		"res://addons/locker/scripts/access_strategy/memory_access_strategy.gd"
	]
	
	var expected: Array[Script] = [
		JSONAccessStrategy,
		EncryptedAccessStrategy
	]
	var result: Array[Script] = LockerPlugin.get_strategy_scripts(
		LockerPlugin.available_strategy_paths
	)
	
	assert_eq(result, expected, "Unexpected available strategy scripts")

func test_get_strategies_returns_valid_strategies() -> void:
	LockerPlugin.available_strategy_paths = [
		"res://addons/locker/scripts/access_strategy/json_access_strategy.gd",
		"res://addons/locker/scripts/access_strategy/encrypted_access_strategy.gd",
		"res://addons/locker/scripts/access_strategy/memory_access_strategy.gd"
	]
	
	var expected: Array[LokAccessStrategy] = [
		JSONAccessStrategy.new(),
		EncryptedAccessStrategy.new()
	]
	var result: Array[LokAccessStrategy] = LockerPlugin.get_strategies(
		[ JSONAccessStrategy, EncryptedAccessStrategy ]
	)
	
	if expected.size() != result.size():
		fail_test("Result had unexpected size")
	
	for i: int in expected.size():
		assert_eq(str(result[i]), str(expected[i]), "Unexpected available strategies")

func test_get_string_of_strategies_returns_available_strategies() -> void:
	LockerPlugin.available_strategy_paths = [
		"res://addons/locker/scripts/access_strategy/json_access_strategy.gd",
		"res://addons/locker/scripts/access_strategy/encrypted_access_strategy.gd",
		"res://addons/locker/scripts/access_strategy/memory_access_strategy.gd"
	]
	
	var expected: String = "JSON,Encrypted"
	var result: String = LockerPlugin.get_string_of_strategies(
		[ JSONAccessStrategy.new(), EncryptedAccessStrategy.new() ]
	)
	
	assert_eq(result, expected, "Unexpected string")

func test_string_to_strategy_returns_json_strategy() -> void:
	LockerPlugin.available_strategy_paths = [
		"res://addons/locker/scripts/access_strategy/json_access_strategy.gd",
		"res://addons/locker/scripts/access_strategy/encrypted_access_strategy.gd",
		"res://addons/locker/scripts/access_strategy/memory_access_strategy.gd"
	]
	
	var expected: LokAccessStrategy = JSONAccessStrategy.new()
	var result: LokAccessStrategy = LockerPlugin.string_to_strategy("JSON")
	
	assert_eq(str(result) == "JSON", str(expected) == "JSON", "Unexpected strategy")

func test_string_to_strategy_returns_encrypted_strategy() -> void:
	LockerPlugin.available_strategy_paths = [
		"res://addons/locker/scripts/access_strategy/json_access_strategy.gd",
		"res://addons/locker/scripts/access_strategy/encrypted_access_strategy.gd",
		"res://addons/locker/scripts/access_strategy/memory_access_strategy.gd"
	]
	
	var expected: LokAccessStrategy = EncryptedAccessStrategy.new()
	var result: LokAccessStrategy = LockerPlugin.string_to_strategy("Encrypted")
	
	assert_eq(str(result) == "Encrypted", str(expected) == "Encrypted", "Unexpected strategy")

func test_string_to_strategy_returns_null_strategy() -> void:
	LockerPlugin.available_strategy_paths = [
		"res://addons/locker/scripts/access_strategy/json_access_strategy.gd",
		"res://addons/locker/scripts/access_strategy/encrypted_access_strategy.gd",
		"res://addons/locker/scripts/access_strategy/memory_access_strategy.gd"
	]
	
	var result: LokAccessStrategy = LockerPlugin.string_to_strategy("Unexisting")
	
	assert_null(result, "Unexpected strategy")

func test_strategy_to_string_returns_json() -> void:
	var expected: String = "JSON"
	var result: String = LockerPlugin.strategy_to_string(JSONAccessStrategy.new())
	
	assert_eq(result, expected, "Unexpected strategy")

func test_strategy_to_string_returns_encrypted() -> void:
	var expected: String = "Encrypted"
	var result: String = LockerPlugin.strategy_to_string(EncryptedAccessStrategy.new())
	
	assert_eq(result, expected, "Unexpected strategy")

func test_strategy_to_string_returns_empty_string() -> void:
	var expected: String = ""
	var result: String = LockerPlugin.strategy_to_string(null)
	
	assert_eq(result, expected, "Unexpected strategy")
