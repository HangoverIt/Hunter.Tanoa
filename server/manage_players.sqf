// Allow group management on server
["Initialize"] call BIS_fnc_dynamicGroups;

// All player slots (playable soldiers set in editor)
if (isNil "HunterPlayers") then {
  diag_log "First time creation of HunterPlayers" ;
  HunterPlayers = [[[]], [[]], [[]], [[]], [[]], [[]], [[]], [[]]] ; // gear
};

publicVariable "HunterPlayers";

// Define a group for none owned soldiers
HunterBlueForGrp = createGroup [west, false] ;

publicVariable "HunterBlueForGrp" ;

// Single player clear up code to remove none player soldiers
if (!isMultiplayer) then {
  {
    _hunter = missionNamespace getVariable format ["hunt%1", (_forEachIndex + 1)] ;
	diag_log format ["Checking if %1, is player...", _hunter] ;
    if (!isNil "_hunter") then {
      if(!(player == _hunter)) then {
	    diag_log format ["Deleting %1 as not player", _hunter] ;
        deleteVehicle _hunter;    
      };
    };
  } forEach HunterPlayers;
};
