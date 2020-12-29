params [ "_unit", "_killer", "_instigator", "_useEffects" ];

_unit removeAllEventHandlers "Killed";
PlayerDeathGear = getUnitLoadout _unit;
diag_log format ["Player %1 dead, saving gear as %2", _unit, PlayerDeathGear] ;

// take all weapons from dead soldier to prevent an exploit to duplicate items 
removeAllWeapons _unit;
removeAllItems _unit;
removeBackpackGlobal _unit ;
removeGoggles _p ; // just diving goggles, use unassignItem and remove from inventory
removeHeadgear _p ;