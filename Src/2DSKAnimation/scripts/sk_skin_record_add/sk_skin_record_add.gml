/// @desc append display data to the skin
/// @param skin
/// @param slot
/// @param attachment
/// @param key
if(sk_object_ofclass(argument1,sk_class_symbol)){
	ds_list_add(argument0[sk_skin_var_displays],[
		argument1,
		sk_object_ofclass(argument2,sk_class_attachment) ? argument2 : undefined,
		argument3
	]);
}