//

// #include "Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
// #include "Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

#define STR_NAV_EMPTY "<t size='0.98'><t color='#000000'><t font='LucidaConsoleB'>No Route Programmed<br/>___________________<br/> </t></t></t>"
#define STR_NAV_PROMPT "<t size='0.98'><t color='#000000'><t font='LucidaConsoleB'>No Route Programmed<br/>___________________<br/> <br/>Select destination by clicking on the map.</t></t></t>"
#define STR_NAV_LIST(A, B, C) "<t size='0.98'><t color='#000000'><t font='LucidaConsoleB'>Select Route Below<br/>__________________<br/><br/>Route Option A<br/>" + (A) + "<br/>Route Option B<br/>" + (B) + "<br/>Route Option C<br/>" + (C) + "</t></t></t>"
#define STR_NAV_CONFRIM(G, M, S) ("<t size='0.98'><t color='#000000'><t font='LucidaConsoleB'>Current Route<br/>_____________<br/> <br/>Enroute to " + (G) + "<br/>Time to Target: " + str round (M) + ":" + str round (S) +"</t></t></t>")
#define STR_RQST_PROMPT "<t size='0.98'><t color='#000000'><t font='LucidaConsoleB'>Request Landing<br/>_______________<br/> <br/>Click on the airfield at which you would like to request landing.</t></t></t>"
#define STR_RQST_CONFIRMED "<t size='0.98'><t color='#000000'><t font='LucidaConsoleB'>Request Landing<br/>_______________<br/> <br/>You have requested landing.</t></t></t>"

#define DRONE_AUTO_CONFIRM_TIMER 60

#define CHECK_FOR_RTB \
    _dataArray = []; \
    { \
        if ([(_x select 0), _drone] call Zen_ValuesAreEqual) exitWith { \
            _dataArray = _x; \
        }; \
    } forEach Zen_OF_DroneManagerData; \
    if ((count _dataArray > 0) && {(_dataArray select 2)}) exitWith { \
        0 = [(_drone + " is on automatic RTB course; no orders will be accepted.")] call Zen_OF_PrintMessage; \
    };

#define CHECK_FOR_DEAD \
    if (count _droneData == 0) exitWith { \
        0 = [(_drone + " is dead.")] call Zen_OF_PrintMessage; \
    };

#define PARSE_WAYPOINT_INFO_M(A) ("ETA: " + str round ((A) select 1) + " s")
#define PARSE_WAYPOINT_INFO_L(A) (format["ETA: %1 s; Fuel: %2 %3", A select 1, (A select 2), "%"])
#define PARSE_WAYPOINT_INFO_H(A) (format["ETA: %1 s; Fuel: %2 %3;<br/>Time On Station: %4 min", A select 1, (A select 2), "%", (A select 3)])

_center = [safeZoneW - 1 + safeZoneX + 0.5,safeZoneH - 1, 0];
_navUL = [1.21843,0.464647, 0];
_navLR = [1.37,0.55, 0];
_camUL = [1.38366,0.464647, 0];
_camLR = [1.54,0.55, 0];
_rqstUL = [1.55303,0.464647, 0];
_rqstLR = [1.705,0.55, 0];
_cancelUL = [1.46843,0.973064, 0];
_cancelLR = [1.7,1.04, 0];
_textUL = [1.2197,1.045, 0];
_textLR = [1.7,1.38, 0];
_exeUL = [1.2197,0.973064, 0];
_exeLR = [1.44697,1.02525, 0];
_droneUL = [1.49,0.390572, 0];
_droneLR = [1.71,0.45, 0];
_timerUL = [1.23,0.90, 0];
_waypointMFDUL = [1.21843, 0.57, 0];
_waypointMFDLR = [1.7, 0.96, 0];

_centerCard = [1.21717,-0.208754, 0];
_fuelRemUL = [1.4798,-0.119529, 0];
_runwayUL = [1.61237,-0.122896, 0];
_timeUL = [1.46212,-0.10101, 0];
_activityUL = [1.34596,-0.0488216, 0];

Zen_OF_DroneGUIEventInProgress = false;

ZEN_OF_DroneDialog_Camera = "camera" camCreate [0,0,0];
ZEN_OF_DroneDialog_Camera camSetFovRange [0.02, 1];
Zen_OF_CameraGUITgtObj = [[0,0,0], "land_wrench_f"] call Zen_SpawnVehicle;
Zen_OF_CameraGUITgtObj allowDamage false;
Zen_OF_CameraGUITgtObj hideObjectGlobal true;

