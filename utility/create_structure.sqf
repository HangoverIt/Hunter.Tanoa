// Use the script_structures code in the editor to build the input array of objects to restore in this function
params["_centrepos", "_objs", ["_rotation",0], ["_create", true], ["_flat", false]] ;

if (_flat) then {
  _centrepos = ATLToASL _centrepos ;
};

// Objs can be a filename containing an array of objects or the array of objects
if (typeName _objs == "STRING") then {
  _objs = [] call compile preprocessFileLineNumbers _objs ;
}; 

if ((count _objs) == 0) exitWith {} ;

// Calculate centre of the structure
private _first_obj = _objs select 0 ;
private _first_pos = _first_obj select 1 ;
private _max = [_first_pos select 0, _first_pos select 1, _first_pos select 2] ;
private _min = [_first_pos select 0, _first_pos select 1, _first_pos select 2] ;
private _lowest_point =0;

{
  _pos = _x select 1 ;
  _max = [((_pos select 0) max (_max select 0)), ((_pos select 1) max (_max select 1)), ((_pos select 2) max (_max select 2))] ;
  _min = [((_pos select 0) min (_min select 0)), ((_pos select 1) min (_min select 1)), ((_pos select 2) min (_min select 2))] ;
}forEach _objs ;

// Create the objects
private _diff = _max vectorDiff _min ;
private _centreobjs = (_diff vectorMultiply 0.5) vectorAdd _min ;
_centreobjs set [2, _min select 2] ; // Set z pos to lowest object
private _transform = _centrepos vectorDiff _centreobjs; // 3D transform

if (_flat) then {
	_lowest_point = getTerrainHeightASL (_first_pos vectorAdd _transform );
	{
	  _newpos = (_x select 1) vectorAdd _transform ;
	  _lowest_point = _lowest_point min (getTerrainHeightASL _newpos) ;
	}forEach _objs ;
};

_centrepos set [2, _lowest_point] ;
_transform = _centrepos vectorDiff _centreobjs; // redo 3D transform

diag_log format["Max %4, Min %5, Center of objects is %1, the transform is %2, to position %3", _centreobjs, _transform, _centrepos, _max, _min] ;

// Check the created flag is set, otherwise skip this and just return size
if (_create) then {
	{
	  _class = _x select 0 ;
	  _pos = _x select 1 ;
	  _dir = _x select 2 ;
	  
	  _newpos = _pos vectorAdd _transform;

	  if (_rotation != 0) then {
		_disfromcentre = _newpos vectorDiff _centrepos ;
		_newpos = [_disfromcentre, -(_rotation)] call BIS_fnc_rotateVector2D;
		_newpos = _newpos vectorAdd _centrepos;
	  };
	  _o = createVehicle [_class, _newpos, [], 0, "CAN_COLLIDE"] ;
	  if (_flat) then {
  	    _o setPosASL _newpos ; // set world position as terrain is unlikely to be 100% flat
	  }else{
	    _o setPosATL _newpos ;
	  };
	  if (_rotation == 0) then {
		_o setDir _dir ;
	  }else{
		_o setDir _dir + _rotation ;
	  };
	}forEach _objs ;
	
};

// Return size of new structure
[abs((_max select 0) - (_min select 0)), abs((_max select 1) - (_min select 1))] ;