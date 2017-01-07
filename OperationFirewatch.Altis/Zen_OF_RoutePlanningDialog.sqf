//

#include "Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

Zen_OF_RouteGUIRefresh = {
    _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;

    _list = [];
    _listData = [];
    {
        _list pushBack str (_forEachIndex + 1);
        _listData pushBack _forEachIndex;
    } forEach ((_droneData select 7) select 0);

    // player sideChat str _list;
    0 = [Zen_OF_RouteGUIList, ["List", _list], ["ListData", _listData]] call Zen_UpdateControl;
    call Zen_RefreshDialog;
};

Zen_OF_RouteGUIInvoke= {
    _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
    0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, [[]]] call Zen_OF_UpdateDrone;

    _list = [];
    _listData = [];
    0 = [Zen_OF_RouteGUIList, ["List", _list], ["ListData", _listData]] call Zen_UpdateControl;
    0 = [Zen_OF_RouteDialog, [safeZoneW - 1 + safeZoneX,safeZoneH - 1], true] call Zen_InvokeDialog;
};

Zen_OF_RouteGUIMove = {
    if (count _this == 0) exitWith {
        player sideChat "There are no waypoints to modify.";
    };

    _waypoint = _this select 0;

    player sideChat "Click on the map to set the waypoint's position.";
    _h_move = [_waypoint] spawn {
        _waypoint = _this select 0;
        _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
        CHECK_FOR_DEAD

        sleep 0.5;
        Zen_OF_DroneMovePos = 0;
        waitUntil {
            sleep 1;
            (typeName Zen_OF_DroneMovePos == "ARRAY")
        };

        _localMovePos =+ Zen_OF_DroneMovePos;
        // player sideChat str ("Click the approve button to confirm the position of the waypoint.");
        // ZEN_FMW_MP_REServerOnly("A3log", [name player + " has ordered " + Zen_OF_RouteGUICurrentDrone + " at " + str (getPosATL (_droneData select 1)) + " to compute path to " + str _localMovePos + "."], call)

        _path = (_droneData select 7) select 0;
        _markers = _droneData select 8;
        {
            deleteMarker _x;
        } forEach _markers;

        _path set [_waypoint, _localMovePos];
        _markers = [[(getPosATL (_droneData select 1))] + _path] call Zen_OF_DroneGUIDrawPath;

        0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, [_path], _markers, 0] call Zen_OF_UpdateDrone;
    };

    0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, "", "", "", "", _h_move] call Zen_OF_UpdateDrone;
};

Zen_OF_RouteGUINew = {
    player sideChat "Click on the map to set the waypoint's position.";
    _h_move = [] spawn {
        _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
        CHECK_FOR_DEAD

        sleep 0.5;
        Zen_OF_DroneMovePos = 0;
        waitUntil {
            sleep 1;
            (typeName Zen_OF_DroneMovePos == "ARRAY")
        };

        _localMovePos =+ Zen_OF_DroneMovePos;
        // player sideChat str ("Click the approve button to confirm the position of the new waypoint.");
        // ZEN_FMW_MP_REServerOnly("A3log", [name player + " has ordered " + Zen_OF_RouteGUICurrentDrone + " at " + str (getPosATL (_droneData select 1)) + " to compute path to " + str _localMovePos + "."], call)

        _path = (_droneData select 7) select 0;
        _markers = _droneData select 8;
        {
            deleteMarker _x;
        } forEach _markers;

        _path pushBack _localMovePos;
        _markers = [[(getPosATL (_droneData select 1))] + _path] call Zen_OF_DroneGUIDrawPath;

        // player sideChat str _path;
        0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, [_path], _markers, 0] call Zen_OF_UpdateDrone;
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

    _markers = _droneData select 8;
    {
        deleteMarker _x;
    } forEach _markers;

    0 = [_path, _waypoint] call Zen_ArrayRemoveIndex;
    _markers = [[(getPosATL (_droneData select 1))] + _path] call Zen_OF_DroneGUIDrawPath;

    0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, [_path], _markers, 0] call Zen_OF_UpdateDrone;
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

Zen_OF_RouteGUIBack = {
    call Zen_CloseDialog;
    0 = [] spawn Zen_OF_DroneGUIInvoke;
};

Zen_OF_RouteGUIList = ["List",
    ["List", []],
    ["ListData", []],
    ["Position", [5, 0]],
    // ["SelectionFunction", "Zen_OF_DroneGUIListSelect"],
    // ["Data", [_barHealth, _barFuel, _textTimer]],
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

_buttonBack = ["Button",
    ["Text", "Back"],
    ["Position", [0, 10]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_RouteGUIBack"]
    // ["LinksTo", [Zen_OF_RouteGUIList]]
] call Zen_CreateControl;

Zen_OF_RouteDialog = [] call Zen_CreateDialog;
{
    0 = [Zen_OF_RouteDialog, _x] call Zen_LinkControl;
} forEach [Zen_OF_RouteGUIList, _buttonMove, _buttonNew, _buttonDelete, _buttonCancel, _buttonBack, _buttonInsert];
