params["_baselist", ["_first", false]] ;

// Load the bases and create the initial crate
{
  _basename = _x select 0 ;
  _basepos = _x select 1 ;
  _baseitems = _x select 2 ;
  
  _crate = objNull ;
  
  // Create a marker on the map for this base using the base name
  _mkr = createMarker[ format["respawn_west_%1",_basename], _basepos] ;
  _mkr setMarkerType "respawn_unknown" ;
  
  if (!_first) then {
    // Clear base
    // Delete vehicles and crates (curated in editor)
    {
      {
        _veh = _x ;
        {_veh deleteVehicleCrew _x } forEach crew _veh;
        deleteVehicle _veh ;
      }forEach (_basepos nearObjects [_x, HUNTER_BASE_RADIUS ]);
      waitUntil{sleep 0.1; (count (_basepos nearObjects [_x, HUNTER_BASE_RADIUS ])) == 0} ;
    }forEach HUNTER_SAVE_CLASSES;
    sleep 0.1 ;
    
    diag_log format ["Restoring base with %1", _baseitems] ;
    _all = [_baseitems] call h_restoreSaveList ; 
    {
      if (_x isKindOf "Man") then {
        [_x] call h_manageUnit ;
      } ;      
    }forEach _all ;
  }else{
    // First time loading, create default base objects
    _crate = createVehicle [HUNTER_BASE_CRATE, _basepos, [], 0, "NONE"]; 
    _bag = createVehicle [HUNTER_CAMP_BAG, _basepos, [], 0, "NONE"];    
    
    // Remove all default items
    clearItemCargoGlobal _crate;
    clearWeaponCargoGlobal _crate;
    clearMagazineCargoGlobal _crate;
    clearBackpackCargoGlobal _crate;
    
    _crate addWeaponCargoGlobal  ["srifle_DMR_01_F", 8]; 
    _crate addMagazineCargo ["10Rnd_762x54_Mag", 30] ;
    _crate addWeaponCargoGlobal  ["LMG_Mk200_F", 2]; 
    _crate addMagazineCargo ["200Rnd_65x39_cased_Box", 10] ;
    _crate addWeaponCargoGlobal  ["arifle_MX_Hamr_pointer_F", 4]; 
    _crate addMagazineCargo ["30Rnd_65x39_caseless_mag", 32] ;
    _crate addWeaponCargoGlobal  ["hgun_PDW2000_Holo_snds_F", 2]; 
    _crate addWeaponCargoGlobal ["hgun_PDW2000_Holo_F", 4];
    _crate addMagazineCargo ["30Rnd_9x21_Yellow_Mag", 16] ;
    _crate addWeaponCargoGlobal ["launch_B_Titan_F", 2];
    _crate addMagazineCargo ["Titan_AA", 6] ;
    _crate addWeaponCargoGlobal ["launch_B_Titan_short_F", 2];
    _crate addMagazineCargo ["Titan_AT", 6] ;
    _crate addMagazineCargo ["Titan_AP", 6] ;
    
    _crate addItemCargoGlobal ["Laserdesignator", 2] ;
    _crate addMagazineCargo ["Laserbatteries", 2 ];
    _crate addItemCargoGlobal ["FirstAidKit", 16] ;
    _crate addItemCargoGlobal ["Medikit", 4] ;
    _crate addItemCargoGlobal ["ToolKit", 4] ;
    _crate addItemCargoGlobal ["B_UavTerminal", 2] ;
  } ;
  
  
  // Find the created crate
  {
    _crate = _x ;
  }forEach (_basepos nearObjects [HUNTER_BASE_CRATE, HUNTER_BASE_RADIUS]);
  
  _crate allowDamage false ; // Cannot be destroyed
  
  // Create action (for development) to clear save file
  [_crate, ["CLEAR GAME FILE", "client\request_save_reset.sqf", nil, 1, false, true, "", "true", 10, false, "",""]] remoteExec["addAction"] ;
  // Create action to add new soldier (testing and concept)
  [_crate, ["RECRUIT SOLDIER", "client\request_new_soldier.sqf", nil, 1, false, true, "", "true", 10, false, "",""]] remoteExec["addAction"] ;
  
  _base = [_basename, _basepos, _crate] ;
  HunterBases pushBack _base ;
}forEach _baselist ;

// Update the global variable for all connected clients
publicVariable "HunterBases" ;