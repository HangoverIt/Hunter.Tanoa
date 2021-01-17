waitUntil {!isNil "HunterLocations"} ;
waitUntil {!isNil "HunterBases"} ;

private _now = dateToNumber date ;
private _min = ((1/365)/24)/60 ;

private _alpha = HunterBases select 0 ;
private _alpha_pos = _alpha select 1 ;

if (isNil "HunterMissions") then {
  // missions - current mission, array of missions [ID, Title, Parameters, Script, completed, mandatory] ;
  HunterMissions = [
                     [
                       [0, "Rescue your contact, get information to progress your mission", 30, "meet", [_alpha_pos, [100,2000], ""], "missions\rescue.sqf", false, true]
                     ],
                     [
                       [11, "Destroy the fuel dump for your contact", 45, "refuel", [15,25,"Land_ReservoirTank_V1_F"], "missions\destroy.sqf", false, true],
                       [12, "Your contact requests you kill the sector officer", 5, "target", [_alpha_pos, [100,2000], "O_G_officer_F"], "missions\assassination.sqf", false, true]
                     ],
                     [
                       [21, "Fetch further intel to progres your mission", 60, "documents", [30,49], "missions\intel.sqf", false, true]
                     ],
                     [
                       [31, "Destroy the guard tower", 60, "scout", [15,25,"Land_Cargo_Patrol_V4_F"], "missions\destroy.sqf", false, true],
                       [32, "Remove commander", 80, "target", [30, 49, "O_A_officer_F"], "missions\assassination.sqf", false,true]
                     ],
                     [
                       [41, "Kill the general", 80, "danger", [90, 1000, "O_A_officer_F"], "missions\assassination.sqf", false,true]
                     ]
                   ];
  diag_log "Created mission list------------------------------------------" ;
  HunterMissionCurrent = 0 ;
};

// Main mission vars
private _missionscripts = [];
private _newmissionset = true ;
// Side mission vars
private _sidemissionscripts = [] ;
private _nextsidemissionat = _now + (floor random(10) + 5) * _min; // at least 5 min between missions up to 15 min
private _maxsidemissionsopen = 5 ;
private _nextidx = 10000 ; // start high to avoid the main missions
while {true} do {
  sleep 20 ;
  _now = dateToNumber date ;
  
  // If main mission list is still open then create or track missions
  if (HunterMissionCurrent < count HunterMissions) then {
    _missionset = HunterMissions select HunterMissionCurrent ;
    if (_newmissionset) then {
      _newmissionset = false ;
      _missionscripts = [] ;
      _missionset = HunterMissions select HunterMissionCurrent ;
      {
        // Activate the mission set excluding completed missions/tasks
        _complete = _x select 6 ;
        if (!_complete) then {
          diag_log format ["Starting a mission %1", _x] ;
          _missionscripts pushBack (_x spawn compileFinal preprocessFileLineNumbers (_x select 5)) ;
        } ;
      }forEach _missionset ;
    }else{
      // Missions are active 
      _openmissions = 0 ;
      {
        _complete = _x select 6 ;
        _mandatory = _x select 7 ;
        if (isNull (_missionscripts select _forEachIndex) && !_complete ) then {
          // Mission stopped and not complete, restart
          _missionscripts set [ _forEachIndex, (_x spawn compileFinal preprocessFileLineNumbers (_x select 5))] ;
        }; 
        if (!_complete && _mandatory) then {
          _openmissions = _openmissions + 1;
        };
      }forEach _missionset;
      
      if (_openmissions == 0) then {
        // All missions complete in this set. Start new set
        HunterMissionCurrent = HunterMissionCurrent +1 ;
         _newmissionset = true ;
      };
    };
  };
  
  if (_now > _nextsidemissionat && (_maxsidemissionsopen > {!isNull _x} count _sidemissionscripts)) then {
    // Set next mission spawn time
    _nextsidemissionat = _now + (floor random(10) + 5) * _min;
    
    // Purge completed missions
    for "_i" from (count _sidemissionscripts) -1 to 0 step -1 do {
      if (isNull (_sidemissionscripts select _i)) then {_sidemissionscripts deleteAt _i ;};
    };
    
    // Randomly choose a mission
    _missionindex = floor random(3) ;
    _sidemission = [] ;
    switch (_missionindex) do {
      case 0: // Cache
        {_sidemission = [_nextidx, "Optional: Secure the weapon cache", 10, "",[10, 1000, [[["optic_DMS", 1], ["muzzle_snds_H", 1], ["FirstAidKit", 5]], [["launch_RPG32_F", 2], ["srifle_DMR_01_DMS_F", 1]], [["RPG32_F", 3], ["RPG32_HE_F", 6], ["10Rnd_762x54_Mag", 3]]]], "missions\cache.sqf", false, false]};
      case 1: // Assassination
        {_sidemission = [_nextidx, "Optional: Assassinate the target", 10, "", [10, 1000, "O_A_officer_F"], "missions\assassination.sqf", false,true]};
      case 2: // Fuel dump
        {_sidemission = [_nextidx, "Optional: Destroy fuel", 10, "", [10,1000,"Land_ReservoirTank_V1_F"], "missions\destroy.sqf", false, true]} ;
    };
    _sidemissionscripts pushBack (_sidemission spawn compileFinal preprocessFileLineNumbers (_sidemission select 5));
    _nextidx = _nextidx + 1; // in theory the number could reach a max supported value, but assume that this would take a long time and not going to happen to check for.
    
  };

};