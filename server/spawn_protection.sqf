if ( isServer ) then {
  
	waitUntil { time > 1 };

	params [ "_veh" ];
  _pos = getPosATL _veh ;
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