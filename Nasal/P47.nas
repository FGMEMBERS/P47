var Vvolume = props.globals.getNode("sim/sound/view-volume",1);
var FDM="";
 var counter=0;

TireSpeed = {
    new : func(number){
        m = { parents : [TireSpeed] };
            m.num=number;
            m.circumference=[];
            m.tire=[];
            m.rpm=[];
            for(var i=0; i<m.num; i+=1) {
                var diam =arg[i];
                var circ=diam * math.pi;
                append(m.circumference,circ);
                append(m.tire,props.globals.initNode("gear/gear["~i~"]/tire-rpm",0,"DOUBLE"));
                append(m.rpm,0);
            }
        m.count = 0;
        return m;
    },
    #### calculate and write rpm ###########
    get_rotation: func (fdm1){
        var speed=0;
        if(fdm1=="yasim"){ 
            speed =getprop("gear/gear["~me.count~"]/rollspeed-ms") or 0;
            speed=speed*60;
            }elsif(fdm1=="jsb"){
                speed =getprop("fdm/jsbsim/gear/unit["~me.count~"]/wheel-speed-fps") or 0;
                speed=speed*18.288;
            }
        var wow = getprop("gear/gear["~me.count~"]/wow");
        if(wow){
            me.rpm[me.count] = speed / me.circumference[me.count];
        }else{
            if(me.rpm[me.count] > 0) me.rpm[me.count]=me.rpm[me.count]*0.95;
        }
        me.tire[me.count].setValue(me.rpm[me.count]);
        me.count+=1;
        if(me.count>=me.num)me.count=0;
    }
};


var tire=TireSpeed.new(3,0.851,0.851,0.415);

controls.gearDown = func(v) {
    if (v < 0) {
        if(!getprop("gear/gear[1]/wow"))setprop("/controls/gear/gear-down", 0);
    } elsif (v > 0) {
      setprop("/controls/gear/gear-down", 1);
    }
}


setlistener("/sim/signals/fdm-initialized", func {
    Vvolume.setDoubleValue(-0.3);
    FDM=getprop("sim/flight-model");
    update();
});

setlistener("/sim/signals/reinit", func(rset) {
    if(rset.getValue()==0){
    }
},1,0);

setlistener("/sim/current-view/internal", func(vw){
    if(vw.getBoolValue()){
    Vvolume.setDoubleValue(-0.3);
    }else{
    Vvolume.setDoubleValue(1);
    }
},1,0);

setlistener("/sim/model/autostart", func(idle){
    if(idle.getBoolValue()){
        Startup();
    }else{
        Shutdown();
    }
},0,0);


var Startup = func{
setprop("controls/electric/engine[0]/generator",1);
setprop("controls/electric/engine[1]/generator",1);
setprop("controls/electric/engine[2]/generator",1);
setprop("controls/electric/engine[3]/generator",1);
setprop("controls/electric/battery-switch",1);
setprop("controls/lighting/instrument-lights",1);
setprop("controls/lighting/nav-lights",1);
setprop("controls/lighting/beacon",1);
setprop("controls/engines/engine[0]/magnetos",3);
setprop("controls/engines/engine[0]/fuel-pump",1);
setprop("controls/engines/engine[0]/propeller-pitch",1);
setprop("controls/engines/engine[0]/mixture",1);
setprop("engines/engine[0]/rpm",1000);
setprop("controls/engines/engine[1]/magnetos",3);
setprop("controls/engines/engine[1]/fuel-pump",1);
setprop("controls/engines/engine[1]/propeller-pitch",1);
setprop("controls/engines/engine[1]/mixture",1);
setprop("engines/engine[1]/rpm",1000);
setprop("controls/engines/engine[2]/magnetos",3);
setprop("controls/engines/engine[2]/fuel-pump",1);
setprop("controls/engines/engine[2]/propeller-pitch",1);
setprop("controls/engines/engine[2]/mixture",1);
setprop("engines/engine[2]/rpm",1000);
setprop("controls/engines/engine[3]/magnetos",3);
setprop("controls/engines/engine[3]/fuel-pump",1);
setprop("controls/engines/engine[3]/propeller-pitch",1);
setprop("controls/engines/engine[3]/mixture",1);
setprop("engines/engine[3]/rpm",1000);
if(FDM=="jsb"){
    setprop("fdm/jsbsim/propulsion/set-running",-1);
}else{
    setprop("engines/engine[0]/running",1);
    setprop("engines/engine[1]/running",1);
    setprop("engines/engine[2]/running",1);
    setprop("engines/engine[3]/running",1);
    }
}

var Shutdown = func{
setprop("controls/electric/engine[0]/generator",0);
setprop("controls/electric/engine[1]/generator",0);
setprop("controls/electric/engine[2]/generator",0);
setprop("controls/electric/engine[3]/generator",0);
setprop("controls/electric/battery-switch",0);
setprop("controls/lighting/instrument-lights",0);
setprop("controls/lighting/nav-lights",0);
setprop("controls/lighting/beacon",0);
setprop("controls/engines/engine[0]/magnetos",0);
setprop("controls/engines/engine[0]/fuel-pump",0);
setprop("controls/engines/engine[1]/magnetos",0);
setprop("controls/engines/engine[1]/fuel-pump",0);
setprop("controls/engines/engine[2]/magnetos",0);
setprop("controls/engines/engine[2]/fuel-pump",0);
setprop("controls/engines/engine[3]/magnetos",0);
setprop("controls/engines/engine[3]/fuel-pump",0);
}

var update = func {
#        updateBMEP();
        tire.get_rotation(FDM);
    settimer(update,0);
}

var updateBMEP = func {
    var hp=0;
    var rpm=0;
    var bmep=0;
    var torque=0;
    for(var engine=0; engine< 4; engine+=1)
    {
        if(FDM=="jsb"){
            rpm=getprop("engines/engine["~engine~"]/rpm") or 1;
            hp=getprop("fdm/jsbsim/propulsion/engine["~engine~"]/power-hp");
            bmep=hp*285/rpm;
    }else{
        torque=getprop("engines/engine["~engine~"]/torque-ftlb") or 0;
    bmep = 150.8 * torque / 2804;
    }
        setprop("engines/engine["~engine~"]/bmep", bmep);
    }
}