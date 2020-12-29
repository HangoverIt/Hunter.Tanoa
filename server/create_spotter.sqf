// No params required, just needs heat map and sectors defined.
// If not defined then exit as nothing can be done until defined
if (isNil "HunterHeatMap" || isNil "HunterSectors") exitWith {
  diag_log "Attempted to create a spotter but heat map and sectors are undefined!" ;
} ;

// Global variable defined by a spotter. Last location and time.
HunterSpotterLastSeen = [[0,0,0],0];

private _max_threat = 0 ;

// Get the sector threat
{
  _hm = _x ;
  _hm_location = _hm select 2 ;
  _sector = [HunterSectors, _hm_location] call h_getSectorFromPosition ;
  if (! ([_sector] call h_isSectorAtMaxThreat) ) then {
    if (count _sector > 0) then { // check return is not null sector
      _sector_threat = [_sector] call h_getSectorThreat ;
      if (_sector_threat > _max_threat) then {
        _max_threat = _sector_threat;
      };
    };
  };
}forEach HunterHeatMap ;

private _arrow1 = "Sign_Arrow_Cyan_F" createvehicle [0,0,0];
//private _arrow2 = "Sign_Arrow_Yellow_F" createVehicle [0,0,0] ;

private _airclass = [HUNTER_THREAT_SPOTTER_AIR, _max_threat] call h_getRandomThreat;

// Edge of map spawn
private _spawn_at = [0,15000,200] ;

_grp = createGroup east ;
private _spotter = createVehicle["C_Plane_Civil_01_F", _spawn_at, [], 0, "FLY"] ;

_movein = true ;
while{_movein} do {
  _spotterunit = _grp createUnit["O_Pilot_F", [0,0,0], [], 0, "NONE" ] ;
  _movein = _spotterunit moveInAny _spotter ;
  if (!_movein) then {deleteVehicle _spotterunit ;};
};
diag_log format["Spotter vehicle created with %1 units", count units _grp];


_spotter flyInHeight 150;
private _heatmapcount = 0 ; //Won't match on first iteration

// Keep spotting until a timeout or fuel is low
while {alive _spotter && ({ alive _x } count (units _grp) > 0) && fuel _spotter > 0.2 && count HunterHeatMap >= 3} do {
  sleep 2;
  
  if (count HunterHeatMap != _heatmapcount) then {
    _heatmapcount = count HunterHeatMap ;
    while {(count (waypoints _grp)) != 0} do {deleteWaypoint ((waypoints _grp) select 0);};

    {
      _hm_location = _x select 2 ;
      _wp = _grp addWaypoint [_hm_location, 300] ;
      _wp setWaypointType "MOVE";
      _wp setWaypointCompletionRadius 300;
      
    }forEach HunterHeatMap ;

    // Cycle back to first waypoint
    _cycle_at = (HunterHeatMap select 0) select 2;
    _wp = _grp addWaypoint [_cycle_at, 300] ;
    _wp setWaypointType "CYCLE";
    _wp setWaypointCompletionRadius 300;
  };
  
  {
    _unit = _x ;
    if (alive _unit && _spotter distance _unit <= 500 && side _unit == west) then {
      _knowledge = _grp knowsAbout (vehicle _unit) ;
      diag_log format["%1: Spotter is in the vicinity of west unit %2. Knows (0-4): %3 about object", time, name (vehicle _unit), _knowledge] ;
    
      if (_grp knowsAbout (vehicle _unit) < 1) then {
        if (!(_unit call h_isInBuilding) && !(_unit call h_isInTrees)) then {
          (units _grp) doWatch (vehicle _unit) ;
          if (vehicle _unit != _unit) then {
            // unit is in a vehicle, increase spotting capability
            (leader _spotter) reveal [(vehicle _unit), 1.5] ;
          };
          sleep 0.2 ;
        };
      };
    };
  }forEach allUnits;
  
  _nearest_enemy = (leader _grp) findNearestEnemy (leader _grp) ;
  if (!isNull _nearest_enemy) then {
    _knowledge = _grp knowsAbout _nearest_enemy ;
    _last_pos = (leader _grp) getHideFrom _nearest_enemy ;
    _arrow1 setPos _last_pos ;
    _arrow1 setvectorup [0,0,1];
    _tk = (leader _grp) targetKnowledge _nearest_enemy ;
    HunterSpotterLastSeen = [_last_pos, dateToNumber date] ;
    //arrow2 setPos (_tk select 6) ;
    //arrow2 setvectorup [0,0,1] ;
    diag_log format["%1: Spotter has seen enemy unit %2. Knows (0-4): %3 about unit, at position %4, target knowledge %5", time, name _nearest_enemy, _knowledge, _last_pos, _tk ] ;    
  }else{
    //(leader _spotter) doWatch objNull ;
  };
  
};

// Spotter either dead or fuel low. Attempt return to base if alive
if (alive _spotter && { alive _x } count (units _grp) > 0) then {
  while {(count (waypoints _grp)) != 0} do {deleteWaypoint ((waypoints _grp) select 0);};
  _wp = _grp addWaypoint [_spawn_at, 1] ;
  _wp setWaypointType "MOVE";
  _wp setWaypointCompletionRadius 1;
  _wp setWaypointBehaviour "CARELESS" ;
  _spotter flyInHeight 2000 ;
};

sleep 300 ; // 5 min timout

{
  if (_x in _spotter) then {
    _spotter deleteVehicleCrew _x ;
  }else{
    deleteVehicle _x ;
  };
}forEach units _grp;

if (damage _spotter < 1) then {deleteVehicle _spotter;}