//

#include "Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

#define SHOW_FULL_PATH_INFO_FOR_MANUAL false

Zen_OF_RouteGUIRefresh = {
    _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;

    _list = [];
    _listData = [];
    {
        _list pushBack (str (_forEachIndex + 1) + "  (" + ((_droneData select 15) select _forEachIndex) + ")");
        _listData pushBack _forEachIndex;
    } forEach ((_droneData select 7) select (_droneData select 9));

    // player sideChat str _list;
    0 = [Zen_OF_RouteGUIList, ["List", _list], ["ListData", _listData]] call Zen_UpdateControl;
    [] call Zen_RefreshDialog;
};

Zen_OF_RouteGUIInvoke = {
    _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
    0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, [[]], [], 0] call Zen_OF_UpdateDrone;

    _list = [];
    _listData = [];
    0 = [Zen_OF_RouteGUIList, ["List", _list], ["ListData", _listData]] call Zen_UpdateControl;

    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has opened manual route planning GUI for " + Zen_OF_RouteGUICurrentDrone + "."], call)
    0 = [Zen_OF_RouteDialog, [safeZoneW - 1 + safeZoneX + 0.5,safeZoneH - 1], false, true] call Zen_InvokeDialog;
};

Zen_OF_RouteGUIInvokeAuto = {
    _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
    // 0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, [[]]] call Zen_OF_UpdateDrone;

    // _list = [];
    // _listData = [];
    // 0 = [Zen_OF_RouteGUIList, ["List", _list], ["ListData", _listData]] call Zen_UpdateControl;

    call Zen_OF_RouteGUIRefresh;

    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has opened manual route planning GUI for " + Zen_OF_RouteGUICurrentDrone + "."], call)
    0 = [Zen_OF_RouteDialogAuto, [safeZoneW - 1 + safeZoneX + 0.5,safeZoneH - 1], false, true] call Zen_InvokeDialog;
};

Zen_OF_RouteGUIMove = {
    if (count _this == 0) exitWith {
        player sideChat "There are no waypoints to modify.";
    };

    _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
    if !(scriptDone (_droneData select 11)) exitWith {
        player sideChat "Use the Cancel button before issuing another move order.";
    };

    _waypoint = _this select 0;

    player sideChat "Click on the map to set the waypoint's position.";
    _h_move = [_waypoint] spawn {
        _waypoint = _this select 0;
        _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
        CHECK_FOR_DEAD

        Zen_OF_DroneMovePos = 0;
        waitUntil {
            sleep 1;
            (typeName Zen_OF_DroneMovePos == "ARRAY")
        };

        _localMovePos =+ Zen_OF_DroneMovePos;
        ZEN_FMW_MP_REServerOnly("A3log", [name player + " has moved waypoint " + str _waypoint + " for " + Zen_OF_RouteGUICurrentDrone + " to " + str _localMovePos + "."], call)

        _path = (_droneData select 7) select 0;
        _markers = _droneData select 8;
        {
            deleteMarker _x;
        } forEach _markers;

        _path set [_waypoint, _localMovePos];

        0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, [_path], _markers, 0] call Zen_OF_UpdateDrone;
        _markers = [Zen_OF_RouteGUICurrentDrone, true, SHOW_FULL_PATH_INFO_FOR_MANUAL] call Zen_OF_DroneGUIDrawPath;
    };

    0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, "", "", "", "", _h_move] call Zen_OF_UpdateDrone;
};

