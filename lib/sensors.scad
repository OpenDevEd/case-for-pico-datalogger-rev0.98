//
// https://github.com/OpenDevEd/case-for-pico-datalogger-rev0.98
//
// module sensor_demo(both=true) {
// 
// Print 'pads' for sensors.
//
// module mount_ada_st(x, y, z=1, pad=1) {
//  repeats rectangles, showing layout for multiple sensors
// module mount_garden(x, y, z=1, pad=1) {
//  same, but for pimoroni garden size
// module mount_ada_mcp(x, y, z=1, pad=1) {
//  same, but for ada mcp size
// module mount_generic(x, y, dx_in, dy_in, z, pad) {
//  utility module

// Specific sensors:
//
// module sensor_ltr559(punch=false, both=false) {
//  print and ltr559 sensor. punch=true prints rods useful for difference. both=true shows both sensor and rods for positioning.
// module sensor_bh1745(punch=false, both=false) {
// module sensor_mcp9808(punch=false, both=false) {
//  as above, but for mcp9808 (non-Qw/ST version)
// module sensor_sht40(punch=false, both=false) {
//  as above, but for sht40
// module sensor_sht45(punch=false, both=false) {
//  as above, but with label sht45 (cad model uses sht40)
// module sensor_mcp9808st(punch=false, both=false) {
//  as above, for Qw/ST version of mcp9808
// module sensor_aht20(punch=false, both=false) {
//  as above for aht20
// module sensor_bh1750(punch=false, both=false) {
//  as above, but with bh1750 label (cad model uses sht40)

//
// Utility functions
//
// module importLabel(file, label="X", size=3) {
// module AdafruitQWST(file, label="X", size=3, punch=false, both=false) {
// module sensorMountHole(diameter = 2.5) {

// Sensors with cad models:
// - SHT40 (not used, but similar to sht45)
// - AHT20
// - MCP9808 (2 versions)
// Sensors without cad models:
// - Adafruit BH1750
// - LTR-559
// - BH1745 
// - Adafruit AM2301B Wired enclosed shell

use <pin_header.scad>;

sensor_demo(both=true); 

// minimum angle
$fa = 1;
// minimum size
$fs = 0.4;
// number of fragments 
$fn = 48;

module sensor_demo(both=true) {
    translate([30,20,0]) mount_ada_st(3,2, col="red");
    
    translate([0,-20,0]) {
        sensor_mcp9808(both=both);
    };
    sensor_bh1750(both=both);
    translate([0,20,0]) {
        sensor_sht45(both=both);
    };
    translate([0,40,0]) {
        sensor_mcp9808st(both=both);
    };
    translate([0,60,0]) {
        sensor_aht20(both=both);
    };
    translate([0,80,0]) {
        sensor_ltr559(both=both);
    };
    translate([0,100,0]) {
        sensor_bh1745(both=both);
    };
    translate([60,100,0]) {
        mountDemo1();
    };
    translate([60,140,0]) {
        mountDemo2();
    };
    
    translate([-30,80,0])  mount_garden(1,5, solid=true, col="green");
    translate([-60,80,0])  mount_garden(1,5);
    translate([25,-20,0])  mount_ada_mcp(3,1, solid=true, col="blue");
    translate([25,-40,0])  {
        mount_ada_mcp(3,1, col="blue");
        translate([0,0,-2]) sensor_mcp9808();
    };
    translate([0,-60,0]) sensor_pdm(both=both) ;
    translate([0,-80,0]) sensor_qwst_hub5(both=both);
    translate([0,-80,0]){
        // checking overlap
        translate([0,-80,0]) sensor_qwst_hub5(both=both);
        translate([6.4,-61.61,0]) rotate([0,0,-90]) mount_garden(both=both);
    };
};


