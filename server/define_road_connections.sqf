waitUntil {!isNil "HunterLocations";};

HunterConnectedLocations = [] ;
// Figure out location connections
{
  _loc = _x ;
  _l_type = (_x select 0) ;
  _l_name = (_x select 1) ;
  _l_pos = (_x select 2) ;
  _l_size = (_x select 3) ;
  _max_size = (_l_size select 0) max (_l_size select 1) ;
  _insert_idx = 0 ;
  _location_connected = false ;
  {
    if (_loc in _x) exitWith {_location_connected = true ;};
  }forEach HunterConnectedLocations ;

  _road_markers = [] ;
  fn_link_roads = {
    params["_road"] ;
    _info = getRoadInfo _road ;
    _road_pos_end = _info select 7 ;
    _end = createMarkerLocal [format["endroad%1", _info select 7], _info select 7] ;
    _road_markers pushBack _end ;
    _end setMarkerTypeLocal "hd_dot" ;
    _end setMarkerColor "ColorBlack" ;
    {
      // Check if locations, other than the starting location has a connecting road
      if (!(_x isEqualTo _loc)) then {
        _chk_loc = _x ;
        _chk_loc_pos = (_x select 2) ;
        _chk_loc_size = (_x select 3) ;
        _chk_max_size = (_chk_loc_size select 0) max (_chk_loc_size select 1) ;
        _found = false ;
        if ((_chk_loc_pos distance2D _road_pos_end) <= _chk_max_size) then {
          // This road links to _loc
          _new_loc = HunterConnectedLocations select _insert_idx ;
          _end setMarkerColor "ColorGreen" ;
          if (!(_chk_loc in _new_loc)) then { // add if not already added to group
            _new_loc pushBack _chk_loc ; // add location to group list
            diag_log format ["%1 connected to %2", _l_name, _chk_loc select 1] ;
          };
        };
      };
    }forEach HunterLocations ;
    
    true ;
  };
  
  if (!_location_connected) then {
    // Use min size to ensure the radius is within the location and not stretching out beyond
    // the boundaries
    _insert_idx = HunterConnectedLocations pushBack [_loc] ; // new connection group
    [_l_pos, fn_link_roads, _max_size] call h_roadCallback ;
    diag_log format ["%1 location connected to %2 other locations", _l_name, count (HunterConnectedLocations select _insert_idx)] ;
    {
      _x setMarkerColor "ColorGrey" ;
    }forEach _road_markers ;
  };
  
} forEach HunterLocations;