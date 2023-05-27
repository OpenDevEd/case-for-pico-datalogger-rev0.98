// https://github.com/OpenDevEd/case-for-pico-datalogger-rev0.98
// Creative Commons - Attribution - Share Alike 
// Sources:
// https://www.thingiverse.com/thing:2051023
// OpenSCAD Customizable Pin header 3D model bykarfesis licensed under theCreative Commons - Attributionlicense.
// based on: https://www.thingiverse.com/thing:26474
// Pin Headers for OpenSCAD byguvis licensed under theCreative Commons - Attribution - Share Alikelicense.

// header_demo();

module header_demo() {
    //Number of rows of pins in the header
    header_rows = 5; //[1,2,3,4,5,6,7,8,9,10]
    
    //Number of columns of pins in the header
    header_columns = 2; //[1,2,3]
    
    //The header's pitch between any two pins
    header_pitch = 1.27; //[1.27,2.54]
    
    pin_header(header_rows,header_columns,header_pitch);
    
    translate([10,0,0]) pin_header();
    translate([20,0,0]) pin_header(10,2);
};

module pin_header(rows=5,cols=2,pitch=2.54){
    offsety=-1*((rows-1)/2*pitch);
    offsetx=-1*((cols-1)/2*pitch);
    translate([offsetx,offsety,0])
    union(){
        for(j=[0:1:cols-1]){
            translate([pitch*j,0,0])
            for(i=[0:1:rows-1]){
                translate([0,pitch*i,0])pin(pitch);
            }
        }
    }
}

module pin(p=2.54){
    s=p/4+0.005;
    h=p*4-0.5;
    base=h/3;
    d=s/2;
    union(){
        color("gold")union(){
            translate([0,0,h+d])rotate([0,0,45])
            cylinder($fn=4,r1=sqrt(2*pow(d,2)),r2=0,h=d,center=false);
            translate([-d,-d,d])cube([s,s,h],center=false);
            translate([0,0,d])rotate([0,0,45])mirror([0,0,d])
            cylinder($fn=4,r1=sqrt(2*pow(d,2)),r2=0,h=d,center=false);
        }
       color("Dimgray")difference(){
            translate([0,0,base+d])cube([p,p,p],center=true);
            union(){
                translate([1.9*s,1.9*s,base+d])rotate([0,0,45])cylinder($fn=3,r=2*d,h=p+1,center=true);
                translate([1.9*s,-1.9*s,base+d-0.15])rotate([0,0,-45])cylinder($fn=3,r=2*d,h=p+1,center=true);
                translate([-1.9*s,-1.9*s,base+d-0.3])rotate([0,0,180+45])cylinder($fn=3,r=2*d,h=p+1,center=true);
                translate([-1.9*s,1.9*s,base+d-0.3])rotate([0,0,180-45])cylinder($fn=3,r=2*d,h=p+1,center=true);
            }
        }
    }
}