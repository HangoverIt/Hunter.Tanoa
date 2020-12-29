

// If the global sector list is not set then create.
if (isNil "HunterSectors" ) then {
  private _grid_size = [6,6] ;
  HunterSectors = [_grid_size] call h_createSectors ;

  // [sectors, ID, threat, max threat]
  [HunterSectors, 0, 0, 20] call h_setSectorBaseThreat;
  [HunterSectors, 1, 0, 20] call h_setSectorBaseThreat;
  [HunterSectors, 2, 0, 20] call h_setSectorBaseThreat;
  [HunterSectors, 3, 0, 20] call h_setSectorBaseThreat;
  [HunterSectors, 4, 0, 20] call h_setSectorBaseThreat;
  [HunterSectors, 5, 0, 20] call h_setSectorBaseThreat;
  [HunterSectors, 40, 0, 20] call h_setSectorBaseThreat;
  [HunterSectors, 23, 50, 100] call h_setSectorBaseThreat;
  [HunterSectors, 16, 90, 200] call h_setSectorBaseThreat;
  [HunterSectors, 17, 30, 50] call h_setSectorBaseThreat;
  [HunterSectors, 24, 50, 100] call h_setSectorBaseThreat;
  [HunterSectors, 25, 50, 100] call h_setSectorBaseThreat;
  [HunterSectors, 26, 30, 50] call h_setSectorBaseThreat;
  [HunterSectors, 33, 30, 50] call h_setSectorBaseThreat;
  [HunterSectors, 31, 90, 200] call h_setSectorBaseThreat;
  [HunterSectors, 32, 90, 200] call h_setSectorBaseThreat;
  [HunterSectors, 30, 90, 200] call h_setSectorBaseThreat;
  [HunterSectors, 35, 90, 200] call h_setSectorBaseThreat;
  [HunterSectors, 36, 90, 200] call h_setSectorBaseThreat;
  [HunterSectors, 28, 90, 200] call h_setSectorBaseThreat;
  [HunterSectors, 29, 90, 200] call h_setSectorBaseThreat;
  [HunterSectors, 39, 90, 200] call h_setSectorBaseThreat;
} ;