Zen_OF_RouteGUINew = {
    _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
    if !(scriptDone (_droneData select 11)) exitWith {
        player sideChat "Use the Cancel button before issuing another move order.";
    };

    player sideChat "Click on the map to set the waypoint's position.";
    _h_move = [] spawn {
        _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
        CHECK_FOR_DEAD

        Zen_OF_DroneMovePos = 0;
        waitUntil {
            sleep 1;
            (typeName Zen_OF_DroneMovePos == "ARRAY")
        };

        _localMovePos =+ Zen_OF_DroneMovePos;
        ZEN_FMW_MP_REServerOnly("A3log", [name player + " has created a waypoint for " + Zen_OF_RouteGUICurrentDrone + " at " + str _localMovePos + "."], call)

        _path = (_droneData select 7) select 0;
        _markers = _droneData select 8;
        _waypointTypes = _droneData select 15;
        {
            deleteMarker _x;
        } forEach _markers;

        _path pushBack _localMovePos;
        _waypointTypes pushBack "Move";

        0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, [_path], _markers, 0, "", "", "", "", "", _waypointTypes] call Zen_OF_UpdateDrone;
        _markers = [Zen_OF_RouteGUICurrentDrone, true, SHOW_FULL_PATH_INFO_FOR_MANUAL] call Zen_OF_DroneGUIDrawPath;

        call Zen_OF_RouteGUIRefresh;
    };

    0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, "", "", "", "", _h_move] call Zen_OF_UpdateDrone;
};

Zen_OF_RouteGUIDelete = {
    if (count _this == 0) exitWith {
        player sideChat "There are no waypoints to modify.";
    };

    _waypoint = _this select 0;
    _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD

    _path = (_droneData select 7) select 0;
    // if (count _path == 1) exitWith {
        // player sideChat "Cannot delete final waypoint.";
    // };

    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has deleted waypoint " + str _waypoint + " for " + Zen_OF_RouteGUICurrentDrone + "."], call)
    _markers = _droneData select 8;
    _waypointTypes = _droneData select 15;
    {
        deleteMarker _x;
    } forEach _markers;

    0 = [_path, _waypoint] call Zen_ArrayRemoveIndex;
    0 = [_waypointTypes, _waypoint] call Zen_ArrayRemoveIndex;

    0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, [_path], _markers, 0, "", "", "", "", "", _waypointTypes] call Zen_OF_UpdateDrone;

    if (count _path > 0) then {
        _markers = [Zen_OF_RouteGUICurrentDrone, true, SHOW_FULL_PATH_INFO_FOR_MANUAL] call Zen_OF_DroneGUIDrawPath;
    };

    call Zen_OF_RouteGUIRefresh;
};

Zen_OF_RouteGUIInsert = {
    player commandChat "Currently not functional.";
};

Zen_OF_RouteGUICancel = {
    _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD
    terminate (_droneData select 11);

    player sideChat (Zen_OF_RouteGUICurrentDrone + " is no longer waiting for destination.");
    ZEN_FMW_MP_REServerOnly("A3log", [(Zen_OF_RouteGUICurrentDrone + " is no longer waiting for destination.")], call)
};

Zen_OF_RouteGUIAccept = {
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has closed manual route planning GUI for " + Zen_OF_RouteGUICurrentDrone + "."], call)
    [0, Zen_OF_RouteGUICurrentDrone] call Zen_OF_DroneGUIApprove;

    call Zen_CloseDialog;
    0 = [] spawn Zen_OF_DroneGUIInvoke;
};

Zen_OF_RouteGUISave = {
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has closed manual route planning GUI for " + Zen_OF_RouteGUICurrentDrone + "."], call)

    call Zen_CloseDialog;
    0 = [] spawn Zen_OF_DroneGUIInvoke;
};

Zen_OF_RouteGUIBack = {
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has closed manual route planning GUI for " + Zen_OF_RouteGUICurrentDrone + " and scrapped the planned route."], call)

    _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
    _markers = _droneData select 8;
    {
        deleteMarker _x;
    } forEach _markers;
    0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, [], [], 0] call Zen_OF_UpdateDrone;

    call Zen_CloseDialog;
    0 = [] spawn Zen_OF_DroneGUIInvoke;
};

