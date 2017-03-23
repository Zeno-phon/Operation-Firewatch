//

// Numpad codes
// 69 181 55 74
// 71 72  73
// 75 76  77 78
// 79 80  81
// 82     83 156

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
#define CAMERA_LASE 156
#define CAMERA_EXIT 82

#define CAMERA_SLEW_TIME 0.1
#define CAMERA_SLEW_FRACTION 15
#define CAMERA_SLEW_ZOOM_STEP 0.1

Zen_OF_CameraGUIInvoke= {
    0 = [Zen_OF_CameraGUIDialog, [0, 0], false, true] call Zen_InvokeDialog;

    player sideChat "Press Numpad 0 to exit camera view.";
    (findDisplay 76) displayAddEventHandler ["KeyDown", {
        0 = _this spawn {
            if ((_this select 1) == CAMERA_EXIT) then {
                [] call Zen_OF_CameraGUIClose;
            };
        };

        (false)
    }];

    player sideChat "Press Numpad Enter to obtain target coordinates.";
    (findDisplay 76) displayAddEventHandler ["KeyDown", {
        0 = _this spawn {
            if ((_this select 1) == CAMERA_LASE) then {
                [] call Zen_OF_CameraGUICoord;
            };
        };

        (false)
    }];

    if (Zen_OF_User_Group_Index < 2) then {
        player sideChat "Press the Numpad arrow keys to move camera.";
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

        player sideChat "Press the Numpad + and - keys to zoom camera.";
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
    player sideChat str (screenToWorld [0.5, 0.5]);
};

Zen_OF_CameraGUIClose = {
    player switchCamera "INTERNAL";
    player cameraEffect ["terminate","back"];
    (findDisplay 76) displayRemoveAllEventHandlers "KeyDown";
    [] call Zen_CloseDialog;
    call Zen_OF_DroneGUIInvoke;
};

Zen_OF_CameraGUIDialog = [] call Zen_CreateDialog;
// {
    // 0 = [Zen_OF_CameraGUIDialog, _x] call Zen_LinkControl;
// } forEach [];

// (findDisplay 46) displayAddEventHandler ["KeyDown", {
    // player commandChat str _this;
    // (false)
// }];
