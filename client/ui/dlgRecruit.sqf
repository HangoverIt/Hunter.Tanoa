params["_buylist"] ;
private _nullReturn = [] ;
HunterDlgReturn = _nullReturn ;
HunterDlgExit = false ;

private _create_click = {
  params["_ctl"] ;
  
  HunterDlgExit = true ;
};

private _cancel_click = {
  params["_ctl"] ;
  HunterDlgReturn = _nullReturn ;
  HunterDlgExit = true ;
};

private _list_changed = {
  params ["_control", "_selectedIndex"];
  if (_selectedIndex >= 0) then {
    HunterDlgReturn = [_control lbData _selectedIndex, _control lbValue _selectedIndex] ;
    _parent = ctrlParent _control ;
    _ctlPic = _parent displayCtrl 1200 ;
    _ctlPic ctrlSetText getText (configFile >> "CfgVehicles" >> (_control lbData _selectedIndex) >> "editorPreview") ;
    
    _cost = _control lbValue _selectedIndex;
    _textout = format["Unit cost %1", _cost] ;
    if (!isNil "HunterEconomy") then {
      _cash = HunterEconomy select 0 ;
      if (_cash < _cost) then {
        _textout = format["Cost %1, not enough funds", _cost] ;
      }else{
        _textout = format["Cost %1, %2 funds available", _cost, _cash] ;
      };
    };
    
    _ctlText = _parent displayCtrl 1000 ;
    _ctlText ctrlSetText _textout ;
  }else{
    HunterDlgReturn = _nullReturn ;
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
      _ctlList lbSetValue[_idx, _cost];
    }forEach _buylist;
    
    _ctlList lbSetCurSel 0; // set first item as default
    HunterDlgReturn = [_ctlList lbData 0, _ctlList lbValue 0] ;
    
    waitUntil { HunterDlgExit || !dialog };
    closeDialog 0;
  };
};

HunterDlgReturn ;