module mountDemo1() {
    // How to punch holes
    color("black") translate([-5,-10,5]) text("a");
    // Show the sensor with green columns to indicate holes: both shows both sensor and columns
    sensor_aht20(both=true);
    // Create a mount for that sensor:
    translate([0,0,-3]) mount_ada_st(1,1,z=2,pad=3);
    // Now show the sensor, and punch holes through the board.
    translate([30,0,0]) {
        color("black") translate([-5,-10,5]) text("b");
        sensor_aht20();
        difference() {
            translate([0,0,-3]) mount_ada_st(1,1,z=2,pad=3);
            sensor_aht20(punch=true);
        }
    }      
};

module mountDemo2() {
    translate([30,0,0]) {
        color("black") translate([-10,0,5]) text("1");
        sensor_aht20();
        difference() {
            translate([0,0,-3]) mount_ada_st(1,1, z=2, pad=3, slicex=13, slicey=5, extendx=20, extendy=10);
            sensor_aht20(punch=true);
        }
    }   
     translate([100,0,0]) {
        color("black") translate([-10,0,5]) text("2");
        sensor_aht20();
        difference() {
            translate([0,0,-3]) mount_ada_st(1,1, z=2, pad=3, slicex=0, slicey=3, extendx=20, extendy=10, clearpins=true, showpins=true, mount_pins_adjust=1);
            sensor_aht20(punch=true);
        }
    }     
    translate([30,40,0]) {
        color("black") translate([-10,0,5]) text("3");
        sensor_aht20();
        difference() {
            translate([0,0,-3]) mount_ada_st(1,1, z=2, pad=3, slicex=0, slicey=8, extendx=20, extendy=10);
            sensor_aht20(punch=true);
        }
    }    
    translate([30,80,0]) {
        color("black") translate([-10,0,5]) text("4");
        sensor_aht20();
        difference() {
            translate([0,0,2]) mount_ada_st(1,1, z=2, pad=3, slicex=0, slicey=8, extendx=20, extendy=10, slicepadx=0, slicepady=5);
            sensor_aht20(punch=true);
        }
    }  
    translate([100,80,0]) {
        // using the sensor with the 'punch=true' ,means you can make holes in any surface. But, you can also punch in the 'repeat' function.
        color("black") translate([-10,0,5]) text("5");
        sensor_aht20();
        translate([0,0,2]) mount_ada_st(1, 1, z=2, 
                pad=3, slicex=0, slicey=8, 
                extendx=20, extendy=10, 
                slicepadx=0, slicepady=5,
                clearpins=true, showpins=true, punch=true);
    }  
    translate([30,120,0]) {
        color("black") translate([-10,0,5]) text("6");
        sensor_mount_2(showpins=true) ;
        translate([30,0,0]) {
            sensor_mount_2(showpins=true) ;
              translate([30,0,0]) {
            sensor_mount_2(showpins=true) ;
        };
        };
    }   
    translate([30,160,0]) {
        color("black") translate([-10,0,5]) text("7");
        // if you dont want to see the sensor:
        // mount_ada_st(nx=3,ny=1, z=2, pad=2, slicex=0, slicey=8, extendx=4, extendy=3, slicepadx=0, slicepady=5, punch=true, clearpins=true, showpins=true);      
        mount_ada_st(nx=3,ny=1, z=2, punch=true, clearpins=true, showpins=true);      

    }    
 
    module sensor_mount_1() {
        sensor_aht20();
        difference() {
            translate([0,0,2]) mount_ada_st(1,1, z=2, pad=3, slicex=0, slicey=8, extendx=4, extendy=1, slicepadx=0, slicepady=5);
            sensor_aht20(punch=true);
        }
    }

    module sensor_mount_2(showpins=false) {
        sensor_aht20();
        translate([0,0,2]) mount_ada_st(nx=1,ny=1, z=2, pad=2, slicex=0, slicey=8, extendx=4, extendy=1, slicepadx=0, slicepady=5, punch=true, showpins=showpins);      
    }

};


