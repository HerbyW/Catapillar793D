# -new light function for MP-Modus
# -all systems
# -Killer grass elimination
# -mouse control
# copyright by Herbert Wagner 02/2016



var sbc1 = aircraft.light.new( "/sim/model/lights/sbc1", [0.5, 0.3] );
sbc1.interval = 0.1;
sbc1.switch( 1 );

var sbc2 = aircraft.light.new( "/sim/model/lights/sbc2", [0.2, 0.3], "/sim/model/lights/sbc1/state" );
sbc2.interval = 0;
sbc2.switch( 1 );

setlistener( "/sim/model/lights/sbc2/state", func(n) {
  var bsbc1 = sbc1.stateN.getValue();
  var bsbc2 = n.getBoolValue();
  var b = 0;
  if( bsbc1 and bsbc2 and getprop( "/controls/lighting/beacon") ) {
    b = 1;
  } else {
    b = 0;
  }
  setprop( "/sim/model/lights/beacon/enabled", b );

  if( bsbc1 and !bsbc2 and getprop( "/controls/lighting/indicators" ) ) {
    b = 1;
  } else {
    b = 0;
  }
  setprop( "/sim/model/lights/indicators/enabled", b );
});

var beacon = aircraft.light.new( "/sim/model/lights/beacon", [0.5, 0.5] );
beacon.interval = 0;

var indicators = aircraft.light.new( "/sim/model/lights/indicators", [0.7, 0.7] );
indicators.interval = 0;

###########################################################################
setlistener("/controls/gear/brake-left", func() {
  
  if (getprop("/controls/gear/brake-left") == 1 or getprop("/controls/gear/brake-parking") == 1)
  {setprop("/controls/gear/braking-light", 1);
  } else
  { setprop("/controls/gear/braking-light", 0);
  }

});

setlistener("/controls/gear/brake-right", func() {
  
  if (getprop("/controls/gear/brake-right") == 1 or getprop("/controls/gear/brake-parking") == 1)
  {setprop("/controls/gear/braking-light", 1);
  } else
  { setprop("/controls/gear/braking-light", 0);
  }

});

setlistener("/controls/gear/brake-parking", func() {
  
  if (getprop("/controls/gear/brake-parking") == 1)
  {setprop("/controls/gear/braking-light", 1);
  } else
  { setprop("/controls/gear/braking-light", 0);
  }

});

###########################################################################
# fcs/rudder-pos-norm ADRIVE Control : NO STEERING CONTROL WITHOUT SERVO

setlistener("fdm/jsbsim/fcs/rudder-pos-norm", func() {
  
  if (getprop("/controls/switches/ADRIVE") == 0)
  {setprop("fdm/jsbsim/fcs/rudder-pos-norm", 0);
   setprop("fdm/jsbsim/fcs/steer-cmd-norm", 0);
   setprop("fdm/jsbsim/fcs/steer-pos-deg", 0);
   setprop("fdm/jsbsim/fcs/steer-pos-deg[1]", 0);
  } 
});
###########################################################################
# fcs/rudder-pos-norm TXDRIVE Control : RANDOM CONFUSION WITHOUT MECHANICAL GEAR CONTROL

setlistener("fdm/jsbsim/fcs/rudder-pos-norm", func() {
  
  if (getprop("/controls/switches/TXDRIVE") == 0)
  {setprop("fdm/jsbsim/fcs/steer-cmd-norm", 2 * rand() - 1);
   setprop("fdm/jsbsim/fcs/steer-pos-deg",  20 * rand() - 10);
  } 
});
###########################################################################
# fcs/rudder-pos-norm TCS Control : More RANDOM CONFUSION WITHOUT Traction CONTROL

setlistener("fdm/jsbsim/fcs/rudder-pos-norm", func() {
  
  if (getprop("/controls/switches/TCS") == 0)
  {setprop("fdm/jsbsim/fcs/steer-cmd-norm", 4 * rand() - 2);
   setprop("fdm/jsbsim/fcs/steer-pos-deg",  40 * rand() - 20);
  } 
});
###########################################################################

