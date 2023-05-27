// Box for https://github.com/bablokb/pcb-pico-datalogger (Rev 0.98)
// Uses:
// QR Code generator for OpenSCAD https://github.com/ridercz/OpenSCAD-QR
// https://github.com/KitWallace/openscad/blob/master/braille.scad
// 
// basic box size: 110 x 100 (interior)
//
// Not final.
// 96x88

// use <lib/braille.scad>
// use <lib/qrcode.scad>
use <lib/sensors.scad>;
use <lib/battery_box_2.0.scad>;

// minimum angle
$fa = 1;
// minimum size
$fs = 0.4;
// number of fragments 
$fn = 48;

project_model_for_printing = false;
wallThickness = 1.5; 
showlidx=false;
makeSides=false;
makeObjects=true;
modelheight=55;

// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/3D_to_2D_Projection
if (project_model_for_printing)
    if (makeObjects)
        text("error - disable makeObjects");
    else
        projection(cut=true) fullModel();
else 
{
    showguides= false;
    if (showguides) {
        cube([7,7,7]);
        showGuides(110, 190, 60, rad=0.5, col="orange");
        translate([7,7,0]) { 
            showGuides(96, 88, 60, rad=0.5, col="green");
            translate([0,88,0]) showGuides(96, 88, 60, rad=0.5, col="green");
        // translate([0,95,0]) showGuides(96, 88, 60, 0, 0, 0, rad=0.5, col="red");
        //rotate([0,0,90]) translate([0,-96,0]) showGuides(96, 88, 60, 0, 0, 0, rad=0.5);
            translate([0,2*88,0]) showGuides(96, 7, 60, 0, 0, 0, rad=0.5, col="red");
            translate([96,0,0]) showGuides(7, 88, 60, rad=0.5, col="blue");
            translate([96,88,0]) showGuides(7, 88, 60, rad=0.5, col="blue");
        };
    };

        translate([16.5+1.5,16.5+1.5,0]) {
        fullModel();
    };
};

module fullModel() {
    makeEverything(74, 84, modelheight, 
        padx=16.5, pady=16.5, 
        wall=wallThickness, 
        extx=0, exty=70, 
        extendBase=wallThickness, 
        extendSide=0,
        showlid=showlidx,
        makeSides=makeSides);
        
    if (makeObjects) {
        makePCB();
        // makeBattery();
    }
}

// translate([-77,0,0]) {
    //sensor_demo(both=true);
// };


    
// Pi + socket is about 16mm, call is 20.
// 10mm headroom, with Inky, gives about 40mm 
// box allows for 50mm

module makeEverything(x, y, z, padx=10, pady=10, wall=2, extx=0, exty=0, extendBase=0, extendSide=0, showlid=false, makeSides=true) {
    // showGuides(110, 190, 60, padx+wall, pady+wall, wall);
    // Full interior dimensions are:
    xx = x + 2 * padx + extx;
    yy = y + 2 * pady + exty;
    zz = z;
    echo("internal ",xx,yy,zz);
    // showGuides(xx, yy, zz, padx, pady, 0);
    // Full exterior dimensions are:
    xxe = xx + 2 * wall;
    yye = yy + 2 * wall;
    zze = zz + 2 * wall;
    echo("external ",xxe,yye,zze);
    // The interior is always xx * yy * z
    // If extendBase is set, then the base is extended, potentially to cover the walls
    // If extendSide is set, then the sides are extended, so that the lid can be inserted.
    // Typically either extendBase and extendSide would be zero, but not both.
    if (extendBase==0 && extendSide==0) {
        echo("Warning: extendBase==0 && extendSide==0: Your parts will not overlap.");
    };
    if (extendBase!=0 && extendSide!=0) {
        echo("Warning: extendBase!=0 && extendSide!=0: Your parts will not fit if you make them separately.");
    };
    // Typically, either extendBased or extendSide would be =wall, to give neat edges.
    // However, you can set extendBase or extendSide > wall, in which case you'll have an overlap, e.g. to attach exterior mount points.
    // This setting is only relevant if you use this to make a single piece, or use different colours.
    //translate([padx, pady,0]) {
    translate([0, 0, 0]) {
        difference() {
            union() {
                // This makes the baseplate:
                baseplatemaker(x,y,z, padx, pady, wall, extx, exty, extendBase, showlid=showlid, mountpointheight=9);
                if (makeSides) {
                    // This makes the sides:
                    makeboxSides(x,y,z, padx, pady, wall, extx, exty, extendSide);
                    makeBoxMounts(x,y,z, padx, pady, wall, extx, exty, extendSide);
                }
            }
            // This punches the holes for screws:
            // makeBoxMounts(x,y,z, padx, pady, wall, extx, exty, extendSide, punchconnects=true);
            makeBoxMounts2(x,y,z, padx, pady, wall, extx, exty, extendSide, punchconnects=true);
        }
    }
}

