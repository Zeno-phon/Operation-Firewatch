// Zen_OF_UpdateZone

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_UpdateZone", _this] call Zen_StackAdd;
private ["_nameString", "_type", "_markers", "_dataArray", "_hasChanged"];

if !([_this, [["STRING"], ["STRING", "SCALAR"], ["ARRAY", "SCALAR"]], [[], [], ["STRING"]], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_nameString = _this select 0;
_type = _this select 1;

// An easy way to get an optional parameter
ZEN_STD_Parse_GetArgumentDefault(_markers, 2, 0)

_dataArray = [];

// a repeat of the Zen_OF_GetZoneData search algorithm
// this time we do not take a copy of the data ('=+') but rather a reference to it ('=')
{
    if ([(_x select 0), _nameString] call Zen_ValuesAreEqual) exitWith {
        _dataArray = _x;
    };
} forEach Zen_OF_Zones_Global;

if (count _dataArray == 0) exitWith {
    ZEN_FMW_Code_ErrorExitVoid("Zen_OF_UpdateZone", "Given zone does not exist")
};

_hasChanged = false;
// We allow the option to skip the type by entering an incompatible type on purpose
if (typeName _type == "STRING") then {
    _hasChanged = true;
    _dataArray set [1, _type];
};

if (typeName _markers == "ARRAY") then {
    _hasChanged = true;
    _dataArray set [2, _markers];
    0 = [_nameString] call Zen_OF_GenerateZoneHeuristic;
};

// this is an optimization to reduce network traffic
if (_hasChanged) then {
    publicVariable "Zen_OF_Zones_Global";
};

call Zen_StackRemove;
if (true) exitWith {};
