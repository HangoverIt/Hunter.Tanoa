params [["_editor", false]] ;
WaitUntil {!isNil "HunterSectors"} ;
private _first = false ;
private _hyp = sqrt (2 * (worldSize * worldSize)) ;

// If the global location list is not set then create.
if (isNil "HunterLocations") then {
  _first = true ;
  HunterLocations = [] ;
  private _location_classes = [] ;
  {_location_classes pushBack (_x select 0);} foreach HUNTER_SPAWN_LOCATIONS ;
  _location_classes = _location_classes - [HUNTER_CUSTOM_LOCATION] ;
  private _all_locations = nearestLocations[[worldSize / 2, worldSize / 2], _location_classes, _hyp / 2] ;

  {
    _pos = locationPosition _x ;
            
    // Capture any vehicles created in the editor within range of a location
    _size = size _x ;
    _max_size = (_size select 0) max (_size select 1) ;
    _listvehicles = ([HUNTER_SAVE_CLASSES, _pos, _max_size, [west,civilian]] call h_createSaveList) ;
    
    // Class, Name, Position, Size, Related Sector, Percent occupied, savedvehicles, tmpspawnedmen, tmpspawnedvehicles, active
    HunterLocations pushBack [type _x, text _x, _pos, size _x, [], 100, _listvehicles,[],[], false, dateToNumber date] ;
    
  } forEach _all_locations;
};

