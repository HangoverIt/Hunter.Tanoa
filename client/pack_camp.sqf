params ["_target", "_caller", "_actionId", "_arguments"];

if (count HUNTER_CAMP > 0) then {
  private _camppos = getPos (HUNTER_CAMP select 0) ;
  {deleteVehicle _x} forEach HUNTER_CAMP ;
  HUNTER_CAMP = [] ;
  publicVariable "HUNTER_CAMP" ;
  _bag = createVehicle [HUNTER_CAMP_BAG, _camppos, [], 0, "NONE"] ;
  deleteMarker "respawn_west_camp" ; // remove spawn marker
};
