// Zen_OF_OrderDroneExecuteRoute

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_OrderDroneExecuteRoute", _this] call Zen_StackAdd;
private ["_drone", "_path", "_droneData", "_isRTB", "_rr", "_markers", "_speed", "_h_orbit", "_droneClassData", "_orbitRadius"];

if !([_this, [["STRING"], ["ARRAY"], ["ARRAY"], ["BOOL"], ["STRING"]], [[], ["ARRAY"], ["STRING"]], 3] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_drone = _this select 0;
_path = _this select 1;
_markers = _this select 2;

ZEN_STD_Parse_GetArgumentDefault(_isRTB, 3, false)
ZEN_STD_Parse_GetArgumentDefault(_rr, 4, "")

_droneData = [_drone] call Zen_OF_GetDroneData;

_droneClassData = [(_droneData select 1)] call Zen_F_GetDroneClassData;
_speed = _droneClassData select 0;
_orbitRadius = _droneClassData select 1;

{
    (_droneData select 1) move _x;

    waitUntil {
        sleep 4;
        (unitReady (_droneData select 1)) || (((_droneData select 1) distance2D _x) < (_speed * 2));
    };
    ZEN_FMW_MP_REServerOnly("A3log", [_drone + " passing checkpoint at " + str _x], call)
} forEach _path;

_h_orbit = [_drone, (_droneData select 1), _orbitRadius] spawn Zen_OF_OrderDroneOrbit;
0 = [_drone, "", "", "", "", 0, "", "", "", "", "", "", "", _h_orbit] call Zen_OF_UpdateDrone;

if (_isRTB) then {
    ZEN_FMW_MP_REServerOnly("A3log", ["RTB order for " + _drone + " compete; standby repair/refuel."], call)
    0 = [_rr, "", (([_rr] call Zen_OF_GetRepairRefuelData) select 3) + 1] call Zen_OF_UpdateRepairRefuel;
    sleep 60*2;
    0 = [_drone, 1, 1] call Zen_OF_UpdateDrone;
    player sideChat (_drone + " repair and refueling complete.");
    0 = [_rr, "", (([_rr] call Zen_OF_GetRepairRefuelData) select 3) - 1] call Zen_OF_UpdateRepairRefuel;
} else {
    player sideChat (_drone + " move order complete.");
    ZEN_FMW_MP_REServerOnly("A3log", ["Move order for " + _drone + " complete."], call)
};

{
    deleteMarker _x;
} forEach _markers;

call Zen_StackRemove;
if (true) exitWith {};
