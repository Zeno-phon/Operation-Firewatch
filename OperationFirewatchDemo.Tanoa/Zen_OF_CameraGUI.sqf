//

// Numpad codes
// 69 181 55 74
// 71 72  73
// 75 76  77 78
// 79 80  81
// 82     83 156

#define CAMERA_OFFSET_X 0.
#define CAMERA_OFFSET_Y -(safeZoneY + (-safeZoneY + safeZoneH) / 3)

#define CAMERA_UP 72
#define CAMERA_DOWN 80
#define CAMERA_LEFT 75
#define CAMERA_RIGHT 77
#define CAMERA_UP_LEFT 71
#define CAMERA_UP_RIGHT 73
#define CAMERA_DOWN_LEFT 79
#define CAMERA_DOWN_RIGHT 81
#define CAMERA_ZOOM_IN 78
#define CAMERA_ZOOM_OUT 74
#define CAMERA_LASE 83
#define CAMERA_EXIT 82

#define CAMERA_SLEW_TIME 0.1
#define CAMERA_SLEW_FRACTION 15
#define CAMERA_SLEW_ZOOM_STEP 0.025

Zen_OF_CameraGUIInvoke = {
    0 = [Zen_OF_GUIMessageBox, ["Position", [-25, 45]]] call Zen_UpdateControl;
    0 = [Zen_OF_CameraGUIDialog, [0 + CAMERA_OFFSET_X, 0 + CAMERA_OFFSET_Y], false, true] call Zen_InvokeDialog;

    0 = ["Press Numpad 0 to exit camera view."] call Zen_OF_PrintMessage;
    (findDisplay 76) displayAddEventHandler ["KeyDown", {
        0 = _this spawn {
            if ((_this select 1) == CAMERA_EXIT) then {
                [] call Zen_OF_CameraGUIClose;
            };
        };

        (false)
    }];

    0 = ["Press Numpad del to obtain target coordinates."] call Zen_OF_PrintMessage;
    (findDisplay 76) displayAddEventHandler ["KeyDown", {
        0 = _this spawn {
            if ((_this select 1) == CAMERA_LASE) then {
                [] call Zen_OF_CameraGUICoord;
            };
        };

        (false)
    }];

    if (Zen_OF_User_Group_Index < 2) then {
        0 = ["Press the Numpad arrow keys to move camera."] call Zen_OF_PrintMessage;
        Zen_OF_CameraGUILastEvent = 0;
        Zen_OF_CameraGUIFOV = 0.7;
        #define CAMERA_PAN(X, Y, K) \
        (findDisplay 76) displayAddEventHandler ["KeyDown", { \
            0 = _this spawn { \
                if ((time > Zen_OF_CameraGUILastEvent + CAMERA_SLEW_TIME) && {((_this select 1) == K)}) then { \
                    Zen_OF_CameraGUILastEvent = time; \
                    ZEN_OF_DroneDialog_Camera camSetTarget (screenToWorld [0.5 X, 0.5 Y]); \
                    ZEN_OF_DroneDialog_Camera camCommit CAMERA_SLEW_TIME; \
                }; \
            }; \
            (false) \
        }];

        CAMERA_PAN(                                       , - safeZoneH / 2 / CAMERA_SLEW_FRACTION, CAMERA_UP)
        CAMERA_PAN(                                       , + safeZoneH / 2 / CAMERA_SLEW_FRACTION, CAMERA_DOWN)
        CAMERA_PAN( - safeZoneW / 2 / CAMERA_SLEW_FRACTION,                                       , CAMERA_LEFT)
        CAMERA_PAN( + safeZoneW / 2 / CAMERA_SLEW_FRACTION,                                       , CAMERA_RIGHT)
        CAMERA_PAN( - safeZoneW / 2 / CAMERA_SLEW_FRACTION, - safeZoneH / 2 / CAMERA_SLEW_FRACTION, CAMERA_UP_LEFT)
        CAMERA_PAN( + safeZoneW / 2 / CAMERA_SLEW_FRACTION, - safeZoneH / 2 / CAMERA_SLEW_FRACTION, CAMERA_UP_RIGHT)
        CAMERA_PAN( - safeZoneW / 2 / CAMERA_SLEW_FRACTION, + safeZoneH / 2 / CAMERA_SLEW_FRACTION, CAMERA_DOWN_LEFT)
        CAMERA_PAN( + safeZoneW / 2 / CAMERA_SLEW_FRACTION, + safeZoneH / 2 / CAMERA_SLEW_FRACTION, CAMERA_DOWN_RIGHT)

        0 = ["Press the Numpad + and - keys to zoom camera."] call Zen_OF_PrintMessage;
        #define CAMERA_ZOOM(S, C, K) \
        (findDisplay 76) displayAddEventHandler ["KeyDown", { \
            0 = _this spawn { \
                if ((time > Zen_OF_CameraGUILastEvent + CAMERA_SLEW_TIME) && {((_this select 1) == K)}) then { \
                    Zen_OF_CameraGUILastEvent = time; \
                    if (Zen_OF_CameraGUIFOV C) then { \
                        ZEN_OF_DroneDialog_Camera camSetFov (Zen_OF_CameraGUIFOV S CAMERA_SLEW_ZOOM_STEP); \
                        Zen_OF_CameraGUIFOV = Zen_OF_CameraGUIFOV S CAMERA_SLEW_ZOOM_STEP; \
                        ZEN_OF_DroneDialog_Camera camCommit CAMERA_SLEW_TIME; \
                    }; \
                }; \
            }; \
            (false) \
        }];

        CAMERA_ZOOM(-, > 0.02, CAMERA_ZOOM_IN)
        CAMERA_ZOOM(+, < .99, CAMERA_ZOOM_OUT)
    };
};

