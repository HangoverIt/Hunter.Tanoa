params [ ["_grid_size", [6,6]] ];

private _sector_width = worldSize / (_grid_size select 0) ;
private _sector_height= worldSize / (_grid_size select 1) ;
private _HunterSectors = [] ;
//_sector_info = ["name", [coords], [size], BaseThreatLevel, MaxThreatLevel, ActualThreatLevel, GeneralBase(1/0), Informants(1/0), Missions(1/0)] ;

private _id = 0 ;

//diag_log format ["%1: creating sectors at size %2", time, _grid_size] ;

for "_y" from 0 to (_grid_size select 1) do {
  for "_x" from 0 to (_grid_size select 0) do {
    _xpos = _x * _sector_width ;
    _ypos = _y * _sector_height ;
    //diag_log format ["%1: creating sector at x %2, y %3", time, _xpos, _ypos] ;
    _sector_coords = [_xpos + (_sector_width / 2),_ypos + (_sector_height / 2)]; // Centered coordinate
    _sector_size = [_sector_width, _sector_height] ;
    _sector_info = ["H"+str _id, _sector_coords, _sector_size, 10, 50, 10, 0, 1, 1] ;
    _HunterSectors pushBack _sector_info ;
    _id = _id + 1 ;
  };
};

_HunterSectors ;