#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Operation Firewatch by Zenophon
// For LT Eric S. Vorm, Indiana University
// Version = Alpha 11/28/16
// Tested with ArmA 3 1.64 Stable

call compileFinal preprocessFileLineNumbers "Zen_OF_Zones\Zen_OF_ZonesCompile.sqf";
call compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_DronesCompile.sqf";
call compileFinal preprocessFileLineNumbers "Zen_OF_RepairRefuel\Zen_OF_RepairRefuelCompile.sqf";

// titleText ["Good Luck", "BLACK FADED", 0.2];
enableSaving [false, false];

if (!isServer) exitWith {};
sleep 1;

["----------Start----------"] call A3log;

// Test creating a zone with one marker
_zone = ["A", ["mkTest", "mkTest2"]] call Zen_OF_InvokeZone;
player sideChat str ([_zone] call Zen_OF_GetZoneData);

// check if the player is in the zone
player sideChat str ([player, _zone] call Zen_OF_IsInZone);

// test updating the zone's type
0 = [_zone, "C"] call Zen_OF_UpdateZone;
player sideChat str ([_zone] call Zen_OF_GetZoneData);

// Spawn some AAA in the zone
// Here I set the density such that 2 AAA spawn
0 = [_zone, 1/ZEN_STD_Math_MarkerArea("mkTest"), "B_APC_Tracked_01_AA_F"] call Zen_OF_SpawnZoneAAA;
player sideChat str ([_zone] call Zen_OF_GetZoneData);

// This tests external management of the cached AAA
// They can be dealt with in other scripts just like any other cached objects
// See the framework's Cache System documentation and demonstration
// sleep 5;
0 = [([_zone] call Zen_OF_GetZoneData) select 3] call Zen_UnCache;
// sleep 5;

// Here the AAA should be deleted and the identifier removed from the data
// 0 = [_zone] call Zen_OF_DeleteZoneAAA;
player sideChat str ([_zone] call Zen_OF_GetZoneData);

player sideChat "Zones Test Complete";

_drone = [player, "o_uav_01_f"] call Zen_OF_InvokeDrone;
player sideChat str ([_drone] call Zen_OF_GetDroneData);

0 = [_drone, "", 0.31] call Zen_OF_UpdateDrone;
player sideChat str ([_drone] call Zen_OF_GetDroneData);

player sideChat "Drones Test Complete";

#include "Zen_OF_DroneDialog.sqf"

player addAction ["Drone GUI", {call Zen_OF_DroneGUIInvoke}];
player sideChat "Drone GUI added";

_rr = ["mkRTB", 3] call Zen_OF_InvokeRepairRefuel;
player sideChat str ([_rr] call Zen_OF_GetRepairRefuelData);

0 = [_rr, 2, 1] call Zen_OF_UpdateRepairRefuel;
player sideChat str ([_rr] call Zen_OF_GetRepairRefuelData);

0 = ["mkRTB", _rr] call Zen_SpawnMarker;

player sideChat "Repair/Refueling point Test Complete";

player sideChat "Drone manager thread started.";
ZEN_FMW_MP_REAll("Zen_OF_ManageDrones", [], spawn)
