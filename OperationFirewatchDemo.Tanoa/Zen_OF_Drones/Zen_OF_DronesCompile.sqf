//

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

Zen_OF_Drones_Local = [];

Zen_OF_DeleteDrone = compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_DeleteDrone.sqf";
Zen_OF_FindDroneRoute = compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_FindDroneRoute.sqf";
Zen_OF_FindDroneRouteData = compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_FindDroneRouteData.sqf";
Zen_OF_FindFire = compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_FindFire.sqf";
Zen_OF_GetDroneData = compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_GetDroneData.sqf";
Zen_OF_InvokeDrone = compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_InvokeDrone.sqf";
Zen_OF_ManageDrones = compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_ManageDrones.sqf";
Zen_OF_OrderDroneExecuteRoute = compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_OrderDroneExecuteRoute.sqf";
Zen_OF_OrderDroneOrbit = compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_OrderDroneOrbit.sqf";
Zen_OF_UpdateDrone = compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_UpdateDrone.sqf";

#define DIST_SCALE 1000.
#define FAILURE_CHANCE 1.

#define ROT_SOLN \
    __y = _m*__x + _l; \
    __x_array = [__x, __y, 0]; \
    __x_array = ZEN_STD_Math_VectRotateZ(__x_array, _phi); \
    __x_array = (__x_array vectorAdd _re) vectorMultiply DIST_SCALE; \
    __x = __x_array select 0;

Zen_OF_CheckCollision = {
    private ["_dir", "_centerPoint", "_dist", "_r0", "_r1", "_x0", "_y0", "_m", "_hasCollision", "_a", "_b", "_r", "_root", "_heuristicCenters", "_x1", "_xMin", "_xMax", "__x", "_re", "_phi", "_y1", "_l", "_heuristicRadii", "__x_array", "__y", "_yMin", "_yMax", "_distToZone", "_r0_t", "_r1_t", "_r0_r", "_r1_r"];

    _r0 = _this select 0;
    _r1 = _this select 1;
    _heuristicCenters = _this select 2;
    _heuristicRadii = _this select 3;

    _dir = [_r0, _r1] call Zen_FindDirection;
    _dist = (_r0 distance2D _r1) / DIST_SCALE;
    // _domainRadius = (vectorMagnitude ([_r0, _dist * .7, _dir + 120, "trig"] call Zen_ExtendVector)) / DIST_SCALE;
    _centerPoint = ([_r0, _dist / 2. * DIST_SCALE, _dir, "trig"] call Zen_ExtendVector) vectorMultiply (1. / DIST_SCALE);

    // 0 = [_centerPoint vectorMultiply DIST_SCALE, "center"] call Zen_SpawnMarker;
    // player commandChat str _domainRadius;

    _x0 = (_r0 select 0);
    _x1 = (_r1 select 0);
    _y0 = (_r0 select 1);
    _y1 = (_r1 select 1);

    if (_x1 < _x0) then {
        _xMin = _x1;
        _xMax = _x0;
    } else {
        _xMin = _x0;
        _xMax = _x1;
    };

    if (_y1 < _y0) then {
        _yMin = _y1;
        _yMax = _y0;
    } else {
        _yMin = _y0;
        _yMax = _y1;
    };

    _r0 = _r0 vectorMultiply (1. / DIST_SCALE);
    _r1 = _r1 vectorMultiply (1. / DIST_SCALE);

    _hasCollision = false;
    {
        _re = _x vectorMultiply (1. / DIST_SCALE);

        _A = (((_heuristicRadii select _forEachIndex) select 0) / DIST_SCALE)^2;
        _B = (((_heuristicRadii select _forEachIndex) select 1) / DIST_SCALE)^2;
        _R = sqrt (_A max _B);

        _distToZone = _centerPoint distance2D _re;
        // player commandChat str (_R + _domainRadius);
        // player commandChat str _distToZone;
        // player commandChat str "____";
        if ((_distToZone < (_R + _dist)) && {random 1 < (FAILURE_CHANCE)}) then {

            _phi = (_heuristicRadii select _forEachIndex) select 2;

            _r0_t = _r0 vectorAdd (_re vectorMultiply -1);
            _r1_t = _r1 vectorAdd (_re vectorMultiply -1);

            _r0_r = ZEN_STD_Math_VectRotateZ(_r0_t, -_phi);
            _r1_r = ZEN_STD_Math_VectRotateZ(_r1_t, -_phi);

            _x0 = (_r0_r select 0);
            _y0 = (_r0_r select 1);
            _x1 = (_r1_r select 0);
            _y1 = (_r1_r select 1);

            _m = (_y1 - _y0) / (_x1 - _x0);
            _l = -_x0 * _m + _y0;

            _root = _A * _B^2 - _A * _B * _l^2 + _A^2 * _b * _m^2;
            // player groupChat str _root;
            if (_root >= 0) then {

                __x = (-_A * _l * _m + sqrt _root) / (_B + _A * _m^2);
                ROT_SOLN
                if (__x <= _xMax && {__x >= _xMin}) exitWith {
                    _hasCollision = true;
                };

                __x = (-_A * _l * _m - sqrt _root) / (_B + _A * _m^2);
                ROT_SOLN
                if (__x <= _xMax && {__x >= _xMin}) exitWith {
                    _hasCollision = true;
                };
            };
        };
    } forEach _heuristicCenters;
    (_hasCollision)
};

if (true) exitWith {};
