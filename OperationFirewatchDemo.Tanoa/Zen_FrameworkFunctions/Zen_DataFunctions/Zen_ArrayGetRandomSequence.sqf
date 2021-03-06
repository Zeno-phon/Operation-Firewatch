// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "..\Zen_StandardLibrary.sqf";
#include "..\Zen_FrameworkLibrary.sqf";

_Zen_stack_Trace = ["Zen_ArrayGetRandomSequence", _this] call Zen_StackAdd;
private ["_array", "_number", "_iterator", "_return", "_remove"];

if !([_this, [["ARRAY"], ["SCALAR"], ["BOOL"]], [], 2] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ([])
};

_array = _this select 0;
_number = _this select 1;
ZEN_STD_Parse_GetArgumentDefault(_remove, 2, false)

_return = [];
if (_remove) then {
    for "i" from 1 to _number do {
        _index = ZEN_STD_Array_RandIndex(_array);
        _return pushBack (_array select _index);
        0 = [_array, _index] call Zen_ArrayRemoveIndex;
    };
} else {
    _iterator = [];
    for "_i" from 0 to (count _array - 1) do {
        _iterator pushBack _i;
    };

    0 = [_iterator] call Zen_ArrayShuffle;
    for "_i" from 1 to _number do {
        _return pushBack (_array select (_iterator select (_i - 1)));
    };
};

call Zen_StackRemove;
(_return)
