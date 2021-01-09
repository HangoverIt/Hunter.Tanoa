playercash = 0;
enemyfuel = 0;
HunterEconomy = [playercash, enemyfuel];

addMissionEventHandler ["EntityKilled",
{
	params ["_killed", "_killer", "_instigator"];
	
	// This is a workaround suggested in the documentation
	// see https://community.bistudio.com/wiki/Arma_3:_Event_Handlers/addMissionEventHandler#EntityKilled
	if (isNull _instigator) then {_instigator = UAVControl vehicle _killer select 0}; // UAV/UGV player operated road kill
	if (isNull _instigator) then {_instigator = _killer}; // player driven vehicle road kill
	
	hint str side _killed;
		
	if(isPlayer _instigator && side _killed == opfor) then {
		private _cash = HunterEconomy select 0;
		_cash = _cash + 10;
		HunterEconomy set [0, _cash];
		diag_log format ["%1 earned", HunterEconomy select 0];
		hint format ["%1 earned", HunterEconomy select 0];
	}
}];
