// Zen_OF_IsInZone

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_IsInZone", _this] call Zen_StackAdd;
private ["_pos", "_nameString", "_data", "_isIn"];

if !([_this, [["VOID"], ["STRING"]], [], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    (false)
};

_pos = [_this select 0] call Zen_ConvertToPosition;
_nameString = _this select 1;

// we get the markers from here
_data = [_nameString] call Zen_OF_GetZoneData;

// and loop over each marker
// since being in any one marker counts as being in
// we use a logic that starts with false and sets the result to true if it passes one check
// using exitWith once the result is found is an easy optimization
_isIn = false;
{
    if ([_pos, _x] call Zen_IsPointInPoly) exitWith {
        _isIn = true;
    };
} forEach (_data select 2);

call Zen_StackRemove;
(_isIn)
