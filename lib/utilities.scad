
// minimum angle
$fa = 1;
// minimum size
$fs = 0.4;
// number of fragments 
$fn = 48;

// use <sector.scad>;

// cylindersector(50, 10, 10, a1=0, a2="", tolerance=0) ;
    
// translate([+86,+40,0]) frame(20,30, height=1, inset=0, cornerspace=8, cornerarch=true, cornerinsidearch=false);

// translate([-25,0,0]) frame(20,30, thickness=1, height=1, inset=0, cornerspace=0, cornerarch=false, cornerinsidearch=false);

// frame(20,30, thickness=1, height=1, inset=0, cornerspace=2, cornerarch=false, cornerinsidearch=false);

// When the thickness gets too large, a tiny amount is left in the centre of the circle and causes a rendering error.
translate([25,0,0]) frame(20,30, thickness=2, height=1, inset=0, cornerspace=2, cornerarch=true, cornerinsidearch=true);

// translate([50,0,0]) frame(20,30, thickness=3, height=1, inset=0, cornerspace=6, cornerarch=true, cornerinsidearch=true);

// translate([-25,40,0]) frame(20,30, thickness=1, height=1, inset=3, cornerspace=0, cornerarch=false, cornerinsidearch=false);

// translate([0,40,0]) frame(20,30, thickness=1, height=1, inset=3, cornerspace=2, cornerarch=false, cornerinsidearch=false);

// translate([25,40,0]) frame(20,30, thickness=1, height=1, inset=3, cornerspace=2, cornerarch=true, cornerinsidearch=false);

// translate([50,40,0]) frame(20,30, thickness=3, height=1, inset=3, cornerspace=6, cornerarch=true, cornerinsidearch=true);


module frame(x,y,thickness="", height=1, inset=0, cornerspace=2, cornerarch=true, cornerinsidearch=false) {  
    if (thickness != "" && thickness>cornerspace) {
    echo("you'll get errors in rendering.");
        // When the thickness gets too large, a tiny amount is left in the centre of the circle and causes a rendering error.

    };
    XX=x-2*inset;
    YY=y-2*inset;
    translate([inset,inset,0]) {
    difference() {
        union() {
            difference() {
                cube([XX, YY,height]);
                //translate([-1,-1,-1]) cube([thickness+1,thickness+1,height+2]);                   
            };
        };
        union() {
            if (thickness != "") {
            // cut the middle frame
            translate([thickness, thickness, -5]) 
            cube([
                XX-2*thickness,
                YY-2*thickness,
                height+10]);
            };
            //cut edges
            if (cornerspace>0) {
                rectangleOfCubes(XX, YY, z=10, d=cornerspace, dx=0, dy=0, 
                n=4, ddx=0, ddy=0, inch=false);          
            };
        };
    };
    if (cornerarch && cornerspace>0) {
       // translate([inset,inset,0]) color("red") difference() {
                // cylinder(r=1,h=height);
                // cube([thickness,thickness,height+1]); 
        makeTubes();
    };    
    };
    module makeTubes() {
        rectangleOfTubes(XX, YY, z=height, d=cornerspace, d2=(cornerinsidearch? cornerspace-thickness : 0), dx=0, dy=0, 
                n=4, ddx=0, ddy=0, inch=false);    
    };
};
// tube(savequadrant=3,center=false,r=4,wall=1, h=1);


module rectangleOfTubes(x, y, z=10, d=2.5, d2=1, dx=0, dy=0, n=4, ddx=0, ddy=0, inch=false) {
    rectangleOfObjects(x, y, z=z, d=d, d2=d2, dx=dx, dy=dy, n=n, ddx=ddx, ddy=ddy, inch=inch, type="tube");
};

module rectangleOfCubes(x, y, z=10, d=2.5, dx=0, dy=0, n=4, ddx=0, ddy=0, inch=false) {
    rectangleOfObjects(x, y, z=z, d=d, dx=dx, dy=dy, n=n, ddx=ddx, ddy=ddy, inch=inch, type="cube");
};

