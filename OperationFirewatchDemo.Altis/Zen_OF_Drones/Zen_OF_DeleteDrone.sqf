// Zen_OF_DeleteDrone

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_DeleteDrone", _this] call Zen_StackAdd;
private ["_nameString", "_indexes"];

if !([_this, [["STRING"]], [], 1] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_nameString = _this select 0;
_indexes = [Zen_OF_Drones_Local, _nameString, 0] call Zen_ArrayGetNestedIndex;

if (count _indexes == 0) exitWith {
    ZEN_FMW_Code_ErrorExitVoid("Zen_OF_DeleteDrone", "Given drone does not exist")
};

_droneData = Zen_OF_Drones_Local select (_indexes select 0);
deleteVehicle (_droneData select 1);
terminate (_droneData select 4);
deleteMarker (_droneData select 6);
{
    deleteMarker _x;
} forEach (_droneData select 8);

0 = [Zen_OF_Drones_Local, (_indexes select 0)] call Zen_ArrayRemoveIndex;

call Zen_StackRemove;
if (true) exitWith {};
