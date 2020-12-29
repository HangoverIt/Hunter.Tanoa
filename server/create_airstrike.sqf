
if (isNil "HunterSectors" || isNil "HunterSpotterLastSeen") exitWith {
  diag_log "Attempted to create an airstrike but sectors or spotter location are undefined!" ;
} ;

private _max_threat = 0 ;
private _last_coords = [0,0,0];
private _min = ((1/365)/24)/60 ;
private _maxage = HUNTER_SAD_TIMEOUT * _min; // measured in minutes

// Get the sector threat
{
  _hm = _x ;
  _hm_location = _hm select 2 ;
  _sector = [HunterSectors, HunterSpotterLastSeen select 0] call h_getSectorFromPosition ;
  if (! ([_sector] call h_isSectorAtMaxThreat) ) then {
    if (count _sector > 0) then { // check return is not null sector
      _sector_threat = [_sector] call h_getSectorThreat ;
      if (_sector_threat > _max_threat) then {
        _max_threat = _sector_threat;
      };
    };
  };
}forEach HunterHeatMap ;

//private _airclass = [HUNTER_THREAT_AIRSTRIKE_AIR, _max_threat] call h_getRandomThreat;
_airclass = "O_Plane_CAS_02_F";

// Edge of map spawn
private _spawn_at = [0,15000,200] ;

private _airstrike = createVehicle[_airclass, _spawn_at, [], 0, "FLY"] ;
createVehicleCrew _airstrike;
_grp = group (leader _airstrike);

_airstrike flyInHeight 150;

// Keep spotting until a timeout or fuel is low
while {alive _airstrike && ({ alive _x } count (units _grp) > 0) && fuel _airstrike > 0.2 && (HunterSpotterLastSeen select 1) + _maxage > (dateToNumber date) } do {
  sleep 2;
  
  if (! (_last_coords isEqualTo (HunterSpotterLastSeen select 0))) then {
    _last_coords = (HunterSpotterLastSeen select 0) ;
    while {(count (waypoints _grp)) != 0} do {deleteWaypoint ((waypoints _grp) select 0);};

    _wp = _grp addWaypoint [_last_coords, 10] ;
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "CARELESS" ;
    _wp setWaypointCompletionRadius 1;
    _grp setCurrentWaypoint [_grp,0] ;

  };

  _nearest_enemy = (leader _grp) findNearestEnemy (leader _grp) ;
  if (_airstrike distance _last_coords <= 500 && isNull _nearest_enemy) then {

  };

  
};

// Airstrike either dead or fuel low. Attempt return to base if alive
if (alive _airstrike && { alive _x } count (units _grp) > 0) then {
  while {(count (waypoints _grp)) != 0} do {deleteWaypoint ((waypoints _grp) select 0);};
  _wp = _grp addWaypoint [_spawn_at, 1] ;
  _wp setWaypointType "MOVE";
  _wp setWaypointCompletionRadius 1;
  _wp setWaypointBehaviour "CARELESS" ;
  _airstrike flyInHeight 2000 ;
};

sleep 300 ; // 5 min timout

{
  if (_x in _airstrike) then {
    _airstrike deleteVehicleCrew _x ;
  }else{
    deleteVehicle _x ;
  };
}forEach units _grp;

if (damage _airstrike < 1) then {deleteVehicle _airstrike;}