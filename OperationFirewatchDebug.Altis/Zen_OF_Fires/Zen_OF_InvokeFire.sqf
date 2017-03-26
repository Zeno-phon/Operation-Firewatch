// Zen_OF_InvokeFire

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_InvokeZone", _this] call Zen_StackAdd;
private ["_center", "_nameString"];

if !([_this, [["VOID"]], [], 1] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ("")
};

_center = [_this select 0] call Zen_ConvertToPosition;

_nameString = format ["Zen_OF_Fire_%1",([10] call Zen_StringGenerateRandom)];

Zen_OF_Fires_Global pushBack [_nameString, _center];
publicVariable "Zen_OF_Fires_Global";

ZEN_FMW_MP_REServerOnly("A3log", ["Fire " + _nameString + " created at " + str _center], call)
0 = [_center, "test_EmptyObjectForFireBig"] call Zen_SpawnVehicle;

call Zen_StackRemove;
(_nameString)
