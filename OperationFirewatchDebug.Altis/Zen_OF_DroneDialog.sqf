//

#include "Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

#define DRONE_AUTO_CONFIRM_TIMER 60

#define CHECK_FOR_RTB \
    _dataArray = []; \
    { \
        if ([(_x select 0), _drone] call Zen_ValuesAreEqual) exitWith { \
            _dataArray = _x; \
        }; \
    } forEach Zen_OF_DroneManagerData; \
    if ((count _dataArray > 0) && {(_dataArray select 2)}) exitWith { \
        player sideChat (_drone + " is on automatic RTB course; no orders will be accepted."); \
    };

#define CHECK_FOR_DEAD \
    if (count _droneData == 0) exitWith { \
        player sideChat (_drone + " is dead."); \
    };

#define PARSE_WAYPOINT_INFO(A) (format["Distance: %1 m; ETA: %2 s; Fuel: %3 %4", A select 0, A select 1, (A select 2) * 100, "%"])

Zen_OF_DroneGUIRefresh = {
    _list = [];
    _listData = [];
    {
        _list pushBack (_x select 0);
        _listData pushBack (_x select 0);
    } forEach Zen_OF_Drones_Local;

    0 = [Zen_OF_DroneGUIList, ["List", _list], ["ListData", _listData]] call Zen_UpdateControl;

    if (count _listData > 0) then {
        _bars = _this select 0;
        _drone = _this select 2;
        _droneData = [_drone] call Zen_OF_GetDroneData;

        CHECK_FOR_DEAD

        0 = [_bars select 0, ["Progress", (_droneData select 2) * 100]] call Zen_UpdateControl;
        0 = [_bars select 1, ["Progress", (_droneData select 3) * 100]] call Zen_UpdateControl;

        if (Zen_OF_User_Is_Group_Two) then {
            _timer = _droneData select 13;
            if (((_timer > 0) && (time - _timer < DRONE_AUTO_CONFIRM_TIMER)) && {(scriptDone (_droneData select 4)) && (scriptDone (_droneData select 11))}) then {
                0 = [_bars select 2, ["Text", "Auto-Confirming Orders in: " + str round (_timer - time + 60) + " seconds"]] call Zen_UpdateControl;
            } else {
                0 = [_bars select 2, ["Text", ""]] call Zen_UpdateControl;
            };
        };

        call Zen_RefreshDialog;
    };
};

Zen_OF_DroneGUIInvoke= {
    _list = [];
    _listData = [];
    {
        _list pushBack (_x select 0);
        _listData pushBack (_x select 0);
    } forEach Zen_OF_Drones_Local;

    0 = [Zen_OF_DroneGUIList, ["List", _list], ["ListData", _listData]] call Zen_UpdateControl;
    0 = [Zen_OF_DroneGUIDialog, [safeZoneW - 1 + safeZoneX + 0.6,safeZoneH - 1], false] call Zen_InvokeDialog;
    0 = [Zen_OF_DroneGUIRefreshButton, "ActivationFunction"] spawn Zen_ExecuteEvent;
};

Zen_OF_DroneGUIListSelect = {
    0 = [(_this select 0), Zen_OF_DroneGUIList, (_this select 1)] call Zen_OF_DroneGUIRefresh;
};

Zen_OF_DroneGUIDrawPath = {
    private ["_drone", "_markDrone", "_droneData", "_path", "_half", "_mkr", "_markers", "_pathData", "_infoOverride"];
    _drone = _this select 0;

    ZEN_STD_Parse_GetArgumentDefault(_markDrone, 1, false)
    ZEN_STD_Parse_GetArgumentDefault(_infoOverride, 2, false)

    _droneData = [_drone] call Zen_OF_GetDroneData;
    _path = (_droneData select 7) select (_droneData select 9);

    // if (Zen_OF_User_Is_Group_Two || _infoOverride) then {
        _pathData = [_drone] call Zen_OF_FindDroneRouteData;
    // };

    _markers = [];
    if (_markDrone) then {
        _markers pushBack ([_droneData select 1, "Drone: " + str (_droneData select 0)] call Zen_SpawnMarker);
        _half = ([(_droneData select 1), ((_droneData select 1) distance2D (_path select 0)) / 2, [(_droneData select 1), (_path select 0)] call Zen_FindDirection, "trig"] call Zen_ExtendVector);
        _mkr = [_half, "", "colorBlack", [((_droneData select 1) distance2D (_path select 0)) / 2, 5], "rectangle", 180-([(_droneData select 1), (_path select 0)] call Zen_FindDirection), 1] call Zen_SpawnMarker;
        _markers pushBack _mkr;
    };

    if (Zen_OF_User_Is_Group_Two || _infoOverride) then {
        _markers pushBack ([_path select 0, PARSE_WAYPOINT_INFO(_pathData select 0)] call Zen_SpawnMarker);
    } else {
        _markers pushBack ([_path select 0, "ETA: " + str round ((_pathData select 0) select 1) + " s"] call Zen_SpawnMarker);
    };

    for "_i" from 0 to (count _path - 2) do {
        _half = ([(_path select _i), ((_path select _i) distance2D (_path select (_i + 1))) / 2, [(_path select _i), (_path select (_i + 1))] call Zen_FindDirection, "trig"] call Zen_ExtendVector);
        _mkr = [_half, "", "colorBlack", [((_path select _i) distance2D (_path select (_i + 1))) / 2, 5], "rectangle", 180-([(_path select _i), (_path select (_i + 1))] call Zen_FindDirection), 1] call Zen_SpawnMarker;
        _markers pushBack _mkr;

        if (Zen_OF_User_Is_Group_Two || _infoOverride) then {
            _markers pushBack ([_path select (_i + 1), PARSE_WAYPOINT_INFO(_pathData select (_i + 1))] call Zen_SpawnMarker);
        } else {
            _markers pushBack ([_path select (_i + 1), "ETA: " + str round ((_pathData select (_i + 1)) select 1) + " s"] call Zen_SpawnMarker);
        };
    };

    0 = [_drone, "", "", "", "", 0, "", _markers, ""] call Zen_OF_UpdateDrone;
    (_markers)
};