module showGuides(xx, yy, zz, padx=0, pady=0, padz=0, rad=3, col="grey") {
    translate([-padx-rad/2, -pady-rad/2, -padz-rad/2]) color(col) {
        rotate([0,90,0]) cylinder(xx,r=rad);
        rotate([-90,0,0]) cylinder(yy,r=rad);
        rotate([0,0,0]) cylinder(zz,r=rad);
    };
}

module baseplatemaker(x,y,z, padx=20, pady=20, wall=2, extx=0, exty=100, extendBase, showlid=false, mountpointheight=5, lid_is_laser_cut = false) {
    // base plate
    sensorboardx=2;
    sensorboardy=+2;
    difference() {
        union() {
            color([1,1,0,0.8]) baseplate(x, y, padx, pady, wall, extx, exty, extendBase);
            screeninsertAndSupports();
        };
        union() {
            cutouts(x, padx, extx, y, pady, exty, wall);
            if (lid_is_laser_cut) {
                pcbMountHoles(x, y, 0, mountpointheight, lid_is_laser_cut);    
            };
             translate([sensorboardx,sensorboardy,0]) {
             // makeStripboard(showboard=false, showpins=false, showcylinder=true,height=50);
             sensorMounts(colonly=true);
             };
        }
    }               
    if (showlid) {
        color([0,1,1,0.8]) translate([0,0,z+extendBase]) baseplate(x, y, padx, pady, wall, extx, exty, extendBase);
    }
    if (!lid_is_laser_cut) {
        // mount point for pcb 1
        pcbMountHoles(x,y, 0, mountpointheight, lid_is_laser_cut);    
        // mount points for pcb2
        // not used // translate([0, y+30, 0]) pcbMountHoles(x,y, 0, mountpointheight);
    };
    translate([sensorboardx,sensorboardy,0]) difference() {
        sensorMounts();
        makeStripboard(showboard=false, showpins=false,showcylinder=true);
    };
    
