gml_pragma("forceinline");
/// @desc update world transform of supplied symbol
/// @param symbol
sk_bone_updateWorldTransform_other(
	argument0[SK_SYMBOL.NESTED_BONE],
	array_get(argument0[SK_SYMBOL.NESTED_SLOT],SK_SLOT.boneFinal)
);