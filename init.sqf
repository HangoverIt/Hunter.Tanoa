[] call compileFinal preprocessFileLineNumbers "config\parameters.sqf" ;

enableSaving [ false, false ];

[] call compileFinal preprocessFileLineNumbers "shared\shared_init.sqf";
if (isServer) then {
  [] call compileFinal preprocessFileLineNumbers "server\server_init.sqf";
};

if (!isDedicated && hasInterface) then {
	waitUntil { alive player };
	[] call compileFinal preprocessFileLineNumbers "client\client_init.sqf";
} ;