    // Modules:
    module screeninsertAndSupports() {
        // supports:
        color("blue") translate([-3,154,0]) cube([80,10,2]);
        color("blue") translate([-3,86,0]) cube([80,10,2]);
        color("blue") translate([-3,+2,0]) cube([80,80,2]);
        color("blue") translate([-3,-7,0]) cube([80,5,2]);
        // screeninsert:
        cutoutdx = 38;
        cutoutdy = 86;
        cutoutx = 15;
        cutouty = +1;
        //cube([x,2,2]);  
        //cube([2,y,2]); 
       // 
        //cube([cutoutdx,2,2]);
        //cube([2,cutoutdy,2]);
        //translate([cutoutdx,0,0]) cube([2,coutoutdy,2]);
        offsetx=16.5;
        offsety=6;
        translate([3.0,0,0])
        translate([cutoutx-offsetx,cutouty-offsety,0]) cube([cutoutdx+2*offsetx,2*offsety+cutoutdy,2]);
        offs2=2;
/*        translate([-offs2,-offs2,0]) { 
            cube([x+2*offs2,4,2]);  
            cube([4,y+2*offs2,2]); 
            translate([0,y+offs2,0]) cube([x+2*offs2,4,2]);  
            translate([x+2*offs2,0,0]) cube([4,y+2*offs2,2]); 
        }; */ /*
        translate([-offs2,-offs2,0]) { 
            cube([x,4,2]);  
            cube([4,y,2]); 
            translate([0,y+offs2,0]) cube([x+2*offs2,4,2]);  
            translate([x+2*offs2,0,0]) cube([4,y+2*offs2,2]); 
        }; */
        
    };
    module sensorMounts(colonly=false) {        
        // Sensors in 'ada-st' format (V3V, gnd, SCL, SDA):
        // - SHT45
        // - AHT20
        // - Adafruit BH1750
        // Same first 4 pins:
        // - MCP9808
        // Sensors in 'garden' (V3V, SDA, SCL, nc, gnd):
        // - LTR-559
        // - BH1745 
        // Other:
        // - Adafruit AM2301B Wired enclosed shell
        // Other:
        // - I2S MEMS Mic
        // - ENS160
        mpadjust=2;
        {
        if (makeObjects) makeStripboard();        
        translate([0,0,-5]) makeStripboard(showboard=false, showstandoff=true,showpins=false, height=10);
        translate([25.4/10,0,0]) {
            tinch=2.54;
            // col 1 - Ada ST
            mount_pins_adjust=mpadjust;
            translate([+0*tinch,-9*tinch,0])        
                translate([-13.11,143.84,-wall]) mount_ada_st(col="orange", mount_pins_above_sensor=true,  mount_pins_adjust=mpadjust, colonly=colonly,  showpins=makeObjects);      
            translate([+0*tinch,-9*tinch,0])        
                translate([-13.11,120.98,-wall]) mount_ada_st(1,1,col="green", mount_pins_above_sensor=true,  mount_pins_adjust=mpadjust, colonly=colonly, showpins=makeObjects);
            
            // col 2 - Pim
            translate([1*tinch,-8*tinch,0]) 
            translate([+16.76,118.44,-wall]) mount_garden(1,1, col="lightgreen",mount_pins_above_sensor=true,  mount_pins_adjust=mpadjust, colonly=colonly, extendx=5, extendy=3, showpins=makeObjects);          
            translate([1*tinch,+1*tinch,0])     translate([+16.76,118.44,-wall]) mount_garden(1,1, col="lightgreen",mount_pins_above_sensor=true,  mount_pins_adjust=mpadjust, colonly=colonly,extendx=5, extendy=1.78,  showpins=makeObjects);            
            // col 3 - 
            translate([+2*tinch,-19*tinch,0]) 
                translate([+42.78,146.58,-wall]) mount_ada_mcp(1,1, col="green",mount_pins_above_sensor=true,  mount_pins_adjust=mpadjust, extendx=7.5, colonly=colonly , showpins=makeObjects);
            translate([+25*tinch,6*tinch,0]) translate([-13.1,98.12,-wall]) mount_ada_st(1,1,col="orange", mount_pins_adjust=mpadjust, mount_pins_above_sensor=true, colonly=colonly,
            extendx=10,  showpins=makeObjects
            );
         };
       };
    };
    module makeStripboard(
        showboard=false, 
        showpins=true,
        showcylinder=false, 
        showstandoff=false, 
        height=5
        ) {
        tinch=25.4/10;
        translate([3*tinch,0,0]) 
        translate([-9.3,93,10]) {
            tinch=2.54;
            // This will kill openscad:
            //rotate([90,0,0]) import("lib/stripboard.stl");
            // This works:
            //translate([-9.171,-76.249,5]) import("lib/pcb.svg");
            stripboard(30,26, 
            padsize=2.54/10*4, //5.6,  // 4
            showboard=showboard, 
            npadx= 3.5, //1.4*tinch,
            npady= 1.5, //0.6*tinch,
            showpins=showpins,
            showcylinder=showcylinder,
            showstandoff=showstandoff, 
            height=height);
        };
    };
    module stripboard(nx, ny, npadx=2, npady=2,
        showboard=false,showpins=true, showcylinder=false, 
        showstandoff=false,
        padsize=0, height=5
    ) {
        pitch=25.4/10;
        cubesize = padsize==0 ? pitch/4 : padsize;
        translate([-npadx*pitch,-npady*pitch]) color("green")         
        if (showboard) {
            difference() {
                boardx=(nx-1+2*npadx);
                boardy=(ny-1+2*npady);
                cube([boardx*pitch, boardy*pitch, 0.1]);
                echo("Boardsize: ");
                echo(boardx);
                echo(boardy);
                getCylinderSet(d=2.5, height=50);
            };
        } else {
        };
        if (showcylinder) color("green") getCylinderSet(height=50);
        if (showstandoff) color("lightblue") difference() {
            union() { 
                // translate([0,0,-1.5*height/4]) getCylinderSet(8,height=height/4);
                // translate([0,0,-height/8]) getCylinderSet(6,height=height/2);
                translate([0,0,-height/4]) getCylinderSet(6,height=height/2);
                getCylinderSet(4.5,height=height); 
                };
            getCylinderSet();
        };
        if (showpins) {
        for(x=[0:1:nx-1]) {
        for(y=[0:1:ny-1]) {
            translate([x*pitch,y*pitch,0]) {
                color("red") cube([cubesize/2,cubesize/2,cubesize], center=true);
                color("red") translate([0.3,0.3,0]) text(str(x+1), size=1);
                translate([-1.3,-1.3,0]) color("green") text(str(y+1), size=1);
            };
        };
        };
        };
        module getCylinderSet(d=2.5, height=10){
            translate([-npadx*pitch,-npady*pitch,0]) 
                cylinderSet((nx-1+2*npadx)*pitch, (ny-1+2*npady)*pitch, z=height,
                dx=3.810,
                dy=3.810, 
                d=d);
        };
     };   

