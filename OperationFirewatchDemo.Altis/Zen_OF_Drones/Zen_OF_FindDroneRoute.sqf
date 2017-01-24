// Zen_OF_FindDroneRoute

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

#define MAX_RANDOM_PATHS 500
#define MAX_SORTED_PATHS 20

_Zen_stack_Trace = ["Zen_OF_FindDroneRoute", _this] call Zen_StackAdd;
private ["_start", "_end", "_pathsArray", "_drone", "_droneData", "_F_CheckCollision", "_zones", "_heuristicCenters", "_heuristicRadii", "_data", "_dist", "_distanceFull", "_dirToStart", "_dir", "_midPoint"];

if !([_this, [["STRING"], ["VOID"], ["VOID"]], [], 3] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ([])
};

_drone = _this select 0;
_droneData = [_drone] call Zen_OF_GetDroneData;

_start = [(_this select 1)] call Zen_ConvertToPosition;
_end = [(_this select 2)] call Zen_ConvertToPosition;

// m = dy/dx = (y1 - y0) / (x1 - x0)
// y - y0 = m*(x - x0)
// y = m*(x - x0) + y0

// (x-a)^2 + (y-b)^2 = r^2
// y = (r^2 - (x-a)^2)^.5 + b

// m*(x - x0) + y0 = (r^2 - (x-a)^2)^.5 + b
// x1 = (2*a + 2*b*m + 2*m^2*x0 - 2*m*y0 +- Sqrt((-2*a - 2*b*m - 2*m^2*x0 + 2*m*y0)^2 - 4 (1 + m^2) (a^2 + b^2 - r^2 + 2 b m x0 + m^2 x0^2 - 2 b y0 - 2 m x0 y0 + y0^2)))/(2 (1 + m^2));

_F_CheckCollision = {
    _r0 = _this select 0;
    _r1 = _this select 1;

    _x0 = _r0 select 0;
    _y0 = _r0 select 1;
    _m = ((_r1 select 1) - _y0) / ((_r1 select 0) - _x0);

    _hasCollision = false;
    {
        _a = _x select 0;
        _b = _x select 1;
        _r = _heuristicRadii select _forEachIndex;

        _root = (-2*_a - 2*_b*_m - 2*_m^2*_x0 + 2*_m*_y0)^2 - 4*(1 + _m^2)*(_a^2 + _b^2 - _r^2 + 2*_b*_m*_x0 + _m^2*_x0^2 - 2*_b*_y0 - 2*_m*_x0*_y0 + _y0^2);
        // player commandChat str _root;
        if (_root >= 0.) exitWith {
            _hasCollision = true;
        };
    } forEach _heuristicCenters;
    (_hasCollision)
};

if (Zen_OF_User_Is_Group_Two) then {
    _pathsArray = [];
    _zones = _droneData select 5;

    // player commandChat str _zones;
    _heuristicCenters = [];
    _heuristicRadii = [];
    {
        _data = [_x] call Zen_OF_GetZoneData;
        _heuristicCenters pushBack (_data select 4);
        _heuristicRadii pushBack (_data select 5);
    } forEach _zones;

    // {
        // 0 = [_x, str _x] call Zen_SpawnMarker;
        // 0 = [_x, str _x, "colorRed", [_heuristicRadii select _forEachIndex, _heuristicRadii select _forEachIndex], "ellipse"] call Zen_SpawnMarker;
    // } forEach _heuristicCenters;

    if ([_end, _start] call _F_CheckCollision) then {
        _distanceFull = (_start distance2D _end);
        _dirToStart = [_end, _start] call Zen_FindDirection;
        while {count _pathsArray < MAX_RANDOM_PATHS} do {
            _dist = random [_distanceFull / 10, _distanceFull / 2, _distanceFull * 9 / 10];
            if (random 1 > 0.5) then {
                _dir =  (random [120, 45, 5]) + _dirToStart;
            } else {
                _dir = -(random [120, 45, 5]) + _dirToStart;
            };

            _midPoint = [_end, _dist, _dir, "trig"] call Zen_ExtendVector;
            if (!([_end, _midPoint] call _F_CheckCollision) && {!([_midPoint, _start] call _F_CheckCollision)}) then {
                _pathsArray pushBack [_start, _midPoint, _end];
            };
        };

        _pathsArray = [_pathsArray, {(((_this select 0) distanceSqr (_this select 1)) + ((_this select 1) distanceSqr (_this select 2)))}, "hash"] call Zen_ArraySort;
        _pathsArray = [_pathsArray, 0, MAX_SORTED_PATHS - 1] call Zen_ArrayGetIndexedSlice;
    } else {
        _pathsArray = [[_start, [_start, (_start distance2D _end) / 2, [_start, _end] call Zen_FindDirection, "trig"] call Zen_ExtendVector, _end]];
    };
} else {
    _pathsArray = [[_start, [_start, (_start distance2D _end) / 2, [_start, _end] call Zen_FindDirection, "trig"] call Zen_ExtendVector, _end]];
};

call Zen_StackRemove;
(_pathsArray)
