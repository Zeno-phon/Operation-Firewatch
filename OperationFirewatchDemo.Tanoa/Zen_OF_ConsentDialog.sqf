//

#define PAGE_COUNT 3

Zen_OF_ConsentGUIAccepted = false;

Zen_OF_ConsentGUIAccept = {
    _lastPage = _this select 0;

    if (_lastPage) then {
        Zen_OF_ConsentGUIAccepted = true;
        player sideChat "You have accepted the terms.";
        ZEN_FMW_MP_REServerOnly("A3log", [name player + " has accepted the terms of the experiment participation consent agreement."], call)
        [] call Zen_CloseDialog;
    } else {
        player sideChat "You must read the terms in their entirety to accept.";
    };
};

Zen_OF_ConsentGUIDecline = {
    player sideChat "You have declined the terms.";
    ZEN_FMW_MP_REServerOnly("A3log", [name player + " has declined the terms of the experiment participation consent agreement."], call)
    [] call Zen_CloseDialog;
    "EndConsentDecline" call BIS_fnc_EndMission;
};

_totalString = "" +
#include "Consent.sqf"
;

_pages = [];

for "_i" from 0 to PAGE_COUNT do {
    _pages pushBack ([_totalString, "PAGEBREAK" + str _i, "PAGEBREAK" + str (_i + 1)] call Zen_StringGetDelimitedPart);
};

Zen_OF_ConsentGUIPageNext = {
    _pages = (_this select 0) select 0;
    _text = (_this select 0) select 1;
    _buttonAccept = (_this select 0) select 2;

    _data = [_text] call Zen_GetControlData;
    _page = 0;

    {
        if (toUpper (_x select 0) == "DATA") then {
            _page = _x select 1;
        };
    } forEach (_data select 2);

    if (_page < PAGE_COUNT - 1) then {
        0 = [_text, ["Text", _pages select (_page + 1)], ["Data", _page + 1]] call Zen_UpdateControl;

        if (_page == PAGE_COUNT - 2) then {
            0 = [_buttonAccept, ["Data", true], ["FontColor", [255, 255, 255, 255]]] call Zen_UpdateControl;
            0 = [0, [_text, _buttonAccept], "else"] call Zen_RefreshDialog;
        } else {
            0 = [0, [_text, _buttonAccept], "else"] call Zen_RefreshDialog;
        };
    };
};

Zen_OF_ConsentGUIPagePrevious = {
    _pages = (_this select 0) select 0;
    _text = (_this select 0) select 1;

    _data = [_text] call Zen_GetControlData;
    _page = 0;

    {
        if (toUpper (_x select 0) == "DATA") then {
            _page = _x select 1;
        };
    } forEach (_data select 2);

    if (_page > 0) then {
        0 = [_text, ["Text", _pages select (_page - 1)], ["Data", _page - 1]] call Zen_UpdateControl;
        0 = [0, [_text], "else"] call Zen_RefreshDialog;
    };
};

F_Test_Event = {
    player commandChat str _this;
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
    ["FontColor", [255, 0, 0, 255]],
    ["Data", false],
    ["ActivationFunction", "Zen_OF_ConsentGUIAccept"]
] call Zen_CreateControl;

_buttonDecline = ["Button",
    ["Text", "Decline"],
    ["FontSize", 16],
    ["Position", [-.75, 56]],
    ["Size", [5,4]],
    ["ActivationFunction", "Zen_OF_ConsentGUIDecline"]
] call Zen_CreateControl;

_consentText = ["StructuredText",
    ["Position", [0, 0]],
    ["Size", [40,54]],
    ["Data", 0],
    // ["Event", [["MOUSEZCHANGED", "F_Test_Event"]]],
    ["Text", _pages select 0]
] call Zen_CreateControl;

_buttonPageNext = ["Button",
    ["Text", "Next Page"],
    // ["FontSize", 14],
    ["Position", [34, 54]],
    ["Size", [5,2]],
    ["Data", [_pages, _consentText, _buttonAccept]],
    ["ActivationFunction", "Zen_OF_ConsentGUIPageNext"]
] call Zen_CreateControl;

_buttonPagePrevious = ["Button",
    ["Text", "Previous Page"],
    // ["FontSize", 14],
    ["Position", [0, 54]],
    ["Size", [5,2]],
    ["Data", [_pages, _consentText]],
    ["ActivationFunction", "Zen_OF_ConsentGUIPagePrevious"]
] call Zen_CreateControl;

Zen_OF_ConsentDialog = [] call Zen_CreateDialog;

{
    0 = [Zen_OF_ConsentDialog, _x] call Zen_LinkControl;
} forEach [_background, _buttonAccept, _buttonDecline, _consentText, _buttonPageNext, _buttonPagePrevious];

0 = [Zen_OF_ConsentDialog, [0.025 * -5, 0.025 * -10], false, true] call Zen_InvokeDialog;

waitUntil {
    (Zen_OF_ConsentGUIAccepted)
};