    module cutouts(x, padx, extx, y, pady, exty, wall) {
        // cutout for screen
        cutoutx = 15;
        cutouty = +1;
        cutoutdx = 38;
        cutoutdy = 86;
        // cutout for screen
        cutout(cutoutx,cutouty, cutoutdx, cutoutdy, wall); 
        // cutout for sensor plate
        // Full dims 
        xx = x + 2 * padx + extx;
        yy = y + 2 * pady + exty;
        // We can start atan
        starty = y+pady;
        minpad = 15;
        dx = padx - minpad;
        dy = exty - minpad;
        //cutout(-dx, dy, xx-20, yy-dy-40, wall); 
        // cutout(-dx, y+pady+20, (xx-2*minpad), dy-20, wall); 
        
        // cutout for sensors:
        // top - full
        // cutout(-9, 114, 91, 40, wall); 
        // topleft
        cutout(-9, 114, 28, 40, wall);
        // topright
        cutout(+48, 114, 34, 40, wall);
        // top middle
        cutout(+21, 102, 21, 40, wall);
        // bottom
        cutout(-9, 99, 85, 19, wall); 

    //    holepunch(0-dx, starty, 2, wall);    
    //    holepunch(0-dx, starty+dy, 2,wall);    
    //    holepunch(x+dx, starty, 2,wall);    
    //    holepunch(x+dx, starty+dy, 2,wall);    
    }
    
    module cutout(cutoutx,cutouty, cutoutdx, cutoutdy, wall) {
        translate([cutoutx,cutouty,-2*wall]) linear_extrude(height = wall*4) square(size = [cutoutdx, cutoutdy]);
    }
    
