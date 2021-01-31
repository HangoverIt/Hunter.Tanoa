params [ "_unit", "_killer", "_instigator", "_useEffects" ];

if ( isServer ) then {

  if (side _instigator == west || side _killer == west) then {
    // Grant cash reward for a vehicle kill
    private _cash = HunterEconomy select 0;

    private _reward = [_unit] call h_getRewardForType;

    HunterEconomy set [0, _cash + _reward];
    publicVariable "HunterEconomy";  
  };

};