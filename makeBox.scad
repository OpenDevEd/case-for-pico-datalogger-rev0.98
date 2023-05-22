// Box for:
// Mounting holes: 84 x 74
// Approx pcb size: 90 x 80
// basic box size: 110 x 100 (interior)
// with sensor patch: 110 x 200 (interior)

use <lib/braille.scad>
use <lib/qrcode.scad>

makebox(84, 74, 40, padx=26, pady=26, wall=3, extx=0, exty=100);


module makebox(x,y,z, padx=20, pady=20, wall=2, extx=0, exty=100) {
    baseplatemaker(x,y,z, padx, pady, wall, extx, exty);
    // Full interior dimensions are:
    xx = x + 2 * padx + extx;
    yy = y + 2 * pady + exty;
    // Base walls:
    translate([-padx, -pady, 0]) color("purple") basewalls(xx, yy, z, wall);
    
    // Box mount
    boxmountscrew = 10;
    translate([-padx, -pady, 0]) boxmounts(xx, yy, z, wall, boxmountscrew, y + pady*2);

    // make text
    makeText(x, padx, y, pady, wall);
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


module baseplatemaker(x,y,z, padx=20, pady=20, wall=2, extx=0, exty=100) {
    // base plate
    difference() {
        baseplate(x, y, padx, pady, wall, extx, exty);
        cutouts(x, padx, extx, y, pady, exty, wall);
    }
    // mount point for pcb 1
    mountpointheight=5;
    pcbMountHoles(x,y, 0, mountpointheight);    
    // mount points for pcb2
    // translate([0, y+30, 0]) pcbMountHoles(x,y, 0, mountpointheight);
}

module cutouts(x, padx, extx, y, pady, exty, wall) {
    // cutout for screen
    cutoutx = 10;
    cutouty = 20;
    cutoutdx = 70;
    cutoutdy = 40;
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
    cutout(-dx, y+pady, (xx-2*minpad), dy, wall); 
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


module basewalls(x, y, z, wall) {
    fullx = x + 2*wall;
    fully = y + 2*wall;
    translate([-wall,-wall,-wall]) linear_extrude(height = z) square(size = [fullx, wall]);
    translate([-wall,-wall,-wall]) linear_extrude(height = z) square(size = [wall, fully]);
    translate([-wall, y,-wall]) linear_extrude(height = z) square(size = [fullx, wall]);
    translate([x, -wall,-wall]) linear_extrude(height = z) square(size = [wall, fully]);
}


module boxmounts(x, y, z, wall, size, pady=100) {
   translate([0, 0, -wall]) boxmount(z, wall, size);
   translate([x, 0, -wall]) rotate(90) boxmount(z, wall, size);
   translate([x, y, -wall]) rotate(180) boxmount(z, wall, size);
   translate([0, y, -wall]) rotate(270) boxmount(z, wall, size);

   translate([x, pady, -wall]) rotate(180) boxmount(z, wall, size);
   translate([0, pady, -wall]) rotate(270) boxmount(z, wall, size);

}

module boxmount(z, wall, size) {
    difference() {
       mountcol(z, wall, size) ;
       translate([size/2, size/2, - wall]) cylinder(2*wall+z, r=size/4);
    };
};

module mountcol(z, wall, size) {
    color("red") cube([size/2, size/2, z]);
    translate([0, size/2, 0]) color("red") cube([size/2, size/2, z]);
    translate([size/2, 0, 0]) color("red") cube([size/2, size/2, z]);
    color("green")
    translate([size/2, size/2, 0]) cylinder(z, r=size/2);
};

// base plate with Cutout and mounts
// x, y = size of rectangle for mounting holes
// padding is added around corners
// -> Full baseplate is (x + 2 padx) by (y + 2 pady)
// Thickness = 2
// Height of mounting holes: z
// 
module baseplate(x,y,padx=20, pady=20, wall=2, extx=0, exty=0) {
    translate([-padx,-pady,-wall]) linear_extrude(height = wall) square(size = [x+2*padx+extx, y+2*pady+exty]);
}

module pcbMountHoles(x,y,zoffset=0, height=5) {
    pcbMountHole(0, 0, zoffset, height);
    pcbMountHole(0, y, zoffset, height);
    pcbMountHole(x, 0, zoffset, height);
    pcbMountHole(x, y, zoffset, height);
}

module pcbMountHole(x, y, zoffset, height) {
    color("green") translate([x,y,zoffset])
    difference() {
linear_extrude(height = height) circle(r=4) ;
linear_extrude(height = height*1.5)circle(r=2) ;
   };
}


// echo(version=version());