Zen_OF_DroneGUIRefresh = {
    _list = [];
    _listData = [];
    if ((typeName (_this select 1) == "BOOL" && {(_this select 1)}) || typeName (_this select 1) != "BOOL") then {
        {
            _list pushBack (_x select 0);
            _listData pushBack (_x select 0);
        } forEach Zen_OF_Drones_Local;

        0 = [Zen_OF_DroneGUIList, ["List", _list], ["ListData", _listData]] call Zen_UpdateControl;
    };

    if ((count _listData > 0) || (typeName (_this select 1) == "BOOL")) then {
        _bars = _this select 0;
        _drone = _this select 2;
        _droneData = [_drone] call Zen_OF_GetDroneData;

        CHECK_FOR_DEAD

        // 0 = [_bars select 0, ["Progress", (_droneData select 2) * 100]] call Zen_UpdateControl;
        // 0 = [_bars select 1, ["Progress", (_droneData select 3) * 100]] call Zen_UpdateControl;
        0 = [_bars select 3, ["MapPosition", (getPosATL (_droneData select 1)) vectorAdd [random 5, 0, 0]]] call Zen_UpdateControl;

        if (Zen_OF_User_Group_Index == 2) then {
            _timer = _droneData select 13;
            if (((_timer > 0) && (time - _timer < DRONE_AUTO_CONFIRM_TIMER)) && {(scriptDone (_droneData select 4)) && (scriptDone (_droneData select 11))}) then {
                0 = [_bars select 2, ["Text", "Auto-Confirming Orders in: " + str round (_timer - time + DRONE_AUTO_CONFIRM_TIMER) + " seconds"]] call Zen_UpdateControl;
            } else {
                0 = [_bars select 2, ["Text", ""]] call Zen_UpdateControl;
            };
        };
    };

    [] call Zen_RefreshDialog;
};

