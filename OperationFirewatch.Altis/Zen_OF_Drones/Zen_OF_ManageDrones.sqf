// Zen_OF_ManageDrones

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

#define FUEL_FRACTION_PER_METER (1. / 10000.)
#define ALPHA_TO_NUMBER(A) (switch (toUpper A) do {case "A": {(0)}; case "B":{(1)}; case "C": {(2)};})

if (isDedicated && isServer) exitWith {};
_Zen_stack_Trace = ["Zen_OF_ManageDrones", _this] call Zen_StackAdd;

Zen_OF_DroneManagerData = [];
while {true} do {
    {
        _x set [6, false];
    } forEach Zen_OF_Zones_Global;

    {
        sleep 5;
        _drone = _x select 0;
        _droneData = _x;
        _dataArray = [];

        {
            if ([(_x select 0), _drone] call Zen_ValuesAreEqual) exitWith {
                _dataArray = _x;
            };
        } forEach Zen_OF_DroneManagerData;

        if (count _dataArray == 0) then {
            Zen_OF_DroneManagerData pushBack [_drone, getPosATL (_droneData select 1), false, 1, time, [false, false, false], [0,0,0], [0,0,0]];
        } else {
            if (alive (_droneData select 1)) then {
                _isRTB = _dataArray select 2;

                _newPos = getPosATL (_droneData select 1);
                _distance = (_dataArray select 1) distance2D _newPos;
                _dataArray set [1, _newPos];

                if !(_isRTB) then {
                    _oldFuel = _droneData select 3;
                    _newFuel = _oldFuel - _distance * FUEL_FRACTION_PER_METER;
                    _dataArray set [3, _newFuel];
                    0 = [_drone, "", _newFuel] call Zen_OF_UpdateDrone;

                    for "_i" from 2 to 9 do {
                        if (_oldFuel > _i/10 && _newFuel < _i/10) exitWith {
                            player sideChat (_drone + " fuel level at " + str _newFuel);
                            ZEN_FMW_MP_REServerOnly("A3log", [_drone + " fuel level at " + str _newFuel], call)
                        };
                    };

                    _health = _droneData select 2;
                    if ((_newFuel < 0.3) || (_health < 0.7)) then {
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

                        player sideChat (_drone + " fuel/health level critical; RTB in progress.");
                        ZEN_FMW_MP_REServerOnly("A3log", [(_drone + " fuel/health level critical at " + str _newFuel + " " + str _health + " ; RTB in progress to " + (_nearest select 0) + " at " + str (_nearest select 1) + ".")], call)

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

                            _h_move = [_drone, [_newPos, (_nearest select 1)], [], true, (_nearest select 0)] spawn Zen_OF_OrderDroneExecuteRoute;
                            0 = [_drone, "", "", _h_move] call Zen_OF_UpdateDrone;
                            ZEN_STD_Code_WaitScript(_h_move)
                            _dataArray set [2, false];
                            _dataArray set [3, 1];
                        };
                    };
                };

                _dt = time - (_dataArray select 4);
                _dataArray set [4, time];

                _zoneViolationOld = _dataArray select 5;
                _zoneViolationNew = [false, false, false];
                _zoneTimings = _dataArray select 6;
                _totalViolations = _dataArray select 7;
                {
                    _center = _x select 4;
                    _radius = _x select 5;

                    if ((_newPos distance2D _center) < _radius) then {
                        _type = _x select 1;
                        _isIn = [_newPos, _x select 0] call Zen_OF_IsInZone;

                        if (_isIn) then {
                            // TODO check against A zone permission list
                            _zoneViolationNew set [ALPHA_TO_NUMBER(_type), true];
                            ZEN_FMW_MP_REServerOnly("A3log", [(_drone + " has trespassed into zone " + (_x select 0) + " of type " + _type + " at " + str _newPos)], call)

                            _x set [6, true];

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
            } else {
                0 = [_drone] call Zen_OF_DeleteDrone;

                player sideChat (_drone + " has been destroyed by AAA.");
                ZEN_FMW_MP_REServerOnly("A3log", [_drone + " has been destroyed by AAA; current data is " + str _dataArray], call)

                _indexes = [Zen_OF_DroneManagerData, _drone, 0] call Zen_ArrayGetNestedIndex;
                0 = [Zen_OF_DroneManagerData, (_indexes select 0)] call Zen_ArrayRemoveIndex;
            };
        };
    } forEach +Zen_OF_Drones_Local;

    {
        if (!(_x select 6) && {((_x select 1) == "C")} && {((_x select 3) != "")}) then {
            0 = [_x select 3] call Zen_Cache;
        };
    } forEach Zen_OF_Zones_Global;
};

call Zen_StackRemove;
if (true) exitWith {};
