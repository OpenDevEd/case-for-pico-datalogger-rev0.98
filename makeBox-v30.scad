// Box for https://github.com/bablokb/pcb-pico-datalogger (Rev 0.98)
// 
// basic box size: 110 x 100 (interior)
//
// Not final.
// 96x88

use <lib/braille.scad>
// use <lib/qrcode.scad>
//use <lib/battery_box_2.0.scad>;

use <lib/sensors-v2.scad>;
use <lib/utilities.scad>;

// School-based
// Temperature Sensor
// url

// Openscad config:
// minimum angle
$fa = 1;
// minimum size
$fs = 0.4;
// number of fragments 
$fn = 48;



// Configuration for the model:
project_model_for_printing = false;
wallThickness = 1.5; 
showlidx=false;
makeSides=false;
makeObjects=false;
modelheight=55;
showguides= false;
makeGuides=showguides;
makeBattery=false;
makeText=true;
showpins = true;
showSensorBoard=true;
showStripboardClearance=true;

// If we use wood screws, M2.5, the pilot hole is 1mm:
pcbMountScrewDiameter=1;

// makePCB();

main();

module main() {
    // https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/3D_to_2D_Projection
    if (project_model_for_printing)
        if (makeObjects)
            text("error - disable makeObjects");
        else
            translate([-45,-55,0]) projection(cut=true) fullModel();
    else 
    {
        if (showguides) {
            cube([7,7,7]);
            showGuides(110, 190, 60, rad=0.5, col="orange");
            translate([7,7,0]) { 
                showGuides(96, 88, 60, rad=0.5, col="green");
                translate([0,88,0]) showGuides(96, 88, 60, rad=0.5, col="green");
                // translate([0,95,0]) showGuides(96, 88, 60, 0, 0, 0, rad=0.5, col="red");
                // rotate([0,0,90]) translate([0,-96,0]) showGuides(96, 88, 60, 0, 0, 0, rad=0.5);
                translate([0,2*88,0]) showGuides(96, 7, 60, 0, 0, 0, rad=0.5, col="red");
                translate([96,0,0]) showGuides(7, 88, 60, rad=0.5, col="blue");
                translate([96,88,0]) showGuides(7, 88, 60, rad=0.5, col="blue");
            };
        };
    
        translate([16.5+1.5,16.5+1.5,0]) {
            fullModel();
        };
          
        if (makeGuides) translate([0,0,-4]) {
            translate([0,0,+3]) color("blue") linear_extrude(5) scale([1,1,1]) import("camdenboss/2//BIM2006_16-GY_GY_Back-v1.svg"); 
        
            translate([0,0,+1]) color("orange") linear_extrude(5) scale([1,1,1]) import("camdenboss/2/BIM2006_16-GY_GY_Back-v2.svg");  
            }; 
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
        
}

module makeEverything(x, y, z, padx=10, pady=10, wall=2, extx=0, exty=0, extendBase=0, extendSide=0, showlid=false, makeSides=true) {
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
            mainElements();
            makeLidHoles();
        }
    }
    color("red") translate([-padx-wall, -pady-wall, 0]) makeLidSupport();

    makeAntennaMount();
    makeFrontSensorMount(showobject=makeObjects);
    
    translate([70,-7,1]) color("red") {
        rotate([0,0,90]) translate([5,60,0.9]) linear_extrude(0.4) text("https://opendeved.net/ilce  (2023-05-29)", size=3);
       label("^OpenDevEd");
    };
    
    if (makeObjects) {
        translate([0,0,6]) makePCB();
    }
    if (makeBattery) makeBatteryBox();
    
    module mainElements() {
        // This makes the baseplate:
        baseplatemaker(x,y,z, padx, pady, wall, extx, exty, extendBase, showlid=showlid, mountpointheight=9+6.21);
        translate([0,0,1]) makeBoxMounts2(x,y,z, padx, pady, wall, extx, exty, extendSide, punchconnects=true, reinforceholes=true);
        if (makeSides) {
            // This makes the sides:
            makeboxSides(x,y,z, padx, pady, wall, extx, exty, extendSide);
            // makeBoxMounts(x,y,z, padx, pady, wall, extx, exty, extendSide);
        }
    };
    
    module makeLidHoles() {
        // This punches the holes for screws:
        makeBoxMounts2(x,y,z, padx, pady, wall, extx, exty, extendSide, punchconnects=true);
        translate([+5, 161, -10]) {
            // translate([0, 0, 22]) color("black") text("mount hole for aht20 case", size=2);
            cylinder(40,d=2.5);
        };
    };
    
    module makeBatteryBox() {
        translate([-13,+82,25]) color("black") cube([19,72,33]);
    };

    module makeLidSupport() {
        frame(xxe,yye,thickness=1.5,height=1.8, inset=2.2, cornerspace=4, cornerarch=true, cornerinsidearch=true);
    };
    

}
    module makeFrontSensorMount(showobject=true, showpunch=false) {
       translate([-18,7,-15.1]) color("black") {
        if (showobject) difference () {
            cube([27,59,13.1]) ;
            translate([27/2,3+3.8/2,-2]) cylinder(17,d=3.8);    
        };
        if (showpunch) {
            translate([27/2,3+3.8/2,-15]) cylinder(37,d=2);                   
            translate([27/2,60+3.8/2,-15]) cylinder(37,d=3);                
        };
    };
    };
    
