waitUntil {!isNil "HunterLocations";};

HunterConnectedLocations = [] ;
_tmpconnectedlocations = [] ;
_locations_visited = [] ;
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
  
  if (_loc in _locations_visited) then {
    _location_connected = true ;
  };

  _road_markers = [] ;
  
  fn_link_roads = {
    params["_road"] ;
    _exitfn = true ;
    _info = getRoadInfo _road ;
    _road_pos_start = _info select 6 ;
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
          _new_loc = _tmpconnectedlocations select _insert_idx ;
          _end setMarkerColor "ColorGreen" ;
          if (!(_chk_loc in _new_loc)) then { // add if not already added to group
            _new_loc pushBack _chk_loc ; // add location to group list
            diag_log format ["%1 connected to %2", _l_name, _chk_loc select 1] ;
            if (_chk_loc in _locations_visited) exitWith {
              // This has been visited in another list, stop walking
              _exitfn = false ;
            };
          };
        };
      };
    }forEach HunterLocations ;
    
    _exitfn ;
  };
  
  if (!_location_connected) then {
    // Use min size to ensure the radius is within the location and not stretching out beyond
    // the boundaries
    _insert_idx = _tmpconnectedlocations pushBack [_loc] ; // new connection group
    [_l_pos, fn_link_roads, _max_size] call h_roadCallback ;
    _locations_visited = _locations_visited + (_tmpconnectedlocations select _insert_idx) ;
    diag_log format ["%1 location connected to %2 other locations", _l_name, count (_tmpconnectedlocations select _insert_idx)] ;
    {
      _x setMarkerColor "ColorGrey" ;
    }forEach _road_markers ;
  };
  
} forEach HunterLocations;

diag_log format ["Found %1, networks in road walk", count _tmpconnectedlocations] ;
// First cut of connections but there will be repeats
{
  _foundmatch = false ;
  _tmpnetwork = _x ;
  // Look at each existing HunterConnectedLocations and check for any matches
  {
    _huntnetwork = _x ;
    if ({_x in _huntnetwork} count _tmpnetwork > 0) then {
      // this network is already included in another list, merge
      _foundmatch = true ;
      {
        _huntnetwork pushBackUnique _x ;
      }forEach _tmpnetwork ;
    };
  }forEach HunterConnectedLocations;
  
  if (!_foundmatch) then {
    // This record doesn't yet exist in any current HunterConnectedLocations
    HunterConnectedLocations pushBack _tmpnetwork ;
  };

}forEach _tmpconnectedlocations ;

diag_log format ["Merged records to %1, networks on map", count HunterConnectedLocations] ;

// Copy all locations to clipboard
_clipboard = "[" ;
private _firstnetwork = true ;
_br = toString [13,10];
{
  _network = _x ;
  _firstentry = true ;
  if (!_firstnetwork) then {
    _clipboard = _clipboard + "," + _br ;
  };
  _firstnetwork = false ;
  _clipboard = _clipboard + "[" + _br ;
  {
    _l_type = (_x select 0) ;
    _l_name = (_x select 1) ;
    _l_pos = (_x select 2) ;
    _l_size = (_x select 3) ;
    if (!_firstentry) then {
      _clipboard = _clipboard + "," + _br ;
    } ;
    _firstentry = false ;
    _clipboard = _clipboard + str([toArray _l_name, _l_pos]);
  }forEach _network ;
  _clipboard = _clipboard + _br + "]" ;
  
}forEach HunterConnectedLocations;
_clipboard = _clipboard + "]";

copyToClipboard _clipboard;