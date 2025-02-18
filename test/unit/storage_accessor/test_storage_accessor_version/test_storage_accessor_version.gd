
extends GutTest

var version: LokStorageAccessorVersion

func before_each() -> void:
	version = LokStorageAccessorVersion.new()

func after_all() -> void:
	queue_free()

#region Property number

func test_number_starts_as_1_0_0() -> void:
	assert_eq(version.number, "1.0.0", "Version didn't start as expected")

#endregion

#region Method compare_versions

func test_compare_versions_returns_minus_one_for_ascending_versions() -> void:
	watch_signals(version)
	
	assert_eq(
		LokStorageAccessorVersion.compare_versions(
			LokStorageAccessorVersion.create("00.0.1"),
			LokStorageAccessorVersion.create("1.0.0")
		),
		-1,
		"Comparison didn't work"
	)

func test_compare_versions_returns_one_for_descending_versions() -> void:
	watch_signals(version)
	
	assert_eq(
		LokStorageAccessorVersion.compare_versions(
			LokStorageAccessorVersion.create("1.0.0"),
			LokStorageAccessorVersion.create("0.0.10")
		),
		1,
		"Comparison didn't work"
	)

func test_compare_versions_returns_zero_for_equal_versions() -> void:
	watch_signals(version)
	
	assert_eq(
		LokStorageAccessorVersion.compare_versions(
			LokStorageAccessorVersion.create("1.0.0"),
			LokStorageAccessorVersion.create("1.0.00")
		),
		0,
		"Comparison didn't work"
	)

#endregion

#region Method compare_minor_versions

func test_compare_minor_versions_returns_minus_one_for_ascending_versions() -> void:
	watch_signals(version)
	
	assert_eq(
		LokStorageAccessorVersion.compare_minor_versions(
			LokStorageAccessorVersion.create("03.0.1"),
			LokStorageAccessorVersion.create("1.0.2")
		),
		-1,
		"Comparison didn't work"
	)

func test_compare_minor_versions_returns_one_for_descending_versions() -> void:
	watch_signals(version)
	
	assert_eq(
		LokStorageAccessorVersion.compare_minor_versions(
			LokStorageAccessorVersion.create("1.0.10"),
			LokStorageAccessorVersion.create("2.1.0")
		),
		1,
		"Comparison didn't work"
	)

func test_compare_minor_versions_returns_zero_for_equal_versions() -> void:
	watch_signals(version)
	
	assert_eq(
		LokStorageAccessorVersion.compare_minor_versions(
			LokStorageAccessorVersion.create("1.0.0"),
			LokStorageAccessorVersion.create("1.3.00")
		),
		0,
		"Comparison didn't work"
	)

#endregion

#region Method compare_patch_versions

func test_compare_patch_versions_returns_minus_one_for_ascending_versions() -> void:
	watch_signals(version)
	
	assert_eq(
		LokStorageAccessorVersion.compare_patch_versions(
			LokStorageAccessorVersion.create("03.0.1"),
			LokStorageAccessorVersion.create("1.1.2")
		),
		-1,
		"Comparison didn't work"
	)

func test_compare_patch_versions_returns_one_for_descending_versions() -> void:
	watch_signals(version)
	
	assert_eq(
		LokStorageAccessorVersion.compare_patch_versions(
			LokStorageAccessorVersion.create("1.2.10"),
			LokStorageAccessorVersion.create("2.1.0")
		),
		1,
		"Comparison didn't work"
	)

func test_compare_patch_versions_returns_zero_for_equal_versions() -> void:
	watch_signals(version)
	
	assert_eq(
		LokStorageAccessorVersion.compare_patch_versions(
			LokStorageAccessorVersion.create("1.03.0"),
			LokStorageAccessorVersion.create("1.3.00")
		),
		0,
		"Comparison didn't work"
	)

#endregion

#region Method compare_major_versions

func test_compare_major_versions_returns_minus_one_for_ascending_versions() -> void:
	watch_signals(version)
	
	assert_eq(
		LokStorageAccessorVersion.compare_major_versions(
			LokStorageAccessorVersion.create("03.0.1"),
			LokStorageAccessorVersion.create("4.1.2")
		),
		-1,
		"Comparison didn't work"
	)

func test_compare_major_versions_returns_one_for_descending_versions() -> void:
	watch_signals(version)
	
	assert_eq(
		LokStorageAccessorVersion.compare_major_versions(
			LokStorageAccessorVersion.create("3.2.10"),
			LokStorageAccessorVersion.create("2.1.0")
		),
		1,
		"Comparison didn't work"
	)

func test_compare_major_versions_returns_zero_for_equal_versions() -> void:
	watch_signals(version)
	
	assert_eq(
		LokStorageAccessorVersion.compare_major_versions(
			LokStorageAccessorVersion.create("1.03.0"),
			LokStorageAccessorVersion.create("1.3.00")
		),
		0,
		"Comparison didn't work"
	)

#endregion
