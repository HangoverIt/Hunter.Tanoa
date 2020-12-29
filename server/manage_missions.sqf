waitUntil {!isNil "HunterLocations"} ;
waitUntil {!isNil "HunterBases"} ;

private _alpha = HunterBases select 0 ;
private _alpha_pos = _alpha select 1 ;

if (isNil "HunterMissions") then {
  // missions - current mission, array of missions [ID, Title, Parameters, Script, completed, mandatory] ;
  HunterMissions = [
                     [
                       [0, "Secure the weapon cache", [_alpha_pos, [100,2000], [[["optic_DMS", 1], ["muzzle_snds_H", 1], ["FirstAidKit", 5]], [["launch_RPG32_F", 2], ["srifle_DMR_01_DMS_F", 1]], [["RPG32_F", 3], ["RPG32_HE_F", 6], ["10Rnd_762x54_Mag", 3]]]], "missions\cache.sqf", false, false],
                       [1, "Recover another weapon cache", [_alpha_pos, [100,2000], [[["optic_DMS", 1], ["muzzle_snds_H", 1], ["FirstAidKit", 5]], [["launch_RPG32_F", 2], ["srifle_DMR_01_DMS_F", 1]], [["RPG32_F", 3], ["RPG32_HE_F", 6], ["10Rnd_762x54_Mag", 3]]]], "missions\cache.sqf", false, false],
                       [2, "Kill the officer", [_alpha_pos, [100,2000], "O_G_officer_F"], "missions\assassination.sqf", false, true]
                     ],
                     [
                       [10, "Enemy weapon cache", [15, 20, [[["optic_DMS", 1], ["muzzle_snds_H", 1], ["FirstAidKit", 5]], [["launch_RPG32_F", 2], ["srifle_DMR_01_DMS_F", 1]], [["RPG32_F", 3], ["RPG32_HE_F", 6], ["10Rnd_762x54_Mag", 3]]]], "missions\cache.sqf", false, false],
                       [11, "Destroy the fuel dump", [15,25,"Land_ReservoirTank_V1_F"], "missions\destroy.sqf", false, true],
                       [12, "Destroy the guard tower", [15,25,"Land_Cargo_Patrol_V4_F"], "missions\destroy.sqf", false, true]
                     ],
                     [ 
                       [20, "Remove officer", [30, 49, "O_A_officer_F"], "missions\assassination.sqf", false,true],
                       [21, "Remove officer", [30, 49, "O_officer_F"], "missions\assassination.sqf", false,true],
                       [22, "Remove officer", [30, 49, "O_A_officer_F"], "missions\assassination.sqf", false,true]
                     ]
                   ];
  diag_log "Created mission list------------------------------------------" ;
  HunterMissionCurrent = 0 ;
};

private _mission_locations = [] ;
private _mission_space = 30 ; // metres
// Slow search function to find mission areas in each sector
/*{
  _spos = [_x] call h_getSectorLocation ;
  _size = [_x] call h_getSectorSize ;
  _ismission = [_x] call h_isSectorMission ;
  if (_ismission) then {
    _max_size = (_size select 0) max (_size select 1) ;
    // find safe position on land within the sector
    _safepos = [_spos, 0, _max_size / 2, _mission_space, 0, 0.1, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos ;
    if (!(_safepos isEqualTo [0,0,0])) then {
      _mission_locations pushBack _safepos ;
      diag_log format ["Added mission location %1", _safepos] ;
    };
  ]:
}forEach HunterSectors ;
*/

private _missionscripts = [scriptNull];
private _newmissionset = true ;
while {true} do {
  sleep 20 ;
  _missionset = HunterMissions select HunterMissionCurrent ;
  if (_newmissionset) then {
    _newmissionset = false ;
    _missionscripts = [] ;
    _missionset = HunterMissions select HunterMissionCurrent ;
    {
      // Activate the mission set excluding completed missions/tasks
      _complete = _x select 4 ;
      if (!_complete) then {
        diag_log format ["Starting a mission %1", _x] ;
        _missionscripts pushBack (_x spawn compileFinal preprocessFileLineNumbers (_x select 3)) ;
      } ;
    }forEach _missionset ;
  }else{
    // Missions are active 
    _openmissions = 0 ;
    {
      _complete = _x select 4 ;
      _mandatory = _x select 5 ;
      if (isNull (_missionscripts select _forEachIndex) && !_complete ) then {
        // Mission stopped and not complete, restart
        _missionscripts set [ _forEachIndex, (_x spawn compileFinal preprocessFileLineNumbers (_x select 3))] ;
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

  if(HunterMissionCurrent >= count HunterMissions) exitWith {
    true ;
  } ;
};