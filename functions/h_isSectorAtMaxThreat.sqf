params ["_sector"] ;

// Null sectors have no elements in array
if (count _sector == 0) exitWith {false;};

private _actual = _sector select 5; // Actual Threat Parameter
private _max = _sector select 4 ; // Max Threat Parameter

_actual >= _max ;