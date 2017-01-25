// Zen_OF_SpawnZoneAAA

#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"
#include "..\Zen_FrameworkFunctions\Zen_FrameworkLibrary.sqf"

_Zen_stack_Trace = ["Zen_OF_SpawnZoneAAA", _this] call Zen_StackAdd;
private ["_nameString", "_density", "_classname", "_binStops", "_markers", "_dataArray", "_area", "_cacheId", "_AAA", "_rand", "_index", "_mkr", "_pos", "_veh"];

if !([_this, [["STRING"], ["SCALAR"], ["STRING"]], [], 3] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
};

_nameString = _this select 0;
_density = _this select 1; // AAA per km^2
_classname = _this select 2;

// a repeat of the Zen_OF_GetZoneData search algorithm
// this time we do not take a copy of the data ('=+') but rather a reference to it ('=')
_dataArray = [];
{
    if ([(_x select 0), _nameString] call Zen_ValuesAreEqual) exitWith {
        _dataArray = _x;
    };
} forEach Zen_OF_Zones_Global;

if (count _dataArray == 0) exitWith {
    ZEN_FMW_Code_ErrorExitVoid("Zen_OF_SpawnZoneAAA", "Given zone does not exist")
};

/**  What we need to do here is create a distribution function for which marker to select that depends upon the area of the markers.  We want to select a marker at random and then generate a random point within that marker such that over many random selections we produce a pattern that is spatially random overall.  The distribution function uses a bin system in which the width of each bin is the area of each corresponding marker.  We generate a random number from the the sum of all areas and then find which bin it falls into. **/

_markers = _dataArray select 2;
// the bins must start at zero and have the areas offset by one to align with the right marker when selection occurs
_binStops = [0];
{
    // a rolling, stored summation
    _binStops pushBack ((_binStops select _forEachIndex) + ZEN_STD_Math_MarkerArea(_x));
} forEach _markers;

// we apply the density parameter to the total area (i.e. the final bin end)
_AAA = [];
// player sideChat str (ZEN_STD_Array_LastElement(_binStops) * _density);
for "_i" from 1 to round (ZEN_STD_Array_LastElement(_binStops) * _density) step 1 do {
    _rand = random ZEN_STD_Array_LastElement(_binStops);
    _index = 0;
    {
        // if the random number fits in this bin, choose the aligned marker
        if ((_rand > _x) && {_rand < (_binStops select (_forEachIndex + 1))}) exitWith {
            _index = _forEachIndex;
        };
    } forEach _binStops;

    // spawn the AAA in the marker and store it
    _mkr = _markers select _index;
    _pos = [_mkr, 0, [], ZEN_FMW_ZFGP_LandingZone] call Zen_FindGroundPosition;
    _veh = [_pos, _classname, random 360] call Zen_SpawnGroundVehicle;
    0 = [crew _veh, "player"] call Zen_SetAISkill;
    _AAA pushBack [[_veh, crew _veh]];
};

// all of the AAA are cached at once and the zone data updated
_cacheId = [_AAA] call Zen_Cache;
_dataArray set [3, _cacheId];
publicVariable "Zen_OF_Zones_Global";

call Zen_StackRemove;
if (true) exitWith {};
