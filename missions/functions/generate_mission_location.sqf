params ["_minthreat", "_maxthreat", "_type"] ;

private _players = call BIS_fnc_listPlayers ;
  
_filteredlocations = [] ;
if (typeName _minthreat == "ARRAY" && typeName _maxthreat == "ARRAY") then {
  // Input is an array, assume location has been provided instead of threat
  _location = _minthreat ;
  _radius_min = _maxthreat select 0 ;
  _radius_max = _maxthreat select 1 ;
 
  {
    _locationpos = _x select 2;
    _dis = _locationpos distance _location;
    if (_dis >= _radius_min && _dis <= _radius_max) then {
      _filteredlocations pushBack _x ;
    };
  }forEach HunterLocations ;
  
}else{
  // Get a random location within min and max threat
  {
    _sector = _x select 4 ;
    _locationpos = _x select 2;
    _threat = [_sector] call h_getSectorBaseThreat ;
    _awayfromplayers = true ;
    if (_threat >= _minthreat && _threat <= _maxthreat) then {
      {
        if (_x distance _locationpos <= 500) then {
          _awayfromplayers = false ;
        };
      }forEach _players ;
      if (_awayfromplayers) then {
          _filteredlocations pushBack _x ;
      };
    }; 
  }forEach HunterLocations ;
};

// Fallback to all locations
if (count _filteredlocations == 0) then {
  _filteredlocations = HunterLocations ;
};

private _location = _filteredlocations select (floor random count _filteredlocations) ;

_location ;