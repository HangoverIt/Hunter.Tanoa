//////////////////////////////////////////////////////////////////////
//
// Creates a unit for the Hunter game. Assigns appropriate variables 
//
// Usage: [group, position, class, location]
// Returns: unit
//
// Alternative Usage: [group, position, [classes], location]
// Returns: unit
//
// Input: group - group unit will join
//        position - 2D or 3D position
//        class - unit class to create (string)
//        classes - Hunter array of unit classes with associated threat (see defined parameters)
//        location - (optional) Hunter location array, used to fetch threat, select unit class and set unit variables to location (kills register at location)
//
params["_grp", "_spawnpos", ["_threatclasses", []], ["_loc", []]] ;

private _manclass = "" ;
private _threat = 0 ;
private _l_sector = [0,0,0] ;

// Determine the man class to create. If no array then only one choice can exist, else if the 
// location and list of classes is an array then lookup the threat and create the unit
if (typeName _threatclasses == "STRING") then {
  _manclass = _threatclasses ;
}else{
  if (count _loc > 0 && typeName _threatclasses == "ARRAY") then {
    _l_sector = (_loc select 4) ;
    _threat = [_l_sector] call h_getSectorThreat ;
    _manclass = [_threatclasses, _threat] call h_getRandomThreat ;
  };
};

// All enemy units are included in the kill event handler
private _unit = _grp createUnit[_manclass, _spawnpos, [], 0, "NONE" ] ;

// If a location is set then associate unit to location
if (count _loc > 0) then {
  [_unit, _loc] call h_assignToLocation ;
}else{
  _unit addEventHandler["Killed", {_this call kill_manager}];
};

_unit;