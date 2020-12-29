private _sector = 0 ;
private _threat = 100 ;
if (count _this == 2) then {
  _sector = _this select 0 ;
  _threat = _this select 1 ;
} ;

if (count _this == 3) then {
  private _sectors = _this select 0 ;
  private _sector = (_sectors select (_this select 1)) ;
  _threat = _this select 2 ;
};

if (count _this == 2 || count _this == 3) then {
  _max_threat = _sector select 4;
  _base_threat = _sector select 3 ;
  // Check if threat is above the max threat threshold. Cap at max threat.
  if (_threat > _max_threat) then {
    _threat = _max_threat ;
  };
  
  // Threat cannot be lower than base threat
  if (_threat < _base_threat) then {
    _threat = _base_threat ;
  };

  _sector set [5, _threat] ;
};
