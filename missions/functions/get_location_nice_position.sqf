// Generate a placement position for an object within location
params["_l", "_o", ["_indoors", false], ["_onland", true],["_onroad",false]] ;

private _l_pos = (_l select 2) ;
private _l_size = (_l select 3) ;
private _radius = (_l_size select 0) max (_l_size select 1) ;

private _try_pos = [0,0,0] ;
if (_indoors) then {
  _allbuildings = [ nearestObjects [_l_pos, ["House"], _radius ], { alive _x } ] call BIS_fnc_conditionalSelect;
  _buildingpositions = [];
  {
    _buildingpositions = _buildingpositions + ( [_x] call BIS_fnc_buildingPositions );
  } foreach _allbuildings;
  if (count _buildingpositions > 0) then {
    _try_pos = _buildingpositions select (floor random count _buildingpositions) ;
  };
}else{
  if (_onroad) then {
    _roads = _l_pos nearRoads _radius;
    if (_roads > 0) then {
      _road = _roads select (floor random count _roads) ;
      _try_pos = (getRoadInfo _road) select 6 ;
    };
  };
};

if (_try_pos isEqualTo [0,0,0]) then {
  _osize = sizeOf (typeOf _o) ;
  // Look for location within radius for safe place 
  if (_onland) then {
    _try_pos = [_l_pos, 0, _radius, _osize, 0, 0, 0, [], [_l_pos,_l_pos]] call BIS_fnc_findSafePos;
  }else{
    _try_pos = [_l_pos, 0, _radius, _osize, 2, 0, 0, [], [_l_pos,_l_pos]] call BIS_fnc_findSafePos;
  };
};

_try_pos;