Zen_OF_DroneGUIInvoke= {
    call Zen_CloseDialog;

    _list = [];
    _listData = [];
    {
        _list pushBack (_x select 0);
        _listData pushBack (_x select 0);
    } forEach Zen_OF_Drones_Local;

    Zen_OF_RouteGUICurrentDrone = _listData select 0;
    0 = [Zen_OF_DroneGUIList, ["List", _list], ["ListData", _listData]] call Zen_UpdateControl;
    0 = [Zen_OF_GUIMessageBox, ["Position", ([([1.2197,1.04377, 0] vectorDiff [safeZoneW - 1 + safeZoneX + 0.5,safeZoneH - 1, 0]) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)]] call Zen_UpdateControl;

    0 = [Zen_OF_DroneGUIDialog, [safeZoneW - 1 + safeZoneX + 0.5,safeZoneH - 1], false, false] call Zen_InvokeDialog;
    0 = [Zen_OF_DroneGUIRefreshButton, "ActivationFunction"] spawn Zen_ExecuteEvent;

    Zen_OF_DroneGUIRefreshThread = [] spawn Zen_OF_DroneGUIRefreshManager;
};

Zen_OF_DroneGUIListSelect = {
    0 = [(_this select 0), false, (_this select 1)] call Zen_OF_DroneGUIRefresh;
    Zen_OF_RouteGUICurrentDrone = _this select 1;
};

Zen_OF_DroneGUIDrawPath = {
    private ["_drone", "_markDrone", "_droneData", "_path", "_half", "_mkr", "_markers", "_pathData", "_infoOverride"];
    _drone = _this select 0;

    ZEN_STD_Parse_GetArgumentDefault(_markDrone, 1, false)
    ZEN_STD_Parse_GetArgumentDefault(_infoOverride, 2, false)

    _droneData = [_drone] call Zen_OF_GetDroneData;
    _path = (_droneData select 7) select (_droneData select 9);

    _pathData = [_drone] call Zen_OF_FindDroneRouteData;

    _markers = [];
    if (_markDrone) then {
        _markers pushBack ([_droneData select 1, "Drone: " + str (_droneData select 0)] call Zen_SpawnMarker);
        _half = ([(_droneData select 1), ((_droneData select 1) distance2D (_path select 0)) / 2, [(_droneData select 1), (_path select 0)] call Zen_FindDirection, "trig"] call Zen_ExtendVector);
        _mkr = [_half, "", "colorBlack", [((_droneData select 1) distance2D (_path select 0)) / 2, 10], "rectangle", 180-([(_droneData select 1), (_path select 0)] call Zen_FindDirection), 1] call Zen_SpawnMarker;
        _markers pushBack _mkr;
    };

    switch (Zen_OF_User_Group_Index) do {
        case 0:{
            // _markers pushBack ([_path select 0, PARSE_WAYPOINT_INFO_M(_pathData select 0)] call Zen_SpawnMarker);
            _markers pushBack ([_path select 0] call Zen_SpawnMarker);
        };
        case 1: {
            // _markers pushBack ([_path select 0, PARSE_WAYPOINT_INFO_L(_pathData select 0)] call Zen_SpawnMarker);
            _markers pushBack ([_path select 0] call Zen_SpawnMarker);
        };
        case 2: {
            // _markers pushBack ([_path select 0, PARSE_WAYPOINT_INFO_H(_pathData select 0)] call Zen_SpawnMarker);
            _markers pushBack ([_path select 0] call Zen_SpawnMarker);
        };
    };

    for "_i" from 0 to (count _path - 2) do {
        _half = ([(_path select _i), ((_path select _i) distance2D (_path select (_i + 1))) / 2, [(_path select _i), (_path select (_i + 1))] call Zen_FindDirection, "trig"] call Zen_ExtendVector);
        _mkr = [_half, "", "colorBlack", [((_path select _i) distance2D (_path select (_i + 1))) / 2, 10], "rectangle", 180-([(_path select _i), (_path select (_i + 1))] call Zen_FindDirection), 1] call Zen_SpawnMarker;
        _markers pushBack _mkr;

        switch (Zen_OF_User_Group_Index) do {
            case 0:{
                // _markers pushBack ([_path select (_i + 1), PARSE_WAYPOINT_INFO_M(_pathData select (_i + 1))] call Zen_SpawnMarker);
                _markers pushBack ([_path select (_i + 1)] call Zen_SpawnMarker);
            };
            case 1: {
                // _markers pushBack ([_path select (_i + 1), PARSE_WAYPOINT_INFO_L(_pathData select (_i + 1))] call Zen_SpawnMarker);
                _markers pushBack ([_path select (_i + 1)] call Zen_SpawnMarker);
            };
            case 2: {
                // _markers pushBack ([_path select (_i + 1), PARSE_WAYPOINT_INFO_H(_pathData select (_i + 1))] call Zen_SpawnMarker);
                _markers pushBack ([_path select (_i + 1)] call Zen_SpawnMarker);
            };
        };
    };

    0 = [_drone, "", "", "", "", 0, "", _markers, ""] call Zen_OF_UpdateDrone;
    (_markers)
};

_map = ["Map",
    ["Position", [-78, -50]],
    ["Size", [78,74]]
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

    // if !(scriptDone (_droneData select 11)) exitWith {
        // 0 = ["Use the Cancel button before issuing another move order."] call Zen_OF_PrintMessage;
    // };

    if !(scriptDone (_droneData select 4)) exitWith {
        0 = [(_drone + " is carrying out a previous move order; use the stop button.")] call Zen_OF_PrintMessage;
    };

    if (Zen_OF_User_Group_Index == 0) exitWith {
        Zen_OF_RouteGUICurrentDrone = _drone;
        call Zen_CloseDialog;
        terminate Zen_OF_DroneGUIRefreshThread;
        [_drone] call Zen_OF_RouteGUIInvoke;
    };

    0 = ["Click on the map to order the drone to Move."] call Zen_OF_PrintMessage;
    0 = [Zen_OF_DroneGUIWaypointMFDText, ["Text", STR_NAV_PROMPT]] call Zen_UpdateControl;
    0 = [0, [Zen_OF_DroneGUIWaypointMFDText], "Else"] call Zen_RefreshDialog;
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
        0 = [("Click the execute button to confirm the path of " + _drone + ".")] call Zen_OF_PrintMessage;
        ZEN_FMW_MP_REServerOnly("A3log", [name player + " has ordered " + _drone + " at " + str (getPosATL (_droneData select 1)) + " to compute path to " + str _localMovePos + "."], call)

        // terminate (_droneData select 4);
        _markers = _droneData select 8;
        {
            deleteMarker _x;
        } forEach _markers;

        _paths = [_drone, (_droneData select 1), _localMovePos] call Zen_OF_FindDroneRoute;
        _path = _paths select 0;

        0 = [_drone, "", "", "", "", 0, _paths, _markers, 0, "", "", "", "", "", ["MOVE", "MOVE", "MOVE", "MOVE"]] call Zen_OF_UpdateDrone;
        _markers = [_drone] call Zen_OF_DroneGUIDrawPath;

        if (Zen_OF_User_Group_Index == 1) then {
            // Route Option A<br/>
            // Total Time: <MIN>:<SEC><br/>
            // Total Fuel Remaining: <FUEL%>
            0 = [Zen_OF_DroneGUIDialog, Zen_OF_DroneGUIWaypointMFDList] call Zen_LinkControl;

            _pathsLastData = [];
            for "_i" from 0 to 2 do {
                _pathData = [_drone, _i, false] call Zen_OF_FindDroneRouteData;
                if (count _pathData == 0) then {
                    _pathsLastData pushBack "No Path";
                } else {
                    _pathData = ZEN_STD_Array_LastElement(_pathData);

                    switch (Zen_OF_User_Group_Index) do {
                        case 0:{
                            _pathsLastData pushBack PARSE_WAYPOINT_INFO_M(_pathData);
                        };
                        case 1: {
                            _pathsLastData pushBack PARSE_WAYPOINT_INFO_L(_pathData);
                        };
                        case 2: {
                            _pathsLastData pushBack PARSE_WAYPOINT_INFO_H(_pathData);
                        };
                    };
                };
            };

            0 = [Zen_OF_DroneGUIWaypointMFDText, ["Text", STR_NAV_LIST(_pathsLastData select 0, _pathsLastData select 1, _pathsLastData select 2)]] call Zen_UpdateControl;
            0 = [0, [Zen_OF_DroneGUIWaypointMFDText], []] call Zen_RefreshDialog;
        };

        if (Zen_OF_User_Group_Index == 2) then {
            terminate (_droneData select 12);
            _h_wait = [_drone, _paths] spawn {
                _drone = _this select 0;
                _paths = _this select 1;
                _droneData = [_drone] call Zen_OF_GetDroneData;

                _pathIndex = _droneData select 9;
                sleep DRONE_AUTO_CONFIRM_TIMER;
                0 = [(_drone + " route auto-confirmed")] call Zen_OF_PrintMessage;
                ZEN_FMW_MP_REServerOnly("A3log", [name player + " has run out of time; path of " + _drone + " through " + str (_paths select _pathIndex) + " is auto-confirmed."], call)
                [0, _drone] call Zen_OF_DroneGUIApprove;
            };
            0 = [_drone, "", "", "", "", 0, "", "", "", "", "", _h_wait, time] call Zen_OF_UpdateDrone;
        };
    };

    0 = [_drone, "", "", "", "", 0, "", "", "", "", _h_event] call Zen_OF_UpdateDrone;
};

