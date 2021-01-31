//////////////////////////////////////////////////////////////////////
//
// Retrieves a reward value for a specified unit type
// adding a bonus value if the unit is armed
// 
// takes an object representing the unit to be evaluated
// returns the reward for that object type
params ["_unit"];

_reward = 0;

{
  // if the unit type is on our reward list set the reward value and exit
  if (_unit isKindOf (_x select 0)) exitWith {
      _reward = (_x select 1);
      
      // if the unit is armed add a bonus
      if(currentWeapon _unit != "") then {
        _reward = _reward + HUNTER_ARMED_BONUS;
      };
    };
  
} forEach HUNTER_CASH_REWARDS;

_reward;
