// Zen_OF_FindDroneRoute

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

// #define MAX_RANDOM_ATTEMPTS 1000
#define MAX_SORTED_PATHS 20

_Zen_stack_Trace = ["Zen_OF_FindDroneRoute", _this] call Zen_StackAdd;
private ["_start", "_end", "_pathsArray", "_drone", "_droneData", "_F_CheckCollision", "_zones", "_heuristicCenters", "_heuristicRadii", "_data", "_dist", "_distanceFull", "_dirToStart", "_dir", "_midPoint", "_attemptsSplitting", "_attempts", "_midPointEnd", "_midPointStart", "_distanceSplit", "_dirToMidSplitStart", "_added"];

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
    private ["_r0", "_r1", "_x0", "_y0", "_m", "_hasCollision", "_a", "_b", "_r", "_root", "_heuristicCenters", "_x1", "_xMin", "_xMax", "__x"];

    _r0 = _this select 0;
    _r1 = _this select 1;
    _heuristicCenters = _this select 2;

    _x0 = (_r0 select 0) / 1000;
    _y0 = (_r0 select 1) / 1000;
    _x1 = (_r1 select 0) / 1000;
    _m = ((_r1 select 1) / 1000 - _y0) / (_x1 - _x0);

    if (_x1 < _x0) then {
        _xMin = _x1;
        _xMax = _x0;
    } else {
        _xMin = _x0;
        _xMax = _x1;
    };

    _hasCollision = false;
    {
        _a = (_x select 0) / 1000;
        _b = (_x select 1) / 1000;
        _r = (_heuristicRadii select _forEachIndex) / 1000;

        _root = (-2*_a - 2*_b*_m - 2*_m^2*_x0 + 2*_m*_y0)^2 - 4*(1 + _m^2)*(_a^2 + _b^2 - _r^2 + 2*_b*_m*_x0 + _m^2*_x0^2 - 2*_b*_y0 - 2*_m*_x0*_y0 + _y0^2);
        // player commandChat str _root;
        if (_root >= 0) then {
            __x = (2*_a + 2*_b*_m + 2*_m^2*_x0 - 2*_m*_y0 - sqrt (_root))/(2* (1 + _m^2));

            // player commandChat str __x;
            if (__x < _xMax && {__x > _xMin}) exitWith {
                _hasCollision = true;
            };
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

    #define GAUSSIAN_STEP(DIST, DIR) \
        _dist = random [DIST / 10, DIST / 2, DIST * 7 / 10]; \
        if (random 1 > 0.5) then { \
            _dir =  (random [120, 45, 5]) + DIR; \
        } else { \
            _dir = -(random [120, 45, 5]) + DIR; \
        };

    if ([_end, _start, _heuristicCenters] call _F_CheckCollision) then {
        _distanceFull = (_start distance2D _end);
        _dirToStart = [_end, _start] call Zen_FindDirection;
        _attempts = 0;
        while {(_attempts < 120)} do {
            GAUSSIAN_STEP(_distanceFull, _dirToStart)
            _midPoint = [_end, _dist, _dir, "trig"] call Zen_ExtendVector;
            if (!([_end, _midPoint, _heuristicCenters] call _F_CheckCollision) && {!([_midPoint, _start, _heuristicCenters] call _F_CheckCollision)}) then {
                _pathsArray pushBack [_start, _midPoint, _end];
            };
            _attempts = _attempts + 1;
        };

        // if (count _pathsArray < 200 / 4) then {
        // if (false) then {
            _attemptsSplitting = 0;
            while {(_attemptsSplitting < 80)} do {
                GAUSSIAN_STEP(_distanceFull, _dirToStart)
                _midPointEnd = [_end, _dist, _dir, "trig"] call Zen_ExtendVector;

                _dist = _distanceFull / 2;
                _dist = random [_distanceFull / 10, _distanceFull / 2, _distanceFull * 7 / 10];
                _midPointStart = [_start, _dist, _dir - (_dir - 90)*2 + _dirToStart + 180, "trig"] call Zen_ExtendVector;

                if (!([_end, _midPointEnd, _heuristicCenters] call _F_CheckCollision) && {!([_midPointStart, _start, _heuristicCenters] call _F_CheckCollision)}) then {
                    // 0 = [_midPointEnd, str _attemptsSplitting, "colorRed"] call Zen_SpawnMarker;
                    // 0 = [_midPointStart, str _attemptsSplitting, "colorBlue"] call Zen_SpawnMarker;
                    // player groupChat str ([_midPointStart, _midPointEnd, _heuristicCenters] call _F_CheckCollision);
                     if !([_midPointStart, _midPointEnd, _heuristicCenters] call _F_CheckCollision) then {
                        _pathsArray pushBack [_start, _midPointStart, _midPointEnd, _end];
                    // } else {
                        // _distanceSplit = (_midPointEnd distance2D _midPointStart);
                        // _dirToMidSplitStart = [_midPointEnd, _midPointStart] call Zen_FindDirection;
                        // _attempts = 0;
                        // _added = 0;
                        // while {(_added < 4) && (_attempts < 50)} do {
                            // GAUSSIAN_STEP(_distanceSplit, _dirToMidSplitStart)
                            // _midPoint = [_midPointEnd, _dist, _dir, "trig"] call Zen_ExtendVector;
                            // if (!([_midPointEnd, _midPoint, _heuristicCenters] call _F_CheckCollision) && {!([_midPoint, _midPointStart, _heuristicCenters] call _F_CheckCollision)}) then {
                                // _pathsArray pushBack [_start, _midPointStart, _midPoint, _midPointEnd, _end];
                                // _added = _added + 1;
                            // };
                            // _attempts = _attempts + 1;
                        // };
                    };
                };

                _attemptsSplitting = _attemptsSplitting + 1;
            };
        // };

            _pathsArray = [_pathsArray, {
                _dist = 0;
                for "_i" from 0 to (count _this - 2) do {
                    _dist = _dist + ((_this select _i) distanceSqr (_this select (_i + 1)));
                };
                (_dist)
            }, "hash"] call Zen_ArraySort;

            _pathsArray = [_pathsArray, 0, MAX_SORTED_PATHS - 1] call Zen_ArrayGetIndexedSlice;
    } else {
        _pathsArray = [[_start, [_start, (_start distance2D _end) / 2, [_start, _end] call Zen_FindDirection, "trig"] call Zen_ExtendVector, _end]];
    };
} else {
    _pathsArray = [[_start, [_start, (_start distance2D _end) / 2, [_start, _end] call Zen_FindDirection, "trig"] call Zen_ExtendVector, _end]];
};

call Zen_StackRemove;
(_pathsArray)