Zen_OF_CameraGUICoord = {
    _coords = screenToWorld [0.5 + CAMERA_OFFSET_X, 0.5 + CAMERA_OFFSET_Y];
    0 = [Zen_OF_CameraGUICoordText, ["Text", (str round (_coords select 0) + ", " + str round (_coords select 1))]] call Zen_UpdateControl;
    [] call Zen_RefreshDialog;
};

Zen_OF_CameraGUIClose = {
    player switchCamera "INTERNAL";
    player cameraEffect ["terminate","back"];
    (findDisplay 76) displayRemoveAllEventHandlers "KeyDown";
    [] call Zen_CloseDialog;
    call Zen_OF_DroneGUIInvoke;
};

Zen_OF_CameraGUIReportFire = {
    _xString = _this select 0;
    _yString = _this select 1;

    if ((count toArray _xString == 0) || (count toArray _yString == 0)) exitWith {
        0 = ["No coordinates entered in one or more fields."] call Zen_OF_PrintMessage;
    };

    _xCoord = call compile ([_xString] call Zen_StringRemoveWhiteSpace);
    _yCoord = call compile ([_yString] call Zen_StringRemoveWhiteSpace);

    _pos = [_xCoord, _yCoord, 0];
    _unconfirmedFires = [Zen_OF_Fires_Detected_Local, {(_this select 1)}] call Zen_ArrayFilterCondition;

    if (count _unconfirmedFires == 0) exitWith {
        0 = ["There are no detected fires waiting to be confirmed."] call Zen_OF_PrintMessage;
    };

    _fire = ([_unconfirmedFires, compile format ["(-1 * ((%1) distanceSqr (([_this select 0] call Zen_OF_GetFireData) select 1)))", _pos]] call Zen_ArrayFindExtremum) select 0;
    _firePos = ([_fire] call Zen_OF_GetFireData) select 1;

    if ((vectorMagnitude (_pos vectorDiff _firePos)) < 100) then {
        0 = ["Fire confirmed and reported."] call Zen_OF_PrintMessage;
        0 = [Zen_OF_Fires_Detected_Local, [_fire, false], [_fire, true]] call Zen_ArrayReplaceValue;
        ZEN_FMW_MP_REServerOnly("A3log", [name player + " has confirmed the detection of a fire at " + str _pos + " which corresponds to fire " + _fire + " at " + str _firePos], call)
    } else {
        0 = ["There are no detected fires within 100m of those coordinates."] call Zen_OF_PrintMessage;
    };
};