// mounts/repeated mounts for 'generic pads' (by sensor mount types):
// Adafruit QwST sensors: 1 x 0.7 inch
module mount_ada_st(nx=1, ny=1, z=2, pad=2, slicex=0, slicey=8, extendx=4, extendy=3, slicepadx=0, slicepady=5, clearpins=true,showpins=true, mount_pins_above_sensor=false, mount_pins_adjust=-4, punch=true, both=false, solid=false, colonly=false, col="yellow") {
    inch=25.4;
    dx = inch;
    dy = 0.7 * inch;
    mount_generic(nx, ny, dx, dy, z=z, pad=pad, 
        slicex=(solid ? 0 : slicex), slicey=(solid ? 0 : slicey), 
        extendx=(solid ? 0 : extendx), extendy=(solid ? 0 : extendy), 
        slicepadx=(solid ? 0 : slicepadx), slicepady=(solid ? 0 : slicepady),
        clearpins=(solid ? false : clearpins),
        showpins=showpins,
        npins=4,
        mount_pins_above_sensor=mount_pins_above_sensor,
        mount_pins_adjust=mount_pins_adjust,
        punch=punch, both=both, colonly=colonly, punchtype="ada_1.0",
        col=col  
    );
};

module mount_ada_mcp(nx=1, ny=1, z=2, pad=2, slicex=0, slicey=4, extendx=2, extendy=3, slicepadx=0, slicepady=1, clearpins=true,showpins=true, mount_pins_above_sensor=false,mount_pins_adjust=-4, punch=true, both=false,colonly=false,  solid=false, col="yellow") {
    
    inch=25.4;
    dx = 0.8 * inch;
    dy = 0.5 * inch;
    
    mount_generic(nx, ny, dx, dy, z=z, pad=pad,
        slicex=(solid ? 0 : slicex), slicey=(solid ? 0 : slicey), 
        extendx=(solid ? 0 : extendx), extendy=(solid ? 0 : extendy), 
        slicepadx=(solid ? 0 : slicepadx), slicepady=(solid ? 0 : slicepady),
        clearpins=(solid ? false : clearpins),
        clearpin_cutoutx=22.32, clearpin_cutouty=5, 
        showpins=showpins,
        npins=8,
        mount_pins_above_sensor=mount_pins_above_sensor,
        mount_pins_adjust=mount_pins_adjust,
        punch=punch, both=both,colonly=colonly, punchtype="ada_0.8", col=col  );
   
};

// Pimoroni Garden sensors
module mount_garden(nx=1, ny=1, z=2, pad=2, slicex=8, slicey=10, extendx=3, extendy=3, slicepadx=0, slicepady=0, 
    clearpins=true,
    showpins=true, mount_pins_above_sensor=false, mount_pins_adjust=-4, punch=true, both=false, colonly=false, solid=false, col="yellow") {
    dx = 19;
    dy = 19;
    mount_generic(nx, ny, dx, dy, z=z, pad=pad,
      slicex=(solid ? 0 : slicex), slicey=(solid ? 0 : slicey), 
        extendx=(solid ? 0 : extendx), extendy=(solid ? 0 : extendy), 
        slicepadx=(solid ? 0 : slicepadx), slicepady=(solid ? 0 : slicepady),
        clearpins=(solid ? false : clearpins),
        clearpin_cutoutx=13.5, clearpin_cutouty=5, 
        showpins=showpins,
        npins=5,
        mount_pins_above_sensor=mount_pins_above_sensor,
        mount_pins_adjust=mount_pins_adjust,
        punch=punch, both=both, colonly=colonly, punchtype="garden" , col=col  
    );
};


