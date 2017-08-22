############################################################################################
#		written by Lake of Constance Hangar :: M.Kraus
#		BMW S 1000 RR for Flightgear September 2014
#		This file is licenced under the terms of the GNU General Public Licence V2 or later
#               small extract modified by Herbert Wagner for Catapillar 793D in 12/2016
############################################################################################### 

var fuel = props.globals.getNode("/consumables/fuel/tank/level-m3");
var fuel_lev = 0;
var fuel_weight = props.globals.getNode("/consumables/fuel/tank/level-lbs"); # max 10846 lbs
var ignition = props.globals.getNode("/controls/engines/engine/ignition");
var throttle = props.globals.getNode("/controls/engines/engine/throttle");
var payload =  props.globals.getNode("/payload/weight/weight-lb");


var loop = func {
  
  # Loadfactor is 0.38 with no and 0.7 with full payload
  var Loadfactor = 0.38+(payload.getValue()*0.000000665825);
  
  # LMPsec is liter per second/8
  var LMPsec = (0.17*2415*Loadfactor)/(0.84*3600*8);
  
  # Consum is LMPsec in lbs
  var Consum = LMPsec*2.20462262185;

       if(ignition.getValue() == 1)
	{
   	 if (fuel.getValue() < 0.015)
	  {
   	   ignition.setValue(0);
   	  }
   	 else
	  {
   	   fuel_lev = fuel_weight.getValue();
   	   fuel_weight.setValue(fuel_lev - (0.85*throttle.getValue()+0.1)*Consum);
   	  }
	}

settimer (loop, 0.125);
}


loop();