# engine LiqCooler temp 2 + press 4
# engine Oel press 3
# engine whatever 7
# engine electrical 5
# ADRIVE press 2
# ADRIVE temp 3
# ADRIVE temp+press 4

 setprop("/controls/liqcooltemp", getprop("environment/temperature-degc")); 
 setprop("/controls/liqcoolpress", getprop("environment/pressure-inhg"));
 setprop("/controls/oelpress", getprop("environment/pressure-inhg"));
 setprop("/controls/enginewhatever", 1);
 setprop("/controls/engineelectric", 1);
 setprop("/controls/ADpress", getprop("environment/pressure-inhg"));
 setprop("/controls/ADtemp", getprop("environment/temperature-degc")); 
 var temptimer = 1200 / (getprop("environment/temperature-degc") +60);
 
 var LiqCoolTempTimer = maketimer(25.0, func { 
   if (getprop("controls/engines/engine/ignition") == 1)
   {
 interpolate("/controls/liqcooltemp", 80, temptimer + 12);
 interpolate("/controls/liqcoolpress", 150, temptimer +8); 
 interpolate("/controls/oelpress", 120, temptimer +5);
 interpolate("/controls/enginewhatever", 0, temptimer + 3);
 interpolate("/controls/ADpress", 130, temptimer + 7);
 interpolate("/controls/ADtemp", 70, temptimer + 10);
   } else {
 interpolate("/controls/liqcooltemp", getprop("environment/temperature-degc"), 23.0);
 interpolate("/controls/liqcoolpress", getprop("environment/pressure-inhg"), 20.0); 
 interpolate("/controls/oelpress", getprop("environment/pressure-inhg"), 17.0);
 interpolate("/controls/enginewhatever", 1, 1.0);
 interpolate("/controls/ADtemp", getprop("environment/temperature-degc"), 23.0);
 interpolate("/controls/ADpress", getprop("environment/pressure-inhg"), 17.0);
  }
});

# start the timer (with 25 second inverval)
LiqCoolTempTimer.start();

# check if battery is on
setlistener("controls/engines/engine/ignition", func() {
  
  if (getprop("controls/engines/engine/ignition") == 1 and getprop("controls/switches/gauge-light") == 0)
  { setprop("/controls/engineelectric", 1);}
  else
  { setprop("/controls/engineelectric", 0);} 
});

setlistener("controls/switches/gauge-light", func() {
  
  if (getprop("controls/engines/engine/ignition") == 1 and getprop("controls/switches/gauge-light") == 0)
  { setprop("/controls/engineelectric", 1);}
  else
  { setprop("/controls/engineelectric", 0);} 
});
###########################################################################


###########################################################################
# gear indicator R, 1-6                               velocities/groundspeed-kt  /fdm/jsbsim/gear/unit/wheel-speed-fps
# velocity -xx  0  1-7 8-14 15-21 22-27 28-34 35-##
# gear      R   0   1   2     3     4     5     6
# DZF = Drehzahlfaktor

setprop("/velocities/gear", 0);
setprop("/velocities/DZF", 1);
setprop("/velocities/Drehzahl", 1);

