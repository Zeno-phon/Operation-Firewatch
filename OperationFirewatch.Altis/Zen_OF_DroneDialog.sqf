//

#include "Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

Zen_OF_DroneGUIRefresh = {
    _list = [];
    _listData = [];
    {
        _list pushBack (_x select 0);
        _listData pushBack (_x select 0);
    } forEach Zen_OF_Drones_Local;

    0 = [Zen_OF_DroneGUIList, ["List", _list], ["ListData", _listData]] call Zen_UpdateControl;
    call Zen_RefreshDialog;
};

Zen_OF_DroneGUIInvoke= {
    _list = [];
    _listData = [];
    {
        _list pushBack (_x select 0);
        _listData pushBack (_x select 0);
    } forEach Zen_OF_Drones_Local;

    0 = [Zen_OF_DroneGUIList, ["List", _list], ["ListData", _listData]] call Zen_UpdateControl;
    0 = [Zen_OF_DroneGUIDialog] call Zen_InvokeDialog;
};

Zen_OF_DroneGUIListSelect = {
    _droneID = _this select 1;
    _droneData = [_droneID] call Zen_OF_GetDroneData;

    _bars = _this select 0;
    0 = [_bars select 0, ["Progress", (_droneData select 2) * 100]] call Zen_UpdateControl;
    0 = [_bars select 1, ["Progress", (_droneData select 3) * 100]] call Zen_UpdateControl;
    call Zen_OF_DroneGUIRefresh;
};

_textHealth = ["Text",
    ["Text", "Health"],
    ["Position", [5, 12]],
    ["Size", [5,2]]
] call Zen_CreateControl;

_barHealth = ["PROGRESSBAR",
    ["Progress", 0],
    ["Position", [5, 14]],
    ["FontColor", [0,255,0, 255]],
    ["Size", [10,2]]
] call Zen_CreateControl;

_barHealthBackGround = ["PROGRESSBAR",
    ["Progress", 100],
    ["Position", [5, 14]],
    ["FontColor", [255,0,0, 255]],
    ["Size", [10,2]]
] call Zen_CreateControl;

_textFuel = ["Text",
    ["Text", "Fuel"],
    ["Position", [10, 12]],
    ["Size", [5,2]]
] call Zen_CreateControl;

_barFuel = ["PROGRESSBAR",
    ["Progress", 0],
    ["Position", [10, 14]],
    ["FontColor", [0,255,0, 255]],
    ["Size", [10,2]]
] call Zen_CreateControl;

_barFuelBackGround = ["PROGRESSBAR",
    ["Progress", 100],
    ["Position", [10, 14]],
    ["FontColor", [255,0,0, 255]],
    ["Size", [10,2]]
] call Zen_CreateControl;

Zen_OF_DroneGUIList = ["List",
    ["List", []],
    ["ListData", []],
    ["Position", [5, 0]],
    ["Size", [35,11.5]],
    ["SelectionFunction", "Zen_OF_DroneGUIListSelect"],
    ["Data", [_barHealth, _barFuel]]
] call Zen_CreateControl;

Zen_OF_DroneGUIShow = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;

    player commandChat str "This function is in an incomplete debug state.";
    openMap [true, false];
    0 = [_droneData select 1, _drone] call Zen_SpawnMarker;
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has plotted the position of " + _drone + " at " + str (getPosATL (_droneData select 1)) + " on the map."], call)
};

Zen_OF_DroneGUIMove = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;

    openMap [true, false];
    0 = [_droneData select 1, _drone] call Zen_SpawnMarker;

    call Zen_CloseDialog;
    player commandChat str "This function is not working as intended due to missing dependencies.";
    player sideChat str "Click on the map to order the drone to Move.";

    0 = ["Zen_OF_", "onMapSingleClick", {Zen_OF_DroneMovePos = _pos}, []] call BIS_fnc_addStackedEventHandler;
    Zen_OF_DroneMovePos = 0;
    waitUntil {
        sleep 1;
        (typeName Zen_OF_DroneMovePos == "ARRAY")
    };

    _localMovePos =+ Zen_OF_DroneMovePos;
     0 = [_localMovePos, "Destination of " + _drone] call Zen_SpawnMarker;
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has ordered " + _drone + " at " + str (getPosATL (_droneData select 1)) + " to move to " + str _localMovePos + "."], call)

    terminate (_droneData select 4);
    (_droneData select 1) move _localMovePos;

    _h_move = [_drone, _localMovePos] spawn {
        _drone = _this select 0;
        _localMovePos = _this select 1;
        waitUntil {
            sleep 5;
            (unitReady _drone) || ((_drone distance2D _localMovePos) < 25);
        };

        ZEN_FMW_MP_REServerOnly("A3log", ["Move order for " + _drone + " compete."], call)
        player sideChat (_drone + " move order complete.");
    };

    0 = [_drone, "", "", _h_move] call Zen_OF_UpdateDrone;
};

