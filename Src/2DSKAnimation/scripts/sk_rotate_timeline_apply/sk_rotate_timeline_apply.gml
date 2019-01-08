__SK_OBJECT_DEBUG_ASSERT_EXISTENCE = !sk_rotate_timeline_exists(argument0);
/// @desc apply the timeline between two keyframes
/// @param timeline
/// @param keyframeA
/// @param keyframeB
/// @param amount
/// @param mixPose
/// @param alpha
var sk_target = argument0[sk_data__timeline.target];
if(sk_target==undefined) then return;
var sk_keyframeA_id = argument1*SK_ROTATE_KEYFRAME_ENTRIES;
var sk_keyframeB_id = argument2*SK_ROTATE_KEYFRAME_ENTRIES;
var sk_keyframes = argument0[sk_data__timeline.keyframes];
// interpolate
var sk_interpolation = sk_ease(argument3,sk_keyframes[| sk_keyframeA_id+SK_ROTATE_KEYFRAME_EASE]);
var sk_r = sk_keyframes[| sk_keyframeA_id+SK_ROTATE_KEYFRAME_ANGLE];
sk_r += sk_interpolation*(
	-angle_difference(sk_r,sk_keyframes[| sk_keyframeB_id+SK_ROTATE_KEYFRAME_ANGLE])
	+360*sk_keyframes[| sk_keyframeA_id+SK_ROTATE_KEYFRAME_CYCLES]
);
// apply
switch(argument4){
	case SK_MIX_BLEND:
		var sk_rotation = sk_target[sk_data_bone.appliedRotation];
		sk_target[@ sk_data_bone.appliedRotation] = sk_rotation-angle_difference(sk_rotation,sk_target[sk_data_bone.setupRotation]+sk_r)*argument5;
	break;
	case SK_MIX_ADD: 
		sk_target[@ sk_data_bone.appliedRotation] = sk_target[sk_data_bone.appliedRotation]+sk_r*argument5;
	break;
	case SK_MIX_OVERWRITE:
		sk_target[@ sk_data_bone.setupRotation] = sk_target[sk_data_bone.setupRotation]+sk_r*argument5;
	break;
}