Zen_OF_CameraGUIReportFalse = {
    _xString = _this select 0;
    _yString = _this select 1;

    if ((count toArray _xString == 0) || (count toArray _yString == 0)) exitWith {
        0 = ["No coordinates entered in one or more fields."] call Zen_OF_PrintMessage;
    };

    _xCoord = call compile ([_xString] call Zen_StringRemoveWhiteSpace);
    _yCoord = call compile ([_yString] call Zen_StringRemoveWhiteSpace);

    _pos = [_xCoord, _yCoord, 0];
    _unconfirmedFires = [Zen_OF_Fires_Detected_Local, {(_this select 1)}] call Zen_ArrayFilterCondition;

    if (count _unconfirmedFires == 0) exitWith {
        0 = ["There are no detected fires waiting to be confirmed."] call Zen_OF_PrintMessage;
    };

    _fire = ([_unconfirmedFires, compile format ["(-1 * ((%1) distanceSqr (([_this select 0] call Zen_OF_GetFireData) select 1)))", _pos]] call Zen_ArrayFindExtremum) select 0;
    _firePos = ([_fire] call Zen_OF_GetFireData) select 1;

    if ((vectorMagnitude (_pos vectorDiff _firePos)) < 100) then {
        0 = ["Fire ignored as false alarm."] call Zen_OF_PrintMessage;
        0 = [Zen_OF_Fires_Detected_Local, [_fire, false], [_fire, true]] call Zen_ArrayReplaceValue;
        ZEN_FMW_MP_REServerOnly("A3log", [name player + " has reported the detection of a fire at " + str _pos + " is a false alarm."], call)
    } else {
        0 = ["There are no detected fires within 100m of those coordinates."] call Zen_OF_PrintMessage;
    };
};

_crosshair = ["Text",
    ["Position", [19, 20]],
    ["Size", [2,2]],
    ["FontSize", 20],
    ["Text", "+"]
] call Zen_CreateControl;

_coordEntryX = ["TextField",
    ["Position", [16, 60]],
    ["Size", [4,2]]
    // ["FontSize", 20],
    // ["Text", ""]
] call Zen_CreateControl;

_coordEntryY = ["TextField",
    ["Position", [21, 60]],
    ["Size", [4,2]]
    // ["FontSize", 20],
    // ["Text", ""]
] call Zen_CreateControl;

_coordEntryComma = ["Text",
    ["Position", [20, 60]],
    ["Size", [1,2]],
    // ["FontSize", 20],
    ["Text", ","]
] call Zen_CreateControl;

_coordEntryText = ["Text",
    ["Position", [9, 60]],
    ["Size", [7,2]],
    // ["FontSize", 20],
    ["Text", "Enter Coordinates: "]
] call Zen_CreateControl;

_reportButton = ["Button",
    ["Position", [26, 60]],
    ["Size", [9,2]],
    // ["FontSize", 20],
    ["ActivationFunction", "Zen_OF_CameraGUIReportFire"],
    ["Text", "Execute"],
    ["LinksTo", [_coordEntryX, _coordEntryY]]
] call Zen_CreateControl;

_falseAlarmbutton = ["Button",
    ["Position", [26, 62]],
    ["Size", [9,2]],
    // ["FontSize", 20],
    ["ActivationFunction", "Zen_OF_CameraGUIReportFalse"],
    ["Text", "Fls Alrm"],
    ["LinksTo", [_coordEntryX, _coordEntryY]]
] call Zen_CreateControl;

_closeButton = ["Button",
    ["Position", [26, 64]],
    ["Size", [9,2]],
    // ["FontSize", 20],
    ["ActivationFunction", "Zen_OF_CameraGUIClose"],
    ["Text", "Map View"]
] call Zen_CreateControl;

Zen_OF_CameraGUICoordText = ["Text",
    ["Position", [17, 62]],
    ["Size", [6,2]],
    // ["FontSize", 20],
    ["Text", ""]
] call Zen_CreateControl;

Zen_OF_CameraGUIDialog = [] call Zen_CreateDialog;
{
    0 = [Zen_OF_CameraGUIDialog, _x] call Zen_LinkControl;
} forEach [_crosshair, Zen_OF_CameraGUICoordText, _coordEntryX, _coordEntryY, _coordEntryComma, _reportButton, _falseAlarmbutton, _coordEntryText, _closeButton, Zen_OF_GUIMessageBox];

// (findDisplay 46) displayAddEventHandler ["KeyDown", {
    // player commandChat str _this;
    // (false)
// }];
