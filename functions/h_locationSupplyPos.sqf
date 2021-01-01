// Takes in a location that needs supplying. This can be used for a resupply or reinforcement position.
// Uses the HunterNetwork to determine routes and positions
// If position cannot be found then can fallback to other algorithms or return [0,0,0] (location null) 
params["_l", "_all_networks", ["_exclude_location_class", []], ["_byland", true], ["_use_fallback_algorithm", true]] ;

private _l_type = (_l select 0) ;
private _l_name = (_l select 1) ;
private _l_pos = (_l select 2) ;
private _l_size = (_l select 3) ;
private _loc_network = [] ;
private _players = call BIS_fnc_listPlayers ;

private _fallback = true ;
private _return_pos = [0,0,0] ;

// Which network is this location in?
{
  _network = _x ;
  {
    if (_l isEqualTo _x) exitWith {
      _loc_network = _network ;
    };
  }forEach _network ;
  if (count _loc_network > 0) exitWith {}; // exit the search if found
}forEach _all_networks ;

diag_log format["h_locationSupplyPos: network search returned %1 network", _loc_network] ;

if (count _loc_network > 0) then {
  // Search for resupply location that the players cannot see spawning
  _location_candidates = [] ;
  {
    _network_location = _x ;
    _network_location_type = (_x select 0) ;
    _network_location_pos = (_x select 2) ;
    _network_location_percent = (_x select 5) ;
    // If not an excluded class and location is outside view spawn distance 
    if (!(_network_location_type in _exclude_location_class) && 
        !(_l isEqualTo _network_location) &&
        _network_location_percent > 0 &&
        {_x distance _network_location_pos <= HUNTER_SPAWN_DISTANCE} count _players == 0) then {
      _location_candidates pushBack _network_location ;
    } ;
  }forEach _loc_network ;
  
  // Sort the resulting array of locations into distance from resupply location
  _location_candidates = [_location_candidates, [], {(_x select 2) distance _l_pos}, "ASCEND"] call BIS_fnc_sortBy ;
  
  diag_log format["h_locationSupplyPos: network search returned %1 location candidates to spawn from", count _location_candidates] ;
  
  // Should have candidates to select from. If not then fallback or return null location
  if (count _location_candidates > 0) then {
    // Select nearest location from random selection of nearest 3 or fewer depending on available locations
    _max_select = (count _location_candidates) min 3 ;
    _selected_location = _location_candidates select (floor random _max_select) ;
    _return_pos = (_selected_location select 2) ; // use position of location
    _selected_location_size = (_selected_location select 3) ;
    _max_size = (_selected_location_size select 0) max (_selected_location_size select 1) ;
    _roads = _return_pos nearRoads _max_size;
    if (count _roads > 0) then { // Check if nearby road and update position to be on road
      _road = _roads select (floor random count _roads);
      _return_pos = (getRoadInfo _road) select 6 ;
      diag_log format["h_locationSupplyPos: spawning in %1, on road at position %2", (_selected_location select 1), _return_pos] ;
    }else{
      
      if (_byland) then {
        // Only return land positions. Fallback is the location position.
        _return_pos = [_return_pos, 0, _max_size, 0, 0, 0, 0, [], [_return_pos,_return_pos]] call BIS_fnc_findSafePos;
      }else{
        // consider any position viable
        _return_pos = [_return_pos, 0, _max_size, 0, 2, 0, 0, [], [_return_pos,_return_pos]] call BIS_fnc_findSafePos;
      };
      diag_log format["h_locationSupplyPos: spawning in %1 at position %2", (_selected_location select 1), _return_pos] ;
    }; 
    _fallback = false ;
  };
};

if (_fallback && _use_fallback_algorithm) then {
  diag_log format["h_locationSupplyPos: using fallback algorithm"] ;
  // select random player to be the point of reference for spawn
  _player = _players select (floor random count _players);
  if (_byland) then {
    // Only return land positions. Fallback is the location position.
    _return_pos = [position _player, HUNTER_SPAWN_DISTANCE, HUNTER_SPAWN_DISTANCE + 100, 0, 0, 0, 0, [], [_return_pos,_return_pos]] call BIS_fnc_findSafePos;
  }else{
    // consider any position viable
    _return_pos = [position _player, HUNTER_SPAWN_DISTANCE, HUNTER_SPAWN_DISTANCE + 100, 0, 2, 0, 0, [], [_return_pos,_return_pos]] call BIS_fnc_findSafePos;
  };
  if ([_return_pos] call h_posOnLand) then {
    // Attempt to find close road
    _roads = _return_pos nearRoads 100 ;
    if (count _roads > 0) then {
      _return_pos = (getRoadInfo (_roads select 0)) select 6 ;
    };
  };
};

diag_log format["h_locationSupplyPos: returning position %1", _return_pos] ;
// Return position
_return_pos ;