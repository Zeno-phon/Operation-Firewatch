// Zen_OF_UpdateRepairRefuel

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_UpdateRepairRefuel", _this] call Zen_StackAdd;
private ["_nameString", "_max", "_current", "_dataArray", "_hasChanged"];

if !([_this, [["STRING"], ["STRING", "SCALAR"], ["STRING", "SCALAR"]], [], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_nameString = _this select 0;
_max = _this select 1;

ZEN_STD_Parse_GetArgumentDefault(_current, 2, "")

_dataArray = [];

{
    if ([(_x select 0), _nameString] call Zen_ValuesAreEqual) exitWith {
        _dataArray = _x;
    };
} forEach Zen_OF_RepairRefuel_Global;

if (count _dataArray == 0) exitWith {
    0 = ["Zen_OF_UpdateRepairRefuel", "Given repair and refuel point does not exist", _this] call Zen_PrintError;
    call Zen_StackPrint;
};

_hasChanged = false;
if (typeName _max == "SCALAR") then {
    _dataArray set [2, _max];
    _hasChanged = true;
};

if (typeName _current == "SCALAR") then {
    _dataArray set [3, _current];
    _hasChanged = true;
};

if (_hasChanged) then {
    publicVariable "Zen_OF_RepairRefuel_Global";
};

call Zen_StackRemove;
if (true) exitWith {};
