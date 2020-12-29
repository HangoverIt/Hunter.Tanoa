if (isNil "HunterBases") then {
  // No bases exist in save, create the first one
  HunterBases = [] ;
  [[["alpha", getMarkerPos "HunterStart", [[],[],[]]]], true] call build_base ;
};
