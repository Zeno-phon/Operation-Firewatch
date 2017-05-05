// Zen_OF_FindDroneRoute

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

#define MAX_SORTED_PATHS 3
#define OFF_MAP(P) ((((P select 0) < 0) || ((P select 1) < 0)) || {(((P select 0) > (_worldSizeXY select 0)) || ((P select 1) > (_worldSizeXY select 1)))})

#define GAUSSIAN_STEP(DIST, DIR) \
    _dist = random [DIST / 10, DIST / 2, DIST * 7 / 10]; \
    if (random 1 > 0.5) then { \
        _dir =  (random [90, 45, 5]) + DIR; \
    } else { \
        _dir = -(random [90, 45, 5]) + DIR; \
    };
    // 0 = [__x_array, ""] call Zen_SpawnMarker; \

#define APPEND_PATH(P) \
    _path = []; \
    if (_startInZone) then { \
        _path pushBack _realStart; \
    }; \
    _path append P; \
    if (_endInZone) then { \
        _path pushBack _realEnd; \
    }; \
    _pathsArray pushBack _path;

_Zen_stack_Trace = ["Zen_OF_FindDroneRoute", _this] call Zen_StackAdd;
private ["_drone", "_droneData", "_start", "_end", "_worldSizeXY", "_pathsArray", "_zones", "_path", "_dist", "_dir", "_endInZone", "_startInZone", "_heuristicCenters", "_heuristicRadii", "_dirToStart", "_data", "_realStart", "_realEnd", "_distanceFull", "_attempts", "_midPoint", "_args", "_attemptsSplitting", "_midPointStart", "_midPointEnd", "_distanceSplit", "_dirToMidSplitStart", "_midpointNew"];

if !([_this, [["STRING"], ["VOID"], ["VOID"]], [], 3] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ([])
};

_drone = _this select 0;
_droneData = [_drone] call Zen_OF_GetDroneData;

_start = [(_this select 1)] call Zen_ConvertToPosition;
_end = [(_this select 2)] call Zen_ConvertToPosition;

_startInZone = false;
_endInZone = false;
_worldSizeXY = [worldSize, worldSize];

