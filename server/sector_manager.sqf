params[["_oneoff", false]] ;
waitUntil {!isNil "HunterSectors"} ;


private _timeframe = 10 ;
private _threattimeout = 0 ;
private _tmpsectorinfo = [] ;
if (isNil "HUNTER_THREAT_DECREASE_TIME") then {
  HUNTER_THREAT_DECREASE_TIME = 600 ;
};

// Create an array to hold temporary info
for "_i" from 0 to (count HunterSectors - 1) do {
  // Hold the last threat indicator
  _tmpsectorinfo pushBack [0];
};

while{true} do {
  
  
  {
    // Draw the sectors
    _loc = [_x] call h_getSectorLocation;
    _size = [_x] call h_getSectorSize;
    _name = [_x] call h_getSectorName ;
    _mkr = createMarkerLocal [(_x select 0), [(_loc select 0), (_loc select 1)] ];
    _mkr setMarkerShapeLocal "RECTANGLE" ;
    _mkr setMarkerSizeLocal [((_size select 0) / 2), ((_size select 1) / 2)] ;  
    _mkr setMarkerTextLocal _name ;

    _mkralpha = 0.1 ;
    _mkrcolour = "ColorBlack" ;
    _mkrbrush = "SolidBorder"  ;
    _threat = [_x] call h_getSectorThreat ;
    if (_threat >= 30) then {
      _mkrcolour = "ColorYellow" ;
      _mkrbrush = "Solid" ;
      _mkralpha = 0.3 ;
    };
    if (_threat >= 50) then {
      _mkrcolour = "ColorOrange" ;
      _mkrbrush = "Solid" ;
      _mkralpha = 0.3 ;
    };
    if (_threat >= 80) then {
      _mkrcolour = "ColorRed" ;
      _mkrbrush = "Solid" ;
      _mkralpha = 0.3 ;
    };
    _mkr setMarkerBrushLocal _mkrbrush ;
    _mkr setMarkerColorLocal _mkrcolour ;
    _mkr setMarkerAlpha _mkralpha;
    
    _mkrtxt = createMarkerLocal ["txt" + _name, [(_loc select 0), (_loc select 1)] ];
    _mkrtxt setMarkerTypeLocal "hd_dot" ;
    _mkrtxt setMarkerText _name ;
    
    // Drop threat in sector after a period of time defined in init.sqf
    if (_threattimeout >= HUNTER_THREAT_DECREASE_TIME) then {
      [_x, _threat - 1] call h_setSectorThreat;
    } ;
    
  } forEach HunterSectors;
  
  _threattimeout = _threattimeout + 1;
  if (_threattimeout > HUNTER_THREAT_DECREASE_TIME) then {
    _threattimeout = 0 ;
  };
  
  if (_oneoff) exitWith {} ;
  sleep _timeframe ;
};