module rectangleOfCylinders(x, y, z=10, d=2.5, dx=0, dy=0, n=4, ddx=0, ddy=0, inch=false) {
    rectangleOfObjects(x, y, z=z, d=d, dx=dx, dy=dy, n=n, ddx=ddx, ddy=ddy, inch=inch, type="cylinder");
};


module rectangleOfObjects(x, y, z=10, d=2.5, dx=0, dy=0, n=4, ddx=0, ddy=0, inch=false, type="cylinder", d2=1) {
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
        makeSet(x*inch, y*inch, 
            z=z, d=d, 
            dx=dx*inch, 
            dy=(dy>0 ? dy*inch : dx*inch),
            n=n, 
            ddx=ddx*inch, 
            ddy=(ddy>0 ? ddy*inch : ddx*inch),
            type=type
        );
    } else {
        makeSet(x, y, z=z, d=d, 
        dx=dx, 
        dy=(dy>0 ? dy : dx),
        n=n, 
        ddx=ddx, 
        ddy=(ddy>0 ? ddy : ddx),
        type=type
        );
    };

    module makeSet(x, y, z=10, d=2.5, dx=0, dy=0, n=4, ddx=0, ddy=0,type="cylinder") {
        translate([ddx,ddy,-z/2]) {
            translate([0+dx,0+dy,0]) makeObject(0,0) ; 
            if (n>1)
                translate([x-dx,0+dy,0]) makeObject(1,0) ; 
            if (n>2)
                translate([0+dx,y-dy,0]) makeObject(0,1) ; 
            if (n>3)
                translate([x-dx,y-dy,0]) makeObject(1,1) ; 
        };

        module makeObject(xo=0,yo=0) {
            if (type=="cylinder")
                cylinder(z, r=d/2); 
            if (type=="cube")
                translate([0,0,z/2]) cube([2*d,2*d,z],center=true);
            if (type=="tube")
                translate([-xo*2*d,-yo*2*d,z/2]) tube(r=d, s=d2, h=z, center=false, xo=xo, yo=yo);            
        };

    };
};

module tube_old(
    h=10,r1="undef", r2="undef", r=2,
    h2="undef", s1="undef", s2="undef", s="",
    center=true, cutquadrant=0, savequadrant=0, wall="",
    xo=0, yo=0
    ) {
        tolerance=1;
        ttolerance=2;
        quadrantarray = [[3,2],[4,1]];
        savequadrant = quadrantarray[xo][yo];
    translate([center ? 0 : r, center ? 0 : r,0]) difference() {
        cylinder(
            h, r1=(r1 != "undef" ? r1 : r), r2=(r2 != "undef" ? r2 : r));
        union() {
            translate([0,0,-tolerance]) cylinder(
                (h2 != "undef"? h2 : h+ttolerance), 
                r1=(s1 != "undef" ? s1 : (s!=""? s : (wall!=""? r-wall : r/2))), 
                r2=(s2 != "undef" ? s2 : (s!=""? s : (wall!=""? r-wall : r/2)))
            );
            if (cutquadrant>0 || savequadrant>0) {
                cutquadrant();
            };
        };
    };
    module cutquadrant() {
        if (cutquadrant==1 || (savequadrant > 0 && savequadrant != 1))
        translate([-tolerance,0,-tolerance]) cube([r,r,h+ttolerance]) ;
        if (cutquadrant==2 || (savequadrant > 0 && savequadrant != 2))
        translate([-r,0,-tolerance]) cube([r,r,h+ttolerance]) ;
        if (cutquadrant==3 || (savequadrant > 0 && savequadrant != 3))
        translate([-r,-r,-tolerance]) cube([r,r,h+ttolerance]) ;
        if (cutquadrant==4 || (savequadrant > 0 && savequadrant != 4))
        translate([0,-r,-tolerance]) cube([r,r,h+ttolerance]) ;
    };
};

