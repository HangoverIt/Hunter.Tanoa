params["_buylist"] ;
HunterDlgReturn = "" ;
HunterDlgExit = false ;


private _create_click = {
  params["_ctl"] ;
  
  HunterDlgExit = true ;
};

private _cancel_click = {
  params["_ctl"] ;
  HunterDlgExit = true ;
};

private _list_changed = {
  params ["_control", "_selectedIndex"];
  if (_selectedIndex >= 0) then {
    HunterDlgReturn = _control lbData _selectedIndex ;
    _parent = ctrlParent _control ;
    _ctlPic = _parent displayCtrl 1200 ;
    _ctlPic ctrlSetText getText (configFile >> "CfgVehicles" >> HunterDlgReturn >> "editorPreview") ;
    
  }else{
    HunterDlgReturn = "" ;
    _ctlPic ctrlSetText "" ;
  };
};

if (createDialog "hunter_recruit") then {
  waitUntil {dialog} ;
  private _dlg = findDisplay 9001 ;
  if (!isNull _dlg) then {
    private _ctlCreate = _dlg displayCtrl 1600 ;
    private _ctlCancel = _dlg displayCtrl 1601 ;
    private _ctlList = _dlg displayCtrl 1500 ;
    
    _ctlCreate ctrlAddEventHandler ["ButtonClick", _create_click] ;
    _ctlCancel ctrlAddEventHandler ["ButtonClick", _cancel_click] ;
    _ctlList ctrlAddEventHandler ["LBSelChanged", _list_changed] ;
    
    lbClear _ctlList ;
    
    {
      _class = _x select 0 ;
      _cost = _x select 1 ;
      _idx = _ctlList lbAdd getText (configFile >> "CfgVehicles" >> _class >> "displayName") ;
      _ctlList lbSetData[_idx, _class ] ;
    }forEach _buylist;
    
    _ctlList lbSetCurSel 0; // set first item as default
    HunterDlgReturn = _ctlList lbData 0 ;
    
    waitUntil { HunterDlgExit || !dialog };
    closeDialog 0;
  };
};

HunterDlgReturn ;