Zen_OF_DroneGUIWaypointTypes = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD
    CHECK_FOR_RTB

    // if !(scriptDone (_droneData select 11)) exitWith {
        // 0 = ["Use the Cancel button before issuing another move order."] call Zen_OF_PrintMessage;
    // };

    if !(scriptDone (_droneData select 4)) exitWith {
        0 = [(_drone + " is carrying out a previous move order; use the stop button.")] call Zen_OF_PrintMessage;
    };

    Zen_OF_RouteGUICurrentDrone = _drone;
    call Zen_CloseDialog;
    terminate Zen_OF_DroneGUIRefreshThread;
    [_drone] call Zen_OF_RouteGUIInvokeAuto;
};

Zen_OF_DroneGUIApprove = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD
    CHECK_FOR_RTB

    if !(scriptDone (_droneData select 4)) exitWith {
        0 = [(_drone + " is carrying out a previous move order; use the stop button.")] call Zen_OF_PrintMessage;
    };

    _paths = _droneData select 7;
    _markers = _droneData select 8;
    _pathIndex = _droneData select 9;
    // _RTBArgs = _droneData select 10;

    if (Zen_OF_User_Group_Index == 1) then {
        0 = [Zen_OF_DroneGUIDialog, Zen_OF_DroneGUIWaypointMFDList] call Zen_UnlinkControl;
        0 = [0] call Zen_RefreshDialog;
    };

    if (count _paths == 0) then {
        0 = [(_drone + " has no destination.")] call Zen_OF_PrintMessage;
    } else {
        0 = [(_drone + " route approved.")] call Zen_OF_PrintMessage;
        ZEN_FMW_MP_REServerOnly("A3log", [name player + " has accepted path of " + _drone + " through " + str (_paths select _pathIndex) + "."], call)

        terminate (_droneData select 14);
        _h_move = ([_drone, _paths select _pathIndex, _markers]) spawn Zen_OF_OrderDroneExecuteRoute;
        0 = [_drone, "", "", _h_move] call Zen_OF_UpdateDrone;
    };
};

