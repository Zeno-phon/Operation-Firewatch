// Zen_OF_InvokeFire

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_InvokeZone", _this] call Zen_StackAdd;
private ["_markers", "_nameString"];

if !([_this, [["ARRAY"]], [["STRING"]], 1] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ("")
};

_markers = _this select 0;

_nameString = format ["Zen_OF_Fire_%1",([10] call Zen_StringGenerateRandom)];

Zen_OF_Fires_Global pushBack [_nameString, _markers];
publicVariable "Zen_OF_Fires_Global";

call Zen_StackRemove;
(_nameString)