_textTimer = ["Text",
    ["Text", ""],
    ["Position", [5, 16]],
    ["Size", [15,2]]
] call Zen_CreateControl;

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
    ["Data", [_barHealth, _barFuel, _textTimer]]
] call Zen_CreateControl;

Zen_OF_DroneGUIShow = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD

    if ((_droneData select 6) == "") then {
        _mkr = [_droneData select 1, _drone] call Zen_SpawnMarker;
        0 = [_drone, "", "", "", "", _mkr] call Zen_OF_UpdateDrone;

        0 = [_mkr, _droneData select 1] spawn {
            _mkr = _this select 0;
            _drone = _this select 1;
            while {true} do {
                sleep 2;
                _mkr setMarkerPos getPosATL _drone;
            };
        };
    } else {
        (_droneData select 6) setMarkerPos getPosATL (_droneData select 1);
    };

    // openMap [true, false];
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has plotted the position of " + _drone + " at " + str (getPosATL (_droneData select 1)) + " on the map."], call)
};

Zen_OF_DroneGUIMove = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD
    CHECK_FOR_RTB

    // openMap [true, false];
    // call Zen_CloseDialog;

    // player groupChat str _droneData;

    if !(scriptDone (_droneData select 11)) exitWith {
        player sideChat "Use the Cancel button before issuing another move order.";
    };

    if !(scriptDone (_droneData select 4)) exitWith {
        player sideChat (_drone + " is carrying out a previous move order; use the stop button.");
    };

    if !(Zen_OF_User_Is_Group_Two) exitWith {
        Zen_OF_RouteGUICurrentDrone = _drone;
        call Zen_CloseDialog;
        [_drone] call Zen_OF_RouteGUIInvoke;
    };

    player sideChat "Click on the map to order the drone to Move.";
    _h_event = [_drone, _droneData] spawn {
        _drone = _this select 0;
        _droneData = _this select 1;
        CHECK_FOR_DEAD

        Zen_OF_DroneMovePos = 0;
        waitUntil {
            sleep 1;
            (typeName Zen_OF_DroneMovePos == "ARRAY")
        };

        _localMovePos =+ Zen_OF_DroneMovePos;
        // call Zen_OF_DroneGUIInvoke;
        player sideChat str ("Click the approve button to confirm the path of " + _drone + ".");
        ZEN_FMW_MP_REServerOnly("A3log", [name player + " has ordered " + _drone + " at " + str (getPosATL (_droneData select 1)) + " to compute path to " + str _localMovePos + "."], call)

        // terminate (_droneData select 4);
        _markers = _droneData select 8;
        {
            deleteMarker _x;
        } forEach _markers;

        _paths = [_drone, (_droneData select 1), _localMovePos] call Zen_OF_FindDroneRoute;
        _path = _paths select 0;

        0 = [_drone, "", "", "", "", 0, _paths, _markers, 0] call Zen_OF_UpdateDrone;
        _markers = [_drone] call Zen_OF_DroneGUIDrawPath;

        // for group #2
        if (Zen_OF_User_Is_Group_Two) then {
            terminate (_droneData select 12);
            _h_wait = [_drone, _paths] spawn {
                _drone = _this select 0;
                _paths = _this select 1;
                _droneData = [_drone] call Zen_OF_GetDroneData;

                _pathIndex = _droneData select 9;
                sleep DRONE_AUTO_CONFIRM_TIMER;
                player sideChat (_drone + " route auto-confirmed");
                ZEN_FMW_MP_REServerOnly("A3log", [name player + " has run out of time; path of " + _drone + " through " + str (_paths select _pathIndex) + " is auto-confirmed."], call)
                [0, _drone] call Zen_OF_DroneGUIApprove;
            };
            0 = [_drone, "", "", "", "", 0, "", "", "", "", "", _h_wait, time] call Zen_OF_UpdateDrone;
        };
    };

    0 = [_drone, "", "", "", "", 0, "", "", "", "", _h_event] call Zen_OF_UpdateDrone;
};