    module holepunch(cutoutx,cutouty, cutoutrad, wall) {
        translate([cutoutx,cutouty,-2*wall])
        linear_extrude(height = wall*4)circle(r=cutoutrad);
    }
    module baseplate(x,y,padx=20, pady=20, wall=2, extx=0, exty=0, lidlip=0) {
        // base plate with Cutout and mounts
        // x, y = size of rectangle for mounting holes
        // padding is added around corners
        // -> Full baseplate is (x + 2 padx) by (y + 2 pady)
        // Thickness = 2
        // Height of mounting holes: z
        // 
        translate([-padx-lidlip,-pady-lidlip,-wall]) 
            linear_extrude(height = wall+0.5) 
                square(size = [x+2*padx+extx+2*lidlip, y+2*pady+exty+2*lidlip]);
    }

    module pcbMountHoles(x,y,zoffset=0, height=5,  lid_is_laser_cut) {
        pcbMountHole(0, 0, zoffset, height,  lid_is_laser_cut);
        pcbMountHole(0, y, zoffset, height,  lid_is_laser_cut);
        pcbMountHole(x, 0, zoffset, height,  lid_is_laser_cut);
        pcbMountHole(x, y, zoffset, height,  lid_is_laser_cut);
    }
    module pcbMountHole(x, y, zoffset, height,  lid_is_laser_cut) {
        // Mounts are 2.5mm. medium fit = 2.9, free fit = 3mm.
        mountholediameter = 2.9;
        mountholeradius = mountholediameter/2;
        color("green") translate([x,y,zoffset])
        if (lid_is_laser_cut) {
            translate([0,0,-10]) linear_extrude(height = 50)circle(r=mountholeradius) ;
        } else {
            difference() {
                linear_extrude(height = height) circle(r=mountholeradius+2);
                linear_extrude(height = height*1.5)circle(r=mountholeradius);
           };
       };
    }
}

// Sides of the box
module makeboxSides(x,y,z, padx=20, pady=20, wall=2, extx=0, exty=100, extendSide=0) {
    // Full interior dimensions are:
    xx = x + 2 * padx + extx;
    yy = y + 2 * pady + exty;

    // Base walls:
    translate([-padx, -pady, 0]) color("purple") 
        // basewalls(xx, yy, z, wall, y_midwall=y + 2 * pady, extendSide=extendSide);
    basewalls(xx, yy, z, wall, y_midwall=0, extendSide=extendSide);
    
    // make text
    // makeText(x, padx, y, pady, wall);
}

// box mounts v1
module makeBoxMounts(x, y, z, padx=20, pady=20, wall=2, extx=0, exty=100, extendSide=0, punchconnects=false) {
    // Full interior dimensions are:
    xx = x + 2 * padx + extx;
    yy = y + 2 * pady + exty;
    
    // Box mount
    // If we use m3 screws, the fit is 3.2mm
    // m4: Normal fit: 4.5 mm 
    // m5: 5.5.
    // Screw hole diameter:
    boxmountscrew = 3.2;
    translate([-padx, -pady, 0]) 
        boxmounts(xx, yy, z, wall, boxmountscrew, y + pady*2, extendSide=extendSide, punchconnects=punchconnects);
    
