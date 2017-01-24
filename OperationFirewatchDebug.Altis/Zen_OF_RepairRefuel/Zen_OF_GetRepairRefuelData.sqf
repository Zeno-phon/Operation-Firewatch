// Zen_OF_GetRepairRefuelData

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_GetRepairRefuelData", _this] call Zen_StackAdd;
private ["_dataArray", "_nameString"];

if !([_this, [["STRING"]], [], 1] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ([])
};

_nameString = _this select 0;
_dataArray = [];

{
    if ([(_x select 0), _nameString] call Zen_ValuesAreEqual) exitWith {
        _dataArray =+ _x;
    };
} forEach Zen_OF_RepairRefuel_Global;

if (count _dataArray == 0) then {
    0 = ["Zen_OF_GetRepairRefuelData", "Given repair and refuel point does not exist", _this] call Zen_PrintError;
    call Zen_StackPrint;
};

call Zen_StackRemove;
(_dataArray)