module mount_generic(x, y, 
        dx_in, dy_in, z, pad, 
        slicex=0, slicey=0, 
        extendx=0, extendy=0,
        slicepadx=1, slicepady=1,
        clearpins=false,
        clearpin_cutoutx=12.5, clearpin_cutouty=5, 
        showpins=false,
        npins=4,
        mount_pins_above_sensor=false,
        mount_pins_adjust=0,
        punch=false, both=false, colonly=false, punchtype="ada_1.0", col="yellow") {
            
    dx = ceil(dx_in + pad);
    dy = ceil(dy_in + pad);   
    for (xx=[0:dx:(x-1)*dx])
        for (yy=[0:dy:(y-1)*dy])
            translate([xx,yy,0]) elements(dx_in=dx_in, dy_in=dy_in, z=z, 
        slicex=slicex, slicey=slicey, 
        extendx=extendx, extendy=extendy,
        slicepadx=slicepadx, slicepady=slicepady, 
        clearpins=clearpins,
        clearpin_cutoutx=clearpin_cutoutx, clearpin_cutouty=clearpin_cutouty,    
        showpins=showpins,
        npins=npins,
        mount_pins_above_sensor=mount_pins_above_sensor,
        mount_pins_adjust=mount_pins_adjust,
        punch=punch, both=both, colonly=colonly, punchtype=punchtype, col=col );
    };
    
    module elements(dx_in=40, dy_in=40, z=2, 
        slicex=2, slicey=2, 
        extendx=0, extendy=0,
        slicepadx=0, slicepady=0, 
        clearpins=false,
        clearpin_cutoutx=0, clearpin_cutouty=0,    
        showpins=false,
        npins=4,
        mount_pins_above_sensor=false,        
        mount_pins_adjust=0,
        punch=false, 
        both=false,
        colonly=false,
        punchtype="ada_1.0",
        col="yellow") {
            
        inch = 25.4;
        if (!colonly) difference() {
            union() {
                color(col) translate([-extendx,-extendy,0]) cube([dx_in+2*extendx, dy_in+2*extendy, z]);                         
            };
            union() {
                if (clearpins) {   
                       translate([dx_in/2-clearpin_cutoutx/2,0,-1]) 
                            cube([clearpin_cutoutx, clearpin_cutouty, z+2]);                                                       
                };
                if (slicex>0) {
                    translate([(dx_in-slicex)/2,-slicepadx,-1]) cube([slicex, dy_in+2*slicepadx, z+2]);  
                };
                if (slicey>0) {
                    translate([-slicepady,(dy_in-slicey)/2,-1]) cube([dx_in+2*slicepady, slicey, z+2]);  
                };
                if (punch && !both) 
                    punchSelector(height=z,punchtype=punchtype);
            }
    };
    if (!colonly && showpins) {
            ypos= (
                punchtype=="ada_1.0" ? 2.5 : (
                punchtype=="ada_0.8" ? 2.3 : 2.5
            ));
            translate([dx_in/2, ypos,
                (mount_pins_above_sensor ? inch/10+z-2*2.54 : inch/6+z-2) + mount_pins_adjust
                    ]) rotate([
                        mount_pins_above_sensor ? 0 : 180,
                            0,90]) pin_header(npins,1);            
            };
    if (colonly || both) 
        punchSelector(height=z,punchtype=punchtype);
    
    
    module punchSelector(height=10, punchtype="ada_1.0") {
        if (punchtype == "ada_1.0") 
           sensorMountHoleAdaQwST(height=z);
        else if (punchtype == "ada_0.8")
            sensorMountHolemcp(height=z);
        else if (punchtype == "garden")
            sensorMountHoleGarden(height=z);
    };
    
    module sensorMountHoleAdaQwST(diameter = 2.5, height=0) {
        inch = 25.4;
        color("green") translate([inch/10,inch/10,-height-10]) linear_extrude(20+2*height) {
            translate([0,0,0]) circle(d=diameter);
            translate([0,inch/2,0]) circle(d=diameter);
            translate([0.8*inch,0,0]) circle(d=diameter);
            translate([0.8*inch,inch/2,0]) circle(d=diameter);
        }
    }
    module sensorMountHolemcp(diameter = 2.5, height=0) {
        inch = 25.4;
        color("green") translate([inch/10,4*inch/10,-10-height]) linear_extrude(20+2*height) {
            translate([0,0,0]) circle(d=diameter);
            translate([0.6*inch,0,0]) circle(d=diameter);          
        }
    }
    
    module sensorMountHoleGarden(diameter = 2.5, height=0) {
        top = 14;
        inch=2.54;
        translate([(19-5*inch)/2,19-inch,0]) color("green") cylinderSet(5, 1, inch=true, z=10, d=diameter, n=2);
    }

};