Zen_OF_DroneGUIRTB = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD
    CHECK_FOR_RTB

    if !(scriptDone (_droneData select 11)) exitWith {
        player sideChat "Use the Cancel button before issuing another move order.";
    };

    if !(scriptDone (_droneData select 4)) exitWith {
        player sideChat (_drone + " is carrying out a previous move order; use the stop button.");
    };

    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has ordered " + _drone + " at " + str (getPosATL (_droneData select 1)) + " with health " + str (_droneData select 2) + " and fuel " + str (_droneData select 3) + " to RTB."], call)
    _nearest = [Zen_OF_RepairRefuel_Global, compile format["
        _pos = _this select 1;
        _dronePos = %1;

        (if ((_this select 3) == (_this select 2)) then {
            (1)
        } else {
            -1 * (_dronePos distanceSqr _pos)
        })
    ", getPosATL (_droneData select 1)]] call Zen_ArrayFindExtremum;

    if ((_nearest select 3) == (_nearest select 2)) then {
        player sideChat "No space available at any repair or refuel points.";
        ZEN_FMW_MP_REServerOnly("A3log", ["RTB order for " + _drone + " has no solution."], call)
    } else {
        ZEN_FMW_MP_REServerOnly("A3log", ["RTB order for " + _drone + " has computed paths to " + (_nearest select 0) + " at " + str (_nearest select 1) + "."], call)
        player sideChat str ("Click the approve button to confirm the path of " + _drone + ".");

        // terminate (_droneData select 4);

        _markers = _droneData select 8;
        {
            deleteMarker _x;
        } forEach _markers;

        _paths = [_drone, (_droneData select 1), (_nearest select 1)] call Zen_OF_FindDroneRoute;
        _path = _paths select 0;

        0 = [_drone, "", "", "", "", 0, _paths, _markers, 0, [true, (_nearest select 0)]] call Zen_OF_UpdateDrone;
        _markers = [_drone] call Zen_OF_DroneGUIDrawPath;

        // for group #2
        if (Zen_OF_User_Is_Group_Two) then {
            terminate (_droneData select 12);
            _h_wait = [_drone, _paths] spawn {
                _drone = _this select 0;
                _paths = _this select 1;
                _droneData = [_drone] call Zen_OF_GetDroneData;

                _pathIndex = _droneData select 9;
                sleep DRONE_AUTO_CONFIRM_TIMER;
                player sideChat (_drone + " route auto-confirmed");
                ZEN_FMW_MP_REServerOnly("A3log", [name player + " has run out of time; path of " + _drone + " through " + str (_paths select _pathIndex) + " is auto-confirmed."], call)
                [0, _drone] call Zen_OF_DroneGUIApprove;
            };
            0 = [_drone, "", "", "", "", 0, "", "", "", "", "", _h_wait, time] call Zen_OF_UpdateDrone;
        };
    };
};

Zen_OF_DroneGUIApprove = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD
    CHECK_FOR_RTB

    if !(scriptDone (_droneData select 4)) exitWith {
        player sideChat (_drone + " is carrying out a previous move order; use the stop button.");
    };

    _paths = _droneData select 7;
    _markers = _droneData select 8;
    _pathIndex = _droneData select 9;
    _RTBArgs = _droneData select 10;

    if (count _paths == 0) then {
        player sideChat (_drone + " has no destination.");
    } else {
        player sideChat (_drone + " route approved.");
        ZEN_FMW_MP_REServerOnly("A3log", [name player + " has accepted path of " + _drone + " through " + str (_paths select _pathIndex) + "."], call)

        player groupChat str (_droneData select 14);
        terminate (_droneData select 14);
        _h_move = ([_drone, _paths select _pathIndex, _markers] + _RTBArgs) spawn Zen_OF_OrderDroneExecuteRoute;
        0 = [_drone, "", "", _h_move] call Zen_OF_UpdateDrone;
    };
};

