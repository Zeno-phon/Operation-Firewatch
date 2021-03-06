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

Zen_OF_Airfield_LandAt_Codes = [[[7137.6,7380.44,0.00143886], 0], [[2140.71,13350.6,17.8909], 1], [[11610.1,3158.68,0.00149488], 2], [[2200.59,3543.36,0.00143909], 3], [[11845,13163.9,0.00143909], 4]];
Zen_OF_Drone_Class_Data = [["b_uav_01_f", 16, 300, 100], ["b_uav_02_f", 105, 300, 400]];

Zen_F_GetDroneClassData = {
    private ["_droneObj", "_droneClassData"];

    _droneObj = _this select 0;
   _droneClassData = [Zen_OF_Drone_Class_Data, typeOf _droneObj, 0] call Zen_ArrayGetNestedValue;

    if (count _droneClassData == 0) exitWith {
        ZEN_FMW_Code_ErrorExitValue("Zen_OF_FindDroneRouteData", "Given drone is of unknown type.", [])
    };

    ([_droneClassData, 1] call Zen_ArrayGetIndexedSlice)
};

#define LINES_PER_BOX 9
#define CHAR_PER_LINE 37
#define SCROLL_INTERVAL 0.4
#define FONT_START "<t size='0.74'><t color='#000000'><t font='LucidaConsoleB'>"
#define FONT_END "</t></t></t>"
#define LINE_BREAK "<br/>"

Zen_OF_Message_Stack = [];
Zen_OF_Message_Stack_Scroll_Index = 0;
Zen_OF_LastScrollTime = 0.;

// for "_i" from 1 to LINES_PER_BOX do {
    // Zen_OF_Message_Stack pushBack (FONT_START + LINE_BREAK + FONT_END);
// };

Zen_OF_PrintMessage = {
    _rawString = _this select 0;
    _rawArr = toArray _rawString;

    _linesArrArr = [];
    _i = 0;
    while {_i <= (count _rawArr - CHAR_PER_LINE - 1)} do {
        _linesArrArr pushBack ([_rawArr, _i, _i + CHAR_PER_LINE - 1] call Zen_ArrayGetIndexedSlice);
        _i = _i + CHAR_PER_LINE;
    };
    _linesArrArr pushBack ([_rawArr, _i] call Zen_ArrayGetIndexedSlice);

    _linesArrString = [];
    {
        _linesArrString pushBack (FONT_START + toString _x + LINE_BREAK + FONT_END);
    } forEach _linesArrArr;

    // player commandChat str _linesArrString;
    Zen_OF_Message_Stack append _linesArrString;

    #define GET_MESSAGE \
    _messageStringArr = []; \
    for "_i" from ((count Zen_OF_Message_Stack - LINES_PER_BOX) max 0) to (count Zen_OF_Message_Stack - 1) step 1 do { \
        _messageStringArr pushBack (Zen_OF_Message_Stack select (_i - Zen_OF_Message_Stack_Scroll_Index)); \
    }; \
    _messageString = ""; \
    { \
        _messageString = _messageString + _x; \
    } forEach _messageStringArr;

    GET_MESSAGE
    0 = [Zen_OF_GUIMessageBox, ["Text", _messageString]] call Zen_UpdateControl;
    [] call Zen_RefreshDialog;
    if (true) exitWith {};
};

Zen_OF_ScrollMessage = {
    // player commandChat str _this;
    _scrollMag = (_this select 0) select 0;

    if (_scrollMag > 0) then {
        Zen_OF_Message_Stack_Scroll_Index = (Zen_OF_Message_Stack_Scroll_Index + 1) min (count Zen_OF_Message_Stack - LINES_PER_BOX);
    } else {
        Zen_OF_Message_Stack_Scroll_Index = (Zen_OF_Message_Stack_Scroll_Index - 1) max 0;
    };

    if (Zen_OF_LastScrollTime + SCROLL_INTERVAL < time) then {
        GET_MESSAGE
        Zen_OF_LastScrollTime = time;
        0 = [Zen_OF_GUIMessageBox, ["Text", _messageString]] call Zen_UpdateControl;
        0 = [0, [Zen_OF_GUIMessageBox], "Else"] call Zen_RefreshDialog;
    };
};

if (!isServer) exitWith {};
sleep 1;

// 0 - manual
// 1 - DOA-L
// 2 - DOA-H
Zen_OF_User_Group_Index = 0;

["----------Start----------"] call A3log;
["Operation Firewatch Debug"] call A3log;
["Running " + str productVersion] call A3log;
// ["Running " + str productVersion, "Table"] call A3log;
[name player + " is a member of Group #" + str Zen_OF_User_Group_Index + "."] call A3log;

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

_obj = ["mkFire", "c_plane_civil_01_f", 100] call Zen_SpawnAircraft;
0 = [[_obj], "none", 0, 1] call Zen_TrackVehicles;

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

#include "Zen_OF_CameraGUI.sqf"
