params["_classes", "_pos", "_radius", ["_side", [east,west,civilian,resistance]]] ; // independent alias for resistance

private _listobjs = [] ;
private _savelist = [] ;

// suggested base classes ["Car", "Tank", "Helicopter", "Ship", "StaticWeapon", "Plane", "ReammoBox_F", "Man"] ;
// OBJITEM = [class, ATLpos, direction, [[cargo, ammocargo, weaponscargo], [crew]] 

// Get a list of all nearby objects
{
  _listobjs append (_pos nearObjects [_x, _radius ]);
}forEach _classes;

// Create a save list of object positions if alive
{
  // Ignore spawned location objects
  _vehpos = _x getVariable "Location" ;
  _playable = playableUnits ;
  if (!isMultiplayer && hasInterface) then {
    _playable = [player] ;
  };

  if ((isNil "_vehpos") &&
      !([_x] call h_isManagedVehicle) &&
      !([_x] call h_isMissionVehicle) &&
      (alive _x) &&
      ( speed _x < 5 ) &&
      ( isNull  attachedTo _x ) &&
      (((getpos _x) select 2) < 10 ) &&
      (side _x in _side) && !(_x in _playable)) then {
    _crew = [] ;
    // Save crew if class can hold crew
    if (_x isKindOf "Car" || _x isKindOf "Tank" || _x isKindOf "Helicopter" || _x isKindOf "Ship" || _x isKindOf "StaticWeapon" || _x isKindOf "Plane") then {
      {if (!isPlayer _x && alive _x) then {_crew pushBack typeOf _x};} forEach (crew _x) ;
    };
    
    // Save contents of vehicle or crate
    _contents = [itemCargo _x, magazinesAmmoCargo _x, weaponsItemsCargo _x, backpackCargo _x] ;
    _containers = [] ;
    {
      _cont = (_x select 1) ;
      _containers pushBack [_x select 0, itemCargo _cont, magazinesAmmoCargo _cont, weaponsItemsCargo _cont, backpackCargo _cont] ;
      //diag_log format ["Saving container %1", [_x select 0, itemCargo _cont, magazinesAmmoCargo _cont, weaponsItemsCargo _cont, backpackCargo _cont]] ;
    }forEach everyContainer _x;
    _contents pushBack _containers ;

    _savelist pushBack [typeof _x, getPosATL _x, getDir _x, _contents, _crew];
  };
} forEach _listobjs ;

_savelist;