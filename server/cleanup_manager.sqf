// unit or group to apply to, followed by an optional timeout in minutes
params["_unit",["_timeout",0]] ;

private _players = call BIS_fnc_listPlayers;
private _timeoutobj = time + (_timeout * 60) ; // covert minutes to seconds
if (typeName _unit == "GROUP") then {
  while { alive (leader _unit) && {_x distance (leader _unit) < (viewDistance +100)} count _players > 0 && (_timeout == 0 || _timeoutobj > time)} do {
    sleep 20;
    if (!isNull ((leader _unit) findNearestEnemy (leader _unit))) then {
      _timeoutobj = time + (_timeout * 60) ; // reset any time out due to player contact
    };
  } ;
  
  // Only delete units if alive
  {
    if (alive _x) then {
      if (vehicle _x == _x) then {
        deleteVehicle _x ;
      }else{
        (vehicle _x) deleteVehicleCrew _x ;
      };
    };
  } forEach units _unit ;

}else{
  // Wait until out of view or time out exceeded
  while { {_x distance _unit < (viewDistance +100)} count _players > 0 && (_timeout == 0 || _timeoutobj > time) && ([_unit] call h_isManagedVehicle)} do {
    sleep 20;
  } ;

  if (_unit isKindOf "Man") then {
    deleteVehicle _unit ;
  }else{
    // Don't delete an occupied vehicle
    while { {!isNull (_x select 0) && alive (_x select 0)} count fullCrew _unit > 0 && ([_unit] call h_isManagedVehicle)} do {
      sleep 20 ;
    };
    // Final check that vehicle is still server managed and not captured by player
    if ([_unit] call h_isManagedVehicle) then {
      deleteVehicle _unit ;
    } ;
  };
};


