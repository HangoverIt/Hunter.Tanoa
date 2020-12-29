private _maxcampbags = 1;

while {true} do {

  {
    _basename = _x select 0 ;
    _basepos = _x select 1 ;
    _basecrate = _x select 2;
    
    _campbags = {_x == HUNTER_CAMP_BAG} count backpackCargo _basecrate;

    if(_campbags < _maxcampbags) then {
      _basecrate addBackpackCargoGlobal [HUNTER_CAMP_BAG,_maxcampbags - _campbags];
    };
    
  } forEach HunterBases ;
  
  
  sleep 5 ;
};