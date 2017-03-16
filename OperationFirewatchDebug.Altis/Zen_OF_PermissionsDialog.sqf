//

#include "Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

Zen_OF_PermissionGUIRefresh = {
    #define REFRESH_LISTS \
        _listDrones = []; \
        _listDronesData = []; \
        { \
            _listDrones pushBack (_x select 0); \
            _listDronesData pushBack (_x select 0); \
        } forEach Zen_OF_Drones_Local; \
        _listZones = []; \
        _listZonesData = []; \
        { \
            _data = [_x] call Zen_OF_GetZoneData; \
            if ((_data select 1) == "A") then { \
                (_data select 7) setMarkerAlpha 1; \
                _listZones pushBack _x; \
                _listZonesData pushBack _x; \
            }; \
        } forEach Zen_OF_Zone_Knowledge_Local; \
        0 = [Zen_OF_PermissionGUIDroneList, ["List", _listDrones], ["ListData", _listDronesData]] call Zen_UpdateControl; \
        0 = [Zen_OF_PermissionGUIZoneList, ["List", _listZones], ["ListData", _listZonesData]] call Zen_UpdateControl;

    REFRESH_LISTS
    [] call Zen_RefreshDialog;
};

Zen_OF_PermissionGUIInvoke= {
    REFRESH_LISTS
    0 = [Zen_OF_PermissionGUIDialog, [safeZoneW - 1 + safeZoneX + 0.4,safeZoneH - 1], false, true] call Zen_InvokeDialog;

    {
        _data = [_x] call Zen_OF_GetZoneData;
        if ((_data select 1) == "A") then {
            (_data select 7) setMarkerColor "colorRed";
        };
    } forEach Zen_OF_Zone_Knowledge_Local;

    _droneData = [_listDronesData select 0] call Zen_OF_GetDroneData;
    {
        _data = [_x] call Zen_OF_GetZoneData;
        (_data select 7) setMarkerColor "colorGreen";
    } forEach (_droneData select 16);
};

Zen_OF_PermissionGUIMapMove = {
    _type = (_this select 0) select 0;
    _map = (_this select 0) select 1;

    if (_type == "Drone") then {
        _drone = _this select 1;
        _droneData = [_drone] call Zen_OF_GetDroneData;
        0 = [_map, ["MapPosition", (getPosATL (_droneData select 1)) vectorAdd [random 5, 0, 0]]] call Zen_UpdateControl;
    } else {
        _zone = _this select 1;
        _zoneData = [_zone] call Zen_OF_GetZoneData;
        0 = [_map, ["MapPosition", (_zoneData select 4) vectorAdd [random 5, 0, 0]]] call Zen_UpdateControl;
    };

    [] call Zen_RefreshDialog;
};

Zen_OF_PermissionGUIDroneList = ["List",
    ["ListData", []],
    ["Position", [8, 0]],
    ["Size", [32,11.5]],
    ["SelectionFunction", "Zen_OF_PermissionGUIMapMove"],
    ["Data", ["Drone", _map]],
    ["List", []]
] call Zen_CreateControl;

Zen_OF_PermissionGUIZoneList = ["List",
    ["ListData", []],
    ["Position", [8, 12]],
    ["Size", [32,11.5]],
    ["SelectionFunction", "Zen_OF_PermissionGUIMapMove"],
    ["Data", ["Zone", _map]],
    ["List", []]
] call Zen_CreateControl;

Zen_OF_PermissionGUIShow = {
    player commandChat str _this;
    _drone = _this select 0;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD

    if ((_droneData select 6) == "") then {
        _mkr = [_droneData select 1, _drone] call Zen_SpawnMarker;
        0 = [_drone, "", "", "", "", _mkr] call Zen_OF_UpdateDrone;
    } else {
        (_droneData select 6) setMarkerPos getPosATL (_droneData select 1);
    };

    openMap [true, false];
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has plotted the position of " + _drone + " at " + str (getPosATL (_droneData select 1)) + " on the map."], call)

    _zone = _this select 1;
    _zoneData = [_zone] call Zen_OF_GetZoneData;

    _mkr = [_zoneData select 4, _zone] call Zen_SpawnMarker;
};

Zen_OF_PermissionGUIRequestPermission = {
    player commandChat str _this;
    _drone = _this select 1;
    _droneData = [_drone] call Zen_OF_GetDroneData;
    CHECK_FOR_DEAD

    _zone = _this select 3;
    _zoneData = [_zone] call Zen_OF_GetZoneData;

    0 = [_drone, "", "", "", "", 0, "", "", "", "", "", "", "", "", "", (_droneData select 16) + [_zone]] call Zen_OF_UpdateDrone;
    player sideChat (_drone + " has been granted permission to cross " + _zone);
    ZEN_FMW_MP_REServerOnly("A3log", [_drone + " at " + str getPosATL (_droneData select 1) + " has been granted permission to cross " + _zone + " at about " + str (_zoneData select 4) + " with radius " + str (_zoneData select 5)], call)

    {
        _data = [_x] call Zen_OF_GetZoneData;
        if ((_data select 1) == "A") then {
            (_data select 7) setMarkerColor "colorRed";
        };
    } forEach Zen_OF_Zone_Knowledge_Local;

    {
        _data = [_x] call Zen_OF_GetZoneData;
        (_data select 7) setMarkerColor "colorGreen";
    } forEach ((_droneData select 16) + [_zone]);
};

Zen_OF_PermissionGUIClose = {
    call Zen_CloseDialog;

    {
        _data = [_x] call Zen_OF_GetZoneData;
        if ((_data select 1) == "A") then {
            (_data select 7) setMarkerAlpha 0;
        };
    } forEach Zen_OF_Zone_Knowledge_Local;
};

_buttonShow = ["Button",
    ["Text", "Show"],
    ["Position", [0, 0]],
    ["Size", [8,2]],
    ["ActivationFunction", "Zen_OF_PermissionGUIShow"],
    ["LinksTo", [Zen_OF_PermissionGUIDroneList, Zen_OF_PermissionGUIZoneList]]
] call Zen_CreateControl;

_buttonRequestPermission = ["Button",
    ["Text", "Request Permission"],
    ["Position", [0, 2]],
    ["Size", [8,2]],
    ["ActivationFunction", "Zen_OF_PermissionGUIRequestPermission"],
    ["LinksTo", [Zen_OF_PermissionGUIDroneList, Zen_OF_PermissionGUIZoneList]]
] call Zen_CreateControl;

_buttonRefresh = ["Button",
    ["Text", "Refresh"],
    ["Position", [0, 4]],
    ["Size", [8,2]],
    // ["Data", [_barHealth, _barFuel]],
    // ["LinksTo", [Zen_OF_DroneGUIList]]
    ["ActivationFunction", "Zen_OF_PermissionGUIRefresh"]
] call Zen_CreateControl;

_buttonClose = ["Button",
    ["Text", "Close"],
    ["Position", [0, 6]],
    ["Size", [8,2]],
    ["ActivationFunction", "Zen_OF_PermissionGUIClose"]
] call Zen_CreateControl;

Zen_OF_PermissionGUIDialog = [] call Zen_CreateDialog;
{
    0 = [Zen_OF_PermissionGUIDialog, _x] call Zen_LinkControl;
} forEach [_background, _map, Zen_OF_PermissionGUIDroneList, Zen_OF_PermissionGUIZoneList, _buttonRefresh, _buttonClose, _buttonRequestPermission];
