// Zen_OF_OrderDroneExecuteRoute

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_OrderDroneExecuteRoute", _this] call Zen_StackAdd;
private ["_drone", "_path", "_droneData", "_isRTB", "_rr", "_markers"];

if !([_this, [["STRING"], ["ARRAY"], ["ARRAY"], ["BOOL"], ["STRING"]], [[], ["ARRAY"], ["STRING"]], 3] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_drone = _this select 0;
_path = _this select 1;
_markers = _this select 2;

ZEN_STD_Parse_GetArgumentDefault(_isRTB, 3, false)
ZEN_STD_Parse_GetArgumentDefault(_rr, 4, "")

_droneData = [_drone] call Zen_OF_GetDroneData;

{
    (_droneData select 1) move _x;

    waitUntil {
        sleep 5;
        (unitReady (_droneData select 1)) || (((_droneData select 1) distance2D _x) < 25);
    };
    ZEN_FMW_MP_REServerOnly("A3log", [_drone + " passing checkpoint at " + str _x], call)
} forEach _path;

if (_isRTB) then {
    ZEN_FMW_MP_REServerOnly("A3log", ["RTB order for " + _drone + " compete; standby repair/refuel."], call)
    0 = [_rr, "", (([_rr] call Zen_OF_GetRepairRefuelData) select 3) + 1] call Zen_OF_UpdateRepairRefuel;
    sleep 5;
    0 = [_drone, 1, 1] call Zen_OF_UpdateDrone;
    player sideChat (_drone + " repair and refueling complete.");
    0 = [_rr, "", (([_rr] call Zen_OF_GetRepairRefuelData) select 3) - 1] call Zen_OF_UpdateRepairRefuel;
} else {
    ZEN_FMW_MP_REServerOnly("A3log", ["Move order for " + _drone + " complete."], call)
    player sideChat (_drone + " move order complete.");
};

{
    deleteMarker _x;
} forEach _markers;

call Zen_StackRemove;
if (true) exitWith {};
