// Base must be built and the sectors defined for correct save
WaitUntil {!isNil "HunterBases"} ;
WaitUntil {!isNil "HunterSectors"} ;
WaitUntil {!isNil "HunterPlayers"} ;
WaitUntil {!isNil "HunterHeatMap"} ;

if (isNil "HUNTER_SAVE_PERIOD") then {
  HUNTER_SAVE_PERIOD = 60;
};

while {true} do {
  sleep HUNTER_SAVE_PERIOD ;
  
  private _camplist = [] ;
  private _bases = [] ;
  private _saveobjs = [] ;
  private _saveplayers = [] ;
  
  if (count HUNTER_CAMP > 0) then {
    // Camp exists, save the standard classes and any soldiers allied to west
    _saveobjs append ([HUNTER_SAVE_CLASSES, getPos (HUNTER_CAMP select 0), HUNTER_CAMP_RADIUS, [west,civilian]] call h_createSaveList) ;
    _saveobjs append ([["Man"], getPos (HUNTER_CAMP select 0), HUNTER_CAMP_RADIUS, [west]] call h_createSaveList) ;

    // Save the camp buildings
    {
      _camplist pushBack [typeof _x, getPosATL _x, getDir _x ]
    } forEach HUNTER_CAMP ;
  };
  
  // Routine for saving base related objects
  {
    _basename = _x select 0;
    _basepos = _x select 1 ;
    _basecrate = _x select 2 ;
    
    // Save base, any allied soldiers and ammo boxes
    _baseitems = ([HUNTER_SAVE_CLASSES, _basepos, HUNTER_BASE_RADIUS, [west,civilian]] call h_createSaveList) ;
    _baseitems append ([["Man"], _basepos, HUNTER_BASE_RADIUS, [west]] call h_createSaveList) ;
    
    //diag_log format ["Saving base %1 with items %2", _basename, _baseitems] ;
    _bases pushBack [_basename, _basepos, _baseitems] ;
  }forEach HunterBases ;
  
  {
    _hunter = missionNamespace getVariable format ["hunt%1", (_forEachIndex + 1)] ;
    _saveplayer = (_x select 0) ; // last saved inventory
    if (!isNil "_hunter") then {
      if (!isNull _hunter) then {
        
        _saveplayer = getUnitLoadout _hunter;
        //diag_log format["Saving player hunt%1 equipment %2", _forEachIndex, _saveplayer] ;
        
        HunterPlayers set [_forEachIndex, [_saveplayer]];
      };   
    };
    _saveplayers pushBack _saveplayer;
  }forEach HunterPlayers ;
  
  private _savegame = [_camplist, _bases, _saveobjs, _saveplayers, HunterSectors, HunterLocations, date, HunterHeatMap, HunterEconomy] ;
  profileNamespace setVariable [HUNTER_SAVE_VAR, _savegame] ;
  saveProfileNamespace ;
  
  //diag_log format ["%1: Saved game %2 objects saved, %3 player data saved", time, count _saveobjs, count _saveplayers];
};