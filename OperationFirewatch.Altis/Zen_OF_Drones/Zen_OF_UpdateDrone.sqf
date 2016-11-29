// Zen_OF_UpdateDrone

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_UpdateDrone", _this] call Zen_StackAdd;
private ["_nameString", "_health", "_fuel", "_dataArray", "_zones"];

if !([_this, [["STRING"], ["STRING", "SCALAR"], ["STRING", "SCALAR"], ["ARRAY", "STRING"]], [[], [], [], ["STRING"]], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_nameString = _this select 0;
_health = _this select 1;

ZEN_STD_Parse_GetArgumentDefault(_fuel, 2, "")
ZEN_STD_Parse_GetArgumentDefault(_zones, 3, "")

_dataArray = [];

{
    if ([(_x select 0), _nameString] call Zen_ValuesAreEqual) exitWith {
        _dataArray = _x;
    };
} forEach Zen_OF_Drones_Local;

if (count _dataArray == 0) exitWith {
    0 = ["Zen_OF_UpdateDrone", "Given zone does not exist", _this] call Zen_PrintError;
    call Zen_StackPrint;
};

if (typeName _health == "SCALAR") then {
    _dataArray set [2, _health];
};

if (typeName _fuel == "SCALAR") then {
    _dataArray set [3, _fuel];
};

if (typeName _zones == "ARRAY") then {
    _dataArray set [5, _zones];
};

call Zen_StackRemove;
if (true) exitWith {};
