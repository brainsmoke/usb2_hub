unfinished


e=.001;
$fn=48;
padding=5;

hole_dist_x = 40;
hole_dist_y = 80;
pcb_height = 1.6;
inner_radius = 4.5;
wall_thickness = 1;
wall_height = 10;
thread = 3;
bottom_thickness = .8;
border_width = 1.;
top_thickness = .8;
top_edge_height = 2.5;
top_edge_width = 1.;
top_edge_margin = 0.;
leg_height = 4;
leg_radius = 2.7;

outer_radius = inner_radius+wall_thickness;
screw_fit_radius = (thread*0.9)/2;

module usb_c()
{
	translate([-10, -9.2/2.+1.25, 0])
		cube([20, 9.2-2.5, 3.2]);
		
	for (y=[-9.2/2.+1.25, 9.2/2.-1.25])
		translate([-10, y, 1.6])
			rotate([0,90,0])
				scale([1.6,1.25,1])
					cylinder(h=20, r=1);
}

module on_pcb()
{
	translate([0,0,bottom_thickness+leg_height+pcb_height]) children();
}

module at_front()
{
	translate([0,hole_dist_y/2,0]) children();
}

module at_holes(x, y)
{
	for (x = [0, hole_dist_x])
		for (y = [0, hole_dist_y])
			translate([x,y,0])
				children();
}

module leg()
{
	difference()
	{
	translate([0,0,-e])
		cylinder(h=leg_height+e, r=leg_radius);
	translate([0,0,-e*2])
		cylinder(h=leg_height+e*3, r=screw_fit_radius);
	}
}

module notched_block(height, radius, notch_size)
{
	translate([notch_size-radius,-radius, 0])
		cube([hole_dist_x-2*(notch_size-radius), hole_dist_y+2*notch_size, height]);
	translate([-notch_size, notch_size-radius, 0])
		cube([hole_dist_x+2*notch_size, hole_dist_y-2*(notch_size-radius), height]);
}

module rounded_block(height, radius)
{
	notched_block(height, radius, radius);
	at_holes() cylinder(h=height, r=radius);
}

module case()
{
	at_holes() translate([0, 0, bottom_thickness])leg();

	difference()
	{
		difference()
		{
			rounded_block(bottom_thickness+wall_height, outer_radius);
			translate([0,0,bottom_thickness]) rounded_block(wall_height+e, inner_radius);
		}
		on_pcb() at_front() usb_c();
	}
}

module top()
{
	rounded_block(top_thickness, outer_radius);
	difference()
	{
		translate([0,0,top_thickness-e])
			rounded_block(top_edge_height+e, inner_radius-top_edge_margin);
		translate([0,0,top_thickness-e*2])
		{
			rounded_block(top_edge_height+e*3, inner_radius-top_edge_margin-top_edge_width);
			notched_block(top_edge_height+e*3, outer_radius+e, 2*outer_radius);
		}
	}
}

module next()
{
	translate([0,hole_dist_y+2*outer_radius+padding, 0]) children();
}

case();
next() top();
