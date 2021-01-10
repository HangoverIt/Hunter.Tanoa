private _createoverlay = true ;
private _showbaseicon = false ;

while {true} do {
  _dialog = uiNamespace getVariable "GUI" ;
  
  // Check if the GUI overlay is active and then do UI overlay stuff  
  if (!isNil "_dialog" ) then {
    if (!isNull _dialog) then {
      _statusctl = _dialog displayCtrl 1202 ;
      _statusctl ctrlSetText format [ "Hunter 0.1      Cash %1$", 1000 ];
      
      _basectl = _dialog displayCtrl 1203 ;
      _attackctl = _dialog displayCtrl 1204 ;
      _attacktxtctl = _dialog displayCtrl 1205 ;
      
      _tctl = _dialog displayCtrl 1200 ; // Tree icon
      _bctl = _dialog displayCtrl 1201 ; // Building icon
      // Cuttext interferes with cutRsc.
      
      // Show if player is in cover      
      if ([player] call h_isInBuilding) then {
        _tctl ctrlShow false;
        _bctl ctrlShow true;
      }else{
        _bctl ctrlShow false;
        if ([player] call h_isInTrees) then {
          _tctl ctrlShow true;
        }else{
          _tctl ctrlShow false;
        };
      };
      
      // Show indicator if within base boundary
      _showbaseicon = false ;
      {
        _basename = _x select 0 ;
        _basepos = _x select 1 ;
        
        if (player distance _basepos <= HUNTER_BASE_RADIUS) exitWith {
          _showbaseicon = true ;
        };

      }forEach HunterBases;
      
      {
        _basepos = _x select 1 ;
        if (player distance _basepos <= HUNTER_CAMP_RADIUS) exitWith {
          _showbaseicon = true ;
        };
      } forEach HUNTER_CAMP ;
      
      _basectl ctrlShow _showbaseicon ;
      
    }else{
      _createoverlay = true ;
    };
  }else{
    _createoverlay = true ;
  };
  
  if (_createoverlay) then {
    // will need creating the first time or when overlay is disabled (respawn for instance)
    _createoverlay = false ;
    cutRsc["hunter_rsc", "PLAIN", -1];
  };
  
  sleep 1;
};