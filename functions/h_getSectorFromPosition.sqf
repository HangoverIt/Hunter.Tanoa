params ["_sectors", "_pos"] ;

private _return = [] ;
// Update associated sector
{
  _spos = [_x] call h_getSectorLocation ;
  _size = [_x] call h_getSectorSize ;
  if (_pos inArea[[(_spos select 0), (_spos select 1)], ((_size select 0) / 2), ((_size select 1) / 2), 0, true, -1]) exitWith {
    _return = _x;
  };
}forEach _sectors ;

_return ;