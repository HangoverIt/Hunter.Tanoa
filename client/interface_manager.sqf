while {true} do {
  // Show the GUI overlay
  cutRsc["hunter_rsc", "PLAIN", 0];
    
  _dialog = uiNamespace getVariable "GUI" ;
  if (isNil "_dialog" || isNull _dialog) then {
    diag_log "Error, no GUI dialog" ;
  };
  _tctl = _dialog displayCtrl 1200 ;
  if (isNil "_tctl") then {
    diag_log "Error, no GUI control" ;
  };
  //_tctl ctrlShow false;
  _bctl = _dialog displayCtrl 1201 ;
  //_bctl ctrlShow false;
  // Cuttext interferes with cutRsc.
   
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
  
  sleep 1;
};