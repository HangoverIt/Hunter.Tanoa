params["_unit"] ;

private _building = nearestObject [_unit, "HouseBase"];

private _relPos = _building worldToModel (getPos _unit);

private _boundingBox = boundingBox _building;
private _min = _boundingBox select 0;
private _max = _boundingBox select 1;

private _myX = _relPos select 0;
private _myY = _relPos select 1;
private _myZ = _relPos select 2;

private _inside = false ;
if ((_myX > (_min select 0)) && (_myX < (_max select 0)) &&
    (_myY > (_min select 1)) && (_myY < (_max select 1)) &&
    (_myZ > (_min select 2)) && (_myZ < (_max select 2))) then {
  _inside = true;
} ;

_inside