Zen_OF_RouteGUIWaypointList = {
    if (count _this < 2) exitWith {
        player sideChat str "There are no waypoints to modify.";
    };

    _waypointType = _this select 0;
    _waypoint = _this select 1;

    _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
    _waypointTypes = _droneData select 15;

    _waypointTypes set [_waypoint, _waypointType];

    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has changed the type of waypoint " + str _waypoint + " to " + _waypointType], call)
    0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, "", "", "", "", "", "", "", "", _waypointTypes] call Zen_OF_UpdateDrone;
    call Zen_OF_RouteGUIRefresh;
};

Zen_OF_RouteGUIListSelect = {
    if (count _this < 2) exitWith {};

    _map = (_this select 0) select 0;
    _waypoint = _this select 1;

    _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;

    0 = [_map, ["MapPosition", (((_droneData select 7) select (_droneData select 9)) select _waypoint) vectorAdd [random 5, 0, 0]]] call Zen_UpdateControl;
    [] call Zen_RefreshDialog;
};

Zen_OF_RouteGUIList = ["List",
    ["List", []],
    ["ListData", []],
    ["Position", [5, 0]],
    ["SelectionFunction", "Zen_OF_RouteGUIListSelect"],
    ["Data", [_map]],
    ["Size", [35,11.5]]
] call Zen_CreateControl;

_buttonMove = ["Button",
    ["Text", "Move"],
    ["Position", [0, 0]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_RouteGUIMove"],
    ["LinksTo", [Zen_OF_RouteGUIList]]
] call Zen_CreateControl;

_buttonNew = ["Button",
    ["Text", "New"],
    ["Position", [0, 2]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_RouteGUINew"]
    // ["LinksTo", [Zen_OF_RouteGUIList]]
] call Zen_CreateControl;

_buttonDelete = ["Button",
    ["Text", "Delete"],
    ["Position", [0, 4]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_RouteGUIDelete"],
    ["LinksTo", [Zen_OF_RouteGUIList]]
] call Zen_CreateControl;

_buttonInsert = ["Button",
    ["Text", "Insert"],
    ["Position", [0, 6]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_RouteGUIInsert"],
    ["LinksTo", [Zen_OF_RouteGUIList]]
] call Zen_CreateControl;

_buttonCancel = ["Button",
    ["Text", "Cancel"],
    ["Position", [0, 8]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_RouteGUICancel"]
    // ["LinksTo", [Zen_OF_RouteGUIList]]
] call Zen_CreateControl;

_buttonAccept = ["Button",
    ["Text", "Accept Route"],
    ["Position", [0, 10]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_RouteGUIAccept"]
    // ["LinksTo", [Zen_OF_RouteGUIList]]
] call Zen_CreateControl;

_buttonSave = ["Button",
    ["Text", "Save Route"],
    ["Position", [0, 10]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_RouteGUISave"]
    // ["LinksTo", [Zen_OF_RouteGUIList]]
] call Zen_CreateControl;

_buttonBack = ["Button",
    ["Text", "Scrap Route"],
    ["Position", [0, 12]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_RouteGUIBack"]
    // ["LinksTo", [Zen_OF_RouteGUIList]]
] call Zen_CreateControl;

_waypointTypeList = ["DropList",
    ["List", ["MOVE", "LAND"]],
    ["ListData", ["MOVE", "LAND"]],
    ["Position", [5, 14]],
    ["Size", [5,2]],
    ["LinksTo", [Zen_OF_RouteGUIList]],
    ["SelectionFunction", "Zen_OF_RouteGUIWaypointList"]
] call Zen_CreateControl;

Zen_OF_RouteDialog = [] call Zen_CreateDialog;
{
    0 = [Zen_OF_RouteDialog, _x] call Zen_LinkControl;
} forEach [_background, _map, Zen_OF_RouteGUIList, _buttonMove, _buttonNew, _buttonDelete, _buttonCancel, _buttonAccept, _buttonBack, _buttonInsert, _waypointTypeList];

Zen_OF_RouteDialogAuto = [] call Zen_CreateDialog;
{
    0 = [Zen_OF_RouteDialogAuto, _x] call Zen_LinkControl;
} forEach [_background, _map, Zen_OF_RouteGUIList, _buttonSave, _waypointTypeList];
