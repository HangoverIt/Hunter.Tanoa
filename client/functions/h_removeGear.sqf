params["_p"] ;

// Remove everything
{_p unassignItem _x;}forEach assignedItems _p ;
removeAllWeapons _p;
removeAllItems _p;
removeBackpackGlobal _p ;
removeVest _p ;
removeUniform _p ;
removeGoggles _p ; // just diving goggles, use unassignItem and remove from inventory
removeHeadgear _p ;