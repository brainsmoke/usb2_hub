e=.001;
$fn=50;

module spacer(height, thread_diameter, ring_width)
{
    difference()
    {
        cylinder(height, r=thread_diameter/2+ring_width);
        translate([0,0,-e]) cylinder(height+2*e, r=thread_diameter/2);
    }
}

module hexnut_cutout(height, size)
{
    translate([0,0,-e])
    cylinder(height+2*e, r=size/sqrt(3), $fn=6);
}

module foot(height, thread_diameter, diameter)
{
    difference()
    {
        spacer(height, thread_diameter, (diameter-thread_diameter)/2);
        translate([0,0,height])
        rotate([180,0,0]) 
        children();
    }
}

n_row=2;
n_col=8;

thread=3;
hole_diameter=thread*1.0667;
ring_width=1;
spacer_height=4;

feet_diameter=7.5;
feet_height=2.6;
hexnut_size=5.5;
hexnut_height=2;

padding=1.5;
offset_spacer=hole_diameter+2*ring_width+padding;
offset_feet=feet_diameter+padding;


for (y=[0:n_col-1])
for (x=[0:n_row-1])
    translate([x*offset_spacer,y*offset_spacer,0])
        spacer(spacer_height, hole_diameter, ring_width, $fn=50);

translate([offset_feet/2+(n_row-.5)*offset_spacer,0,0])
for (y=[0:n_col-1])
for (x=[0:n_row-1])
    translate([x*offset_feet,y*offset_feet,0])
        foot(feet_height, hole_diameter, feet_diameter) hexnut_cutout(hexnut_height, hexnut_size);
