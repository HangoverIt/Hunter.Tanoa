if (!params [ "_sector"] || count _sector == 0) exitWith {false} ; // missing or invalid parameters

(_sector select 6) > 0; // General base sector