Zen_OF_DroneGUIRTB = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;

    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has ordered " + _drone + " at " + str (getPosATL (_droneData select 1)) + " with health " + str (_droneData select 2) + " and fuel " + str (_droneData select 3) + " to RTB."], call)
    _nearest = [Zen_OF_RepairRefuel_Global, compile format["
        _pos = _this select 1;
        _dronePos = %1;

        (if ((_this select 3) == (_this select 2)) then {
            (1)
        } else {
            -1 * (_dronePos distance2D _pos)
        })
    ", getPosATL (_droneData select 1)]] call Zen_ArrayFindExtremum;

    if ((_nearest select 3) == (_nearest select 2)) then {
        player sideChat "No space available at any repair or refuel points.";
        ZEN_FMW_MP_REServerOnly("A3log", ["RTB order for " + _drone + " has no solution."], call)
    } else {
        ZEN_FMW_MP_REServerOnly("A3log", ["RTB order for " + _drone + " in progress to " + (_nearest select 0) + " at " + str (_nearest select 1) + "."], call)
        player sideChat (_drone + " will RTB at marked point.");
        0 = [(_nearest select 1), (_nearest select 0)] call Zen_SpawnMarker;

        terminate (_droneData select 4);
        (_droneData select 1) move (_nearest select 1);
    };

    _h_move = [_drone, _droneData, _nearest] spawn {
        _drone = _this select 0;
        _droneData = _this select 1;
        _nearest = _this select 2;
        waitUntil {
            sleep 5;
            (unitReady (_droneData select 1)) || (((_droneData select 1) distance2D (_nearest select 1)) < 25);
        };

        ZEN_FMW_MP_REServerOnly("A3log", ["RTB order for " + _drone + " compete; standby repair/refuel"], call)
        0 = [_nearest select 0, "", (([_nearest select 0] call Zen_OF_GetRepairRefuelData) select 3) + 1] call Zen_OF_UpdateRepairRefuel;
        sleep 5;
        0 = [_drone, 1, 1] call Zen_OF_UpdateDrone;
        player sideChat (_drone + " repair and refueling complete.");
        0 = [_nearest select 0, "", (([_nearest select 0] call Zen_OF_GetRepairRefuelData) select 3) - 1] call Zen_OF_UpdateRepairRefuel;
    };

    0 = [_drone, "", "", _h_move] call Zen_OF_UpdateDrone;
};

Zen_OF_DroneGUIApprove = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;

    player commandChat str "Currently non-functional.";
};

Zen_OF_DroneGUIRecalc = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;

    player commandChat str "Currently non-functional.";
};

Zen_OF_DroneGUIStop = {
    // player commandChat str _this;
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;

    terminate (_droneData select 4);
    (_droneData select 1) move getPosATL (_droneData select 1);

    player sideChat (_drone + " stopping.");
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has ordered " + _drone + " at " + str (getPosATL (_droneData select 1)) + " to stop."], call)
};

_buttonShow = ["Button",
    ["Text", "Show"],
    ["Position", [0, 0]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_DroneGUIShow"],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

_buttonMove = ["Button",
    ["Text", "Move"],
    ["Position", [0, 2]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_DroneGUIMove"],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

_buttonRTB = ["Button",
    ["Text", "RTB"],
    ["Position", [0, 4]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_DroneGUIRTB"],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

_buttonApprove = ["Button",
    ["Text", "Approve"],
    ["Position", [0, 6]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_DroneGUIApprove"],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

_buttonRecalc= ["Button",
    ["Text", "Recalc"],
    ["Position", [0, 8]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_DroneGUIRecalc"],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

_buttonStop = ["Button",
    ["Text", "Stop"],
    ["Position", [0, 10]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_DroneGUIStop"],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

_buttonRefresh = ["Button",
    ["Text", "Refresh"],
    ["Position", [0, 12]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_DroneGUIRefresh"]
] call Zen_CreateControl;

_buttonClose = ["Button",
    ["Text", "Close"],
    ["Position", [0, 14]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_CloseDialog"]
] call Zen_CreateControl;

Zen_OF_DroneGUIDialog = [] call Zen_CreateDialog;
{
    0 = [Zen_OF_DroneGUIDialog, _x] call Zen_LinkControl;
} forEach [Zen_OF_DroneGUIList, _buttonShow, _buttonApprove, _buttonClose, _buttonMove, _buttonRTB, _buttonRecalc, _buttonRefresh, _buttonStop, _textHealth, _textFuel, _barHealthBackGround, _barFuelBackGround, _barHealth, _barFuel];