    // modules:
    module boxmounts(x, y, z, wall, mountdiameter, pady=100, extendSide=0, punchconnects=false) {  
        // Outer diameter:
        mountdiameter_outer = mountdiameter*2;
        translate([0, 0, -extendSide]) 
            boxmount(z, extendSide, mountdiameter_outer,  punchconnects=punchconnects);
        translate([x, 0, -extendSide]) rotate(90) 
            boxmount(z, extendSide, mountdiameter_outer,  punchconnects=punchconnects);
        translate([x, y, -extendSide]) rotate(180) 
            boxmount(z, extendSide, mountdiameter_outer,  punchconnects=punchconnects);
        translate([0, y, -extendSide]) rotate(270) 
            boxmount(z, extendSide, mountdiameter_outer,  punchconnects=punchconnects);
        // extra mounts:
        translate([x, y/2, -extendSide]) rotate(180) 
            boxmount(z, extendSide, mountdiameter_outer,  punchconnects=punchconnects);
        translate([0, y/2, -extendSide]) rotate(270) 
            boxmount(z, extendSide, mountdiameter_outer, punchconnects=punchconnects);
    };
    module mountcol(z, wall, size) {
        color("red") cube([size/2, size/2, z]);
        translate([0, size/2, 0]) color("red") cube([size/2, size/2, z]);
        translate([size/2, 0, 0]) color("red") cube([size/2, size/2, z]);
        color("green")
        translate([size/2, size/2, 0]) cylinder(z, r=size/2);
    };
    module boxmount(z, extendSide, mountdiameter_outer, punchconnects=false) {
        if (punchconnects) {
            connectcol(z, punchconnects ? extendSide+20 : extendSide, mountdiameter_outer);
        } else {
            difference() {
               mountcol(z, extendSide, mountdiameter_outer);
               connectcol(z, extendSide, mountdiameter_outer);
            };
        }
    };
    module connectcol(z, wall, mountdiameter_outer) {
       height = 2*wall+z;
       // echo(height);
       translate([mountdiameter_outer/2, mountdiameter_outer/2, -wall]) 
            cylinder(height, r=mountdiameter_outer/4);
    };
    
};

module makeBoxMounts2(x, y, z, padx=20, pady=20, wall=2, extx=0, exty=100, extendSide=0, punchconnects=false) {
    
    // Fit the camden box 
    // screw distances are: 96x88
    // Short side: 110mm
    // - Distance from outside to mid-screw: 7mm
    // - screw-to-screw distance 96mm
    // - mid-screw-to-wall: 7mm
    // = 110mm
    // Long side: 7 + 88 + 88 + 7.
    
    // Full exterior dimensions are:
    xx = x + 2 * padx + extx + 2*wall;
    yy = y + 2 * pady + exty + 2*wall;
    
    // Box mount
    // If we use m3 screws, the fit is 3.2mm
    // m4: Normal fit: 4.5 mm 
    // m5: 5.5.
    // Screw hole diameter:
    boxmountscrew = 3.2;
    // ^^ correct for camden.
    translate([-padx, -pady, 0]) 
        boxmounts(xx, yy, z, wall, boxmountscrew, y + pady*2, extendSide=extendSide, 
            punchconnects=punchconnects);
    
    // modules:
    module boxmounts(x, y, z, wall, boxmountscrew, pady=100, extendSide=0, punchconnects=false) {  
        // Outer diameter:
        mountdiameter_outer = boxmountscrew*2;
        translate([0, 0, -extendSide]) 
            boxmount(z, extendSide, mountdiameter_outer, punchconnects=punchconnects, 
                mount_x=7, mount_y=7);
        translate([x, 0, -extendSide])  
            boxmount(z, extendSide, mountdiameter_outer,  punchconnects=punchconnects, 
                mount_x=-7, mount_y=7);
        translate([x, y, -extendSide])  
            boxmount(z, extendSide, mountdiameter_outer,  punchconnects=punchconnects, 
                mount_x=-7, mount_y=-7);
        translate([0, y, -extendSide])  
            boxmount(z, extendSide, mountdiameter_outer,  punchconnects=true, 
                mount_x=7, mount_y=-7);
        // extra mounts:
        translate([x, y/2, -extendSide]) 
            boxmount(z, extendSide, mountdiameter_outer,  punchconnects=punchconnects, 
                mount_x=-7, mount_y=0);
        translate([0, y/2, -extendSide]) rotate(0) 
            boxmount(z, extendSide, mountdiameter_outer, punchconnects=punchconnects,
                mount_x=7, mount_y=0);
    };
    module mountcol(z, wall, size) {
        color("green")
        translate([size/2, size/2, 0]) cylinder(z, r=size/2);
    };
    module boxmount(z, extendSide, mountdiameter_outer, punchconnects=false, mount_x=7, mount_y=7) {
        if (punchconnects) {
            connectcol(z, punchconnects ? extendSide+20 : extendSide, mountdiameter_outer,
                mount_x=mount_x, mount_y=mount_y);
        } else {
            difference() {
               mountcol(z, extendSide, mountdiameter_outer);
               connectcol(z, extendSide, mountdiameter_outer);
            };
        }
    };
    module connectcol(z, wall, mountdiameter_outer, mount_x=0, mount_y=0, man_mount=true) {
       height = 2*wall+z;
       // echo(height);
       translate([
        (!man_mount ? mountdiameter_outer/2 : mount_x)-mountdiameter_outer/4, 
        (!man_mount ? mountdiameter_outer/2 : mount_y)-mountdiameter_outer/4, 
        -wall]) 
            cylinder(height, r=mountdiameter_outer/4);
    };
    
};