setlistener("/gear/gear/rollspeed-ms", func() {
  
  if (getprop("controls/engines/engine/ignition") == 1)
  {  
  
  if (getprop("/gear/gear/rollspeed-ms") > 18)
  {setprop("/velocities/gear", 6);
   setprop("/velocities/DZF", 0.85);
   setprop("/velocities/Drehzahl", getprop("/gear/gear/rollspeed-ms") * getprop("/velocities/DZF"));
  }
  
  if (getprop("/gear/gear/rollspeed-ms") < 18)
  {setprop("/velocities/gear", 5);
   setprop("/velocities/DZF", 1);
   setprop("/velocities/Drehzahl", getprop("/gear/gear/rollspeed-ms") * getprop("/velocities/DZF"));
  }
  
  if (getprop("/gear/gear/rollspeed-ms") < 14)
  {setprop("/velocities/gear", 4);
   setprop("/velocities/DZF", 1.28);
   setprop("/velocities/Drehzahl", getprop("/gear/gear/rollspeed-ms") * getprop("/velocities/DZF"));
  }
  
  if (getprop("/gear/gear/rollspeed-ms") < 10)
  {setprop("/velocities/gear", 3);
   setprop("/velocities/DZF", 1.8);
   setprop("/velocities/Drehzahl", getprop("/gear/gear/rollspeed-ms") * getprop("/velocities/DZF"));
  }
  
  if (getprop("/gear/gear/rollspeed-ms") < 6)
  {setprop("/velocities/gear", 2);
   setprop("/velocities/DZF", 3);
   setprop("/velocities/Drehzahl", getprop("/gear/gear/rollspeed-ms") * getprop("/velocities/DZF"));
  }
  
  if (getprop("/gear/gear/rollspeed-ms") < 3)
  {setprop("/velocities/gear", 1);
   setprop("/velocities/DZF", 6);
   setprop("/velocities/Drehzahl", getprop("/gear/gear/rollspeed-ms") * getprop("/velocities/DZF"));
  }
  
  if (getprop("/gear/gear/rollspeed-ms") < 0.02 and getprop("/gear/gear/rollspeed-ms") > -0.02)
  {setprop("/velocities/gear", 0);
   setprop("/velocities/Drehzahl", getprop("/controls/engines/engine[0]/throttle") * 21 );
  }
  
  if (getprop("/gear/gear/rollspeed-ms") < -0.02)
  {setprop("/velocities/gear", 0);
   setprop("/velocities/DZF", -1);
   setprop("/velocities/Drehzahl", getprop("/gear/gear/rollspeed-ms") * getprop("/velocities/DZF"));
  }

  }
  
});


   
   
var timerLeerlauf = maketimer(0.1, func

{ 
  if (getprop("/controls/engines/engine/direction") == 0 and getprop("controls/engines/engine/ignition") == 1)
  {setprop("/velocities/gear", 0);
   setprop("/velocities/Drehzahl", getprop("/controls/engines/engine[0]/throttle") * 21 );   
  } else
  {
    if (getprop("/controls/engines/engine/direction") == 0 and getprop("controls/engines/engine/ignition") == 0)
  {setprop("/velocities/gear", 0);
   setprop("/velocities/Drehzahl", 0);
  }
  }
});

# start the timer (with 0.1 second inverval)
timerLeerlauf.start();   
   
###########################################################################
# engine brake
setprop("/fdm/jsbsim/systems/enginebrake", 0);


setlistener("/controls/engines/engine/direction", func() {
  
  if (getprop("/controls/engines/engine/direction") > 0)
   { setprop("/fdm/jsbsim/systems/enginebrake", 1); }
  if (getprop("/controls/engines/engine/direction") == 0)
   { setprop("/fdm/jsbsim/systems/enginebrake", 0); }
  if (getprop("/controls/engines/engine/direction") == -1)
   { setprop("/fdm/jsbsim/systems/enginebrake", 0); } 
   
});

# engine brake soft control
setprop("/fdm/jsbsim/systems/enginebrake-factor", 1);


setlistener("/controls/engines/engine/throttle", func() {
  
  if (getprop("/fdm/jsbsim/external_reactions/enginebrake/magnitude") > getprop("/fdm/jsbsim/external_reactions/engine/magnitude"))
   { interpolate("/fdm/jsbsim/systems/enginebrake-factor", 1 , 15 ); }
  if (getprop("/fdm/jsbsim/external_reactions/enginebrake/magnitude") < getprop("/fdm/jsbsim/external_reactions/engine/magnitude"))
   { interpolate("/fdm/jsbsim/systems/enginebrake-factor", 0.1 , 1 ); }
   
});
###########################################################################
# Killer grass and other surfaces get now killed themselfs :)
# by HerbyW 07-2015
#

var min_carrier_alt = 2;

# Do terrain modelling ourselves.
setprop("sim/fdm/surface/override-level", 1);

