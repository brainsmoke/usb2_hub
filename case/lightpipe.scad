use <case.scad>

for (i=[0:10:30])
translate([i,0,0]) rotate([0,-90,0]) light_pipe(3);

translate([40,0,0]) rotate([0,-90,0]) light_pipe(2);
