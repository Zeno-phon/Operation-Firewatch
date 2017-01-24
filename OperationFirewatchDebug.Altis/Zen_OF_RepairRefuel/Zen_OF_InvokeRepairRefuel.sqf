// Zen_OF_InvokeRepairRefuel

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_InvokeRepairRefuel", _this] call Zen_StackAdd;
private ["_pos", "_max", "_nameString"];

if !([_this, [["VOID"], ["SCALAR"]], [], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ("")
};

_pos = [(_this select 0)] call Zen_ConvertToPosition;
_max = _this select 1;

_nameString = format ["Zen_OF_RepairRefuel_%1",([10] call Zen_StringGenerateRandom)];

Zen_OF_RepairRefuel_Global pushBack [_nameString, _pos, _max, 0];
publicVariable "Zen_OF_RepairRefuel_Global";

call Zen_StackRemove;
(_nameString)