Zen_OF_DroneGUIRecalc = {
    if !(Zen_OF_User_Is_Group_Two) exitWith {
        player commandChat str "Recalc has no function for group #1.";
    };

    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD
    CHECK_FOR_RTB

    if !(scriptDone (_droneData select 4)) exitWith {
        player sideChat (_drone + " is carrying out a previous move order; use the stop button.");
    };

    _paths = _droneData select 7;
    _markers = _droneData select 8;
    _pathIndex = _droneData select 9;

    {
        deleteMarker _x;
    } forEach _markers;

    if (count _paths == 0) then {
        player sideChat (_drone + " has no destination.");
    } else {
        if ((_pathIndex + 1) == count _paths) then {
            ZEN_FMW_MP_REServerOnly("A3log", [name player + " has rejected path of " + _drone + " through " + str (_paths select _pathIndex) + ", but there are no new solutions to show."], call)
            player sideChat "No more computed path solutions, returning to first solution.";

            0 = [_drone, "", "", "", "", 0, "", _markers, 0] call Zen_OF_UpdateDrone;
            _markers = [_drone] call Zen_OF_DroneGUIDrawPath;
        } else {
            ZEN_FMW_MP_REServerOnly("A3log", [name player + " has rejected path of " + _drone + " through " + str (_paths select _pathIndex) + "."], call)
            player sideChat ("Drawing next path; click the approve button to confirm the path of " + _drone + ".");
            _pathIndex = _pathIndex + 1;

            0 = [_drone, "", "", "", "", 0, "", _markers, _pathIndex] call Zen_OF_UpdateDrone;
            _markers = [_drone] call Zen_OF_DroneGUIDrawPath;
        };
    };
};

Zen_OF_DroneGUIStop = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD
    CHECK_FOR_RTB

    if !(scriptDone (_droneData select 4)) then {
        terminate (_droneData select 4);
        _markers = _droneData select 8;
        {
            deleteMarker _x;
        } forEach _markers;
        0 = [_drone, "", "", "", "", 0, [], [], 0] call Zen_OF_UpdateDrone;
    };

    _h_orbit = [_drone, (_droneData select 1), 500] spawn Zen_OF_OrderDroneOrbit;
    0 = [_drone, "", "", "", "", 0, [], [], 0, "", "", "", "", _h_orbit] call Zen_OF_UpdateDrone;

    player sideChat (_drone + " stopping.");
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has ordered " + _drone + " at " + str (getPosATL (_droneData select 1)) + " to stop."], call)
};

Zen_OF_DroneGUIReportFire = {
    //

    player sideChat ("All detected fires reported.");
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has reported all known fires; they are " + str Zen_OF_Fires_Detected_Local], call)
};

Zen_OF_DroneGUICancel = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD
    terminate (_droneData select 11);

    player sideChat (_drone + " is no longer waiting for destination.");
    ZEN_FMW_MP_REServerOnly("A3log", [(_drone + " is no longer waiting for destination.")], call)
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

_buttonFire = ["Button",
    ["Text", "Report Fire"],
    ["Position", [0, 10]],
    ["Size", [5,2]],
    // ["LinksTo", [Zen_OF_DroneGUIList]],
    ["ActivationFunction", "Zen_OF_DroneGUIReportFire"]
] call Zen_CreateControl;

_buttonStop = ["Button",
    ["Text", "Stop"],
    ["Position", [0, 12]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_DroneGUIStop"],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

_buttonCancel = ["Button",
    ["Text", "Cancel"],
    ["Position", [0, 14]],
    ["Size", [5,2]],
    ["LinksTo", [Zen_OF_DroneGUIList]],
    ["ActivationFunction", "Zen_OF_DroneGUICancel"]
] call Zen_CreateControl;

Zen_OF_DroneGUIRefreshButton = ["Button",
    ["Text", "Refresh"],
    ["Position", [0, 16]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_DroneGUIRefresh"],
    ["Data", [_barHealth, _barFuel, _textTimer]],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

_buttonClose = ["Button",
    ["Text", "Close"],
    ["Position", [0, 18]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_CloseDialog"]
] call Zen_CreateControl;

_map = ["Map",
    ["Position", [-88, -50]],
    ["Size", [88,74]]
] call Zen_CreateControl;

_background = ["Picture",
    ["Position", [0, -51]],
    ["Size", [50,76]],
    ["Picture", "images\blank.paa"]
] call Zen_CreateControl;

Zen_OF_DroneGUIDialog = [] call Zen_CreateDialog;
{
    0 = [Zen_OF_DroneGUIDialog, _x] call Zen_LinkControl;
} forEach [_background, _map, Zen_OF_DroneGUIList, _buttonShow, _buttonApprove, _buttonClose, _buttonMove, _buttonRTB, _buttonRecalc, Zen_OF_DroneGUIRefreshButton, _buttonStop, _textHealth, _textFuel, _barHealthBackGround, _barFuelBackGround, _barHealth, _barFuel, _buttonFire, _buttonCancel, _textTimer];

0 = ["Zen_OF_DroneGUIMove", "onMapSingleClick", {Zen_OF_DroneMovePos = _pos}, []] call BIS_fnc_addStackedEventHandler;
