private _savedgame = profileNamespace getVariable HUNTER_SAVE_VAR ;
  
// If the saved game exists then delete all vehicles from the surrounding area of the base.
// This allows the initial map design to set some default vehicles for the players from the start of the game
if (!isNil "_savedgame") then {
  private _camplist = _savedgame select 0 ;
  private _baselist = _savedgame select 1 ;
  private _objslist = _savedgame select 2 ;
  private _hunters = _savedgame select 3 ;
  HunterSectors = _savedgame select 4 ;
  HunterLocations = _savedgame select 5 ;
  _date = _savedgame select 6 ;
  HunterHeatMap = _savedgame select 7 ;
  HunterBases = [] ;
  HunterPlayers = [] ;
  
  // Restore the game time and exec on all client machines
  [_date] remoteExec ["setDate"] ;
  
  [_baselist] call build_base ; 
  
  // Create the camp buildings and vehicles
  HUNTER_CAMP = [] ;
  {
    private _o = createVehicle[_x select 0, _x select 1, [], 0, "NONE"];
    _o setDir (_x select 2);
    
    if (_forEachIndex == 0) then {
      _o allowDamage false ;
      [_o, ["Pack Camp", "client\pack_camp.sqf", nil, 1, true, true, "", "true", 10, false, "",""]] remoteExec["addAction"] ;
    };
    HUNTER_CAMP pushBack _o ;
  } forEach _camplist ;
  publicVariable "HUNTER_CAMP" ;
  
  if (count HUNTER_CAMP > 0) then {
    private _camppos = getPos (HUNTER_CAMP select 0);
    private _mkr = createMarker["respawn_west_camp", _camppos] ;
    _mkr setMarkerPos _camppos ; // belts and braces to ensure that this is moved if already exists
    _mkr setMarkerType "respawn_unknown" ;
  };
  
  //diag_log format["Loaded objlist %1", _objslist] ;
  [_objslist] call h_restoreSaveList;
  
  {
    HunterPlayers pushBack [_x] ;
  }forEach _hunters ;
  publicVariable "HunterPlayers";
  
};
diag_log "Finished load" ;