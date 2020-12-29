params ["_pos"] ;

private _roads = _pos nearRoads 800;
private _aroad = (_roads select 0);
private _maxconnecteddistance = 0 ;
private _maxpos = [0,0,0] ;
private _maxiterations = 500 ;
private _first = true ;

private _branches = [_aroad] ;
private _oldbranches = [] ;

while {count _branches > 0 && _maxiterations > 0} do {
  _newbranches = [] ;
  {
    _connected = roadsConnectedTo [_x, _first] ;
    {
      if (!(_x in _oldbranches)) then {
        _info = getRoadInfo _x ;
        //_end = createMarkerLocal [format["endroad%1", _info select 7], _info select 7] ;
        //_end setMarkerTypeLocal "hd_dot" ;
        //_end setMarkerText "e" ;
        _newbranches pushBack _x ;
        
        _dis = (_pos distance (_info select 7));
        if (_dis > _maxconnecteddistance) then {
          _maxconnecteddistance = _dis ;
          _maxpos = (_info select 7) ;
        };
      };
    }forEach _connected ;
  }forEach _branches;
  
  _first = false ;
  _oldbranches = +_branches ; 
  _branches = +_newbranches ;
  _maxiterations = _maxiterations - 1;
} ;

if (!canSuspend) then {
  _pos = _maxpos ;
};

_maxpos ;
