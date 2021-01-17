params["_handle"] ;

// If game time is greater than the mission expiry then return true
(dateToNumber date) > (_handle select 3) ;
