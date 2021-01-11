params [ "_unit", "_killer", "_instigator", "_useEffects" ];

if ( isServer ) then {

  if (side _instigator == west || side _killer == west) then {
    hint "vehicle destroyed";
  
    // Grant cash reward for a vehicle kill
    private _cash = HunterEconomy select 0;
    _cash = _cash + HUNTER_CASH_REWARD_VEHICLE;    
    HunterEconomy set [0, _cash];
    publicVariable "HunterEconomy";
  
  };

};