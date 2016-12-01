// Zen_OF_FindDroneRoute

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_FindDroneRoute", _this] call Zen_StackAdd;
private ["_start", "_end", "_pathsArray"];

if !([_this, [["VOID"], ["VOID"]], [], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ([])
};

_start = [(_this select 0)] call Zen_ConvertToPosition;
_end = [(_this select 1)] call Zen_ConvertToPosition;

_path0 = [_start, [_start, (_start distance2D _end) / 2, [_start, _end] call Zen_FindDirection, "trig"] call Zen_ExtendVector, _end];
_pathsArray = [_path0];

call Zen_StackRemove;
(_pathsArray)