module tube(
    h=10,r1="undef", r2="undef", r=2,
    h2="undef", s1="undef", s2="undef", s="",
    center=true, cutquadrant=0, savequadrant=0, wall="",
    xo=0, yo=0
    ) {
        tolerance=1;
        ttolerance=2;
        // quadrantarray = [[3,2],[4,1]];
        // savequadrant = quadrantarray[xo][yo];
        quadrantarray = [[+2,1],[+3,+0]];
        savequadrant = quadrantarray[xo][yo];
        translate([center ? 0 : r, center ? 0 : r,0]) 
        difference() {
        cylindersector(
            h, r1=(r1 != "undef" ? r1 : r), r2=(r2 != "undef" ? r2 : r), 
            a1=90*savequadrant, tolerance=1);
        union() {
            translate([0,0,-tolerance]) cylindersector(
                (h2 != "undef"? h2 : h+ttolerance), 
                r1=(s1 != "undef" ? s1 : (s!=""? s : (wall!=""? r-wall : r/2))), 
                r2=(s2 != "undef" ? s2 : (s!=""? s : (wall!=""? r-wall : r/2))),
            a1=90*savequadrant, tolerance=+2
            );
            
        };
    };    
};

/*
module cutquadrant() {
        if (cutquadrant==1 || (savequadrant > 0 && savequadrant != 1))
        translate([-tolerance,0,-tolerance]) cube([r,r,h+ttolerance]) ;
        if (cutquadrant==2 || (savequadrant > 0 && savequadrant != 2))
        translate([-r,0,-tolerance]) cube([r,r,h+ttolerance]) ;
        if (cutquadrant==3 || (savequadrant > 0 && savequadrant != 3))
        translate([-r,-r,-tolerance]) cube([r,r,h+ttolerance]) ;
        if (cutquadrant==4 || (savequadrant > 0 && savequadrant != 4))
        translate([0,-r,-tolerance]) cube([r,r,h+ttolerance]) ;
    };
*/

// Inspired by https://gist.github.com/plumbum/78e3c8281e1c031601456df2aa8e37c6

module cylindersector(h, r1=10, r2=10, a1="", a2="", tolerance=0) {
    if (a1=="") {
         cylinder(h=h, r1=r1, r2=r2);
    } else {
        a2x = (a2!=""? a2 : a1 + 90)+tolerance;
        a1x = a1 - tolerance;
        if (a2x - a1x > 180) {
            difference() {
                cylinder(h=h, r1=r1, r2=r2);
                translate([0,0,-0.5]) cylindersector(h=h+1, r1=r1, r2=r2, a2x-360, a1x); 
            }
        } else {
            difference() {
                cylinder(h=h, r1=r1, r2=r2);
                rotate([0,0,a1x]) translate([-r1, -r1, -0.5])
                    cube([r1*2, r1, h+1]);
                rotate([0,0,a2x]) translate([-r1, 0, -0.5])
                    cube([r1*2, r1, h+1]);
            }
//   color("red")     rotate([0,0,a1x]) translate([-r1, -r1, -0.5]) cube([r1*2, r1, h+1]);
// color("green") rotate([0,0,a2x]) translate([-r1, 0, -0.5]) cube([r1*2, r1, h+1]);
        }
};
}    


module sectordh(h, d, a1, a2) {
    if (a2 - a1 > 180) {
        difference() {
            cylinder(h=h, d=d);
            translate([0,0,-0.5]) sector(h+1, d+1, a2-360, a1); 
        }
    } else {
        difference() {
            cylinder(h=h, d=d);
            rotate([0,0,a1]) translate([-d/2, -d/2, -0.5])
                cube([d, d/2, h+1]);
            rotate([0,0,a2]) translate([-d/2, 0, -0.5])
                cube([d, d/2, h+1]);
        }
    }
}    
