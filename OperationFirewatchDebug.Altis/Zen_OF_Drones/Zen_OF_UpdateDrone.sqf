// Zen_OF_UpdateDrone

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_UpdateDrone", _this] call Zen_StackAdd;
private ["_nameString", "_health", "_fuel", "_dataArray", "_zones", "_script", "_marker", "_pathMarkers", "_paths", "_currentPath", "_RTBArgs", "_GUIScript", "_autoConfirmScript", "_timer", "_orbitThread", "_waypoints"];

if !([_this, [["STRING"], ["STRING", "SCALAR"], ["STRING", "SCALAR"], ["SCRIPT", "STRING"], ["ARRAY", "STRING"], ["SCALAR", "STRING"], ["ARRAY", "STRING"], ["ARRAY", "STRING"], ["SCALAR", "STRING"], ["ARRAY", "STRING"], ["SCRIPT", "STRING"], ["SCRIPT", "STRING"], ["SCALAR", "STRING"], ["SCRIPT", "STRING"]], [[], [], [], [], ["STRING"], [], ["ARRAY"], ["STRING"]], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_nameString = _this select 0;
_health = _this select 1;

ZEN_STD_Parse_GetArgumentDefault(_fuel, 2, "")
ZEN_STD_Parse_GetArgumentDefault(_script, 3, "");
ZEN_STD_Parse_GetArgumentDefault(_zones, 4, "")
ZEN_STD_Parse_GetArgumentDefault(_marker, 5, 0)
ZEN_STD_Parse_GetArgumentDefault(_paths, 6, "")
ZEN_STD_Parse_GetArgumentDefault(_pathMarkers, 7, "")
ZEN_STD_Parse_GetArgumentDefault(_currentPath, 8, "")
ZEN_STD_Parse_GetArgumentDefault(_RTBArgs, 9, "")
ZEN_STD_Parse_GetArgumentDefault(_GUIScript, 10, "")
ZEN_STD_Parse_GetArgumentDefault(_autoConfirmScript, 11, "")
ZEN_STD_Parse_GetArgumentDefault(_timer, 12, "")
ZEN_STD_Parse_GetArgumentDefault(_orbitThread, 13, "")
ZEN_STD_Parse_GetArgumentDefault(_waypoints, 14, "")

_dataArray = [];

{
    if ([(_x select 0), _nameString] call Zen_ValuesAreEqual) exitWith {
        _dataArray = _x;
    };
} forEach Zen_OF_Drones_Local;

if (count _dataArray == 0) exitWith {
    ZEN_FMW_Code_ErrorExitVoid("Zen_OF_UpdateDrone", "Given drone does not exist")
};

if (typeName _health == "SCALAR") then {
    _dataArray set [2, _health];
};

if (typeName _fuel == "SCALAR") then {
    _dataArray set [3, _fuel];
};

if (typeName _script == "SCRIPT") then {
    _dataArray set [4, _script];
};

if (typeName _zones == "ARRAY") then {
    _dataArray set [5, _zones];
};

if (typeName _marker == "STRING") then {
    _dataArray set [6, _marker];
};

if (typeName _paths == "ARRAY") then {
    _dataArray set [7, _paths];
};

if (typeName _pathMarkers == "ARRAY") then {
    _dataArray set [8, _pathMarkers];
};

if (typeName _currentPath == "SCALAR") then {
    _dataArray set [9, _currentPath];
};

if (typeName _RTBArgs == "ARRAY") then {
    _dataArray set [10, _RTBArgs];
};

if (typeName _GUIScript == "SCRIPT") then {
    _dataArray set [11, _GUIScript];
};

if (typeName _autoConfirmScript == "SCRIPT") then {
    _dataArray set [12, _autoConfirmScript];
};

if (typeName _timer == "SCALAR") then {
    _dataArray set [13, _timer];
};

if (typeName _orbitThread == "SCRIPT") then {
    _dataArray set [14, _orbitThread];
};

if (typeName _waypoints == "ARRAY") then {
    _dataArray set [15, _waypoints];
};

call Zen_StackRemove;
if (true) exitWith {};
