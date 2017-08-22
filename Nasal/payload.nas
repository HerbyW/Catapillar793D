
###################################################################################################
#  modified or copyright by Herbert Wagner 01/2016 for cat793D heavy off highway truck (Flightgear)
###################################################################################################

#
#Storage roll out and jump
#
setlistener("/controls/storage/jump-signal", func(v) {
 if(v.getValue()){
    interpolate("/controls/storage/jump-signal-pos", 1, 0.25);
    
  }else{
    interpolate("/controls/storage/jump-signal-pos", 0, 0.25);
  }
});

#
#Storage loading 7 containers
#
setlistener("/controls/storage/load-signal", func(v) {
  if(v.getValue()){
    interpolate("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", 480607, 25);
    setprop("controls/storage/trigger/state", 1);
  }else{
    interpolate("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", 0, 25);
  }
});
 
 
########################################################################################### 
 
 
var storageWeight = 480607;

var listener_id2 = setlistener("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]" , func {setprop("controls/storage/storage", getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]") / storageWeight)}, 0, 0);

var storageTimerRunning = 0;
var storageTimer = func(){
storageTimerRunning = 1;
var count = getprop("controls/storage/storage");
var state = getprop("controls/storage/trigger/state");
if (count > 0){
var weight = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]") - storageWeight;

# roll
interpolate("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", weight, 25);
setprop("sim/messages/copilot","Storage rolling");

# jump
settimer(func{
setprop("controls/storage/trigger/state",1);
setprop("sim/messages/copilot","Storage out");
},25);

# prepair next
settimer(func{
setprop("controls/storage/trigger/state",0);
storageTimer();
},27.1);

}else{
setprop("controls/storage/trigger/state",0);
setprop("sim/messages/copilot", "There is no Storage inside");
storageTimerRunning = 0;
}
};

setlistener("controls/storage/jump-signal", func(state){

if (state.getValue()){
 if (state.getValue() == 1){
storageTimer();
}
}

});