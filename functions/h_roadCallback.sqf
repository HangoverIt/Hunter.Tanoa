params ["_pos", "_fn", ["_radius", 50], ["_maxiterations", 100000]] ;

// Assume that this function starts near a road, caller will need to find that road
private _roads = _pos nearRoads _radius;
if (count _roads == 0) exitWith {} ;
private _aroad = (_roads select 0);
private _first = true ;
private _exit = false ;

private _branches = [_aroad] ;
private _oldbranches = [] ;

while {count _branches > 0 && _maxiterations > 0 && !_exit} do {
  _newbranches = [] ;
  {
    // search extended on first attempt for roads that are extended road.
	  // after this the search will keep to main roads
    _connected = roadsConnectedTo [_x, _first] ;
    {
      if (!(_x in _oldbranches)) then {
        _newbranches pushBack _x ;
        
        // Callback the provided function which is called for each new 
        // road connection. Function can stop the search by returning false
        if (!([_x] call _fn)) exitWith {
          _exit = true ;
        } ;
      };
    }forEach _connected ;
	  if (_exit) exitWith {} ; // exit foreach if fn returned false
  }forEach _branches;
  
  _first = false ;
  _oldbranches = +_branches ; 
  _branches = +_newbranches ;
  _maxiterations = _maxiterations - 1;
} ;

