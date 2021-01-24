params [ "_unit", "_killer", "_instigator", "_useEffects" ];

if ( isServer ) then {

  if (side _instigator == west || side _killer == west) then {
    // Grant cash reward for a vehicle kill
    private _cash = HunterEconomy select 0;

    private _reward = [_unit] call h_getRewardForType;
    //diag_log format ["reward for a %1 is %2", _reward];
    _cash = _cash + _reward;    

    HunterEconomy set [0, _cash];
    publicVariable "HunterEconomy";
  
  };

};