terrain_survol = func {

var lat = getprop("/position/latitude-deg");
var lon = getprop("/position/longitude-deg");
var info = geodinfo(lat, lon);




 if (info != nil) {
    if (info[0] != nil){
       setprop("fdm/jsbsim/environment/terrain-hight",info[0]);

#var terrain_hight = info[0];
#print("TERRAIN ",terrain_hight);

      
    }
    if (info[1] != nil){
      if (info[1].solid !=nil){
        setprop("fdm/jsbsim/environment/terrain-undefined",0);
        setprop("fdm/jsbsim/environment/terrain-solid",info[1].solid);

#var solid = info[1].solid;
#print("SOLID ",solid);

    }
      if (info[1].light_coverage !=nil)
       setprop("fdm/jsbsim/environment/terrain-light-coverage",info[1].light_coverage);
      if (info[1].load_resistance !=nil)
       setprop("fdm/jsbsim/environment/terrain-load-resistance",info[1].load_resistance);
      if (info[1].friction_factor !=nil)
       setprop("fdm/jsbsim/environment/terrain-friction-factor",info[1].friction_factor);
      if (info[1].bumpiness !=nil)
       setprop("fdm/jsbsim/environment/terrain-bumpiness",info[1].bumpiness);
      if (info[1].rolling_friction !=nil)
       setprop("fdm/jsbsim/environment/terrain-rolling-friction",info[1].rolling_friction);
      if (info[1].names !=nil)
       setprop("fdm/jsbsim/environment/terrain-names",info[1].names[0]);

#unfortunately when on carrier the info[1]  is nil,  only info[0] is valid
#var terrain_name = info[1].names[0];
#print("NAME ",terrain_name);
      #if (terrain_name == "Ocean" and terrain_hight >  min_carrier_alt)
        #setprop("fdm/jsbsim/environment/terrain-oncarrier",1);
    }else{
setprop("fdm/jsbsim/environment/terrain-undefined",1);
}
	      #debug.dump(geodinfo(lat, lon));


  }else {
    setprop("fdm/jsbsim/environment/terrain-hight",0);
    setprop("fdm/jsbsim/environment/terrain-solid",1);
    setprop("fdm/jsbsim/environment/terrain-oncarrier",0);
    setprop("fdm/jsbsim/environment/terrain-light-coverage",1);
    setprop("fdm/jsbsim/environment/terrain-load-resistance",1e+30);
    setprop("fdm/jsbsim/environment/terrain-friction-factor",1);
    setprop("fdm/jsbsim/environment/terrain-bumpiness",0);
    setprop("fdm/jsbsim/environment/terrain-rolling-friction",0.02);
    setprop("fdm/jsbsim/environment/terrain-names","unknown");
    }

settimer (terrain_survol, 0.5);
}


terrain_survol();



setlistener("fdm/jsbsim/environment/terrain-friction-factor", func { 
  
  if (getprop("fdm/jsbsim/environment/terrain-friction-factor") > 0.7)
  {
          setprop("fdm/jsbsim/environment/terrain-friction-factor", 0.8)
  }  
}
);

setlistener("fdm/jsbsim/environment/terrain-rolling-friction", func { 
  
  if (getprop("fdm/jsbsim/environment/terrain-rolling-friction") > 0.5)
  {
          
	  setprop("fdm/jsbsim/environment/terrain-rolling-friction", 0.25)
  }  
}
);

##############################################################################
setlistener("/controls/flight/elevator", func (position){
    var position = position.getValue();
    # helper for braking
    var ms = getprop("/devices/status/mice/mouse/mode") or 0;
    if (ms == 1 and position < 0) {
        setprop("/controls/gear/brake-left", 1);
        setprop("/controls/gear/brake-right", 1);
    }
    var ms = getprop("/devices/status/mice/mouse/mode") or 0;
    if (ms == 1 and position > 0) {
        setprop("/controls/gear/brake-left", 0);
        setprop("/controls/gear/brake-right", 0);
    }
    
    # helper for throtte on throttle axis or elevator
    var se = getprop("/controls/engines/engine/throttle") or 0;
    if (ms == 1 and position >= 0) setprop("/controls/engines/engine/throttle", position*1);
},0,1);

