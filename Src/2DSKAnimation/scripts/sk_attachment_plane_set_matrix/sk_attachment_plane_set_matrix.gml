/// @desc sets a property
/// @param attachment
/// @param x
/// @param y
/// @param xscale
/// @param yscale
/// @param xshear
/// @param yshear
/// @param rotation
argument0[@ sk_attachment_plane_var_x] = real(argument1);
argument0[@ sk_attachment_plane_var_y] = real(argument2);
var sk_xscale = is_real(argument3) ? argument3 : 1;
var sk_yscale = is_real(argument4) ? argument4 : 1;
var sk_rotation = real(argument7);
var sk_rotationX = sk_rotation+real(argument5);
var sk_rotationY = sk_rotation+real(argument6)+90;
argument0[@ sk_attachment_plane_var_m00] = dcos(sk_rotationX)*sk_xscale;
argument0[@ sk_attachment_plane_var_m01] = -dsin(sk_rotationX)*sk_xscale;
argument0[@ sk_attachment_plane_var_m10] = dcos(sk_rotationY)*-sk_yscale;
argument0[@ sk_attachment_plane_var_m11] = -dsin(sk_rotationY)*-sk_yscale;