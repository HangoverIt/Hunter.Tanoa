params["_unit"] ;

private _inwoods = false ;

private _nearTrees = nearestTerrainObjects [_unit, ["TREE"], 8, false];

//private _nearTrees = nearestTerrainObjects [_unit, ["FOREST TRIANGLE","FOREST BORDER","FOREST SQUARE","FOREST"], 13, false];
if (count _nearTrees > 0) then {
  _inwoods = true ;
}else{
  _nearTrees = nearestTerrainObjects [_unit, ["TREE","SMALL TREE"], 15, false];
  if (count _nearTrees > 3) then {
    _inwoods = true ;
  };
};

_inwoods ;
