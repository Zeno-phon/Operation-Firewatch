//

Zen_OF_ConsentGUIAccepted = false;
Zen_OF_ConsentGUIAccept = {
    Zen_OF_ConsentGUIAccepted = true;
    player sideChat "You have accepted the terms.";
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has accepted the terms of the experiment participation consent agreement."], call)
    [] call Zen_CloseDialog;
};

Zen_OF_ConsentGUIDecline = {
    player sideChat "You have declined the terms.";
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has declined the terms of the experiment participation consent agreement."], call)
    [] call Zen_CloseDialog;
    "EndConsentDecline" call BIS_fnc_EndMission;
};

_background = ["Picture",
    ["Position", [-30, -10]],
    ["Size", [120,90]],
    ["Picture", "images\blank.paa"]
] call Zen_CreateControl;

_buttonAccept = ["Button",
    ["Text", "Accept"],
    ["FontSize", 16],
    ["Position", [34, 56]],
    ["Size", [5,4]],
    ["ActivationFunction", "Zen_OF_ConsentGUIAccept"]
] call Zen_CreateControl;

_buttonDecline = ["Button",
    ["Text", "Decline"],
    ["FontSize", 16],
    ["Position", [-.5, 56]],
    ["Size", [5,4]],
    ["ActivationFunction", "Zen_OF_ConsentGUIDecline"]
] call Zen_CreateControl;

_consentText = ["StructuredText",
    ["Position", [0, 0]],
    ["Size", [40,56]],
    ["Text",
#include "Consent.sqf"
]
] call Zen_CreateControl;

Zen_OF_ConsentDialog = [] call Zen_CreateDialog;

{
    0 = [Zen_OF_ConsentDialog, _x] call Zen_LinkControl;
} forEach [_background, _buttonAccept, _buttonDecline, _consentText];

0 = [Zen_OF_ConsentDialog, [0.025 * -5, 0.025 * -10], false, false] call Zen_InvokeDialog;

waitUntil {
    (Zen_OF_ConsentGUIAccepted)
};
