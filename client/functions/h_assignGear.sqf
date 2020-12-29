params["_p", "_contents"] ;

_weapons = _contents select 0 ;
_goggles = _contents select 1 ;
_vest = _contents select 2 ;
_uniform = _contents select 3 ;
_backpack = _contents select 4 ;
_headgear = _contents select 5 ;
_hmd = _contents select 6 ;
_assigned = _contents select 7 ;
_vestcontents = _contents select 8;
_uniformcontents = _contents select 9 ;
_backpackcontents = _contents select 10 ;

      diag_log format["%1: assigning player _weapons %2", time, _weapons] ;
      diag_log format["%1: assigning player _goggles %2", time, _goggles] ;
      diag_log format["%1: assigning player _vest %2", time, _vest] ;
      diag_log format["%1: assigning player _uniform %2", time, _uniform] ;
      diag_log format["%1: assigning player _backpack %2", time, _backpack] ;
      diag_log format["%1: assigning player _headgear %2", time, _headgear] ;
      diag_log format["%1: assigning player _headmounteddisplay %2", time, _hmd] ;
      diag_log format["%1: assigning player _assigned %2", time, _assigned] ;
      diag_log format["%1: assigning player _vestcontents %2", time, _vestcontents] ;
      diag_log format["%1: assigning player _uniformcontents %2", time, _uniformcontents] ;
      diag_log format["%1: assigning player _backpackcontents %2", time, _backpackcontents] ;

// Remove everything
{_p unassignItem _x;}forEach assignedItems _p ;
removeAllWeapons _p;
removeAllItems _p;
removeBackpackGlobal _p ;
removeVest _p ;
removeUniform _p ;
removeGoggles _p ; // just diving goggles, use unassignItem and remove from inventory
removeHeadgear _p ;

// Add all gear
_p addGoggles _goggles ;
_p addVest _vest ;
_p forceAddUniform _uniform ;
_p addBackpackGlobal _backpack;
//waitUntil {!isNull backpackContainer _p;} ;
_p addHeadgear _headgear ;
{
  _p addWeapon (_x select 0) ;
  _p addWeaponItem [_x select 0, _x select 2, true];
  _p addWeaponItem [_x select 0, _x select 3, true];
  _mags = (_x select 4);
  _mags2 = (_x select 5) ;
  if (count _mags > 0) then {
    _p addWeaponItem [_x select 0, [_mags select 0, _mags select 1], true];
  };
  if (count _mags2 > 0) then {
    _p addWeaponItem [_x select 0, [_mags2 select 0, _mags2 select 1], true] ;
  };
  _p addWeaponItem [_x select 0, _x select 6] ;
}forEach _weapons ;

// Get a list of assigned items (binoculars are in the weapons and assign before this).
// Only add items not already assigned
_alreadyassigneditems = assignedItems _p ;
{
  if (!(_x in _alreadyassigneditems)) then {
    _p addItem _x ;
    _p assignItem _x;
  };
} forEach _assigned ;

// Get the player containers
_vestcontainer = vestContainer _p ;
_uniformcontainer = uniformContainer _p ;
_backpackcontainer = backpackContainer _p ;

// Populate vest all items
{_vestcontainer addItemCargoGlobal [_x, 1];}forEach (_vestcontents select 0);
{_vestcontainer addMagazineAmmoCargo [_x select 0, 1, _x select 1];}forEach (_vestcontents select 1);
{_vestcontainer addWeaponWithAttachmentsCargoGlobal [_x,1];}forEach (_vestcontents select 2);

// Populate uniform all items
{_uniformcontainer addItemCargoGlobal [_x, 1];}forEach (_uniformcontents select 0);
{_uniformcontainer addMagazineAmmoCargo [_x select 0, 1, _x select 1];}forEach (_uniformcontents select 1);
{_uniformcontainer addWeaponWithAttachmentsCargoGlobal [_x,1];}forEach (_uniformcontents select 2);

// Populate backpack all items
{_backpackcontainer addItemCargoGlobal [_x, 1];}forEach (_backpackcontents select 0);
{_backpackcontainer addMagazineAmmoCargo [_x select 0, 1, _x select 1];}forEach (_backpackcontents select 1);
{_backpackcontainer addWeaponWithAttachmentsCargoGlobal [_x,1];}forEach (_backpackcontents select 2);

[_p,"Default","male01engfre"] call BIS_fnc_setIdentity;