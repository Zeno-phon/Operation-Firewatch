// Zen_OF_OrderDroneExecuteRoute

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

#define REFUEL_TIME 60*2

_Zen_stack_Trace = ["Zen_OF_OrderDroneExecuteRoute", _this] call Zen_StackAdd;
private ["_drone", "_path", "_droneData", "_markers", "_speed", "_h_orbit", "_droneClassData", "_orbitRadius", "_nearestRR", "_waypointTypes", "_droneObj", "_nearestRRData", "_nearestAirfield", "_height", "_dataArray"];

if !([_this, [["STRING"], ["ARRAY"], ["ARRAY"], ["BOOL"], ["STRING"]], [[], ["ARRAY"], ["STRING"]], 3] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_drone = _this select 0;
_path = _this select 1;
_markers = _this select 2;

_droneData = [_drone] call Zen_OF_GetDroneData;

_droneClassData = [(_droneData select 1)] call Zen_F_GetDroneClassData;
_speed = _droneClassData select 0;
_orbitRadius = _droneClassData select 1;
_height = _droneClassData select 2;

_waypointTypes = _droneData select 15;
_droneObj = _droneData select 1;
{
    _droneObj move _x;
    (_droneData select 1) flyInHeight _height;

    waitUntil {
        sleep 4;
        (unitReady _droneObj) || ((_droneObj distance2D _x) < (_speed * 2));
    };
    ZEN_FMW_MP_REServerOnly("A3log", [_drone + " passing checkpoint at " + str _x], call)

    if ((toUpper (_waypointTypes select _forEachIndex)) == "LAND") then {
        _nearestRRData = [Zen_OF_RepairRefuel_Global, compile format["
            _pos = _this select 1;
            _dronePos = %1;

            (if ((_this select 3) == (_this select 2)) then {
                (1)
            } else {
                -1 * (_dronePos distanceSqr _pos)
            })
        ", getPosATL _droneObj]] call Zen_ArrayFindExtremum;
        _nearestRR = _nearestRRData select 0;

        if (_nearestRRData select 4) then {
            _nearestAirfield = [Zen_OF_Airfield_LandAt_Codes, compile format["
                _pos = _this select 0;
                _RRPos = %1;

                (-1 * (_RRPos distanceSqr _pos))
            ", (_nearestRRData select 1)]] call Zen_ArrayFindExtremum;

            _droneObj landAt (_nearestAirfield select 1);
        } else {
            _droneObj land (_nearestRRData select 1);
        };

        waitUntil {
            sleep 2;
            (isTouchingGround _droneObj)
        };

        sleep 15;
        _droneObj setFuel 0;

        ZEN_FMW_MP_REServerOnly("A3log", ["RTB order for " + _drone + " compete; standby repair/refuel."], call)
        0 = [_nearestRR, "", (_nearestRRData select 3) + 1] call Zen_OF_UpdateRepairRefuel;

        0 = [_drone, "", "", "", "", 0, "", "", "", [time, REFUEL_TIME]] call Zen_OF_UpdateDrone;
        sleep REFUEL_TIME;
        0 = [_drone, 1, 1] call Zen_OF_UpdateDrone;
        _droneObj setFuel 1;

        player sideChat (_drone + " repair and refueling complete.");
        ZEN_FMW_MP_REServerOnly("A3log", [(_drone + " repair and refueling complete.")], call)
        0 = [_nearestRR, "", (([_nearestRR] call Zen_OF_GetRepairRefuelData) select 3) - 1] call Zen_OF_UpdateRepairRefuel;

        _dataArray = [];
        {
            if ([(_x select 0), _drone] call Zen_ValuesAreEqual) exitWith {
                _dataArray = _x;
            };
        } forEach Zen_OF_DroneManagerData;

        _dataArray set [10, 5 + (_dataArray select 10)];
    };
} forEach _path;

if (toUpper (_waypointTypes select (count _path -1 )) != "LAND") then {
    _h_orbit = [_drone, _droneObj, _orbitRadius] spawn Zen_OF_OrderDroneOrbit;
    0 = [_drone, "", "", "", "", 0, "", "", "", "", "", "", "", _h_orbit] call Zen_OF_UpdateDrone;
};

player sideChat ("Move order for " + _drone + " complete.");
ZEN_FMW_MP_REServerOnly("A3log", ["Move order for " + _drone + " complete."], call)

{
    deleteMarker _x;
} forEach _markers;

call Zen_StackRemove;
if (true) exitWith {};
