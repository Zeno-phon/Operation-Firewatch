// Zen_OF_DeleteZoneAAA

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_DeleteZoneAAA", _this] call Zen_StackAdd;
private ["_nameString", "_cacheId", "_cacheUnits", "_dataArray"];

if !([_this, [["STRING"]], [], 1] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_nameString = _this select 0;

// a repeat of the Zen_OF_GetZoneData search algorithm
// this time we do not take a copy of the data ('=+') but rather a reference to it ('=')
_dataArray = [];
{
    if ([(_x select 0), _nameString] call Zen_ValuesAreEqual) exitWith {
        _dataArray = _x;
    };
} forEach Zen_OF_Zones_Global;

if (count _dataArray == 0) exitWith {
    0 = ["Zen_OF_UpdateZone", "Given zone does not exist", _this] call Zen_PrintError;
    call Zen_StackPrint;
};

// This deals with cached units, there is a lot of framework documentation about the cache system
_cacheId = _dataArray select 3;
if ([_cacheId] call Zen_IsCached) then {
    0 = [_cacheId] call Zen_UnCache;
};

_cacheUnits = [_cacheId] call Zen_GetCachedUnits;
0 = [_cacheUnits, _cacheId] call Zen_UnassignCache;
{
    deleteVehicle _x;
} forEach ([_cacheUnits] call Zen_ConvertToObjectArray);

0 = [_cacheId] call Zen_RemoveCache;

_dataArray set [3, ""];
publicVariable "Zen_OF_Zones_Global";

call Zen_StackRemove;
if (true) exitWith {};
