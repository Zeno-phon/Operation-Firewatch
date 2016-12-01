// Zen_OF_InvokeDrone

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_InvokeDrone", _this] call Zen_StackAdd;
private ["_pos", "_class", "_nameString", "_obj"];

if !([_this, [["VOID"], ["STRING"]], [], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ("")
};

_pos = [(_this select 0)] call Zen_ConvertToPosition;
_class = _this select 1;

_obj = [_pos, _class, 100] call Zen_SpawnAircraft;

_nameString = format ["Zen_OF_Drone_%1",([10] call Zen_StringGenerateRandom)];

Zen_OF_Drones_Local pushBack [_nameString, _obj, 1, 1, scriptNull, [], "", [], [], 0, []];
publicVariable "Zen_OF_Drones_Local";

call Zen_StackRemove;
(_nameString)
