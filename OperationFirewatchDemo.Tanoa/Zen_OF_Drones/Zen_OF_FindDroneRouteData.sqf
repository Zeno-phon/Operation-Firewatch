// Zen_OF_FindDroneRouteData

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

// #define FUEL_FRACTION_PER_METER (1. / 100000.)
#define FUEL_FRACTION_PER_SEC (1. / 60. / 60. / 1.)

_Zen_stack_Trace = ["Zen_OF_FindDroneRouteData", _this] call Zen_StackAdd;
private ["_pathArray", "_nameString", "_droneObj", "_prevFuel", "_speed", "_prevPos", "_result", "_nextPos", "_dist", "_nextFuel", "_droneClassData"];

if !([_this, [["STRING"]], [], 1] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    ([])
};

_nameString = _this select 0;
_droneObj = objNull;
_prevFuel = 0;
_pathArray = [];

{
    if ([(_x select 0), _nameString] call Zen_ValuesAreEqual) exitWith {
        _droneObj = (_x select 1);
        _prevFuel = (_x select 3);
        _pathArray = (_x select 7) select (_x select 9);
    };
} forEach Zen_OF_Drones_Local;

if (isNil "_pathArray" or {(count _pathArray == 0)}) exitWith {
    ZEN_FMW_Code_ErrorExitValue("Zen_OF_FindDroneRouteData", "Given drone does not exist or has no paths.", [])
};

_droneClassData = [_droneObj] call Zen_OF_GetDroneClassData;
_speed = _droneClassData select 0;

_prevPos = getPosATL _droneObj;

_result = [];
{
    _nextPos = _x;
    _dist = [_prevPos, _nextPos] call Zen_Find2dDistance;
    // _nextFuel = _prevFuel - _dist * FUEL_FRACTION_PER_METER;
    _nextFuel = _prevFuel - _dist / _speed * FUEL_FRACTION_PER_SEC;

    _result pushBack [round _dist, round (_dist / _speed), round (100 * _nextFuel), round (_nextFuel / FUEL_FRACTION_PER_SEC / 60.)];

    _prevPos = _x;
    _prevFuel = _nextFuel;
} forEach _pathArray;

call Zen_StackRemove;
(_result)
