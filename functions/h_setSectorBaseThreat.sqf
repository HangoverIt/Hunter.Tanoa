if (!params [ "_sectors", "_id", "_threat", "_max_threat" ] || count _sectors == 0 || _id > (count _sectors) -1 || _id < 0) exitWith {false} ; // missing or invalid parameters

(_sectors select _id) set [3, _threat] ;
(_sectors select _id) set [4, _max_threat] ;
(_sectors select _id) set [5, _threat] ;

true ;