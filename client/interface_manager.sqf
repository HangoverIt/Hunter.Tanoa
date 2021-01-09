while {true} do {
  _dialog = uiNamespace getVariable "GUI" ;

  // Check if the GUI overlay is active and then do UI overlay stuff  
  if (!isNil "_dialog" ) then {
    if (!isNull _dialog) then {
      _statusctl = _dialog displayCtrl 1202 ;
      _statusctl ctrlSetText format [ "Hunter 0.1      Cash %1$", 1000 ];
      
      _basectl = _dialog displayCtrl 1202 ;
      
      _tctl = _dialog displayCtrl 1200 ; // Tree icon
      _bctl = _dialog displayCtrl 1201 ; // Building icon
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
    }else{
      cutRsc["hunter_rsc", "PLAIN", -1];
    };
  }else{
    cutRsc["hunter_rsc", "PLAIN", -1];
  };
  
  sleep 1;
};