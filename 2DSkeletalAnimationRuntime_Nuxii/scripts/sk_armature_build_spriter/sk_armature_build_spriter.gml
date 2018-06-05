/// @desc loads an armature file
/// @param json
/// @param armatureNameOrID
var sp_armature = noone;
// extract armature data from spriter json
var sp_skel = json_decode(argument0);
if(ds_exists(sp_skel,ds_type_map)){
	var sp_armature_found = false;
	var sp_armatures = sp_skel[? "entity"];
	if(is_real(sp_armatures)&&ds_exists(sp_armatures,ds_type_list)){
		var sp_armature_count = ds_list_size(sp_armatures);
        for(var sp_armature_id = 0; sp_armature_id < sp_armature_count; sp_armature_id++){
            var sp_armature_data = sp_armatures[| sp_armature_id];
            if(is_real(sp_armature_data)&&ds_exists(sp_armature_data,ds_type_map)
			&&( (sp_armature_data[? "name"]==argument1)||(sp_armature_data[? "id"]==argument1) )){
    			// armature found
				sp_armature = sp_armature_data;
    			sp_armature_found = true;
				break;
    		}
        }
	}
	if(!sp_armature_found){
		ds_map_destroy(sp_skel);
		return noone;
	}
} else {
	return noone;
}
// extract important data
var sp_folders = sp_skel[? "folder"];
var sp_objInfo = sp_armature[? "obj_info"];
var sp_characterMaps = sp_armature[? "character_map"];
var sp_animations = sp_armature[? "animation"];
// create armature
var sk_skel = sk_armature_create(sp_armature[? "name"]);
// transfer sprite data (attachments)
if(is_real(sp_folders)&&ds_exists(sp_folders,ds_type_list)){
	var sp_folder_count = ds_list_size(sp_folders);
	for(var sp_folder_id = 0; sp_folder_id < sp_folder_count; sp_folder_id++){
		var sp_folder = sp_folders[| sp_folder_id];
		if(is_real(sp_folder)&&ds_exists(sp_folder,ds_type_map)){
			var sp_files = sp_folder[? "file"];
			if(is_real(sp_files)&&ds_exists(sp_files,ds_type_list)){
				var sp_file_count = ds_list_size(sp_files);
				for(var sp_file_id = 0; sp_file_id < sp_file_count; sp_file_id++){
					var sp_sprite = sp_files[| sp_file_id];
					if(is_real(sp_sprite)&&ds_exists(sp_sprite,ds_type_map)){
						#region // add attachment
						var sk_attachment_name = sk_createCompoundKey(sp_folder_id,sp_file_id); // a tuple consisting of the folder and file indicies
						var sk_attachment_path = string(sp_sprite[? "name"]);
						// create new record and append data
						var sk_attachment_pivot_x = real(sp_sprite[? "pivot_x"]);
						var sk_attachment_pivot_y = 1-(is_real(sp_sprite[? "pivot_y"]) ? sp_sprite[? "pivot_y"] : 1);
						var sk_attachment_pivot_w = real(sp_sprite[? "w"]);
						var sk_attachment_pivot_h = real(sp_sprite[? "h"]);
						var sk_attachment = sk_attachment_create_plane(sk_attachment_name);
						sk_attachment_plane_set_regionKey(sk_attachment,sk_attachment_path);
						sk_attachment_plane_set_transform(
							sk_attachment,
							-sk_attachment_pivot_x*sk_attachment_pivot_w,
							-sk_attachment_pivot_y*sk_attachment_pivot_h,
							1,1,
							0,0,
							0
						);
						sk_armature_add_attachment(sk_skel,sk_attachment);
						#endregion
					}
				}
			}
		}
	}
}
// transfer object data (bones and constraints)
if(is_real(sp_objInfo)&&ds_exists(sp_objInfo,ds_type_list)){
	var sp_obj_count = ds_list_size(sp_objInfo);
	for(var sp_obj_id = 0; sp_obj_id < sp_obj_count; sp_obj_id++){
	    var sp_obj_record = sp_objInfo[| sp_obj_id];
	    if(is_real(sp_obj_record)&&ds_exists(sp_obj_record,ds_type_map)){
			switch(sp_obj_record[? "type"]){
				case "bone":
					
				break;
			}
		}
	}
}
// create a default skin and define remap data
var sk_defaultSkin = sk_skin_create("default");
sk_armature_add_skin(sk_skel,sk_defaultSkin);
if(is_real(sp_characterMaps)&&ds_exists(sp_characterMaps,ds_type_list)){
	var sp_map_count = ds_list_size(sp_characterMaps);
	for(var sp_map_id = 0; sp_map_id < sp_map_count; sp_map_id++){
	    var sp_map_record = sp_characterMaps[| sp_map_id];
	    if(is_real(sp_map_record)&&ds_exists(sp_map_record,ds_type_map)){
			#region // add character map
			var sk_map_key = string(sp_map_record[? "name"]);
			var sk_map = ds_map_create();
			sk_skin_remaps_add(sk_defaultSkin,sk_map,sk_map_key);
			// fill ds_map
			var sp_map = sp_map_record[? "map"];
			if(is_real(sp_map)&&ds_exists(sp_map,ds_type_list)){
				var sp_item_count = ds_list_size(sp_map);
				for(var sp_item_id = 0; sp_item_id < sp_item_count; sp_item_id++){
				    var sp_remap_record = sp_map[| sp_item_id];
					if(is_real(sp_remap_record)&&ds_exists(sp_remap_record,ds_type_map)){
						var sp_remap_current = sk_createCompoundKey(sp_remap_record[? "folder"],sp_remap_record[? "file"]);
						var sp_remap_target = sk_createCompoundKey(sp_remap_record[? "target_folder"],sp_remap_record[? "target_file"]);
						// get the current and target attachments
						var sk_remap_attachment_current = sk_armature_find_attachment_plane(sk_skel,sp_remap_current);
						var sk_remap_attachment_target = sk_armature_find_attachment_plane(sk_skel,sp_remap_target);
						// remap
						if(sk_struct_exists(sk_remap_attachment_current,sk_type_attachment_plane)){
							sk_map[? sk_struct_get_name(sk_remap_attachment_current)] = sk_remap_attachment_target;
						}
					}
				}
			}
			#endregion
		}
	}
}
// iterate through all the animation timelines and compile a list of symbols
if(is_real(sp_animations)&&ds_exists(sp_animations,ds_type_list)){
	var sp_anim_count = ds_list_size(sp_animations);
	for(var sp_anim_id = 0; sp_anim_id < sp_anim_count; sp_anim_id++){
	    var sp_anim_record = sp_animations[| sp_anim_id];
	    if(is_real(sp_anim_record)&&ds_exists(sp_anim_record,ds_type_map)){
			// get animation timelines
			var sp_anim_timelines = sp_anim_record[? "timeline"];
			if(is_real(sp_anim_timelines)&&ds_exists(sp_anim_timelines,ds_type_list)){
				var sp_timeline_count = ds_list_size(sp_anim_timelines);
				for(var sp_timeline_id = 0; sp_timeline_id < sp_timeline_count; sp_timeline_id++){
					var sp_timeline_record = sp_anim_timelines[| sp_timeline_id];
					if(is_real(sp_timeline_record)&&ds_exists(sp_timeline_record,ds_type_map)){
						// timeline exists
						var sp_timeline_type = is_string(sp_timeline_record[? "object_type"]) ? sp_timeline_record[? "object_type"] : "sprite";
						if(sp_timeline_type=="sprite"){
							#region // add symbol
							var sk_symbol_name = sp_timeline_record[? "name"];
							if(sk_armature_find_symbol(sk_skel,sk_symbol_name)==noone){
								// symbol doesn't exist, create it
								var sk_symbol = sk_symbol_create(sk_symbol_name);
								sk_symbol_set_transformMode(sk_symbol,sk_transformMode_normal&(~sk_transformMode_skew)); // no skew transform
								sk_symbol_set_setupPose(
									sk_symbol,
									0,0,
									1,1,
									0,0,
									0,
									$ffffff,1,
									noone,noone
								);								
								sk_armature_add_symbol(sk_skel,sk_symbol);
							}
							#endregion
						}
					}
				}
			}
		}
	}
}
// get orders
sk_armature_updateCache(sk_skel);
var sk_drawOrder = sk_armature_get_drawOrder(sk_skel);
var sk_updateOrder = sk_armature_get_updateCache(sk_skel);
// transfer animation data
if(is_real(sp_animations)&&ds_exists(sp_animations,ds_type_list)){
	var sp_anim_count = ds_list_size(sp_animations);
	for(var sp_anim_id = 0; sp_anim_id < sp_anim_count; sp_anim_id++){
	    var sp_anim_record = sp_animations[| sp_anim_id];
	    if(is_real(sp_anim_record)&&ds_exists(sp_anim_record,ds_type_map)){
			#region // add animation
			var sk_anim = sk_animation_create(string(sp_anim_record[? "name"]));
			sk_animation_set_duration(sk_anim,real(sp_anim_record[? "length"]));
			sk_animation_set_looping(sk_anim,sp_anim_record[? "looping"]!="false");
			sk_armature_add_animation(sk_skel,sk_anim);
			// create a map to easily look up the timeline attributed to the object
			var SP_BONE_TIMELINE_MAP = ds_map_create();
			var SP_OBJECT_TIMELINE_MAP = ds_map_create();
			ds_map_add_map(sp_anim_record,"|SP_BONE_TIMELINE_MAP|",SP_BONE_TIMELINE_MAP);
			ds_map_add_map(sp_anim_record,"|SP_OBJECT_TIMELINE_MAP|",SP_OBJECT_TIMELINE_MAP);
			// iterate through mainline
			var sp_anim_timelines = sp_anim_record[? "timeline"];
			if(is_real(sp_anim_timelines)&&ds_exists(sp_anim_timelines,ds_type_list)){
				var sp_anim_mainline = sp_anim_record[? "mainline"];
				if(is_real(sp_anim_mainline)&&ds_exists(sp_anim_mainline,ds_type_map)){
					var sp_anim_mainline_frames = sp_anim_mainline[? "key"];
					if(is_real(sp_anim_mainline_frames)&&ds_exists(sp_anim_mainline_frames,ds_type_list)){
						var sp_anim_mainline_frame_count = ds_list_size(sp_anim_mainline_frames);
						for(var sp_anim_mainline_frame_id = 0; sp_anim_mainline_frame_id < sp_anim_mainline_frame_count; sp_anim_mainline_frame_id++){
							var sp_anim_mainline_frame = sp_anim_mainline_frames[| sp_anim_mainline_frame_id];
							if(is_real(sp_anim_mainline_frame)&&ds_exists(sp_anim_mainline_frame,ds_type_map)){
								// frame exists
								var sp_anim_mainline_frame_bones = sp_anim_mainline_frame[? "bone_ref"];
								var sp_anim_mainline_frame_objects = sp_anim_mainline_frame[? "object_ref"];
								var sp_anim_mainline_frame_time = max(real(sp_anim_mainline_frame[? "time"]),0);
								// get curve
								var sk_anim_frame_curve = sk_tweenEasing_linear;
								switch(sp_anim_mainline_frame[? "curve_type"]){
									case "instant": sk_anim_frame_curve = sk_tweenEasing_none; break;
									case "bezier": sk_anim_frame_curve = sk_bezier_aproximateCurve(
											real(sp_anim_mainline_frame[? "c1"]),
											real(sp_anim_mainline_frame[? "c2"]),
											real(sp_anim_mainline_frame[? "c3"]),
											real(sp_anim_mainline_frame[? "c4"])
										);
									break;
								}
								// get parent
								var sk_anim_frame_parent = sk_armature_find_bone(sk_skel,sp_anim_mainline_frame[? "parent"]);
								// create lists for constructing future order timelines
								var SK_BONE_HIERARCHY_FRAMES = ds_list_create();
								var SK_OBJECT_HIERARCHY_FRAMES = ds_list_create();
								ds_map_add_list(sp_anim_mainline_frame,"|SK_BONE_HIERARCHY_FRAMES|",SK_BONE_HIERARCHY_FRAMES);
								ds_map_add_list(sp_anim_mainline_frame,"|SK_OBJECT_HIERARCHY_FRAMES|",SK_OBJECT_HIERARCHY_FRAMES);
								#region // compile bone frames
								
								#endregion
								#region // compile object frames
								if(is_real(sp_anim_mainline_frame_objects)&&ds_exists(sp_anim_mainline_frame_objects,ds_type_list)){
									var sp_anim_object_count = ds_list_size(sp_anim_mainline_frame_objects);
									for(var sp_anim_object_id = 0; sp_anim_object_id < sp_anim_object_count; sp_anim_object_id++){
										var sp_anim_object_record = sp_anim_mainline_frame_objects[| sp_anim_object_id];
										if(is_real(sp_anim_object_record)&&ds_exists(sp_anim_object_record,ds_type_map)){
											var sp_anim_object_keyframe_id = sp_anim_object_record[? "key"];
											var sp_anim_object_timeline_id = sp_anim_object_record[? "timeline"];
											// lookup timeline data
											if(!is_undefined(sp_anim_object_keyframe_id)&&!is_undefined(sp_anim_object_timeline_id)){
												sp_anim_object_keyframe_id = real(sp_anim_object_keyframe_id);
												sp_anim_object_timeline_id = real(sp_anim_object_timeline_id);
												var sp_anim_object_timeline_record = sp_anim_timelines[| sp_anim_object_timeline_id];
												if(is_real(sp_anim_object_timeline_record)&&ds_exists(sp_anim_object_timeline_record,ds_type_map)){
													// timeline exists
													var sp_anim_object_timeline_keys = sp_anim_object_timeline_record[? "key"];
													if(is_real(sp_anim_object_timeline_keys)&&ds_exists(sp_anim_object_timeline_keys,ds_type_list)){
														var sp_anim_object_timeline_keyframe = sp_anim_object_timeline_keys[| sp_anim_object_keyframe_id];
														if(is_real(sp_anim_object_timeline_keyframe)&&ds_exists(sp_anim_object_timeline_keyframe,ds_type_map)){
															// keyframe exists
															var sp_anim_timeline_type = is_string(sp_anim_object_timeline_record[? "object_type"]) ? sp_anim_object_timeline_record[? "object_type"] : "sprite";
															if(sp_anim_timeline_type=="sprite"){
																var sk_anim_symbol_name = sp_anim_object_timeline_record[? "name"];
																var sk_anim_symbol = sk_armature_find_symbol(sk_skel,sk_anim_symbol_name);
																if(sk_struct_exists(sk_anim_symbol,sk_type_symbol)){
																	// add frame
																	var sk_anim_frame_timeline = SP_OBJECT_TIMELINE_MAP[? sk_anim_symbol_name];
																	if(!sk_struct_exists(sk_anim_frame_timeline,sk_type_timeline_symbol)){
																		sk_anim_frame_timeline = sk_timeline_create_symbol(string(sk_anim_symbol_name)+".TimelineSymbol",sk_anim_symbol);
																		sk_animation_add_timeline(sk_anim,sk_anim_frame_timeline);
																		SP_OBJECT_TIMELINE_MAP[? sk_anim_symbol_name] = sk_anim_frame_timeline;
																	}
																	// get frame data
																	var sk_anim_symbol_file = 0;
																	var sk_anim_symbol_folder = 0;
																	var sk_anim_symbol_x = 0;
																	var sk_anim_symbol_y = 0;
																	var sk_anim_symbol_rotation = 0;
																	var sk_anim_symbol_rotationSpin = real(sp_anim_object_timeline_keyframe[? "spin"]); // cycles
																	var sk_anim_symbol_xscale = 1;
																	var sk_anim_symbol_yscale = 1;
																	var sk_anim_symbol_alpha = 1;
																	var sk_anim_frame_time = real(sp_anim_object_timeline_keyframe[? "time"]);
																	// compile transformation data
																	var sp_anim_frame_objectTransform = sp_anim_object_timeline_keyframe[? "object"];
																	if(is_real(sp_anim_frame_objectTransform)&&ds_exists(sp_anim_frame_objectTransform,ds_type_map)){
																		sk_anim_symbol_file = real(sp_anim_frame_objectTransform[? "file"]);
																		sk_anim_symbol_folder = real(sp_anim_frame_objectTransform[? "folder"]);
																		sk_anim_symbol_x = real(sp_anim_frame_objectTransform[? "x"]);
																		sk_anim_symbol_y = real(sp_anim_frame_objectTransform[? "y"]);
																		sk_anim_symbol_rotation = real(sp_anim_frame_objectTransform[? "angle"]);
																		sk_anim_symbol_xscale = is_real(sp_anim_frame_objectTransform[? "scale_x"]) ? sp_anim_frame_objectTransform[? "scale_x"] : 1;
																		sk_anim_symbol_yscale = is_real(sp_anim_frame_objectTransform[? "scale_y"]) ? sp_anim_frame_objectTransform[? "scale_y"] : 1;
																		sk_anim_symbol_alpha = is_real(sp_anim_frame_objectTransform[? "a"]) ? sp_anim_frame_objectTransform[? "a"] : 1;
																	}
																	// get attachment key
																	var sk_anim_symbol_attachmentKey = sk_createCompoundKey(sk_anim_symbol_folder,sk_anim_symbol_file);
																	// add record to skin
																	if(!sk_skin_record_exists(sk_defaultSkin,sk_anim_symbol,sk_anim_symbol_attachmentKey)){
																		sk_skin_record_add(
																			sk_defaultSkin,
																			sk_anim_symbol,
																			sk_armature_find_attachment_plane(sk_skel,sk_anim_symbol_attachmentKey),
																			sk_anim_symbol_attachmentKey
																		);
																	}
																	// add data to timelines
																	sk_timeline_symbol_add_frame(
																		sk_anim_frame_timeline,
																		sk_anim_frame_time,
																		sk_anim_frame_parent
																	);
																	sk_timeline_symbol_add_frame_translate(
																		sk_anim_frame_timeline,
																		sk_anim_frame_time,
																		sk_anim_symbol_x,
																		-sk_anim_symbol_y,
																		sk_anim_frame_curve
																	);
																	sk_timeline_symbol_add_frame_scale(
																		sk_anim_frame_timeline,
																		sk_anim_frame_time,
																		sk_anim_symbol_xscale,
																		sk_anim_symbol_yscale,
																		sk_anim_frame_curve
																	);
																	sk_timeline_symbol_add_frame_rotate(
																		sk_anim_frame_timeline,
																		sk_anim_frame_time,
																		sk_anim_symbol_rotation,
																		sk_anim_symbol_rotationSpin,
																		sk_anim_frame_curve
																	);
																	sk_timeline_symbol_add_frame_colour(
																		sk_anim_frame_timeline,
																		sk_anim_frame_time,
																		$ffffff,
																		sk_anim_symbol_alpha,
																		sk_anim_frame_curve
																	);
																	sk_timeline_symbol_add_frame_display(
																		sk_anim_frame_timeline,
																		sk_anim_frame_time,
																		sk_anim_symbol_attachmentKey
																	);
																	// add symbol to drawOrder
																	ds_list_add(SK_OBJECT_HIERARCHY_FRAMES,sk_anim_symbol);
																}
															}
														}
													}
												}
											}
										}
									}
								}
								#endregion
								#region // compile update order frames (SK_BONE_HIERARCHY_FRAMES)
								
								#endregion
								#region // compile draw order frames (SK_OBJECT_HIERARCHY_FRAMES)
								
								#endregion
							}
						}
					}
				}
			}
			#endregion
		}
	}
}
// apply setup
sk_armature_setToDefaultSkin(sk_skel);
sk_armature_setToSetupPose(sk_skel);
sk_armature_updateWorldTransform(sk_skel);
// return final structure
ds_map_destroy(sp_skel);
return sk_skel;