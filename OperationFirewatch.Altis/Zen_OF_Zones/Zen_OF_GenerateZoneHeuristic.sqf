// Zen_OF_GenerateZoneHeuristic

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_GenerateZoneHeuristic", _this] call Zen_StackAdd;
private ["_nameString", "_center", "_markers", "_dataArray", "_isIn", "_maxRadius"];

if !([_this, [["STRING"]], [], 1] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_nameString = _this select 0;

_dataArray = [];
{
    if ([(_x select 0), _nameString] call Zen_ValuesAreEqual) exitWith {
        _dataArray = _x;
    };
} forEach Zen_OF_Zones_Global;

if (count _dataArray == 0) exitWith {
    ZEN_FMW_Code_ErrorExitVoid("Zen_OF_GenerateZoneHeuristic", "Given zone does not exist")
};

_markers = _dataArray select 2;

_center = [_markers] call Zen_FindCenterPosition;
for "_r" from 1 to 10000 step 25 do {
    _isIn = false;
    for "_phi" from 0 to 330 step 30 do {
        if ([([_center, _r, _phi, "trig"] call Zen_ExtendVector), _nameString] call Zen_OF_IsInZone) exitWith {
            _isIn = true;
        };
    };
    if !(_isIn) exitWith {
        _maxRadius = _r;
    };
};

_dataArray set [4, _center];
_dataArray set [5, _maxRadius];

// publicVariable "Zen_OF_Zones_Global";

call Zen_StackRemove;
if (true) exitWith {};
