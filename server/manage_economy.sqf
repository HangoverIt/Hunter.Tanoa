// temporarily initialise to zero, these will eventually get thier values from the save file
playercash = 0;
enemyfuel = 0;

// Data structure for the economy
HunterEconomy = [playercash, enemyfuel];

//diag_log format ["rewards array %1", HUNTER_CASH_REWARDS];


publicVariable "HunterEconomy" ;
