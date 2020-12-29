params["_objslist"] ;

private _all_objs = [] ;
{
  // OBJITEM = [class, ATLpos, direction, [cargo, ammocargo, weaponscargo], [crew]]
  _objclass = _x select 0 ;
  _objpos = _x select 1 ;
  _objdir = _x select 2 ;
  _objcontents = _x select 3 ;
  _objcrew = _x select 4 ;
  
  _obj = objNull ;
  if (_objclass isKindOf "Man") then {
    diag_log format["Loading soldier unit %1, at position %2", _objclass, _objpos] ;
    _obj = (createGroup west) createUnit[_objclass, _objpos, [], 0, "NONE"] ;
  }else{
    diag_log format["Loading vehicle unit %1, at position %2", _objclass, _objpos] ;
    _obj = createVehicle[_objclass, _objpos, [], 0, "NONE"];
  
    clearItemCargoGlobal _obj;
    clearWeaponCargoGlobal _obj;
    clearMagazineCargoGlobal _obj;
    clearBackpackCargoGlobal _obj;

    // Add associated units
    _grp = createGroup west;
    {
      _unit = _grp createUnit[_x, getPos _obj, [], 0, "NONE"] ; // create unit but place outside vehicle
      _unit moveInAny _obj ;
    }forEach (_objcrew) ;
    
    // Add the existing items, magazines and weapons back to the vehicle
    {_obj addItemCargoGlobal [_x, 1];} forEach (_objcontents select 0) ;
    {_obj addMagazineAmmoCargo [_x select 0, 1, _x select 1];} forEach (_objcontents select 1) ;
    {_obj addWeaponWithAttachmentsCargoGlobal [_x,1];} forEach (_objcontents select 2) ;
    {_obj addBackpackCargoGlobal [_x,1];} forEach (_objcontents select 3) ;
    _containers = (_objcontents select 4) ;
    {
      _cont = (_x select 1) ;
      _savedcontainer = _containers select _forEachIndex;
      if (!isNil "_savedcontainer") then {
        {_cont addItemCargoGlobal [_x, 1];} forEach (_savedcontainer select 1) ;
        {_cont addMagazineAmmoCargo [_x select 0, 1, _x select 1];} forEach (_savedcontainer select 2) ;
        {_cont addWeaponWithAttachmentsCargoGlobal [_x, 1];} forEach (_savedcontainer select 3) ;
        {_cont addBackpackCargoGlobal [_x,1];} forEach (_savedcontainer select 4) ;
      };
    }forEach everyContainer _obj;
    
    [_obj] spawn spawn_protection ;
  };
  _obj setDir _objdir;
  
  _all_objs pushBack _obj ;
  
} forEach _objslist ;

// Return all created objects
_all_objs;