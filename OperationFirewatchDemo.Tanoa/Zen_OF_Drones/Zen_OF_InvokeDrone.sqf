// Zen_OF_InvokeDrone

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_InvokeDrone", _this] call Zen_StackAdd;
private ["_pos", "_class", "_nameString", "_obj", "_orbitRadius", "_droneClassData", "_h_orbit"];

if !([_this, [["VOID"], ["STRING", "OBJECT"]], [], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ("")
};

_pos = [(_this select 0)] call Zen_ConvertToPosition;
_class = _this select 1;

if (typeName _class == "STRING") then {
    _obj = [_pos, _class, 100] call Zen_SpawnAircraft;
} else {
    _obj = _class;
};

_nameString = format ["Zen_OF_Drone_%1",([4, "Numeric"] call Zen_StringGenerateRandom)];

_h_orbit = scriptNull;
if (ZEN_STD_OBJ_ATLPositionZ(_obj) > 5) then {
    _droneClassData = [_obj] call Zen_OF_GetDroneClassData;
    // _speed = _droneClassData select 0;
    _orbitRadius = _droneClassData select 1;

    _h_orbit = [_nameString, _pos, _orbitRadius] spawn Zen_OF_OrderDroneOrbit;
};

Zen_OF_Drones_Local pushBack [_nameString, _obj, 1, 1, scriptNull, [], "", [], [], 0, [], scriptNull, scriptNull, 0, _h_orbit, [], []];
publicVariable "Zen_OF_Drones_Local";

call Zen_StackRemove;
(_nameString)
