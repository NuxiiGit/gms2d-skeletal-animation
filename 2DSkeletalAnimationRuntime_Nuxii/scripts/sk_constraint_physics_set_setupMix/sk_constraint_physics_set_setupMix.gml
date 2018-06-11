/// @desc sets the setup mix for the constraint
/// @param constraint
/// @param gravity
/// @param direction
/// @param drivingRatio
argument0[@ SK_CONSTRAINT_PHYSICS.XGrav] = argument1*dcos(argument2);
argument0[@ SK_CONSTRAINT_PHYSICS.YGrav] = -argument1*dsin(argument2);
argument0[@ SK_CONSTRAINT_PHYSICS.drive] = argument3;