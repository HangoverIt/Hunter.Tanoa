params [ "_unit", "_killer", "_instigator", "_useEffects" ];

if ( isServer ) then {
  _l = _unit getVariable "Location" ;
  _percent = _unit getVariable "Percent" ;
  if (!isNil "_l") then {
    // Opposition killed for spawn location
	// could be in location or a resupply vehicle
    _l_type = (_l select 0) ;
    _l_name = (_l select 1) ;
    _l_sector = (_l select 4) ;
    _l_percent = (_l select 5) ;
    _threatnow = [_l_sector] call h_getSectorThreat ;
	
    // Only increase threat if kill was west unit
    if (side _instigator == west || side _killer == west) then {
      // Threat increases by 1 points (trial this approach)
      _threatnow = _threatnow + 1 ;
      [_l_sector, _threatnow] call h_setSectorThreat ;
    };
    
    // Only update percent if set on object
    if (!isNil "_percent") then {
      _new_percent = _l_percent - _percent ;
      if (_new_percent <= 0) then { _new_percent = 0;};
      _l set[5, _new_percent] ;
      diag_log format ["%1: enemy killed at location %2, percent now %3", time, _l_name, _new_percent] ;
    }else{
      diag_log format ["%1: enemy killed associated with location %2", time, _l_name] ;
    };

  };
  
  private _pos = position _unit; 
  if (side _instigator == west || side _killer == west) then {
    // Update sector threat
    {
      _spos = [_x] call h_getSectorLocation ;
      _size = [_x] call h_getSectorSize ;
      if (_pos inArea[[(_spos select 0), (_spos select 1)], ((_size select 0) / 2), ((_size select 1) / 2), 0, true, -1]) exitWith {
        _l_sector = _x;
        _threatnow = [_l_sector] call h_getSectorThreat ;
        _threatnow = _threatnow + 1 ; // kills in sector increase by 1 (by 2 for location kill)
        [_l_sector, _threatnow] call h_setSectorThreat ;
        diag_log format ["%1: enemy killed ector threat level is now %2, sector is at cap - %3", time, _threatnow, [_x] call h_isSectorAtMaxThreat] ;
      };
    }forEach HunterSectors ;
    
    // Update kill list for any kill made by side west
    if (!isNil "HunterKillList" && count HunterKillList > 0) then {
      diag_log format ["%1: adding death of %2 to kill list", time, name _unit] ;
      if (count (HunterKillList select 1) >= 30) then {
        _idx = HunterKillList select 0 ;
        (HunterKillList select 1) set [_idx, [dateToNumber date, position _killer, false]] ;
        HunterKillList set [0, _idx + 1] ;
      }else{
        (HunterKillList select 1) pushBack [dateToNumber date, position _killer, false] ;
      };
    };
  };
  
  // Grant cash reward for a kill
  private _cash = HunterEconomy select 0;
  _cash = _cash + CASH_REWARD;
  //HunterEconomy set [0, _cash];
  hint format ["%1 earned", HunterEconomy select 0];

  
};