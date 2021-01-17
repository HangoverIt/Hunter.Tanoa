params["_id", "_title", "_expiry", "_pos", "_description", ["_icon", ""]];

// Expiry is in minutes
private _now = dateToNumber date ;
private _min = ((1/365)/24)/60 ;
private _mission_end_time = (_expiry * _min) + _now;

private _taskid = format["task%1", _id] ;
private _enddate = numberToDate [2008, _mission_end_time] ;
_description = _description + format[". Expires at %1:%2", _enddate select 3, _enddate select 4] ;
[true, _taskid, [_description, _title, format["huntermission%1", _id]], _pos, "AUTOASSIGNED", -1, true, _icon, false] call BIS_fnc_taskCreate ;

// Handle for mission
[true, _description, _taskid, _mission_end_time];

// Supported icons
/*
[CfgTaskTypes/Default
CfgTaskTypes/armor
CfgTaskTypes/attack
CfgTaskTypes/backpack
CfgTaskTypes/boat
CfgTaskTypes/box
CfgTaskTypes/car
CfgTaskTypes/container
CfgTaskTypes/danger
CfgTaskTypes/defend
CfgTaskTypes/destroy
CfgTaskTypes/documents
CfgTaskTypes/download
CfgTaskTypes/exit
CfgTaskTypes/getin
CfgTaskTypes/getout
CfgTaskTypes/heal
CfgTaskTypes/heli
CfgTaskTypes/help
CfgTaskTypes/intel
CfgTaskTypes/interact
CfgTaskTypes/kill
CfgTaskTypes/land
CfgTaskTypes/listen
CfgTaskTypes/map
CfgTaskTypes/meet
CfgTaskTypes/mine
CfgTaskTypes/move
CfgTaskTypes/move1
CfgTaskTypes/move2
CfgTaskTypes/move3
CfgTaskTypes/move4
CfgTaskTypes/move5
CfgTaskTypes/navigate
CfgTaskTypes/plane
CfgTaskTypes/radio
CfgTaskTypes/rearm
CfgTaskTypes/refuel
CfgTaskTypes/repair
CfgTaskTypes/rifle
CfgTaskTypes/run
CfgTaskTypes/scout
CfgTaskTypes/search
CfgTaskTypes/takeoff
CfgTaskTypes/talk
CfgTaskTypes/talk1
CfgTaskTypes/talk2
CfgTaskTypes/talk3
CfgTaskTypes/talk4
CfgTaskTypes/talk5
CfgTaskTypes/target
CfgTaskTypes/truck
CfgTaskTypes/unknown
CfgTaskTypes/upload
CfgTaskTypes/use
CfgTaskTypes/wait
CfgTaskTypes/walk
CfgTaskTypes/whiteboard
CfgTaskTypes/A
CfgTaskTypes/B
CfgTaskTypes/C
CfgTaskTypes/D
CfgTaskTypes/E
CfgTaskTypes/F
CfgTaskTypes/G
CfgTaskTypes/H
CfgTaskTypes/I
CfgTaskTypes/J
CfgTaskTypes/K
CfgTaskTypes/L
CfgTaskTypes/M
CfgTaskTypes/N
CfgTaskTypes/O
CfgTaskTypes/P
CfgTaskTypes/Q
CfgTaskTypes/R
CfgTaskTypes/S
CfgTaskTypes/T
CfgTaskTypes/U
CfgTaskTypes/V
CfgTaskTypes/W
CfgTaskTypes/X
CfgTaskTypes/Y
CfgTaskTypes/Z
CfgTaskTypes/airdrop]
*/