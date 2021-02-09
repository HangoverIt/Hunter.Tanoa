// If the economy hasn't been loaded this is the first time so initialise the economy
if (isNil "HunterEconomy") then {
  playercash = 0;
  enemyfuel = 0;

  // Data structure for the economy
  HunterEconomy = [playercash, enemyfuel];
  
  publicVariable "HunterEconomy" ;
};