// Pimoroni Garden
module sensor_ltr559(punch=false, both=false) {
    sensor_garden_generic("LTR-559", punch=punch, both=both) ;
};

module sensor_bh1745(punch=false, both=false) {
    sensor_garden_generic("BH1745", punch=punch, both=both) ;
};

module sensor_garden_generic(text="Garden", punch=false, both=false) {
    translate([1,9,5]) color("black") text(text,size=3);
    difference() {
        color("lightblue") cube([19,19,4.7]);
        union() {
            // cut out at bottom
            translate([-1,-1,2]) cube([21,8,4]);
            // cutout at top
            // translate([-1,14,2]) cube([21,10,4]);
            adjust=3;
            translate([-1,14,2]) cube([3+adjust,6,7]);
            translate([17-adjust,14,2]) cube([30,6,7]);            
            // side cutouts:
            translate([-1,-1,-1]) cube([3,6,7]);
            translate([17,-1,-1]) cube([3,6,7]);
            sensorMountHoleGarden(diameter = 2.5, height=10);
        };
    };
    
    module sensorMountHoleGarden(diameter = 2.5, height=0) {
        top = 14;
        inch=2.54;
        translate([(19-5*inch)/2,19-inch,0]) color("green") cylinderSet(5, 1, inch=true, z=10, d=diameter, n=2);
    }
};

// Adafruit non-QW/ST
module sensor_mcp9808(punch=false, both=false) {
    file = "1782-MCP9808.stl";
    label = "MCP9808";
    if (!punch) 
        importLabel(file, label, size=3);
    if (punch || both) 
        sensorMountHolemcp(diameter=2.5);
    
    module sensorMountHolemcp(diameter = 2.5) {
        inch = 25.4;
        color("green") translate([inch/10,4*inch/10,-10]) linear_extrude(20) {
            translate([0,0,0]) circle(d=diameter);
            translate([0.6*inch,0,0]) circle(d=diameter);          
        }
    }

};

module sensor_pdm(punch=false, both=false) {
    file = "PDM-Mic-with-JST-SH.stl";
    label = "PDM/ST";
    if (!punch) 
        importLabel(file, label, size=3);
    if (punch || both) 
        sensorMountHole(diameter=2.5);
    
    module sensorMountHole(diameter = 2.5) {
        inch = 25.4;
        color("green") translate([inch/10,4.5*inch/10,-10]) linear_extrude(20) {
            translate([0,0,0]) circle(d=diameter);
            translate([0.35*inch,0,0]) circle(d=diameter);          
        }
    }
};


module sensor_qwst_hub5(punch=false, both=false) {
    file = "5625_Stemma_5_Port_Hub.stl";
    label = "QW/ST Hub";
    if (!punch) 
        importLabel(file, label, size=3);
    if (punch || both) {
        inch=25.4;
        //cylinderSet(1*inch, 7*inch/10, dx=inch/10, dy=inch/10, z=10, d=2.5);
        // or
        // translate([inch/10,inch/10,0]) cylinderSet(0.8*inch, 5*inch/10, d=2.5);
        // or
        // cylinderSet(0.8*inch, 5*inch/10, d=2.5, ddx=inch/10, ddy=inch/10);
        // cylinderSet( 8, inch=true, 5, d=2.5, ddx=1, ddy=1);
        // cylinderSet( 8, inch=true, 5, d=2.5, ddx=1);
        cylinderSet(10, inch=true, 7, dx=1, z=10, d=2.5);
    };
    //    color("green") translate([inch/10,4.5*inch/10,-10]) linear_extrude(20) {
    //        translate([0,0,0]) circle(d=diameter);
    //        translate([0.35*inch,0,0]) circle(d=diameter);          
};

