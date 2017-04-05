#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Operation Firewatch Demo
// For LT Eric S. Vorm, Indiana University
// Version = Alpha
// Tested with ArmA 3 1.66 Stable

/**  Each system has its own compile script that complies all function, initializes all variables, and declares any extra helper functions it needs.  They are compiled and called directly here using compileFinal so that they cannot be compiled or called again. */
call compileFinal preprocessFileLineNumbers "Zen_OF_Zones\Zen_OF_ZonesCompile.sqf";
call compileFinal preprocessFileLineNumbers "Zen_OF_Drones\Zen_OF_DronesCompile.sqf";
call compileFinal preprocessFileLineNumbers "Zen_OF_RepairRefuel\Zen_OF_RepairRefuelCompile.sqf";
call compileFinal preprocessFileLineNumbers "Zen_OF_Fires\Zen_OF_FiresCompile.sqf";

call compileFinal preprocessFileLineNumbers "oo_camera.sqf";

titleText ["Standby", "BLACK FADED", 0.4];
enableSaving [false, false];

// Airfield positions and landAt codes for Zen_OF_OrderDroneExecuteRoute to use
Zen_OF_Airfield_LandAt_Codes = [[[7137.6,7380.44,0.00143886], 0], [[2140.71,13350.6,17.8909], 1], [[11610.1,3158.68,0.00149488], 2], [[2200.59,3543.36,0.00143909], 3], [[11845,13163.9,0.00143909], 4]];

/**  Each drone is listed by classname along with their straight line cruise speed (m/s) and their loiter radius (m). */
Zen_OF_Drone_Class_Data = [["b_uav_01_f", 16, 300, 100], ["b_uav_02_f", 105, 300, 400]];

/**  This function encapsulates the process of retrieving the data in the above array.  This allows any function to obtain the parameters of the drone it's dealing with. */
Zen_F_GetDroneClassData = {
    private ["_droneObj", "_droneClassData"];

    // This is the actual in-game object, so that we can access it classname using typeOf
    _droneObj = _this select 0;

    // Zen_ArrayGetNestedValue is a generic array search function in the framework
    // It will return the first nested array that has the given value at the given index
   _droneClassData = [Zen_OF_Drone_Class_Data, typeOf _droneObj, 0] call Zen_ArrayGetNestedValue;

    // We check if there was any values to find
    if (count _droneClassData == 0) exitWith {
        ZEN_FMW_Code_ErrorExitValue("Zen_OF_FindDroneRouteData", "Given drone is of unknown type.", [])
    };

    ([_droneClassData, 1] call Zen_ArrayGetIndexedSlice)
};

// This will make the markers invisible during the briefing
// Since marker names are just strings, naming them sequentially in the editor allows scripts to loop over them easily
for "_i" from 1 to 21 do {
    ("AORLarge_" + str _i) setMarkerAlpha 0;
};

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
(random 1), // clockwise\anti-clockwise
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

// 0 - manual
// 1 - DOA-L
// 2 - DOA-H
Zen_OF_User_Group_Index = 2;

// Here we have the start of the log files
// The second argument is which log file to print to, with the default being the generic A3Log
["----------Start----------"] call A3log;
["Operation Firewatch Demo"] call A3log;
["Running " + str productVersion] call A3log;
["Running " + str productVersion, "Table"] call A3log;
[name player + " is a member of Group #" + str Zen_OF_User_Group_Index + "."] call A3log;

#include "Zen_OF_ConsentDialog.sqf"
titleText ["Standby", "BLACK FADED", 1.];

/**  Throughout the code, I will make ample use of the preprocessor.  SQF's preprocessor is very similar to C/C++; it is a copy-paste tool that prevents repeating blocks of code without having to make a new function.  It can also be used to copy-paste values that cannot be passed to a function.  These lines will copy-paste the entire contents of the files into this file, making them part of the init.sqf; this is handy for organizing long definitions of functions and variables into separate files. */
#include "Zen_OF_DroneDialog.sqf"
#include "Zen_OF_PermissionsDialog.sqf"
#include "Zen_OF_RoutePlanningDialog.sqf"
#include "Zen_OF_CameraGUI.sqf"

// debug
// 0 = ["Charlie_1", "test_EmptyObjectForFireBig"] call Zen_SpawnVehicle;

/**  This loop will initialize all markers into the zones system.  I am using nested arrays to provide all three parameters that are needed to setup each type of zone.  AAA is also spawned in Charlie zones.  Again I use the index of the inner loop to construct the marker names. */
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

