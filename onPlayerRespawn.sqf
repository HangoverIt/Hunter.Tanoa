params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

waitUntil{!isNil "h_defaultGear" && !isNil "h_assignGear"};

diag_log "Respawning player" ;

player addAction ["Deploy Camp", "client\deploy_camp.sqf", nil, 1.5, false, false, "", "backpack player == HUNTER_CAMP_BAG", 10, false, "", ""] ;
player addEventHandler["Killed", {_this call player_killed}];

// Sort out player gear
private _loadedplayer = false ;

if (!isNil "PlayerDeathGear") then {
  _loadedplayer = true ;
  player setUnitLoadout PlayerDeathGear ;
};

// If this is the first spawn of a player then there will be no saved death gear. Load from save file
if (!_loadedplayer) then {
  {
    _hunter = missionNamespace getVariable format ["hunt%1", (_forEachIndex + 1)] ;
    if (!isNil "_hunter") then {
      diag_log format ["%1: Found a hunter at index %2 named %3", time, _forEachIndex, name _hunter] ;
    }else{
      diag_log format ["%1: No spawned hunter at index %2", time, _forEachIndex] ;
    };
    
    if (!isNil "_hunter") then {
      if(_hunter isEqualTo player) exitWith {
        // load gear - OLD FORMAT
        // [_weapons, _goggles, _vest, _uniform, _backpack, _headgear, _headmounteddisplay, _assigned, _vestcontents, _uniformcontents, _backpackcontents]
        _contents = (_x select 0) ;
        
        if (count _contents == 0) then {
          diag_log format ["%1: No gear for hunter index %2, setting default", time, _forEachIndex] ;
          // set default gear - OLD FORMAT, REPLACE WITH NEW using get/setUnitLoadout
          _contents = [] call h_defaultGear ;
          [_hunter, _contents] call h_assignGear ; 
        }else{
          _hunter setUnitLoadout _contents ;
        };
        diag_log format ["%1: Hunter %2 Assigning gear %3", time, _forEachIndex, _contents] ;

      };
    };
  } forEach HunterPlayers;
  publicVariable "HunterPlayers";
};

// Allow multi roles for players
player setUnitTrait ["Medic",true];
player setUnitTrait ["Engineer",true];    



