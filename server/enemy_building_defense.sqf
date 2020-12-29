params ["_unit"];

_unit setUnitPos "UP";
_unit disableAI "MOVE";
private _move_is_disabled = true;

while { _move_is_disabled && alive _unit } do {
	_hostilecount = { alive _x && side _x == west } count ( (getpos _unit) nearEntities [ ["Man"], 20 ] );


	if ( _hostilecount > 0 || ( damage _unit > 0.25 ) ) then {
		if ( _move_is_disabled ) then {
			_move_is_disabled = false;
			_unit enableAI "MOVE";
			_unit setUnitPos "AUTO";
		};
	};

	if ( _move_is_disabled ) then {
		_target = assignedTarget _unit;
		if(!(isNull _target)) then {
			_vd = (getPosASL _target) vectorDiff (getpos _unit);
			_newdir = (_vd select 0) atan2 (_vd select 1);
			if (_newdir < 0) then {_dir = 360 + _newdir };
			_unit setDir (_newdir);
      [_unit, _newdir] remoteExec ["setDir"] ;
		};
	};

	sleep 3;

};