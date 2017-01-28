// Zen_OF_OrderDroneOrbit

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_OrderDroneOrbit", _this] call Zen_StackAdd;
private ["_drone", "_center", "_radius", "_droneData", "_orbitPoints", "_dPhi", "_speed", "_i"];

if !([_this, [["STRING"], ["VOID"], ["SCALAR"]], [], 3] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

sleep 1;

_drone = _this select 0;
_center = [(_this select 1)] call Zen_ConvertToPosition;
_radius = _this select 2;

_droneData = [_drone] call Zen_OF_GetDroneData;

_orbitPoints = [];
_dPhi = 180 - 135;

for "_phi" from 0 to (360 - _dPhi) step _dPhi do {
    _orbitPoints pushBack ([_center, _radius, _phi] call Zen_ExtendVector);
};

_speed = [Zen_OF_Drone_Speeds, typeOf (_droneData select 1), 0] call Zen_ArrayGetNestedValue;

if (count _speed == 0) exitWith {
    ZEN_FMW_Code_ErrorExitValue("Zen_OF_FindDroneRouteData", "Given drone is of unknown type.", [])
};

_speed = _speed select 1;

ZEN_FMW_MP_REServerOnly("A3log", [_drone + " is orbiting " + str _center + " with radius " + str _radius], call)
_i = 0;
while {true} do {
    (_droneData select 1) move (_orbitPoints select _i);

    waitUntil {
        sleep 4;
        (unitReady (_droneData select 1)) || (((_droneData select 1) distance2D (_orbitPoints select _i)) < (_speed * 2));
    };

    _i = _i + 1;
    _i = _i % (count _orbitPoints);
};

call Zen_StackRemove;
if (true) exitWith {};
