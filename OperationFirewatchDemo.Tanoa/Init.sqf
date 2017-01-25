#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Operation Firewatch Demo
// For LT Eric S. Vorm, Indiana University
// Version = Alpha
// Tested with ArmA 3 1.66 Stable

call compileFinal preprocessFileLineNumbers "Zen_OF_Zones\Zen_OF_ZonesCompile.sqf";
call compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_DronesCompile.sqf";
call compileFinal preprocessFileLineNumbers "Zen_OF_RepairRefuel\Zen_OF_RepairRefuelCompile.sqf";
call compileFinal preprocessFileLineNumbers "Zen_OF_Fires\Zen_OF_FiresCompile.sqf";

call compileFinal preprocessFileLineNumbers "oo_camera.sqf";

// titleText ["Good Luck", "BLACK FADED", 0.2];
enableSaving [false, false];

Zen_OF_Drone_Speeds = [["b_uav_01_f", 16], ["b_uav_02_f", 105]];

if (!isServer) exitWith {};
sleep 1;

/**
#define BUL_UAVintro_Text "OPERATION FIREWATCH"
private ["_colorWest", "_colorEast"];
_colorWest = [west] call BIS_fnc_sideColor;
_colorEast = [east] call BIS_fnc_sidecolor;
starts the UAV orbiting above
[getMarkerPos "BIS_establishingShot_center", // need to create a marker called BIS_establishingShot_center
BUL_UAVintro_Text, // spawns the text
250, // height
500, // radius
5, // angle
(random 1), // clockwise\anit-clock
[["\A3\ui_f\data\map\mapcontrol\Transmitter_CA.paa", _colorEast, getmarkerpos "BIS_establishingShot_center",  1, 1, 0, "ALERT! Fire detected in 03W 25.5N", 0]],0] call BIS_fnc_establishingShot;
// */

/* Assign UAVs already on the map*/
/**
uav1 = missionNamespace getVariable ["ORBIT1", objNull];
uav2 = missionNamespace getVariable ["ORBIT2", objNull];
uav3 = missionNamespace getVariable ["ORBIT3", objNull];
uav4 = missionNamespace getVariable ["ORBIT4", objNull];
uav5 = missionNamespace getVariable ["ORBIT5", objNull];
uav6 = missionNamespace getVariable ["ORBIT6", objNull];
uav7 = missionNamespace getVariable ["ORBIT7", objNull];
uav8 = missionNamespace getVariable ["ORBIT8", objNull];
uav9 = missionNamespace getVariable ["ORBIT9", objNull];
////
// OO Camera Script by Code34 //
// Used to stream feeds to in-game monitors //
// edited for use by rustic4-1 //
////

sleep 2;
_cam1 = ["new", []] call OO_CAMERA;
    ["backcamera", uav1] spawn _cam1;
    ["r2o", screen1] call _cam1;
    ["setPipEffect", [0]] call _cam1;
    //
_cam2 = ["new", []] call OO_CAMERA;
    ["backCamera", uav2] spawn _cam2;
    ["r2o", screen2] call _cam2;
    ["setPipEffect", [0]] call _cam2;
    //
_cam3 = ["new", []] call OO_CAMERA;
    ["backcamera", uav3] spawn _cam3;
    ["r2o", screen3] call _cam3;
    ["setPipEffect", [0]] call _cam3;
    //
_cam4 = ["new", []] call OO_CAMERA;
    ["backcamera", uav4] spawn _cam4;
    ["r2o", screen4] call _cam4;
    ["setPipEffect", [0]] call _cam4;
    //
_cam5 = ["new", []] call OO_CAMERA;
    ["backcamera", uav5] spawn _cam5;
    ["r2o", screen5] call _cam5;
    ["setPipEffect", [0]] call _cam5;
//
_cam6 = ["new", []] call OO_CAMERA;
    ["backcamera", uav6] spawn _cam6;
    ["r2o", screen_6] call _cam6;
    ["setPipEffect", [0]] call _cam6;
    //
_cam7 = ["new", []] call OO_CAMERA;
    ["backcamera", uav7] spawn _cam7;
    ["r2o", screen7] call _cam7;
    ["setPipEffect", [0]] call _cam7;
    //
_cam8 = ["new", []] call OO_CAMERA;
    ["backcamera", uav8] spawn _cam8;
    ["r2o", screen8] call _cam8;
    ["setPipEffect", [0]] call _cam8;
    //
_cam9 = ["new", []] call OO_CAMERA;
    ["backcamera", uav9] spawn _cam9;
    ["r2o", screen_9] call _cam9;
    ["setPipEffect", [0]] call _cam9;
//*/

