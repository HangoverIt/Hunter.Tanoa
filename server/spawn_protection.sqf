if ( isServer ) then {
  
	waitUntil { time > 1 };

	params [ "_veh", ["_pos", [0,0,0]] ];
  if (count _pos == 2) then {_pos pushBack (getTerrainHeightASL _pos);} ;
	_veh allowdamage false;
	_veh setdamage 0;
  if (!(_pos isEqualTo [0,0,0])) then {
    _veh setPosATL _pos ;
  };

  sleep 2 ;

  _veh setdamage 0;
  _veh setVectorUp [0,0,1] ;
  if (!(_pos isEqualTo [0,0,0])) then {
    _veh setPosATL _pos ;
  };
  sleep 2;

  _veh setdamage 0;
  _veh allowdamage true;

};