// Custom game locations defined using map markers.
// Always execute here to define the custom locations before defining triggers and linking to sectors
_prelen = count HUNTER_SPECIAL_MARKER_PREFIX;
{
	if (_x find HUNTER_SPECIAL_MARKER_PREFIX == 0) then {
	  //special marker found
	  _mkrlen = count _x ;
	  _special_location_name = _x select [_prelen, _mkrlen - _prelen] ;
	  _special_file = _special_location_name + ".sqf" ;
	  _size = [markerPos _x, HUNTER_PREDEFINED_DIR + "\" + _special_file, markerDir _x, false] call compile preprocessFileLineNumbers "utility\create_structure.sqf" ;
	  diag_log format ["size of bounding area is %1", _size] ;
	  _size = [(_size select 0) + 50, (_size select 1) + 50] ; // expand size slightly as size is exact rectangle of objects created
	  _max_size = (_size select 0) max (_size select 1) ; // define max bounds for circle
	  
	  {
		_x hideObjectGlobal true ;
		deleteVehicle _x ;
		//diag_log format["deleting terrain object %1 within radius %2", _x, (_max_size /2)];
	  } forEach (nearestTerrainObjects [(markerPos _x) ,[], _max_size / 2]) ;
	  
	  [markerPos _x, HUNTER_PREDEFINED_DIR + "\" + _special_file, markerDir _x] call compile preprocessFileLineNumbers "utility\create_structure.sqf" ;

    if (_first) then {
      _listvehicles = ([HUNTER_SAVE_CLASSES, markerPos _x, _max_size, [west,civilian]] call h_createSaveList) ;
      
      // add to locations
      HunterLocations pushBack [_special_location_name, _special_location_name, markerPos _x, _size, [], 100, _listvehicles, [], [], false, dateToNumber date] ;
    };
	  deleteMarker _x ; 
	}
}forEach allMapMarkers ;
  
// Define custom locations for patrols. Only needs running once to seed locations
if (_first) then {
  [] call compileFinal preprocessFileLineNumbers HUNTER_CUSTOM_LOCATION_FILE ;
  
  // if no custom location defined then define in code
  // Really slow check of houses, if not in a location area or close to existing house then add to game locations
  _houses = [] ;
  if (({(_x select 0) == HUNTER_CUSTOM_LOCATION} count HunterLocations) == 0) then {
    _map_houses = nearestObjects [[worldSize / 2, worldSize / 2], ["house"], _hyp / 2];
    diag_log format ["Defining custom locations from %1 houses in world", count _map_houses] ;
    _clipboard = "" ;
    _br = toString [13,10];
    {
      _obj = _x ;
      _objpos = position _x ;
      _patrolsize = 100 ;
      _placelocation = true ;
      
      {
        _l_pos = (_x select 2) ;
        _l_size = (_x select 3) ;
        _max_size = (_l_size select 0) max (_l_size select 1) ;
        if (_objpos inArea[[(_l_pos select 0), (_l_pos select 1)], _max_size + _patrolsize, _max_size + _patrolsize, 0, true, -1]) exitWith {
          _placelocation = false ;
        };
      }forEach HunterLocations ;
      
      if (_placelocation) then {
        {
          if (_objpos inArea[[(_x select 0), (_x select 1)], _patrolsize * HUNTER_CUSTOM_LOCATION_SPACING_FACTOR, _patrolsize * HUNTER_CUSTOM_LOCATION_SPACING_FACTOR, 0, true, -1]) exitWith {
            _placelocation = false ;
          };
        }forEach _houses ;
      };
      
      if (_placelocation) then {
        _houses pushBack _objpos ;
        _listvehicles = ([HUNTER_SAVE_CLASSES, _objpos, _patrolsize, [west,civilian]] call h_createSaveList) ;
        HunterLocations pushBack [HUNTER_CUSTOM_LOCATION, format ["Patrol%1", _objpos], _objpos, [_patrolsize, _patrolsize], [], 100, _listvehicles,[],[],false, dateToNumber date] ;
        _clipboard = _clipboard + "HunterLocations pushBack " + str([HUNTER_CUSTOM_LOCATION, format ["Patrol%1", _objpos], _objpos, [_patrolsize, _patrolsize], [], 100, [],[],[],false, dateToNumber date]) + ";" + _br ;
      } ;
    }forEach _map_houses ;
    
    copyToClipboard _clipboard;
  };
} ;

// Add sectors, remove vehicles and set triggers for locations
if (!_editor) then {
  {
    _l_type = (_x select 0) ;
    _l_name = (_x select 1) ;
    _l_pos = (_x select 2) ;
    _l_size = (_x select 3) ;
    //_l_sector = (_x select 4) ;
    _l_percent = (_x select 5) ;
    
    // Associate all sectors with locations
    _l_sector = [] ;
    // Match and cache locations to sectors. Slow function run once per game.
    {
      _spos = [_x] call h_getSectorLocation ;
      _size = [_x] call h_getSectorSize ;
      if (_l_pos inArea[[(_spos select 0), (_spos select 1)], ((_size select 0) / 2), ((_size select 1) / 2), 0, true, -1]) exitWith {
        _l_sector = _x;
      };
    }forEach HunterSectors ;
    //diag_log format ["%1: creating location %2, type %3, size %4, in sector %5", time, _l_name, _l_type, _l_size, [_l_sector] call h_getSectorName] ;
    
    // Set reference to sector array
    _x set [4, _l_sector] ;
    
    // Reset spawn flags before defining the triggers
    _x set [9, false] ;
    
    _max_size = (_l_size select 0) max (_l_size select 1) ;
    
    // Delete vehicles (curated in editor)
    {
      {
        _veh = _x ;
        {_veh deleteVehicleCrew _x } forEach crew _veh;
        deleteVehicle _veh ;
      }forEach (_l_pos nearObjects [_x, _max_size ]);
    }forEach HUNTER_SAVE_CLASSES;
    
      // Define trigger for location spawn
    _trg = createTrigger["EmptyDetector", _l_pos, true] ;
    _trg setTriggerActivation ["ANYPLAYER", "PRESENT", true];
    if (_l_type == HUNTER_CUSTOM_LOCATION) then {
      _trg setTriggerArea [HUNTER_CUSTOM_RADIUS_SPAWN, HUNTER_CUSTOM_RADIUS_SPAWN, 0, false];
    }else{
      _trg setTriggerArea [HUNTER_LOCATION_RADIUS_SPAWN, HUNTER_LOCATION_RADIUS_SPAWN, 0, false];
    };
    _trg setVariable ["Location", _x] ;
    _trg setVariable ["Spawned", false] ;
    _trg setTriggerStatements 
    [
      "this", 
      "[thisTrigger] remoteExec [""trigger_spawn_location"", 2, false];", 
      "[thisTrigger] remoteExec [""trigger_despawn_location"", 2, false];"
    ];
    
  } forEach HunterLocations;
};
// broadcast locations to clients
publicVariable "HunterLocations" ;