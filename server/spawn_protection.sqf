if ( isServer ) then {
  
	waitUntil { time > 1 };

	params [ "_veh", ["_pos", [0,0,0]] ];
  if (_pos isEqualTo [0,0,0]) then {
    _pos = getPosATL _veh ;
  };
  if (count _pos == 2) then {_pos pushBack (getTerrainHeightASL _pos);} ;
	_veh allowdamage false;
	_veh setdamage 0;
  _veh setPosATL _pos ;

  sleep 2 ;


  _veh setdamage 0;
  _veh setPosATL _pos ;
  sleep 5;

  _veh setdamage 0;
  _veh allowdamage true;

};