module makeAntennaMount() { 
    qq=1;
    // antenna
    translate([+82,2,0]) {
        difference() {
            makeMount();
            antenna(tolerance=1);
        };
        if (makeObjects) antenna();
    };        
    
    module makeMount() {
        //mount
        translate([-3,30,0]) cube([6,30,25]);
        translate([1,5,0]) {
            translate([-3-6+qq,50.5,22]) cube([12,2,15]);
            translate([-3-6+qq,25,22]) cube([12,5,15]);
        };
                         
    };
    module antenna(tolerance=0) {
        //antenna
        translate([1,5,0]) {
            translate([-3+qq,0,+30]) {
                rotate([-90,0,0]) {
                cylinder(60, d=5.5+tolerance);
                color("blue") cylinder(50, d=8+tolerance);
                };
            };    
        };
    };
};


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
        baseplatemakerMain();
        baseplatemakerSubtract();
    };
        
    // translate([sensorboardx,sensorboardy,0]) sensorSchablone();
    
    if (showpins) translate([sensorboardx,sensorboardy,0]) 
        sensorSchablone(showpinsonly=true, schablone=false);
    
    if (showlid) {
        color([0,1,1,0.8]) translate([0,0,z+extendBase]) baseplate(x, y, padx, pady, wall, extx, exty, extendBase);
    }

    // mount point for pcb 1
    pcbMountHoles(x,y, 0, mountpointheight, lid_is_laser_cut);    
    // mount points for pcb2
    // not used // translate([0, y+30, 0]) pcbMountHoles(x,y, 0, mountpointheight);

    translate([sensorboardx,sensorboardy,0]) difference() {
        sensorpcbMounts();
        // This will make full width screw holes, e.g., nylon screws.
        // makeStripboard(showboard=false, showpins=false,showcylinder=true);
        // But - with wood screws, search for pcbMountScrewDiameter.
    };
    // Screws for testing:
    showscrews=makeObjects;
    if (showscrews) {
        translate([0,0,14])
        color("red") {  
            cylinderSet(x, y, z=11, d=3/2);
            translate([0,0,4.6]) cylinderSet(x, y, z=1, d=3);
            translate([0,0,5.5]) cylinderSet(x, y, z=1, d=5);
        };
    };
    
    // Modules:
            
    module baseplatemakerMain() {
        color([1,1,0,0.8]) baseplate(x, y, padx, pady, wall, extx, exty, extendBase);
        //RENDER
        screeninsertAndSupports();
    };
    module baseplatemakerSubtract() {
        // cut out the screen
        cutoutScreen();
        // cut out the sensors
        translate([sensorboardx,sensorboardy,0]) sensorSchablone();
        translate([sensorboardx,sensorboardy,0]) {
            // makeStripboard(showboard=false, showpins=false, showcylinder=true,height=50);
            sensorpcbMounts(colonly=true);
        };
        makeFrontSensorMount(showpunch=true);

    } ;     

    module screeninsertAndSupports() {
        // supports:
        color("blue") translate([-3,154,0]) cube([80,10,2]);
        color("blue") translate([-15,94,0]) cube([104,64,2]);
        color("blue") translate([-3,86,0]) cube([80,10,2]);
        color("blue") translate([-3,+2,0]) cube([80,80,2]);
        color("blue") translate([-3,-7,0]) cube([80,5,2]);
        
        cutoutdx = 37.5;
        cutoutdy = 86;
        cutoutx = 16;
        cutouty = +1; 
        offsetx=17;
        offsety=6;
        // If this just touches the cylinders, they'll be a rendering error.
        translate([3.0,0,0]) 
            translate([cutoutx-offsetx,cutouty-offsety,0]) 
                cube([cutoutdx+2*offsetx,2*offsety+cutoutdy,2]);        

    };    
    module sensorpcbMounts(colonly=false) {
        if (makeObjects) makeStripboard(showboard=showSensorBoard);        
        makeStripboard(showboard=false, showstandoff=true,showpins=false); 

    };
    module sensorSchablone(colonly=false, showpinsonly=false, schablone=true) {        
        // Sensors in 'ada-st' format (V3V, gnd, SCL, SDA):
        // - AHT20
        // - SHT45
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
        translate([25.4/10,0,0]) {
            tinch=2.54;
            // col 1 - Ada ST 
            mount_pins_adjust=mpadjust;            
            translate([+0*tinch,-9*tinch,0])        
                translate([-13.11,120.98,-wall]) {
                    if (makeText) translate([0,7,0]) color("black") text("AHT20",size=2);
                    mount_ada_st_size1_pins4(1,1,col="green", mount_pins_above_sensor=true,  mount_pins_adjust=mpadjust, colonly=colonly, showpins=makeObjects, showpinsonly=showpinsonly,schablone=schablone);
                };                
            // unused area
            if (schablone) {
                translate([-13,117,-wall*2]) {
                    if (makeText) translate([0,7,0]) color("black") text("(spare1)",size=2);
                    cube([25,25,10]);
                };
            };                            
            // col2-3, sht45
            translate([+9*tinch,+0*tinch,0]) 
                translate([-11.84,143.84,-wall]) {
                if (makeText) translate([0,7,0]) color("black") text("SHT45",size=2);
                mount_ada_st_size1_pins5(col="orange", mount_pins_above_sensor=true,  mount_pins_adjust=mpadjust, colonly=colonly,  showpins=makeObjects, showpinsonly=showpinsonly,schablone=schablone);      
            };
            // col 2 - Pim
            translate([+0.00,0.76,0]) {
            translate([1*tinch,-8*tinch,0]) 
            translate([+16.76,118.44,-wall]) {
                if (makeText) translate([0,7,0]) color("black") text("LTR559",size=2);
                mount_garden(1,1, col="lightgreen",mount_pins_above_sensor=true,  mount_pins_adjust=mpadjust, colonly=colonly, extendx=5, extendy=3, showpins=makeObjects, showpinsonly=showpinsonly,schablone=schablone); 
            };         
            translate([1*tinch,+1*tinch,0])     
            translate([+16.76,118.44,-wall]) {
                if (makeText) translate([0,7,0]) color("black") text("BH1745",size=2);
                mount_garden(1,1, col="lightgreen",mount_pins_above_sensor=true,  mount_pins_adjust=mpadjust, colonly=colonly,extendx=5, extendy=1.78,  showpins=makeObjects, showpinsonly=showpinsonly,schablone=schablone);            
            };
        };
        // col 3 - 
        translate([+2*tinch,-19*tinch,0]) 
            translate([+42.78,146.58,-wall]) {
                if (makeText) translate([0,4,0]) color("black") text("MCP9808",size=2);
                mount_ada_mcp(col="green",mount_pins_above_sensor=true,  mount_pins_adjust=mpadjust, extendx=7.5, colonly=colonly , showpins=makeObjects, showpinsonly=showpinsonly,schablone=schablone);
            };
        // translate([+24*tinch,6*tinch,0]) translate([-13.1,98.12,-wall]) { 
           // if (makeText) translate([0,7,0]) color("black") text("I2S",size=2);
           // mount_ada_st_size1_pins6(1,1,col="orange", mount_pins_adjust=mpadjust, mount_pins_above_sensor=true, colonly=colonly,
        // extendx=10,  showpins=makeObjects, showpinsonly=showpinsonly,schablone=schablone); };
            translate([+26*tinch,14*tinch,+3]) 
                translate([-13.75,97.84,-wall]) { 
                    if (makeText) translate([0,7,0]) color("black") text("I2S",size=2);
                    rotate([180,0,0]) mount_ada_mems_i2s(schablone=schablone);
        };
        // col2-3, sht45
        translate([+22*tinch,-1*tinch,0]) translate([-13.11,143.84,-wall]) {
            if (makeText) translate([0,7,0]) color("black") text("BH1750",size=2);
            mount_ada_st_size1_pins6(col="orange", mount_pins_above_sensor=true,  mount_pins_adjust=mpadjust, colonly=colonly,  showpins=makeObjects, showpinsonly=showpinsonly,schablone=schablone);    
        };               
       };
    };
    module makeStripboard(
        showboard=false, 
        showpins=true,
        showcylinder=false, 
        showstandoff=false, 
        height=12.1
        ) {
        tinch=25.4/10;
        translate([3*tinch,0,4.1]) 
        translate([-9.3,93,10]) {
            if (showStripboardClearance) {
                // Clearance for sensor board
                // 8.3 for socket + 2.3 for pins soldered to sensors = 10.3
                // socket
                translate([70,60,-8.3]) color("black") cube([9,5,8.3]);
               // pins soldered to sensors 
                translate([70,60,-10.6]) color("grey") cube([9,5,2.3]);
                // board of the sensor = 1.5
                translate([70,60,-12.1]) color("green") cube([9,5,1.5]);
            };
            tinch=2.54;
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
            boardx=(nx-1+2*npadx);
            boardy=(ny-1+2*npady);
            difference() {               
                cube([boardx*pitch, boardy*pitch, 2]);                
                cylinderSet((nx-1+2*npadx)*pitch, (ny-1+2*npady)*pitch, z=10,
                dx=3.810,
                dy=3.810, 
                d=2.5);            
            };
        } else {
        };
        showscrews=makeObjects;
        if (showboard && showscrews) {
           translate([-2*pitch,0,5]) color("red") {  
            x = (nx-1+2*npady+1)*pitch;
            y = (ny-1)*pitch;
            cylinderSet(x, y, z=11, d=3/2);
            translate([0,0,4.6]) cylinderSet(x, y, z=1, d=3);
            translate([0,0,5.5]) cylinderSet(x, y, z=1, d=5);
        };     
        };   
        if (showcylinder) color("green") getCylinderSet(height=50);
        if (showstandoff) color("lightblue") difference() {
            union() { 
                extender=3;
                // translate([0,0,-1.5*height/4]) getCylinderSet(8,height=height/4);
                // translate([0,0,-height/8]) getCylinderSet(6,height=height/2);
                translate([0,0,-3*height/4-extender/2]) getCylinderSet(6,height=height/2+extender);
                translate([0,0,-height/2-extender/2]) getCylinderSet(4.5,height=height+extender); 
                };
                // This cots out the 1mm hole:
            getCylinderSet(pcbMountScrewDiameter, height=50);
        };
        translate([0,0,2]) if (showpins) {
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

    module cutoutScreen() {
        ten=2;
        cutoutx = 14.5-ten/2;
        cutouty = +0.5-ten/2;
        cutoutdx = 38+ten;
        cutoutdy = 86+ten;
        cutout(cutoutx, cutouty, cutoutdx, cutoutdy, wall); 
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
        translate([-padx-lidlip,-pady-lidlip,-wall]) {
            //linear_extrude(height = wall+0.5) 
            //    square(size = [x+2*padx+extx+2*lidlip,y+2*pady+exty+2*lidlip ]);                  
            frame(x+2*padx+extx+2*lidlip,y+2*pady+exty+2*lidlip, height=wall+0.5, inset=0, cornerspace=6, cornerarch=true, cornerinsidearch=false);
            };
    }

    module pcbMountHoles(x,y,zoffset=0, height=5,  lid_is_laser_cut) {
        pcbMountHole(0, 0, zoffset, height,  lid_is_laser_cut);
        pcbMountHole(0, y, zoffset, height,  lid_is_laser_cut);
        pcbMountHole(x, 0, zoffset, height,  lid_is_laser_cut);
        pcbMountHole(x, y, zoffset, height,  lid_is_laser_cut);
    }
    module pcbMountHole(x, y, zoffset, height,  lid_is_laser_cut) {
        // Mounts are 2.5mm. medium fit = 2.9, free fit = 3mm.
        // mountholediameter = 2.9;
        mountholediameter=pcbMountScrewDiameter;
        mountholeradius = pcbMountScrewDiameter/2;
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

// box mounts v1 - not used. Design was for fully 3d printed box.
module makeBoxMounts(x, y, z, padx=20, pady=20, wall=2, extx=0, exty=100, extendSide=0, punchconnects=false) {
    // Full interior dimensions are:
    xx = x + 2 * padx + extx;
    yy = y + 2 * pady + exty;
    
    // Box mount
    // If we use m3 screws, the fit is 3.2mm
    // m4: Normal fit: 4.5 mm 
    // m5: 5.5.
    // Screw hole diameter:
    // boxmountscrew = 3.2;
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
       translate([mountdiameter_outer/2, mountdiameter_outer/2, -wall]) 
            cylinder(height, r=mountdiameter_outer/4);
    };
    
};

module makeBoxMounts2(x, y, z, padx=20, pady=20, wall=2, extx=0, exty=100, extendSide=0, punchconnects=false, reinforceholes=false) {
    
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
        boxmounts(xx, yy, z, wall, boxmountscrew, y + pady*2, extendSide=extendSide, punchconnects=punchconnects);

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
       if (!reinforceholes) {
           height = 2*wall+z;
           // echo(height);
           translate([
            (!man_mount ? mountdiameter_outer/2 : mount_x)-mountdiameter_outer/4, 
            (!man_mount ? mountdiameter_outer/2 : mount_y)-mountdiameter_outer/4, 
            -wall])
                    cylinder(height, r=mountdiameter_outer/4);
       }   else {
            translate([
            (!man_mount ? mountdiameter_outer/2 : mount_x)-mountdiameter_outer/4, 
            (!man_mount ? mountdiameter_outer/2 : mount_y)-mountdiameter_outer/4, -2.0] )
                cylinder(2.3, r=mountdiameter_outer/2-0.4);          
    };
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


module makeBattery() {
    translate([40,170,30]) rotate([90,0,0]) mainBody();
} 

module makePCB() {
    makeInky(); 
    makePico();
    
    // pcb
    translate([177,-53,+10]) rotate([90,0,0]) scale(1000) import("lib/pcb.stl");
    
    module makeInky() {
        // 87 x 38.7 x 9.7
        // 8mm screen+pcb
        translate([53,0,+1]) rotate([0,0,90]) {
            translate([0,0,-3]) {
                color("orange") linear_extrude(3) square([87, 38.7]);
                // buttons protrude 1mm
                for(x=[5:12:30]) 
                color("purple") translate([99-15,x+1,-1.0]) cylinder(d=2.5);
            };
            //mounts, inc extra bit from stacking header
            translate([0,0,+3]) {     
                translate([18,10,3]) color("yellow") cube([52, 1,3]);
                offs2=19;
                translate([18,10+offs2,3]) color("yellow") cube([52, 20-offs2,3]);
            };
            translate([0,0,-3]) {     
                translate([18,10,3]) color("black") cube([52, 3,6]);
                offs=17;
                translate([18,10+offs,3]) color("black") cube([52, 20-offs,6]);
            };
       };
    };
    
    module makePico() {
        // 51.3mm x 21mm x 3.9mm

        translate([32.9,43.6,18]) rotate([90,0,180]) color("green") import("lib/Raspberry-Pi-Pico-R3.stl");

    }
}