module basewalls(x, y, z, wall, y_midwall=0, extendSide=0) {
    fullx = x + 2*wall;
    fully = y + 2*wall;
    wallz = extendSide;
    translate([-wall,-wall,-wallz]) linear_extrude(height = z + 2*wallz) square(size = [fullx, wall]);
    translate([-wall,-wall,-wallz]) linear_extrude(height = z + 2*wallz) square(size = [wall, fully]);
    translate([-wall, y,-wallz]) linear_extrude(height = z + 2*wallz) square(size = [fullx, wall]);
    translate([x, -wall,-wallz]) linear_extrude(height = z + 2*wallz) square(size = [wall, fully]);
    // extra 
    if (y_midwall > 0) {
        difference() {
            translate([-wall,y_midwall,-wallz]) linear_extrude(height = z + 2*wallz) square(size = [fullx, wall]);
            cutx=50;
            translate([x/2-cutx/2, y_midwall-10,20]) linear_extrude(height = 10) square(size = [cutx, cutx]);
        }
    }
}



module makeText(x, padx, y, pady, wall) {
    // Text
    translate([-15,-5,-wall]) rotate([180,0,0]) color("orange") linear_extrude(height = 1) text("Better Learning");
    translate([-15,12,-wall]) rotate([180,0,0]) color("orange") linear_extrude(height = 1) text("opendeved.net/ilce");
    
    // Text in braille
    text = ["^Open Development" , "and Education"];
    //translate([-padx-wall,-pady,z/2]) rotate([270,0,90]) label(text);
    translate([1.7*padx,y+pady/2,-wall]) rotate([180,0,0]) color("orange") label(text);
    
    translate([-padx+5,pady+20,-wall]) color("black") rotate([180,0,0])  make_qr();

}


// echo(version=version());


module makeBattery() {
    translate([40,170,30]) rotate([90,0,0]) mainBody();
} 

module makePCB() {
    makeInky(); 
    makePico();
    
    // pcb
    translate([177,-53,+10]) rotate([90,0,0]) scale(1000) import("lib/pcb.stl");
    
    // antenna
    color("green") translate([+73,49,+11]) rotate([0,90,0]) linear_extrude(70) circle(3);
    
    module makeInky() {
        // 87 x 38.7 x 9.7
        // 8mm screen+pcb
         translate([53,0,1]) rotate([0,0,90]) union() {
            color("orange") linear_extrude(3) square([87, 38.7]);
            translate([18,10,3]) color("black") linear_extrude(6) square([52, 20]);
                // color("purple") translate([87-15,0,-1.7]) linear_extrude(9.7) square([4, 38.7]);
            for(x=[5:12:30]) 
                color("purple") translate([87-15,x,-1.7]) linear_extrude(9.7) square([4, 4]);
            };
    }
    
    module makePico() {
        // 51.3mm x 21mm x 3.9mm

        translate([32.9,43.6,18]) rotate([90,0,180]) color("green") import("lib/Raspberry-Pi-Pico-R3.stl");

   
    }
}
