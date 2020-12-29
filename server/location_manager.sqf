params[["_oneoff", false]] ;

WaitUntil {!isNil "HunterSectors"} ;
WaitUntil {!isNil "HunterLocations"} ;

private _min = ((1/365)/24)/60 ;
private _savetimeout = 0 ;
private _timeframe = 5 ;
private _tmplocationinfo = [] ;

// Create an array to hold temporary info
for "_i" from 0 to (count HunterLocations - 1) do {
  // Hold the resupply spawn handle
  _tmplocationinfo pushBack [scriptNull];
};
diag_log format ["Created tmp array %1", _tmplocationinfo] ;

// Loop forever
while {true} do {
  
  _savetimeout = _savetimeout + _timeframe;
  {
    _l_type = (_x select 0) ;
    _l_name = (_x select 1) ;
    _l_pos = (_x select 2) ;
    _l_size = (_x select 3) ;
    _l_sector = (_x select 4) ;
    _l_percent = (_x select 5) ;
    _l_vehicles = (_x select 6) ;
    //_l_spawned_men = (_x select 7);
    //_l_spawned_veh = (_x select 8);
    _l_active = (_x select 9) ;
    _l_next_reinforce_time = (_x select 10) ;
    
    _now = dateToNumber date ; // game time as float number
    
    _thislocationtmp = _tmplocationinfo select _forEachIndex ;

    _max_size = (_l_size select 0) max (_l_size select 1) ;
   
    // Draw locations on map
    if (!isNil "HUNTER_SHOW_LOCATION_AREA" && HUNTER_SHOW_LOCATION_AREA) then {
      _mkr = createMarkerLocal ["mkrArea" + _l_name, _l_pos] ;
      _mkr = "mkrArea" + _l_name;
      _mkr setMarkerShapeLocal "ELLIPSE" ;
      _mkr setMarkerBrushLocal "Solid" ;
      if (_l_percent > 0) then {
        deleteMarker ("respawn_west_" + _l_name) ;
        _mkr setMarkerColorLocal "ColorRed" ;
        if (_l_type == HUNTER_CUSTOM_LOCATION) then {
          _mkr setMarkerColorLocal "ColorOrange" ;
        } ;
        _mkr setMarkerAlphaLocal (_l_percent / 100) + 0.1 ; // add 10% to keep it a bit more visible on map
      }else{
        if (_l_type != HUNTER_CUSTOM_LOCATION) then {
          _rspwn = createMarker ["respawn_west_" + _l_name, _l_pos] ;
        } ;
        _mkr setMarkerColorLocal "ColorBlue" ;
        _mkr setMarkerAlphaLocal (0.8) ;
      };
      // Final marker command sets the changes global
      _mkr setMarkerSize [_max_size, _max_size] ;
    };
    
    // Save vehicles
    if (_l_active && (_savetimeout >= HUNTER_LOCATION_CAPTURE_PERIOD)) then {
      // Finally save any remaining units back into location
      private _listvehicles = ([HUNTER_SAVE_CLASSES, _l_pos, _max_size, [west,civilian]] call h_createSaveList) ;
      
      // Save vehicles back to the location
      _x set [6, _listvehicles] ;
      //diag_log format["%1: Location_manager saved %2 objects at active location %3", time, _listvehicles, _l_name] ;
    };
    
    // If the max threat has been reached and the next reinforce time is less that the standard threat timeout then push back next reinforcement
    if ([_l_sector] call h_isSectorAtMaxThreat && _l_next_reinforce_time < _now + (HUNTER_LOCATION_STD_THREAT_COOLDOWN *_min)) then {
      // Threat has hit max capacity, opposing forces will not reinforce for a longer time
      diag_log format ["%1: Location %2 has exceeded the max threat, the enemy have retreated for %3 minutes", time, _l_name, HUNTER_LOCATION_MAX_THREAT_COOLDOWN] ;
      _x set [10, _now + (HUNTER_LOCATION_MAX_THREAT_COOLDOWN *_min)] ;
    };
    
    if (_now >= _l_next_reinforce_time && _l_percent < 100 && isNull (_thislocationtmp select 0)) then {
      // Reinforcement timeout expired, the location is below 100% strength and there's not current reinforcement spawned
      
      // Set next reinforcement timeout
      _x set [10, _now + (HUNTER_LOCATION_STD_THREAT_COOLDOWN *_min)] ;
      
      _handle = [_x] spawn createLocationSupply ;
      _thislocationtmp set [0, _handle] ;
    };

  }forEach HunterLocations ;
  
  if (_savetimeout >= HUNTER_LOCATION_CAPTURE_PERIOD) then {
    _savetimeout = 0 ;
  } ;
  
  if (_oneoff) exitWith {} ;
  sleep _timeframe ;
};