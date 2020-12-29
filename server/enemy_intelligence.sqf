waitUntil {!isNil "HunterSectors"} ;

// Define global array of killed items.
// This is used by the kill_manager to record activity and when it happened
// Format: [time, location, processed]
HunterKillList = [0,[]] ;
private _markercache = [] ;
private _min = ((1/365)/24)/60 ;
private _maxage = HUNTER_HEATMAP_AGE * _min; // measured in minutes
private _radius = 500 ; // 1km resolution
private _spotter_handle = scriptNull ;
private _sad_handle = scriptNull ;
private _cas_null = [0,0,[0,0,0]] ;
private _airstrike_timeout = HUNTER_CAS_TIMEOUT * _min; // measured in minutes
private _last_airstrike = 0 ;

// Heatmap: [time, hits, heatmapposition] ;
// HunterHeatMap definition required
if (isNil "HunterHeatMap") then {
  HunterHeatMap = [] ;
};

while{true} do {

  _now = dateToNumber date ;
  _is_new = true ;
  
  // Remove old heat map items
  for "_i" from count HunterHeatMap - 1 to 0 step -1 do {
    _hm = HunterHeatMap select _i ;
    _hm_time = _hm select 0;
    if (_hm_time + _maxage < _now) then {
      HunterHeatMap deleteAt _i ;
    };
  };
      
  // Go through all data
  {
    _kill_time = _x select 0;
    _kill_loc = _x select 1;
    _kill_processed = _x select 2;
    
    // Only interested in unprocessed kills that are not old
    if (!_kill_processed && (_kill_time + _maxage) > _now) then {

      _is_new = true ;
      // Iterate all heat maps and if within radius of an existing heat map then combine
      {
        _hm_hits = _x select 1 ;
        _hm_loc = _x select 2 ;
        _distance = _kill_loc distance2D _hm_loc ;
        if (_distance < _radius && _is_new) then {
          // Existing location within heat location
          _diff = _kill_loc vectorDiff _hm_loc ;
          _moveby = _diff vectorMultiply (1 / (_hm_hits+1));
          _newloc = _hm_loc vectorAdd _moveby ;
          diag_log format ["%1: updating intelligence on last action, _hm_loc %5, _kill_loc %6, _diff %2, _moveby %3, _newloc %4", time, _diff, _moveby, _newloc, _hm_loc, _kill_loc] ;
          _x set[0, dateToNumber date] ; // update time
          _x set[1, _hm_hits + 1] ;
          _x set[2, _newloc] ;
          _is_new = false ;
        };
      }forEach HunterHeatMap ;
      diag_log format["%1: new kill registered for heat map at %2. Is kill new - %3", time, _kill_loc, _is_new] ;
     
      
      // New location 
      if (_is_new) then {
        HunterHeatMap pushBack [_now, 1, _kill_loc];
      };
      
      _x set[2,true] ; // kill has been processed
      
    };
    
  }forEach (HunterKillList select 1);
  
  // Remove old markers
  {
    deleteMarker _x ;
  }forEach _markercache ;
  _markercache = [] ;
  
  _cas_hm = _cas_null ;
  // Update markers
  {
    _hm_time = _x select 0;
    _hm_hits = _x select 1 ;
    _hm_loc = _x select 2 ;
    _mkr = createMarkerLocal[format["mkr%1",_hm_loc], _hm_loc] ;
    _mkr setMarkerTypeLocal "hd_unknown" ;
    _mkr setMarkerColorLocal "ColorRed" ;
    _mkr setMarkerAlpha (_maxage / (_maxage - (_now - _hm_time)));
    _markercache pushBack _mkr ; // cache the marker
    
    // If hits threshold exceeded and last hit was under 2 min ago then log as target
    if (_hm_hits > HUNTER_HEAT_THRESHOLD && ((_now - _hm_time) / _min) <= 2) then {
      if ((_cas_hm select 1) < _hm_hits) then {
        _cas_hm = _x ;
      };
    };
  }forEach HunterHeatMap ;
  
  // Exclude any heat maps in max threat sectors (player temporary capture)
  _ownedsectorcount = {_sector = [HunterSectors, (_x select 2)] call h_getSectorFromPosition; !([_sector] call h_isSectorAtMaxThreat);} count HunterHeatMap;
  
  // If hunter squads have hit multiple targets in the timeout period then send a spotter plane
  if (_ownedsectorcount >= 2 && isNull _spotter_handle) then {
    _spotter_handle = [] spawn create_spotter ;
  };
  
  // Send out a search and destroy group if heatmap has any entries
  if (_ownedsectorcount > 0 && isNull _sad_handle) then {
    _sad_handle = [] spawn create_sad ;
  };
  
  _perform_cas_run = false ;
  _cas_target = [0,0,0];
  _cas_type = 3 ;
  // Check if time since last CAS check has expired 
  if (_now > (_last_airstrike + _airstrike_timeout)) then {
    // if there's no recent heat map target, but spotter has seen players then attack the spotter target
    if (_cas_hm isEqualTo _cas_null && !isNil "HunterSpotterLastSeen") then {
      if (((_now - (HunterSpotterLastSeen select 1)) / _min) < 4) then {
        _perform_cas_run = true ;
        _cas_target = (HunterSpotterLastSeen select 0);
        _cas_type = 3 ; // bomb run 
        diag_log format ["CAS started to position %1, for a bomb run on spotter target", _cas_target] ;
      };
    }else{
      // has there been a recent heat map attack? 
      if (!(_cas_hm isEqualTo _cas_null)) then {
        _perform_cas_run = true ;
        _cas_target = (_cas_hm select 2);
        _cas_type = 2 ; // guns and missiles
        diag_log format ["CAS started to position %1, for a missles and gun run on heat map target", _cas_target] ;
      };
    };
  
    if (_perform_cas_run) then {
      _last_airstrike = _now ;
	  // Look for valid target in close vicinity
	  {
	    _obj = _x ;
	    if({_obj isKindof _x} count ["Car", "Tank", "Helicopter", "Ship", "StaticWeapon", "Plane"] > 0) then {
		  if (alive _obj && side _obj == west && !([_obj] call h_isInTrees)) exitWith {
		    _cas_target = getPosATL _obj ;
		  };
		};
	  } forEach (_cas_target nearObjects 50) ;
      _logic = "Logic" createVehicleLocal _cas_target;
      _logic setDir (random 360);
      _logic setVariable ["vehicle","O_Plane_CAS_02_F"];
      _logic setVariable ["type",_cas_type]; 

      [_logic,nil,true] call BIS_fnc_moduleCAS;

      deleteVehicle _logic;
    };
    
  }; 
  
  sleep 30 ;
};