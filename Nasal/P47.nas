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

#################################

var tire=TireSpeed.new(3,0.851,0.851,0.415);

controls.gearDown = func(v) {
    if (v < 0) {
        if(!getprop("gear/gear[1]/wow"))setprop("/controls/gear/gear-down", 0);
    } elsif (v > 0) {
      setprop("/controls/gear/gear-down", 1);
    }
}

controls.startEngine = func(v=1 ) {

    if(getprop("systems/electrical/batt-volts")<=8) v=0;
    if(getprop("engines/engine/energizer")<0.7)v=0;
    setprop("controls/engines/engine/starter",v);
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


var update = func {
        tire.get_rotation(FDM);
        var eg=props.globals.getNode("engines/engine/energizer",1);
        var engr=eg.getValue();
        var scnd = getprop("sim/time/delta-sec");
        if(getprop("controls/engines/engine/energizer")==1){
            if(getprop("systems/electrical/batt-volts")>5){
                engr=engr+(scnd*0.06);
                if(engr>1)engr=1;
            }
        }else{
            if(engr>0){
                engr=engr-(scnd*0.1);
                if(engr<0)engr=0;
            }
        }
        eg.setValue(engr);

    settimer(update,0);
}
