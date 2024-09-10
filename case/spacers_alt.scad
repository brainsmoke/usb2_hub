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

module foot(height, thread_diameter, diameter, flange_height, flange_diameter)
{
    translate([0,0,height])
    rotate([180,0,0]) 
    difference()
    {
        union(){
        cylinder(flange_height, r=flange_diameter/2);
        spacer(height, thread_diameter, (diameter-thread_diameter)/2);
        }
        children();
    }
}

module flip(height)
{
    translate([0,0,height])
    rotate([180,0,0])
    children();
}

n_row=4;
n_col=4;

thread=3;
hole_diameter=thread*1.0667;
ring_width=3-hole_diameter/2;
spacer_height=4;

flange_diameter=9.5;
flange_height=0.8;
feet_diameter=7.5;
feet_height=2.6;
hexnut_size=5.5;
hexnut_height=1.8;

padding=1.5;
offset_spacer=hole_diameter+2*ring_width+padding;
offset_feet=flange_diameter+padding;


for (y=[0:n_col-1])
for (x=[0:n_row-1])
    translate([x*offset_spacer,y*offset_spacer,0])
        spacer(spacer_height, hole_diameter, ring_width, $fn=50);


translate([offset_feet/2+(n_row-.5)*offset_spacer,0,0])
for (y=[0:n_col-1])
for (x=[0:n_row-1])
    translate([x*offset_feet,y*offset_feet,0])
        flip(feet_height)
            foot(feet_height, hole_diameter, feet_diameter, flange_height, flange_diameter) hexnut_cutout(hexnut_height, hexnut_size);