// if (random 1 > 0.5) then {
    Zen_OF_User_Is_Group_Two = false;
// };

#include "Zen_OF_DroneDialog.sqf"
#include "Zen_OF_PermissionsDialog.sqf"
#include "Zen_OF_RoutePlanningDialog.sqf"

["----------Start----------"] call A3log;
["Operation Firewatch Demo"] call A3log;
["Running " + str productVersion] call A3log;
[name player + " is a member of Group #" + (if (Zen_OF_User_Is_Group_Two) then {("2")} else {("1")}) + "."] call A3log;

// debug
// 0 = ["Charlie_1", "test_EmptyObjectForFireBig"] call Zen_SpawnVehicle;

for "_i" from 1 to 21 do {
    ("AORLarge_" + str _i) setMarkerAlpha 0;
};

{
    _type = _x select 0;
    _prefix = _x select 1;
    _count = _x select 2;

    for "_i" from 1 to _count do {
        _zone = [_type, [_prefix + str _i]] call Zen_OF_InvokeZone;

        if (_type == "C") then {
            0 = [_zone, 1/ZEN_STD_Math_MarkerArea((_prefix + str _i)), "O_APC_Tracked_02_AA_F"] call Zen_OF_SpawnZoneAAA;
        };
    };
} forEach [["A", "ALPHA_", 6], ["B", "BRAVO_", 13], ["C", "CHARLIE_", 5]];

{
    Zen_OF_Zone_Knowledge_Local pushBack (_x select 0);
} forEach Zen_OF_Zones_Global;

ZEN_FMW_MP_REAll("Zen_OF_ManageDrones", [], spawn)

_drone = [player, "b_uav_02_f"] call Zen_OF_InvokeDrone;

player sideChat "Player has been assigned 1 drone.";

PC addAction ["Drone GUI", {call Zen_OF_DroneGUIInvoke}];
PC addAction ["Permissions GUI", {call Zen_OF_PermissionGUIInvoke}];

player addAction ["Drone GUI", {call Zen_OF_DroneGUIInvoke}];
player addAction ["Permissions GUI", {call Zen_OF_PermissionGUIInvoke}];

_rr = [player, 5] call Zen_OF_InvokeRepairRefuel;

0 = [] spawn {
    _index = [1, 21, true] call Zen_FindInRange;
    _aor = "AORLarge_" + str _index;
    _aor setMarkerAlpha 1;

    player sideChat ("Player has been assigned AOR " + str _index);
    _icon = [_aor, "AOR " + str _index, "colorBlack", [1,1], "mil_marker"] call Zen_SpawnMarker;

    waitUntil {
        _droneObjs = [];
        {
            _droneObjs pushBack (([_x select 0] call Zen_OF_GetDroneData) select 1);
        } forEach Zen_OF_Drones_Local;

        !([_droneObjs, _aor] call Zen_AreNotInArea)
    };

    _fireArea = [[_aor] call Zen_FindGroundPosition, "", "colorBlack", [10,10], "ellipse", 0, 0] call Zen_SpawnMarker;
    0 = [[_fireArea]] call Zen_OF_InvokeFire;
};
