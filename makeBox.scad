// LetterBlock.scad - Basic usage of text() and linear_extrude()

// Module instantiation
LetterBlock(80,90,50,wall=5);

module LetterBlock(x,y,z,wall=3) {
    mount_hole_distance = 5;
    difference() {
        translate([0,0,0]) linear_extrude(height = wall, center = true) square(size = [x, y]);
        translate([mount_hole_distance,mount_hole_distance,0]) linear_extrude(height = wall*1.1, center = true) circle(r=3) ;
    }
}

echo(version=version());
