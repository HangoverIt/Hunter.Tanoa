params ["_options", "_threat"] ;

private _last_level = (_options select 0) ;
{
  if (_threat < (_x select 0)) exitWith{}; 
  _last_level = (_options select _forEachIndex) ;

}forEach _options ;

_objects = (_last_level select 1) ;

// Return a random choice from the threat list
_objects select (floor random count _objects);