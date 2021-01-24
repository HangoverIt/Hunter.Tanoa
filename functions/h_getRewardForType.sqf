//////////////////////////////////////////////////////////////////////
//
// Retrieves a reward value for a specified target type
// 
// takes an object representing the target to be evaluated
// returns the reward for that object type
params ["_target"];

{
  if (_target isKindOf (_x select 0)) exitWith {
      diag_log format ["this is a %1, its reward is %2", _x select 0, _x select 1];
      (_x select 1)
    };
  
} forEach HUNTER_CASH_REWARDS;