module cylinderSet(x, y, z=10, d=2.5, dx=0, dy=0, n=4, ddx=0, ddy=0, inch=false) {
/*
    x,y: size of board (specify hole offset with dx, dy)
         or: size of rectangle of holes (dx=dy=0)
             specifiy offset with ddx, ddy.
    n:   number of cylinders to make
    inch: values for x,y,dx,dy,ddx,ddy are specified in tenth of inch.
    d:   diameter of cylinders (always in mm)
    z:   height of cylinder (always in mm)
*/    
    if (inch) {
        inch=25.4/10;
        makeCylinderSet(x*inch, y*inch, 
            z=z, d=d, 
            dx=dx*inch, 
            dy=(dy>0 ? dy*inch : dx*inch),
            n=n, 
            ddx=ddx*inch, 
            ddy=(ddy>0 ? ddy*inch : ddx*inch)
        );
    } else {
        makeCylinderSet(x, y, z=z, d=d, 
        dx=dx, 
        dy=(dy>0 ? dy : dx),
        n=n, 
        ddx=ddx, 
        ddy=(ddy>0 ? ddy : ddx)
        );
    };
};

module makeCylinderSet(x, y, z=10, d=2.5, dx=0, dy=0, n=4, ddx=0, ddy=0) {
    translate([ddx,ddy,-z/2]) {
        translate([0+dx,0+dy,0]) cylinder(z, r=d/2); 
        if (n>1)
            translate([x-dx,0+dy,0]) cylinder(z, r=d/2); 
        if (n>2)
            translate([0+dx,y-dy,0]) cylinder(z, r=d/2); 
        if (n>3)
            translate([x-dx,y-dy,0]) cylinder(z, r=d/2); 
    }
};

// Adafruit QW/ST
// - outer 1.00 by 0.70
// - outer(mm) 25.4 by 17.78
// - hole spacing 0.8 by 0.5
// - hole: 0.1
// mcp9808 non-QW/ST
// - outer: 0.8 by 0.5
// - outer(mm): 20.32 by 12.7
// - hole spacing: 0.6
// - hole: 0.1
// https://learn.adafruit.com/adafruit-mcp9808-precision-i2c-temperature-sensor-guide/downloads

module sensor_sht40(punch=false, both=false) {
    AdafruitQWST("4485-SHT40.stl","SHT40", punch=punch, both=both);
};

module sensor_sht45(punch=false, both=false) {
    // Using the stl for SHT40. Prob very similar to SHT45.
    // Adding ~ to the name as a reminder.
    AdafruitQWST("4485-SHT40.stl","~SHT45~", punch=punch, both=both);
};

module sensor_bh1750(punch=false, both=false) {
    // Using the stl for SHT40. Will be different, but better than nothing.
    // Adding ~ to the name as a reminder.
    AdafruitQWST("4485-SHT40.stl","~BH1750~", punch=punch, both=both);
};


module sensor_mcp9808st(punch=false, both=false) {
    AdafruitQWST("5027-MCP9808-Stemma.stl","MCP9808 Qw/ST", punch=punch, both=both);
};

module sensor_aht20(punch=false, both=false) {
    AdafruitQWST("4566-AHT20-Sensor.stl","AHT20", punch=punch, both=both);
};

module importLabel(file, label="X", size=3) {
    translate([1,5,5]) color("black") text(label, halign="left", size=size);
    color("lightblue") import(file);
};
    
module AdafruitQWST(file, label="X", size=3, punch=false, both=false) {
    if (!punch) 
        importLabel(file, label, size);
    if (punch || both) 
        sensorMountHole(diameter=2.5);
    
    module sensorMountHole(diameter = 2.5) {
        inch = 25.4;
        color("green") translate([inch/10,inch/10,-10]) linear_extrude(20) {
            translate([0,0,0]) circle(d=diameter);
            translate([0,inch/2,0]) circle(d=diameter);
            translate([0.8*inch,0,0]) circle(d=diameter);
            translate([0.8*inch,inch/2,0]) circle(d=diameter);
        }
    }
};

