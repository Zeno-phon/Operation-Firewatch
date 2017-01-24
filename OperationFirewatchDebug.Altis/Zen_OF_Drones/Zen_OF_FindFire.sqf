// Zen_OF_FindFire

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_FindFire", _this] call Zen_StackAdd;
private ["_drone", "_fires"];

if !([_this, [["STRING"]], [], 1] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ([])
};

_drone = _this select 0;
_droneData = [_drone] call Zen_OF_GetDroneData;

_fires = [];

{
    _markers = _x select 1;
    _center = [_markers] call Zen_FindCenterPosition;

    if (((_droneData select 1) distance2D _center) < 300) then {
        _fires pushBack [(_x select 0), _center];
    };
} forEach Zen_OF_Fires_Global;

call Zen_StackRemove;
(_fires)