if (Zen_OF_User_Group_Index > 0 && {!(OFF_MAP(_end))}) then {
    _pathsArray = [];
    _zones = _droneData select 5;

    _heuristicCenters = [];
    _heuristicRadii = [];
    _dirToStart = [_end, _start] call Zen_FindDirection;
    {
        if !(_x in (_droneData select 16)) then {
            _data = [_x] call Zen_OF_GetZoneData;
            _heuristicCenters pushBack (_data select 4);
            _heuristicRadii pushBack (_data select 5);
            _polyDim = [(_data select 5), 0, 1] call Zen_ArrayGetIndexedSlice;
            _polyDir = (_data select 5) select 2;
            // reverse _polyDim;
            if !(_startInZone) then {
                _startInZone = [_start, (_data select 4), _polyDim, _polyDir, "ellipse"] call Zen_IsPointInPoly;
                if (_startInZone) then {
                    _realStart =+ _start;
                    _start = [_start, ([_start, _dirToStart + 180, (_data select 4), _polyDim, _polyDir, "ellipse"] call Zen_FindDistanceToPolyEdge) + 10, _dirToStart + 180, "trig"] call Zen_ExtendVector;
                };
            };

            if !(_endInZone) then {
                _endInZone = [_end, (_data select 4), _polyDim, _polyDir, "ellipse"] call Zen_IsPointInPoly;
                if (_endInZone) then {
                    _realEnd =+ _end;
                    _end = [_end, ([_end, _dirToStart, (_data select 4), _polyDim, _polyDir, "ellipse"] call Zen_FindDistanceToPolyEdge) + 10, _dirToStart, "trig"] call Zen_ExtendVector;
                    0 = [_end] call Zen_SpawnMarker;
                };
            };
        };
    } forEach _zones;

    // {
        // 0 = [_x, str _x] call Zen_SpawnMarker;
        // 0 = [_x, str _x, "colorRed", [_heuristicRadii select _forEachIndex, _heuristicRadii select _forEachIndex], "ellipse"] call Zen_SpawnMarker;
    // } forEach _heuristicCenters;

    if ([_end, _start, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision) then {
        _dirToStart = [_end, _start] call Zen_FindDirection;
        _distanceFull = (_start distance2D _end);
        _attempts = 0;
        while {(_attempts < 40)} do {
            _attempts = _attempts + 1;
            GAUSSIAN_STEP(_distanceFull, _dirToStart)

            _midPoint = [_end, _dist, _dir, "trig"] call Zen_ExtendVector;
            if !(OFF_MAP(_midPoint)) then {
                if (!([_end, _midPoint, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision) && {!([_midPoint, _start, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision)}) then {
                    _args = [_start, _midPoint, _end];
                    APPEND_PATH(_args)
                };
            };
        };

        // /**
        _attemptsSplitting = 0;
        while {(_attemptsSplitting < 20)} do {
            _attemptsSplitting = _attemptsSplitting + 1;
            GAUSSIAN_STEP(_distanceFull, _dirToStart)

            _midPointEnd = [_end, _dist, _dir, "trig"] call Zen_ExtendVector;
            if !(OFF_MAP(_midPointEnd)) then {

                // _dist = _distanceFull / 2;
                // _dist = random [_distanceFull / 10, _distanceFull / 2, _distanceFull * 7 / 10];
                GAUSSIAN_STEP(_distanceFull, _dirToStart + 180)

                // _midPointStart = [_start, _dist, _dir - (_dir - 90)*2 + _dirToStart + 180, "trig"] call Zen_ExtendVector;
                // _midPointStart = [_start, _dist, _dirToStart - _dir, "trig"] call Zen_ExtendVector;
                _midPointStart = [_start, _dist, _dir, "trig"] call Zen_ExtendVector;

                if !(OFF_MAP(_midPointEnd)) then {
                    if (!([_end, _midPointEnd, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision) && {!([_midPointStart, _start, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision)}) then {
                        // 0 = [_midPointEnd, str _attemptsSplitting, "colorRed"] call Zen_SpawnMarker;
                        // 0 = [_midPointStart, str _attemptsSplitting, "colorBlue"] call Zen_SpawnMarker;
                        // player groupChat str ([_midPointStart, _midPointEnd, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision);
                         if !([_midPointStart, _midPointEnd, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision) then {
                            _args = [_start, _midPointStart, _midPointEnd, _end];
                            APPEND_PATH(_args)
                        };
                    };
                };
            };
        };
        //*/

        // /**
        _attemptsRecursive = 0;
        while {(_attemptsRecursive < 10)} do {
            _attemptsRecursive = _attemptsRecursive + 1;
            GAUSSIAN_STEP(_distanceFull, _dirToStart)

            _midPointEnd = [_end, _dist, _dir, "trig"] call Zen_ExtendVector;
            if !(OFF_MAP(_midPointEnd)) then {
                GAUSSIAN_STEP(_distanceFull, _dirToStart + 180)
                _midPointStart = [_start, _dist, _dir, "trig"] call Zen_ExtendVector;

                if !(OFF_MAP(_midPointEnd)) then {
                    if (!([_end, _midPointEnd, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision) && {!([_midPointStart, _start, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision)}) then {
                         if !([_midPointStart, _midPointEnd, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision) then {
                            _args = [_start, _midPointStart, _midPointEnd, _end];
                            APPEND_PATH(_args)
                        } else {
                            _distanceSplit = (_midPointEnd distance2D _midPointStart);
                            _dirToMidSplitStart = [_midPointEnd, _midPointStart] call Zen_FindDirection;
                            _attempts = 0;
                            while {_attempts < 10} do {
                                GAUSSIAN_STEP(_distanceSplit, _dirToMidSplitStart)
                                _midPoint = [_midPointEnd, _dist, _dir, "trig"] call Zen_ExtendVector;

                                if !(OFF_MAP(_midPoint)) then {
                                    if (!([_midPointEnd, _midPoint, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision) && {!([_midPoint, _midPointStart, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision)}) then {
                                        _args = [_start, _midPointStart, _midPoint, _midPointEnd, _end];
                                        APPEND_PATH(_args)
                                    };

                                    _attempts = _attempts + 1;
                                };
                            };
                        };
                    };
                };
            };
        };
        //*/

        // /**
        {
            _path = _x;
            for "_i" from (if (_startInZone) then {1} else {0}) to (count _path - 3) step 1 do {
                _start = _path select _i;
                _midpoint = _path select (_i + 1);
                _end = _path select (_i + 2);

                _dist = _midpoint distance2D _end;
                _dir = [_end, _midpoint] call Zen_FindDirection;
                for "_j" from 0 to 4 do {
                    _midpointNew = [_end, _dist * _j / 5, _dir, "trig"] call Zen_ExtendVector;
                    if !([_start, _midpointNew, _heuristicCenters, _heuristicRadii] call Zen_OF_CheckCollision) exitWith {
                        _path set [_i + 1, _midpointNew];
                    };
                };
            };
        } forEach _pathsArray;
        //*/

        _pathsArray = [_pathsArray, {
            _dist = 0;
            for "_i" from 0 to (count _this - 2) do {
                _dist = _dist + ((_this select _i) distanceSqr (_this select (_i + 1)));
            };
            (_dist)
        }, "hash"] call Zen_ArraySort;

        _pathsArray = [_pathsArray, 0, MAX_SORTED_PATHS - 1] call Zen_ArrayGetIndexedSlice;
    } else {
        _args = [_start, [_start, (_start distance2D _end) / 2, [_start, _end] call Zen_FindDirection, "trig"] call Zen_ExtendVector, _end];
        APPEND_PATH(_args)
    };
} else {
    _args = [_start, [_start, (_start distance2D _end) / 2, [_start, _end] call Zen_FindDirection, "trig"] call Zen_ExtendVector, _end];
    APPEND_PATH(_args)
};

call Zen_StackRemove;
(_pathsArray)