Zen_OF_DroneGUIRecalc = {
    // if (Zen_OF_User_Group_Index == 0) exitWith {
        // player commandChat str "Recalc has no function for manual group.";
    // };

    if (count _this < 2) exitWith {};

    _pathIndex = _this select 0;
    _drone = _this select 2;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD
    CHECK_FOR_RTB

    if !(scriptDone (_droneData select 4)) exitWith {
        0 = [(_drone + " is carrying out a previous move order; use the stop button.")] call Zen_OF_PrintMessage;
    };

    _paths = _droneData select 7;
    _markers = _droneData select 8;

    if (count _paths == 0) then {
        0 = [(_drone + " has no destination.")] call Zen_OF_PrintMessage;
    } else {
        if (_pathIndex >= count _paths) then {
            ZEN_FMW_MP_REServerOnly("A3log", [name player + " has selected the path of " + _drone + " that does not exist."], call)
            0 = ["That path has not been computed."] call Zen_OF_PrintMessage;

            // _pathIndex = _droneData select 9;
            // 0 = [_drone, "", "", "", "", 0, "", _markers, 0] call Zen_OF_UpdateDrone;
            // _markers = [_drone] call Zen_OF_DroneGUIDrawPath;
        } else {
            waitUntil {
                !(Zen_OF_DroneGUIEventInProgress)
            };

            Zen_OF_DroneGUIEventInProgress = true;

            _droneData = [_drone] call Zen_OF_GetDroneData;
            _markers = _droneData select 8;

            ZEN_FMW_MP_REServerOnly("A3log", [name player + " has selected the path of " + _drone + " through " + str (_paths select _pathIndex) + "."], call)
            0 = [("Drawing next path; click the approve button to confirm the path of " + _drone + ".")] call Zen_OF_PrintMessage;

            {
                deleteMarker _x;
            } forEach _markers;

            0 = [_drone, "", "", "", "", 0, "", "", _pathIndex] call Zen_OF_UpdateDrone;
            _markers = [_drone] call Zen_OF_DroneGUIDrawPath;
            0 = [_drone, "", "", "", "", 0, "", _markers] call Zen_OF_UpdateDrone;
            Zen_OF_DroneGUIEventInProgress = false;
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

    _droneClassData = [(_droneData select 1)] call Zen_OF_GetDroneClassData;
    // _speed = _droneClassData select 0;
    _orbitRadius = _droneClassData select 1;

    _h_orbit = [_drone, (_droneData select 1), _orbitRadius] spawn Zen_OF_OrderDroneOrbit;
    0 = [_drone, "", "", "", "", 0, [], [], 0, "", "", "", "", _h_orbit] call Zen_OF_UpdateDrone;

    0 = [(_drone + " stopping.")] call Zen_OF_PrintMessage;
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has ordered " + _drone + " at " + str (getPosATL (_droneData select 1)) + " to stop."], call)
};

Zen_OF_DroneGUIReportFire = {
    //

    0 = [("All detected fires reported.")] call Zen_OF_PrintMessage;
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has reported all known fires; they are " + str Zen_OF_Fires_Detected_Local], call)
};

Zen_OF_DroneGUICancel = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD
    terminate (_droneData select 11);

    0 = [(_drone + " is no longer waiting for destination.")] call Zen_OF_PrintMessage;
    ZEN_FMW_MP_REServerOnly("A3log", [(_drone + " is no longer waiting for destination.")], call)
};

Zen_OF_DroneGUICamera = {
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD

    _offset = [10, 90 - (getDir (_droneData select 1)), 0];
    _offset = ZEN_STD_Math_VectCylCart(_offset);

    _center = (getPosATL (_droneData select 1)) vectorAdd _offset;
    _center set [2, 0];
    if (({(_x select 1)} count Zen_OF_Fires_Detected_Local == 0) || Zen_OF_User_Group_Index < 2) then {
        0 = [(_drone + " has not detected any fires.")] call Zen_OF_PrintMessage;
    } else {
        _nearestFire = ([Zen_OF_Fires_Detected_Local, compile format [" (-1 * ((%1) distanceSqr (([_this select 0] call Zen_OF_GetFireData) select 1))) ", _droneData select 1]] call Zen_ArrayFindExtremum) select 0;
        _center = ([_nearestFire] call Zen_OF_GetFireData) select 1;

        ZEN_FMW_MP_REServerOnly("A3log", [name player + " has entered camera view of " + _drone + " and is viewing fire " + _nearestFire + " at " + str _center], call)
    };

    ZEN_OF_DroneDialog_Camera cameraEffect ["internal","back"];
    ZEN_OF_DroneDialog_Camera camSetRelPos ((getPosATL (_droneData select 1)) vectorDiff _center);
    showCinemaBorder false;

    detach ZEN_OF_DroneDialog_Camera;
    ZEN_OF_DroneDialog_Camera attachTo [(_droneData select 1), [0, 0, -1.]];

    _center = [_center] call Zen_ConvertToPosition;
    _camPos = (_center) vectorDiff (getPosATL ZEN_OF_DroneDialog_Camera);
    _camPos = ZEN_STD_Math_VectCartPolar(_camPos);
    _camPos set [0, 5];
    _camPos = ZEN_STD_Math_VectPolarCart(_camPos);
    _camPos = _camPos vectorAdd (getPosATL ZEN_OF_DroneDialog_Camera);

    Zen_OF_CameraGUITgtObj setPosATL _camPos;
    ZEN_OF_DroneDialog_Camera camSetTarget (getPosATL Zen_OF_CameraGUITgtObj);
    ZEN_OF_DroneDialog_Camera camCommit 0;

    call Zen_CloseDialog;
    terminate Zen_OF_DroneGUIRefreshThread;
    [] call Zen_OF_CameraGUIInvoke;
};

Zen_OF_DroneGUIRQST = {
    0 = ["Click on the zone for which you want to request permission for " + Zen_OF_RouteGUICurrentDrone] call Zen_OF_PrintMessage;
    0 = [Zen_OF_DroneGUIWaypointMFDText, ["Text", STR_RQST_PROMPT]] call Zen_UpdateControl;
    0 = [0, [Zen_OF_DroneGUIWaypointMFDText], "Else"] call Zen_RefreshDialog;

    _h_event = [] spawn {
        Zen_OF_DroneMovePos = 0;
        waitUntil {
            sleep 1;
            (typeName Zen_OF_DroneMovePos == "ARRAY")
        };

        _Azones = [];
        {
            if (toUpper (_x select 1) == "A") then {
                _Azones pushBack [_x select 0, _x select 4];
            };
        } forEach Zen_OF_Zones_Global;

        _nearestZone = [_Azones, compile format ["-((_this select 1) distanceSqr %1)", Zen_OF_DroneMovePos]] call Zen_ArrayFindExtremum;

        _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;
        _zoneData = [(_nearestZone select 0)] call Zen_OF_GetZoneData;
        if !((_nearestZone select 0) in (_droneData select 16)) then {
            0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, "", "", "", "", "", "", "", "", "", (_droneData select 16) + [(_nearestZone select 0)]] call Zen_OF_UpdateDrone;
        };

        0 = [(Zen_OF_RouteGUICurrentDrone + " requested landing at " + (_nearestZone select 0))] call Zen_OF_PrintMessage;
        0 = [((_nearestZone select 0) + " " + Zen_OF_RouteGUICurrentDrone + " approved to land at "+ (_nearestZone select 0))] call Zen_OF_PrintMessage;
        ZEN_FMW_MP_REServerOnly("A3log", [Zen_OF_RouteGUICurrentDrone + " at " + str getPosATL (_droneData select 1) + " has been granted permission to land at " + (_nearestZone select 0) + " at about " + str (_zoneData select 4) + " with radius " + str (_zoneData select 5)], call)

        0 = [Zen_OF_DroneGUIWaypointMFDText, ["Text", STR_RQST_CONFIRMED]] call Zen_UpdateControl;
        0 = [0, [Zen_OF_DroneGUIWaypointMFDText], "Else"] call Zen_RefreshDialog;

        terminate (_droneData select 4);
        _droneData set [7, []];
        {
            deleteMarker _x;
        } forEach (_droneData select 8);
        _droneData set [8,[]];
        _droneData set [9,0];

        _nearestRR = [Zen_OF_RepairRefuel_Global, compile format["
            _pos = _this select 1;
            _dronePos = %1;

            (if ((_this select 3) == (_this select 2)) then {
                (1)
            } else {
                -1 * (_dronePos distanceSqr _pos)
            })
        ", _nearestZone select 1]] call Zen_ArrayFindExtremum;

        0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, "", "", "", "", "", "", "", "", ["MOVE", "LAND"]] call Zen_OF_UpdateDrone;
        _h_move = [Zen_OF_RouteGUICurrentDrone, [getPosATL (_droneData select 1), (_nearestRR select 1)], []] spawn Zen_OF_OrderDroneExecuteRoute;
        0 = [Zen_OF_RouteGUICurrentDrone, "", "", _h_move, "", 0, [[getPosATL (_droneData select 1), (_nearestRR select 1)]], [], 0] call Zen_OF_UpdateDrone;
    };

    0 = [Zen_OF_RouteGUICurrentDrone, "", "", "", "", 0, "", "", "", "", _h_event] call Zen_OF_UpdateDrone;
};

Zen_OF_DroneGUITimer = ["Text",
    ["Text", ""],
    ["FontColor", [0, 0, 0, 255]],
    ["Position", ([(_timerUL vectorDiff _center) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["Size", [15,2]]
] call Zen_CreateControl;

Zen_OF_DroneGUIList = ["DropList",
    ["List", []],
    ["ListData", []],
    ["Position", ([(_droneUL vectorDiff _center) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["Size", ([(_droneLR vectorDiff _droneUL) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["SelectionFunction", "Zen_OF_DroneGUIListSelect"],
    ["Data", [_barHealth, _barFuel, Zen_OF_DroneGUITimer, _map]]
] call Zen_CreateControl;

_buttonCamera = ["Button",
    ["Text", "Camera"],
    ["Position", ([(_camUL vectorDiff _center) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["Size", ([(_camLR vectorDiff _camUL) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["ActivationFunction", "Zen_OF_DroneGUICamera"],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

_buttonMove = ["Button",
    ["Text", "NAV"],
    ["Position", ([(_navUL vectorDiff _center) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["Size", ([(_navLR vectorDiff _navUL) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["ActivationFunction", "Zen_OF_DroneGUIMove"],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

// _buttonWaypointTypes = ["Button",
    // ["Text", "Waypoint Types"],
    // ["Position", [0, 4]],
    // ["Size", [5,2]],
    // ["ActivationFunction", "Zen_OF_DroneGUIWaypointTypes"],
    // ["LinksTo", [Zen_OF_DroneGUIList]]
// ] call Zen_CreateControl;

_buttonApprove = ["Button",
    ["Text", "Execute"],
    ["Position", ([(_exeUL vectorDiff _center) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["Size", ([(_exeLR vectorDiff _exeUL) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["ActivationFunction", "Zen_OF_DroneGUIApprove"],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

// _buttonRecalc= ["Button",
    // ["Text", "Recalc"],
    // ["Position", [0, 8]],
    // ["Size", [5,2]],
    // ["ActivationFunction", "Zen_OF_DroneGUIRecalc"],
    // ["LinksTo", [Zen_OF_DroneGUIList]]
// ] call Zen_CreateControl;

// _buttonFire = ["Button",
    // ["Text", "Report Fire"],
    // ["Position", [0, 10]],
    // ["Size", [5,2]],
    // ["LinksTo", [Zen_OF_DroneGUIList]],
    // ["ActivationFunction", "Zen_OF_DroneGUIReportFire"]
// ] call Zen_CreateControl;

_buttonStop = ["Button",
    ["Text", "Cancel"],
    ["Position", ([(_cancelUL vectorDiff _center) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["Size", ([(_cancelLR vectorDiff _cancelUL) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["ActivationFunction", "Zen_OF_DroneGUIStop"],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

// _buttonCancel = ["Button",
    // ["Text", "Cancel"],
    // ["Position", [0, 14]],
    // ["Size", [5,2]],
    // ["LinksTo", [Zen_OF_DroneGUIList]],
    // ["ActivationFunction", "Zen_OF_DroneGUICancel"]
// ] call Zen_CreateControl;

Zen_OF_DroneGUIRefreshButton = ["Button",
    ["Text", "Refresh"],
    ["Position", [-5, 16]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_OF_DroneGUIRefresh"],
    ["Data", [_barHealth, _barFuel, Zen_OF_DroneGUITimer, _map]],
    ["LinksTo", [Zen_OF_DroneGUIList]]
] call Zen_CreateControl;

_buttonClose = ["Button",
    ["Text", "Close"],
    ["Position", [-5, 20]],
    ["Size", [5,2]],
    ["ActivationFunction", "Zen_CloseDialog"]
] call Zen_CreateControl;

_buttonPermissions = ["Button",
    ["Text", "RQST"],
    ["Position", ([(_rqstUL vectorDiff _center) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["Size", ([(_rqstLR vectorDiff _rqstUL) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    // ["Transparency", 1],
    ["ActivationFunction", "Zen_OF_DroneGUIRQST"]
] call Zen_CreateControl;

_background = ["Picture",
    ["Position", [0, -51]],
    ["Size", [50,76]],
    ["Picture", "images\blank.paa"]
] call Zen_CreateControl;

_statusPicture = ["Picture",
    ["Position", [0, -49.25]],
    ["Size", [20,73]],
    // ["Angle", [-90, 0.5, 0.5]],
    ["Picture", "images\Status_Overlay_Full.paa"]
] call Zen_CreateControl;

Zen_OF_GUIMessageBox = ["StructuredText",
    ["Position", ([(_textUL vectorDiff _center) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["Size", ([(_textLR vectorDiff _textUL) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["Event", [["MOUSEZCHANGED", "Zen_OF_ScrollMessage"]]],
    ["Text", ""]
] call Zen_CreateControl;

Zen_OF_DroneGUIWaypointMFDText = ["StructuredText",
    ["Position", ([(_waypointMFDUL vectorDiff _center) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["Size", ([(_waypointMFDLR vectorDiff _waypointMFDUL) vectorMultiply 40, 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["Text", STR_NAV_EMPTY]
] call Zen_CreateControl;

Zen_OF_DroneGUIWaypointMFDList = ["List",
    ["Position", ([((_waypointMFDUL vectorDiff _center) vectorMultiply 40) vectorAdd [0, 4.5, 0], 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["Size", ([((_waypointMFDLR vectorDiff _waypointMFDUL) vectorMultiply 40) vectorAdd [0, -6, 0], 0, 1] call Zen_ArrayGetIndexedSlice)],
    ["ListData", [0, 0, 1, 1, 2, 2]],
    ["List", ["", "", "", "", "", ""]],
    // ["ForegroundColor", [255, 255, 255, 0]],
    // ["FontSize", 20],
    ["Transparency", 0.8],
    ["SelectionFunction", "Zen_OF_DroneGUIRecalc"],
    ["LinksTo", [Zen_OF_DroneGUIList]],
    ["List", []]
] call Zen_CreateControl;

Zen_OF_DroneGUIDialog = [] call Zen_CreateDialog;
{
    0 = [Zen_OF_DroneGUIDialog, _x] call Zen_LinkControl;
} forEach [_background, _map, _statusPicture, Zen_OF_DroneGUIList, _buttonApprove, _buttonPermissions, _buttonCamera, _buttonMove, Zen_OF_DroneGUIRefreshButton, _buttonStop, _buttonClose, Zen_OF_DroneGUITimer, Zen_OF_GUIMessageBox, Zen_OF_DroneGUIWaypointMFDText] + (switch (Zen_OF_User_Group_Index) do { case 0: {[]}; case 1: {[]}; case 2: {[]}; });

0 = ["Zen_OF_DroneGUIMove", "onMapSingleClick", {Zen_OF_DroneMovePos = _pos}, []] call BIS_fnc_addStackedEventHandler;

// 0 = [] spawn {
    // while {true} do {
        // sleep 2;
        // player commandChat str getMousePosition;
        // copyToClipboard str getMousePosition;
    // };
// };

Zen_OF_DroneGUIRefreshManager = {
    while {true} do {
        _droneData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_GetDroneData;

        // For drone status cards
        // TODO

        // For waypoint MFD current route text
        if !(scriptDone (_droneData select 4)) then {
            _path = (_droneData select 7) select (_droneData select 9);
            _pathData = [Zen_OF_RouteGUICurrentDrone] call Zen_OF_FindDroneRouteData;

            _lastWaypoint = ZEN_STD_Array_LastElement(_path);
            _timeS = round ((ZEN_STD_Array_LastElement(_pathData)) select 1);

            0 = [Zen_OF_DroneGUIWaypointMFDText, ["Text", STR_NAV_CONFRIM(mapGridPosition _lastWaypoint, floor _timeS / 60, _timeS % 60)]] call Zen_UpdateControl;
            // 0 = [0, [Zen_OF_DroneGUIWaypointMFDText], "Else"] call Zen_RefreshDialog;
        };

        // DOA-H auto-confirm timer
        if (Zen_OF_User_Group_Index == 2) then {
            _timer = _droneData select 13;
            if (((_timer > 0) && (time - _timer < DRONE_AUTO_CONFIRM_TIMER)) && {(scriptDone (_droneData select 4)) && (scriptDone (_droneData select 11))}) then {
                0 = [Zen_OF_DroneGUITimer, ["Text", "Auto-Confirming Orders in: " + str round (_timer - time + DRONE_AUTO_CONFIRM_TIMER) + " seconds"]] call Zen_UpdateControl;
            } else {
                0 = [Zen_OF_DroneGUITimer, ["Text", "test 2"]] call Zen_UpdateControl;
            };
        };

        0 = [0, [Zen_OF_DroneGUIWaypointMFDText, Zen_OF_DroneGUITimer], "else"] call Zen_RefreshDialog;
        sleep 0.9;
    };
};
