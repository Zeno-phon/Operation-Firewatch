// Zen_OF_ManageDrones

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

// #define FUEL_FRACTION_PER_METER (1. / 100000.)
#define FUEL_FRACTION_PER_SEC (1. / 60. / 60. / 1.)
// #define SENSOR_DAMAGE_PER_SCAN (1. / 10000.)
#define ALPHA_TO_NUMBER(A) (switch (toUpper A) do {case "A": {(0)}; case "B":{(1)}; case "C": {(2)};})

if (isDedicated && isServer) exitWith {};
_Zen_stack_Trace = ["Zen_OF_ManageDrones", _this] call Zen_StackAdd;

Zen_OF_DroneManagerData = [];
while {true} do {
    {
        _x set [6, false];
    } forEach Zen_OF_Zones_Global;

    _drones = [];
    {
        _drones pushBack (_x select 0);
    } forEach Zen_OF_Drones_Local;

    {
        sleep 0.3;
        _drone = _x;
        _droneData = [_x] call Zen_OF_GetDroneData;
        _dataArray = [];

        {
            if ([(_x select 0), _drone] call Zen_ValuesAreEqual) exitWith {
                _dataArray = _x;
            };
        } forEach Zen_OF_DroneManagerData;

        if (count _dataArray == 0) then {
            Zen_OF_DroneManagerData pushBack [_drone, getPosATL (_droneData select 1), false, (_droneData select 3), time, [false, false, false], [0,0,0], [0,0,0], (_droneData select 2), [], 0];
            _mkr = [_droneData select 1, _drone] call Zen_SpawnMarker;
            0 = [_drone, "", "", "", "", _mkr] call Zen_OF_UpdateDrone;
        } else {
            if (alive (_droneData select 1)) then {
                _newPos = getPosATL (_droneData select 1);
                (_droneData select 6) setMarkerPos _newPos;

                _isRTB = _dataArray select 2;

                _dt = time - (_dataArray select 4);
                // _distance = (_dataArray select 1) distance2D _newPos;
                _dataArray set [1, _newPos];

                // Fuel warning and auto RTB
                _oldFuel = _droneData select 3;
                // _newFuel = _oldFuel - _distance * FUEL_FRACTION_PER_METER;
                _newFuel = _oldFuel - _dt * FUEL_FRACTION_PER_SEC;
                // _dataArray set [3, _newFuel];
                0 = [_drone, "", _newFuel] call Zen_OF_UpdateDrone;

                if (_newFuel <= 0.) then {
                    // Drone death
                    0 = [_drone] call Zen_OF_DeleteDrone;

                    0 = [(_drone + " has run out of fuel and crashed.")] call Zen_OF_PrintMessage;
                    ZEN_FMW_MP_REServerOnly("A3log", [_drone + " has run out of fuel and crashed; current data is " + str _dataArray], call)

                    _indexes = [Zen_OF_DroneManagerData, _drone, 0] call Zen_ArrayGetNestedIndex;
                    0 = [Zen_OF_DroneManagerData, (_indexes select 0)] call Zen_ArrayRemoveIndex;
                } else {
                    // Scanning for fires and sensor health
                    // _newHealth = (_droneData select 2) - SENSOR_DAMAGE_PER_SCAN;
                    // 0 = [_drone, _newHealth] call Zen_OF_UpdateDrone;
                    // _dataArray set [8, _newHealth];

                    _oldFires = _dataArray select 9;
                    _newFires = [_drone] call Zen_OF_FindFire;

                    {
                        _indexes = [_oldFires, _x select 0, 0] call Zen_ArrayGetNestedIndex;
                        if (count _indexes > 0) then {
                            if (((_x select 1) distance2D ((_oldFires select _forEachIndex) select 1)) > 10.) then {
                                (_oldFires select _forEachIndex) set [1, (_x select 1)];
                                _mkr = (_oldFires select _forEachIndex) select 2;
                                _mkr setMarkerPos (_x select 1);
                                0 = [(_drone + " has updated the position of a fire at about " + str (_x select 1) + ".")] call Zen_OF_PrintMessage;
                                ZEN_FMW_MP_REServerOnly("A3log", [(_drone + " has updated the position of fire " + (_x select 0) + " at about " + str (_x select 1) + ".")], call)
                            };
                        } else {
                            0 = [(_drone + " has detected a new fire at about " + str (_x select 1) + ".")] call Zen_OF_PrintMessage;
                            ZEN_FMW_MP_REServerOnly("A3log", [(_drone + " has detected new fire " + (_x select 0) + " at about " + str (_x select 1) + ".")], call)

                            if !(([(_x select 0), false] in Zen_OF_Fires_Detected_Local) || ([(_x select 0), true] in Zen_OF_Fires_Detected_Local)) then {
                                Zen_OF_Fires_Detected_Local pushBack [(_x select 0), false];
                            };

                            _mkr = [_x select 1, _x select 0] call Zen_SpawnMarker;
                            _oldFires pushBack (_x + [_mkr]);
                        };
                    } forEach _newFires;
                    _dataArray set [9, _oldFires];

                    if !(_isRTB) then {
                        for "_i" from 2 to 9 do {
                            if (_oldFuel > _i/10 && _newFuel < _i/10) exitWith {
                                0 = [(_drone + " fuel level at " + str _newFuel)] call Zen_OF_PrintMessage;
                                ZEN_FMW_MP_REServerOnly("A3log", [_drone + " fuel level at " + str _newFuel], call)
                            };
                        };

                        // if ((_newFuel < 0.3) || (_newHealth < 0.7)) then {
                        if (_newFuel < 0.3) then {
                            _dataArray set [2, true];

                            _nearest = [Zen_OF_RepairRefuel_Global, compile format["
                                _pos = _this select 1;
                                _dronePos = %1;

                                (if ((_this select 3) == (_this select 2)) then {
                                    (1)
                                } else {
                                    -1 * (_dronePos distanceSqr _pos)
                                })
                            ", _newPos]] call Zen_ArrayFindExtremum;

                            0 = [(_drone + " fuel/health level critical; RTB in progress.")] call Zen_OF_PrintMessage;
                            // ZEN_FMW_MP_REServerOnly("A3log", [(_drone + " fuel/fuel level critical at " + str _newFuel + " " + str _newHealth + " ; RTB in progress to " + (_nearest select 0) + " at " + str (_nearest select 1) + ".")], call)
                            ZEN_FMW_MP_REServerOnly("A3log", [(_drone + " fuel level critical at " + str _newFuel + " ; RTB in progress to " + (_nearest select 0) + " at " + str (_nearest select 1) + ".")], call)

                            terminate (_droneData select 4);
                            _droneData set [7, []];
                            {
                                deleteMarker _x;
                            } forEach (_droneData select 8);
                            _droneData set [8,[]];
                            _droneData set [9,0];

                            0 = [_dataArray, _drone, _newPos, _nearest] spawn {
                                _dataArray = _this select 0;
                                _drone = _this select 1;
                                _newPos = _this select 2;
                                _nearest = _this select 3;

                                0 = [_drone, "", "", "", "", 0, "", "", "", "", "", "", "", "", ["MOVE", "LAND"]] call Zen_OF_UpdateDrone;
                                _h_move = [_drone, [_newPos, (_nearest select 1)], []] spawn Zen_OF_OrderDroneExecuteRoute;
                                0 = [_drone, "", "", _h_move] call Zen_OF_UpdateDrone;
                                ZEN_STD_Code_WaitScript(_h_move)
                                _dataArray set [2, false];
                                // _dataArray set [3, 1];
                                // _dataArray set [8, 1];
                            };
                        };
                    };

                    // zone violations
                    _dataArray set [4, time];

                    _zoneViolationOld = _dataArray select 5;
                    _zoneViolationNew = [false, false, false];
                    _zoneTimings = _dataArray select 6;
                    _totalViolations = _dataArray select 7;
                    {
                        _center = _x select 4;
                        _radius = ((_x select 5) select 0) max ((_x select 5) select 1);

                        if ((_newPos distance2D _center) < _radius) then {
                            _type = _x select 1;
                            _isIn = [_newPos, _x select 0] call Zen_OF_IsInZone;

                            if (_isIn) then {
                                if !(_x in (_droneData select 16)) then {
                                    _zoneViolationNew set [ALPHA_TO_NUMBER(_type), true];
                                    0 = [(_drone + " has tresspassed in zone " + (_x select 0) + " of type " + _type)] call Zen_OF_PrintMessage;
                                    ZEN_FMW_MP_REServerOnly("A3log", [(_drone + " has trespassed into zone " + (_x select 0) + " of type " + _type + " at " + str _newPos)], call)

                                    _x set [6, true];

                                    switch (ALPHA_TO_NUMBER(_type)) do {
                                        case 0: {
                                            _dataArray set [10, -5 + (_dataArray select 10)];
                                        };
                                        case 1: {
                                            _dataArray set [10, -10 + (_dataArray select 10)];
                                        };
                                        case 2: {
                                            _dataArray set [10, -20 + (_dataArray select 10)];
                                        };
                                    };

                                    if (ALPHA_TO_NUMBER(_type) == 2) then {
                                        (_droneData select 1) allowDamage true;
                                        _zoneAAA = _x select 3;
                                        0 = [_zoneAAA] call Zen_UnCache;
                                        _AAAObjs = [_zoneAAA] call Zen_GetCachedUnits;
                                        {
                                            _x reveal (_droneData select 1);
                                        } forEach ([_AAAObjs] call Zen_ConvertToObjectArray);

                                        ZEN_FMW_MP_REServerOnly("A3log", ["AAA has been uncached in " + (_x select 0) + " in response to trespass by " + _drone], call)
                                    };
                                };
                            };
                        };
                    } forEach Zen_OF_Zones_Global;

                    if !(_zoneViolationNew select 2) then {
                        (_droneData select 1) allowDamage false;
                    };

                    {
                        if ((_zoneViolationOld select _x) && {(_zoneViolationNew select _x)}) then {
                            _zoneTimings set [_x, (_zoneTimings select _x) + _dt];
                        } else {
                            if ((_zoneViolationOld select _x) || {(_zoneViolationNew select _x)}) then {
                                _zoneTimings set [_x, (_zoneTimings select _x) + _dt / 2.];

                                if (!(_zoneViolationOld select _x) && {(_zoneViolationNew select _x)}) then {
                                    _totalViolations set [_x, (_totalViolations select _x) + 1];
                                };
                            };
                        };
                    } forEach [0, 1, 2];

                    _dataArray set [5, _zoneViolationNew];
                };

                _AORs = [];
                for "_i" from 1 to 21 do {
                    _AORs pushBack ("AORLarge_" + str _i);
                };
                _inAOR = false;
                {
                    if ([(_droneData select 1), _x] call Zen_IsPointInPoly) exitWith {
                        _inAOR = true;
                    };
                } forEach _AORs;

                if (_inAOR) then {
                    _dt = time - (_dataArray select 4);
                    _dataArray set [10, _dt / 20 + (_dataArray select 10)];
                };
            } else {
                // Drone death
                0 = [_drone] call Zen_OF_DeleteDrone;

                0 = [(_drone + " has been destroyed by AAA.")] call Zen_OF_PrintMessage;
                ZEN_FMW_MP_REServerOnly("A3log", [_drone + " has been destroyed by AAA; current data is " + str _dataArray], call)

                _indexes = [Zen_OF_DroneManagerData, _drone, 0] call Zen_ArrayGetNestedIndex;
                0 = [Zen_OF_DroneManagerData, (_indexes select 0)] call Zen_ArrayRemoveIndex;
            };
        };
    } forEach _drones;

    {
        if (!(_x select 6) && {((_x select 1) == "C")} && {((_x select 3) != "")}) then {
            0 = [_x select 3] call Zen_Cache;
        };
    } forEach Zen_OF_Zones_Global;
};

call Zen_StackRemove;
if (true) exitWith {};
