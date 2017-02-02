// Zen_OF_GetDroneData

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_GetDroneData", _this] call Zen_StackAdd;
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
} forEach Zen_OF_Drones_Local;

if (count _dataArray == 0) then {
    ZEN_FMW_Code_Error("Zen_OF_GetDroneData", "Given drone does not exist.")
};

call Zen_StackRemove;
(_dataArray)
