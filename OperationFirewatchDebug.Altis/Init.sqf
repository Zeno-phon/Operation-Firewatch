#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Operation Firewatch Debug by Zenophon
// For LT Eric S. Vorm, Indiana University
// Version = Alpha
// Tested with ArmA 3 1.66 Stable

call compileFinal preprocessFileLineNumbers "Zen_OF_Zones\Zen_OF_ZonesCompile.sqf";
call compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_DronesCompile.sqf";
call compileFinal preprocessFileLineNumbers "Zen_OF_RepairRefuel\Zen_OF_RepairRefuelCompile.sqf";
call compileFinal preprocessFileLineNumbers "Zen_OF_Fires\Zen_OF_FiresCompile.sqf";

// titleText ["Good Luck", "BLACK FADED", 0.2];
enableSaving [false, false];

Zen_OF_Drone_Speeds = [["b_uav_01_f", 16], ["b_uav_02_f", 105]];

if (!isServer) exitWith {};
sleep 1;

// if (random 1 > 0.5) then {
    Zen_OF_User_Is_Group_Two = false;
// };

["----------Start----------"] call A3log;
["Running " + str productVersion] call A3log;
[name player + " is a member of Group #" + (if (Zen_OF_User_Is_Group_Two) then {("2")} else {("1")}) + "."] call A3log;

// Test creating a zone with one marker
_zone = ["A", ["mkTest"]] call Zen_OF_InvokeZone;
_zone = ["A", ["mkTest2"]] call Zen_OF_InvokeZone;
player commandChat str ([_zone] call Zen_OF_GetZoneData);

// check if the player is in the zone
player commandChat str ([player, _zone] call Zen_OF_IsInZone);

// test updating the zone's type
0 = [_zone, "C"] call Zen_OF_UpdateZone;
player commandChat str ([_zone] call Zen_OF_GetZoneData);

// Spawn some AAA in the zone
// Here I set the density such that 2 AAA spawn
0 = [_zone, 1/ZEN_STD_Math_MarkerArea("mkTest"), "O_APC_Tracked_02_AA_F"] call Zen_OF_SpawnZoneAAA;
player commandChat str ([_zone] call Zen_OF_GetZoneData);

// This tests external management of the cached AAA
// They can be dealt with in other scripts just like any other cached objects
// See the framework's Cache System documentation and demonstration
// sleep 5;
0 = [([_zone] call Zen_OF_GetZoneData) select 3] call Zen_UnCache;
// sleep 5;

// Here the AAA should be deleted and the identifier removed from the data
// 0 = [_zone] call Zen_OF_DeleteZoneAAA;
player commandChat str ([_zone] call Zen_OF_GetZoneData);

{
    Zen_OF_Zone_Knowledge_Local pushBack (_x select 0);
} forEach Zen_OF_Zones_Global;

player commandChat "Zones Test Complete";

_drone = [player, "b_uav_01_f"] call Zen_OF_InvokeDrone;
player commandChat str ([_drone] call Zen_OF_GetDroneData);

0 = [_drone, "", 0.5, "", +Zen_OF_Zone_Knowledge_Local] call Zen_OF_UpdateDrone;
player commandChat str ([_drone] call Zen_OF_GetDroneData);

_drone = [player, "b_uav_02_f"] call Zen_OF_InvokeDrone;

/** Drone speed test
_droneData = [_drone] call Zen_OF_GetDroneData;
_droneObj = _droneData select 1;
0 = [_droneObj] spawn {
    while {true} do {
        sleep 2;
        player commandChat str vectorMagnitude velocity (_this select 0);
    };
};
//*/

player commandChat "Drones Test Complete";

#include "Zen_OF_DroneDialog.sqf"
player addAction ["Drone GUI", {call Zen_OF_DroneGUIInvoke}];
player commandChat "Drone GUI added";

_rr = ["mkRTB", 3] call Zen_OF_InvokeRepairRefuel;
player commandChat str ([_rr] call Zen_OF_GetRepairRefuelData);

0 = [_rr, 2, 1] call Zen_OF_UpdateRepairRefuel;
player commandChat str ([_rr] call Zen_OF_GetRepairRefuelData);

0 = ["mkRTB", _rr] call Zen_SpawnMarker;
player commandChat "Repair/Refueling point Test Complete";

player commandChat "Drone manager thread started.";
ZEN_FMW_MP_REAll("Zen_OF_ManageDrones", [], spawn)

_fire = [["mkFire"]] call Zen_OF_InvokeFire;
player commandChat str ([_fire] call Zen_OF_GetFireData);
player commandChat "Fire system test complete.";

#include "Zen_OF_PermissionsDialog.sqf"
player addAction ["Permissions GUI", {call Zen_OF_PermissionGUIInvoke}];
player commandChat "Permissions GUI added";

#include "Zen_OF_RoutePlanningDialog.sqf"
// player addAction ["Permissions GUI", {call Zen_OF_PermissionGUIInvoke}];
player commandChat "Route Planning GUI added";
