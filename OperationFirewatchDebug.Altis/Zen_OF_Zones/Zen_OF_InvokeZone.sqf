// Zen_OF_InvokeZone

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_InvokeZone", _this] call Zen_StackAdd;
private ["_type", "_markers", "_nameString"];

if !([_this, [["STRING"], ["ARRAY"]], [[], ["STRING"]], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ("")
};

_type = _this select 0;
_markers = _this select 1;

// We generate a unique string identifier
// this will be used to match a specific zone to its data later
_nameString = format ["Zen_OF_Zone_%1",([10] call Zen_StringGenerateRandom)];

// ignore the fourth element for now, Zen_OF_SpawnZoneAAA and Zen_OF_DeleteZoneAAA will deal with that
Zen_OF_Zones_Global pushBack [_nameString, _type, _markers, "", [], 0, false, ""];

// this function is only used internally to approximate the zone's coverage everytime it changes
0 = [_nameString] call Zen_OF_GenerateZoneHeuristic;

// the zone system is designed to be managed from the server and propagated to all the clients
// The zones will be the same on all clients and they will have access to all its data and functions
publicVariable "Zen_OF_Zones_Global";

call Zen_StackRemove;
(_nameString)