/**  There is a variable for the player's knowledge of zones; this is not currently used. */
{
    Zen_OF_Zone_Knowledge_Local pushBack (_x select 0);
} forEach Zen_OF_Zones_Global;

/**  Here the first drone is created.  In this usage we give an existing object, Drone_Fixed_01, so the spawn point (player) isn't used.  We can also give the classname of a new vehicle to spawn.  Zen_OF_InvokeDrone always creates a drone (i.e. the data of the drone; the abstract drone object) local to the client that it was run on.  In SP this doesn't matter, but in MP Zen_OF_InvokeDrone must be run on the correct client's machine. */
_drone = [player, Drone_Fixed_01] call Zen_OF_InvokeDrone;

// The drone manager is started on all machines
// It will wait for drones to be created and automatically manage their fuel, fire scanning, etc.
ZEN_FMW_MP_REAll("Zen_OF_ManageDrones", [], spawn)

/**  Drones pathfind using their personal knowledge of zones; thus, the initial zone data must be copied to them as well. */
0 = [_drone, "", "", "", +Zen_OF_Zone_Knowledge_Local] call Zen_OF_UpdateDrone;

/**  This is the generation of the sample tabular data log file.  I 'spawn' a new thread so that will run in parallel (it's not simultaneous, but close enough) so the init can continue after this.. */
// 0 = [Drone_Fixed_01] spawn {
    // _drone = _this select 0;
    // ["Time, s     Speed, m/s,     Direction, deg", "Table"] call A3log;
    // while {true} do {
        // sleep 2;
        // [(str time + "      " + str (vectorMagnitude velocity _drone) + "        " + str getDir _drone), "Table"] call A3log;
    // };
// };

titleText ["", "BLACK FADED", 0.001];
call Zen_OF_DroneGUIInvoke;

// player sideChat "Player has been assigned 1 drone.";

// Here I provide the user access to the drone and permissions GUI
// player addAction ["Drone GUI", {call Zen_OF_DroneGUIInvoke}];
// player addAction ["Permissions GUI", {call Zen_OF_PermissionGUIInvoke}];

// A repair/refuel point is currently trivial
// Once created, everything is handled automatically by the systems
// This may be changed to assist with the drones' landing procedures
_rr = [player, 5] call Zen_OF_InvokeRepairRefuel;

// A test of the fire detection randomness
// for "_i" from 0 to 10 do {
    // _dist = 100 * _i;
    // _timeScale = 0.5 * 6;
    // _detectionProb = 1. / 2 - (1. / 2 - 1. / 60) * _dist / 1000.;

    // player sideChat str ((1. - _detectionProb) ^ _timeScale);
// };

/**  This block will assign an AOR and generate a fire within it every 10 minutes. */
0 = [] spawn {
    while {true} do {
        // We select an AOR at random and display it on the map
        _index = [1, 21, true] call Zen_FindInRange;
        _aor = "AORLarge_" + str _index;
        _aor setMarkerAlpha 1;

        // This icon highlights the AOR for the user
        player sideChat ("Player has been assigned AOR " + str _index);
        _icon = [_aor, "AOR " + str _index, "colorBlack", [1,1], "mil_marker"] call Zen_SpawnMarker;

        // /**
        // Here I have already provided some generalization
        // We are waiting for any drone to be inside the AOR
        waitUntil {
            _droneObjs = [];

            /**  Notice that I use Zen_OF_Drones_Local directly here, but what that variable is and how to use it does not appear in the documentation.  Normally, particularly with my framework, internal variables are private and should never be used directly; the framework provides public functions that make that unnecessary.  However, in a project like this, I will use internal variables wherever it is expedient, since all of the systems are tied together very closely to make the mission work. //*/
            // /**
            {
                _droneObjs pushBack (_x select 1);
            } forEach Zen_OF_Drones_Local;

            // ! Zen_AreNotInArea has become a staple of the framework, despite being confusing at first
            !([_droneObjs, _aor] call Zen_AreNotInArea)
        };
        // */

        // Since fires are defined by area markers, we create one at a random position within the AOR
        // This is the first use of Zen_FindGroundPosition, which is a very powerful tool
        // Here we are just using it to ensure that the fire is on land and not water
        0 = [[_aor] call Zen_FindGroundPosition] call Zen_OF_InvokeFire;

        // 10 minutes between fires
        sleep 60*10;
    };
};
