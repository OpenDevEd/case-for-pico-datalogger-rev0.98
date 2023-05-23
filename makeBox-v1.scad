// Box for https://github.com/bablokb/pcb-pico-datalogger (Rev 0.98)
// Uses:
// QR Code generator for OpenSCAD https://github.com/ridercz/OpenSCAD-QR
// https://github.com/KitWallace/openscad/blob/master/braille.scad
// 
// basic box size: 110 x 100 (interior)
// with sensor patch: 110 x 200 (interior)
//
// Not final.

// use <lib/braille.scad>
// use <lib/qrcode.scad>

wallThickness = 3;
// showlidx=true;
showlidx=false;
makeEverything(84, 74, 50, padx=26, pady=26, wall=wallThickness, extx=0, exty=50, extendBase=wallThickness, extendSide=0,showlid=showlidx);
makeInky();

module makeSensors() {
    for(x=[5:18:100]) 
translate([x,140,1]) rotate([180,0,270]) color("grey") import("lib/4566-AHT20-Sensor.stl");
};

module makeInky() {
// 87 x 38.7 x 9.7
    translate([0,21,0]) union() {
     color("orange") linear_extrude(8) square([87, 38.7]);
//     color("purple") translate([87-15,0,-1.7]) linear_extrude(9.7) square([4, 38.7]);
  for(x=[5:12:30]) 
        color("purple") translate([87-15,x,-1.7]) linear_extrude(9.7) square([4, 4]);
    };
}

// Pi + socket is about 16mm, call is 20.
// 10mm headroom, with Inky, gives about 40mm 
// box allows for 50mm


module makeEverything(x, y, z, padx=10, pady=10, wall=1, extx=0, exty=0, extendBase=0, extendSide=0, showlid=false) {
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
                baseplatemaker(x,y,z, padx, pady, wall, extx, exty, extendBase, showlid=showlid);
                // This makes the sides:
                makeboxSides(x,y,z, padx, pady, wall, extx, exty, extendSide);
                makeBoxMounts(x,y,z, padx, pady, wall, extx, exty, extendSide);
            }
            // This punches the holes for screws:
            makeBoxMounts(x,y,z, padx, pady, wall, extx, exty, extendSide, punchconnects=true);
        }
    }
    makeSensors();

}

module showGuides(xx, yy, zz, padx=0, pady=0, padz=0) {
    rad=3;
    translate([-padx, -pady, -padz]) color("grey") {
        rotate([0,90,0]) cylinder(xx,r=rad);
        rotate([-90,0,0]) cylinder(yy,r=rad);
        rotate([0,0,0]) cylinder(zz,r=rad);
    };
}

module baseplatemaker(x,y,z, padx=20, pady=20, wall=2, extx=0, exty=100, extendBase, showlid=false, mountpointheight=5, lid_is_laser_cut = true) {
    // base plate
    difference() {
        color([1,1,0,0.8]) baseplate(x, y, padx, pady, wall, extx, exty, extendBase);
        union() {
            cutouts(x, padx, extx, y, pady, exty, wall);
            if (lid_is_laser_cut) {
                pcbMountHoles(x,y, 0, mountpointheight, lid_is_laser_cut);    
            };
        }
    }
    if (showlid) {
        color([0,1,1,0.8]) translate([0,0,z+lidlip]) baseplate(x, y, padx, pady, wall, extx, exty, extendBase);
    }
    if (!lid_is_laser_cut) {
        // mount point for pcb 1
        pcbMountHoles(x,y, 0, mountpointheight, lid_is_laser_cut);    
        // mount points for pcb2
        // not used // translate([0, y+30, 0]) pcbMountHoles(x,y, 0, mountpointheight);
    };
    
    // Modules:
    module cutouts(x, padx, extx, y, pady, exty, wall) {
        // cutout for screen
        cutoutx = 70;
        cutouty = 22;
        cutoutdx = 10;
        cutoutdy = 35;
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
        cutout(-dx, y+pady+20, (xx-2*minpad), dy-20, wall); 
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
        translate([-padx-lidlip,-pady-lidlip,-wall]) linear_extrude(height = wall) square(size = [x+2*padx+extx+2*lidlip, y+2*pady+exty+2*lidlip]);
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
                linear_extrude(height = height) circle(r=5);
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
        basewalls(xx, yy, z, wall, y_midwall=y + 2 * pady, extendSide=extendSide);
    
    // make text
    // makeText(x, padx, y, pady, wall);
}

// box mounts
module makeBoxMounts(x, y, z, padx=20, pady=20, wall=2, extx=0, exty=100, extendSide=0, punchconnects=false) {
    // Full interior dimensions are:
    xx = x + 2 * padx + extx;
    yy = y + 2 * pady + exty;
    
    // Box mount
    // If we use m3 screws, the fit is 3.2mm
    // m4: Normal fit: 4.5 mm 
    // m5: 5.5.
    // Screw hole diameter:
    boxmountscrew = 4.5;
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
        translate([x, pady, -extendSide]) rotate(180) 
            boxmount(z, extendSide, mountdiameter_outer,  punchconnects=punchconnects);
        translate([0, pady, -extendSide]) rotate(270) 
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
