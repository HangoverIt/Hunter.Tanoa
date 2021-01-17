//////////////////////////////////////////////////////////////////////
//
// Creates a vehicle for the Hunter game. Assigns appropriate variables 
//
// Usage: [position, class, location, special, spawnprotect, managed]
// Returns: vehicle
//
// Alternative Usage: [position, [classes], location, special, spawnprotect, managed]
// Returns: vehicle
//
// Input: position - 2D or 3D position
//        class - unit class to create (string)
//        classes - Hunter array of unit classes with associated threat (see defined parameters)
//        location - (optional) Hunter location array, used to fetch threat, select unit class and set unit variables to location (kills register at location)
//        special - (optional) NONE, FLY or CAN_COLLIDE
//        spawnprotect - (optional) protect at the position provided (disable if moving vehicle immediately after spawn)
//        managed - (optional) set if vehicle will be managed by server and removed when not required. Player vehicles are not managed
//
params["_spawnpos", ["_threatclasses", []], ["_loc", []], ["_special", "NONE"], ["_spawnprotect", true], ["_managed", true]] ;

private _vehclass = "" ;
private _threat = 0 ;
private _l_sector = [0,0,0] ;

// Determine the class to create. If no array then only one choice can exist, else if the 
// location and list of classes is an array then lookup the threat and create the object
if (typeName _threatclasses == "STRING") then {
  _vehclass = _threatclasses ;
}else{
  if (count _loc > 0 && typeName _threatclasses == "ARRAY") then {
    _l_sector = (_loc select 4) ;
    _threat = [_l_sector] call h_getSectorThreat ;
    _vehclass = [_threatclasses, _threat] call h_getRandomThreat ;
  };
};

// All enemy units are included in the kill event handler
private _veh = createVehicle [_vehclass, _spawnpos, [], 0, _special ] ;
_veh addEventHandler["GetIn", {_this call event_getin}] ;
if (_vehclass select [0, 2] != "C_") then { // Bit hackey but don't apply kill handler to civilian vehicles
  _veh addEventHandler["Killed", {_this call vehicle_destruction_manager}];
};
if (_spawnprotect) then {[_veh, _spawnpos] spawn spawn_protection ;} ;

// Vehicle is a location vehicle or managed, but not both
if (count _loc > 0) then {
  [_veh, _loc] call h_assignToLocation ;
}else{
  if (_managed) then {[_veh] call h_setManagedVehicle ;};
};

_veh;