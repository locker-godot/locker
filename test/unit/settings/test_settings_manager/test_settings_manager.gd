
extends GutTest

var _strategy_scripts: Array[Script] = []

func load_scripts(path: String) -> Array[Script]:
	var scripts: Array[Script] = []
	
	for resource: Resource in LokFileSystemUtil.load_resources(path):
		if not resource is Script:
			continue
		
		scripts.append(resource as Script)
	
	return scripts

func before_all() -> void:
	_strategy_scripts = load_scripts(LokSettingsManager.STRATEGY_SCRIPTS_PATH)

func after_all() -> void:
	queue_free()

#region General behavior

func test_settings_manager_knows_strategies() -> void:
	var expected: Array[Script] = _strategy_scripts
	var result: Array[Script] = LokSettingsManager._strategy_scripts
	
	if expected.size() != result.size():
		fail_test("Result had unexpected size")
	
	for i: int in expected.size():
		assert_true(result.has(expected[i]), "Unexpected strategy scripts")

#endregion

#region General Methods

func test_set_setting_access_strategy_sets_JSON_strategy() -> void:
	LokSettingsManager.set_setting_access_strategy("JSON")
	
	assert_eq(LokSettingsManager.get_setting_access_strategy(), "JSON", "Unexpected strategy")

func test_get_setting_access_strategy_parsed_returns_JSON_strategy_instance() -> void:
	LokSettingsManager.set_setting_access_strategy("JSON")
	
	assert_eq(str(LokSettingsManager.get_setting_access_strategy_parsed()), "JSON", "Unexpected strategy")

func test_load_strategy_scripts_returns_scripts() -> void:
	var expected: Array[Script] = _strategy_scripts
	var result: Array[Script] = LokSettingsManager._load_strategy_scripts()
	
	if expected.size() != result.size():
		fail_test("Result had unexpected size")
	
	for i: int in expected.size():
		assert_true(result.has(expected[i]), "Unexpected strategy scripts")

func test_get_strategies_returns_strategy_instances() -> void:
	var expected_str: Array[String] = []
	
	for script: Script in _strategy_scripts:
		expected_str.append(str(script.new()))
	
	var result_str: Array[String] = []
	
	for strategy: LokAccessStrategy in LokSettingsManager._get_strategies():
		result_str.append(str(strategy))
	
	if expected_str.size() != result_str.size():
		fail_test("Result had unexpected size")
	
	for i: int in expected_str.size():
		assert_true(result_str.has(expected_str[i]), "Unexpected strategies")

func test_get_strategies_enum_string_includes_all_strategies() -> void:
	var expected: String = ""
	
	for i: int in _strategy_scripts.size():
		var strategy: LokAccessStrategy = _strategy_scripts[i].new()
		
		expected += str(strategy)
		
		if i != _strategy_scripts.size() - 1:
			expected += ","
	
	var result: String = LokSettingsManager._get_strategies_enum_string()
	
	assert_eq(result, expected, "Unexpected enum")

#endregion

#region Method _get_default_strategy_name

func test_get_default_strategy_name_returns_whichever_if_not_found() -> void:
	var strategy_names: Array[String] = []
	
	for strategy: LokAccessStrategy in LokSettingsManager._get_strategies():
		strategy_names.append(str(strategy))
	
	var result: String = LokSettingsManager._get_default_strategy_name("Unexisting")
	
	assert_true(strategy_names.has(result), "Invalid strategy name")

func test_get_default_strategy_name_returns_wanted_name() -> void:
	var result: String = LokSettingsManager._get_default_strategy_name("JSON")
	
	assert_eq(result, "JSON", "JSON strategy not found")

#endregion

#region _string_to_strategy

func test_string_to_strategy_parses_encrypted_strategy() -> void:
	var result: LokAccessStrategy = LokSettingsManager._string_to_strategy("Encrypted")
	
	assert_eq(str(result), "Encrypted", "Unexpected strategy")

func test_string_to_strategy_parses_json_strategy() -> void:
	var result: LokAccessStrategy = LokSettingsManager._string_to_strategy("JSON")
	
	assert_eq(str(result), "JSON", "Unexpected strategy")

func test_string_to_strategy_doesnt_parse_unknown_strategy() -> void:
	var result: LokAccessStrategy = LokSettingsManager._string_to_strategy("Unknown")
	
	assert_null(result, "Unexpected strategy")

#endregion

#region Method _strategy_to_string

func test_strategy_to_string_parses_encrypted_strategy() -> void:
	var result: String = LokSettingsManager._strategy_to_string(LokEncryptedAccessStrategy.new())
	
	assert_eq(result, "Encrypted", "Unexpected strategy")

func test_strategy_to_string_parses_json_strategy() -> void:
	var result: String = LokSettingsManager._strategy_to_string(LokJSONAccessStrategy.new())
	
	assert_eq(result, "JSON", "Unexpected strategy")

#endregion
