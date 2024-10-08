e=.001;
$fn=48;
padding=5;

use <usb.scad>

hole_dist_x = 40;
hole_dist_y = 80;
pcb_thickness = 1.6;
pcb_radius = 3;
inner_radius = 4;
wall_thickness = 1;
wall_height = 9.6;
thread = 3;
bottom_thickness = .8;
border_width = 1.;
top_thickness = .8;
top_edge_height = 2.5;
top_edge_width = 1.;
top_edge_margin = 0.;
top_grid_height = 2;
grid_width=.8;
leg_height = .6;
leg_radius = 2.7;
usb_c_board_offset = 3; // based on kicad position
screw_tension_gap = 0;


lightpipe_width = 2.5;
lightpipe_height = 1.6;
lightpipe_bar_width = 2.2;
lightpipe_guide_thickness = 2;
lightpipe_guide_border = 1;

led_pitch = 2.1;
led_x = hole_dist_x;

led_clearance = 1.8;
outer_radius = inner_radius+wall_thickness;
screw_fit_radius = (thread*0.9)/2;
total_height = bottom_thickness+wall_height+top_thickness;
component_z = bottom_thickness+leg_height+pcb_thickness;

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


module preview()
{
	if ($preview) children();
}

module usb_c(margin=0)
{
	translate([0,-usb_c_board_offset,0]) 
	usb_c_type_c31_m12(margin) usb_c_plug(margin);
}

module usb_a(margin=0)
{
	usb_a_shou_han(margin) usb_a_plug(margin);
}

module usb_a_keepout()
{
	usb_a_shou_han(.25) usb_a_plug(.5);
}

module usb_c_keepout()
{
	usb_c(margin=.5);
}

module on_pcb()
{
	translate([0,0,component_z]) children();
}

module at_front()
{
	translate([hole_dist_x+pcb_radius,hole_dist_y/2,0]) rotate([0,0,-90])  children();
}

module at_top()
{
	translate([hole_dist_x/2,hole_dist_y+pcb_radius,0]) children();
}

module usb_a_locations()
{
	at_front() for (x=[-30,-10,10,30] ) translate([x, 0, 0]) children();
}

module led_locations()
{
	for (dy=[-30,-10,10,30] ) translate([0, hole_dist_y/2+dy, 0]) children();
}

module at_holes(x, y)
{
	for (x = [0, hole_dist_x])
		for (y = [0, hole_dist_y])
			translate([x,y,0])
				children();
}

module leg(h)
{
	difference()
	{
	translate([0,0,-e])
		cylinder(h=h+e, r=leg_radius);
	translate([0,0,-e*2])
		cylinder(h=h+e*3, r=screw_fit_radius);
	}
}

module pcb()
{
	translate([0,0,bottom_thickness+leg_height])
		color("green")
			rounded_block(pcb_thickness, pcb_radius);
}

module h_grid(n, pitch, depth, w, h)
{
	translate([-w/2,-depth/2, 0])
		for (i=[0:n-1])
			translate([(i-(n-1)/2)*pitch,0,0])
				cube([w, depth, h]);
}

module grid(w, h, n_rows, row_pitch, n_cols, col_pitch, bar_w, bar_h)
{
	translate([hole_dist_x/2,hole_dist_y/2,0])
	{
		h_grid(n_rows, row_pitch, h, bar_w, bar_h);
		rotate([0,0,90])
		h_grid(n_cols, col_pitch, w, bar_w, bar_h);
	}
}


module case()
{
	at_holes() translate([0, 0, bottom_thickness])leg(leg_height);

	difference()
	{
		difference()
		{
			rounded_block(bottom_thickness+wall_height, outer_radius);
			translate([0,0,bottom_thickness]) rounded_block(wall_height+e, inner_radius);
		}
		union()
		{
			at_holes() translate([0,0,-e]) cylinder(bottom_thickness+2*e, r=screw_fit_radius);
			on_pcb()
			{
				at_top() usb_c_keepout();
				usb_a_locations() usb_a_keepout();
			}
		}
	}

	translate([0,0,bottom_thickness-e]) grid(hole_dist_x+(outer_radius-e)*2, hole_dist_y+(outer_radius-e)*2, 4, 10, 7, 10, grid_width, leg_height+e);
}

module light_pipe_keepout(n_leds)
{
	for (i=[0:n_leds-1])
	{
		dy = (i-(n_leds-1)/2)*led_pitch;
		w = lightpipe_width;
		h = lightpipe_height;
		z = total_height-top_thickness;
		translate([-w/2, -h/2+dy, z-e]) 
			cube( [w,h,top_thickness+e*2] );
	}
	w = lightpipe_bar_width;
	h = led_pitch*(n_leds-1)+lightpipe_height+lightpipe_guide_border*2;
	z = component_z + led_clearance;
    d = total_height-top_thickness-z;

	translate([-w/2,-h/2-e,z-e]) 
		cube([w, h+2*e, d+e]);

}

module light_pipe(n_leds)
{
color("#f0f0f0")
{

	for (i=[0:n_leds-1])
	{
		dy = (i-(n_leds-1)/2)*led_pitch;
		w = lightpipe_bar_width*.8;
		h = lightpipe_height*.8;
		z = component_z + led_clearance;
		translate([-w/2, -h/2+dy, z-e]) 
			cube( [w,h,total_height-z] );
	}
	w = .4;
	h = led_pitch*(n_leds-1)+lightpipe_height+lightpipe_guide_border*2;
    d = 1.9;
	z = total_height-top_thickness-d;

	translate([-lightpipe_bar_width*.8/2,-h/2-e,z-e]) 
		cube([w, h+2*e, d+e]);

}
}

module light_pipe_guide(n_leds)
{
	w = lightpipe_width+lightpipe_guide_border*2;
	h = led_pitch*(n_leds-1)+lightpipe_height+lightpipe_guide_border*2;
	d = lightpipe_guide_thickness;
	z = wall_height+bottom_thickness-lightpipe_guide_thickness;
	translate([-w/2,-h/2,z]) 
		cube([w, h, d+e]);
}

module leds_hub()
{
	translate([6,hole_dist_y,0])
		children();
}


module top()
{
	difference()
	{
		union()
		{
		translate([0,0,bottom_thickness+wall_height])
		{
			translate([0,0,-top_grid_height]) grid(hole_dist_x+(inner_radius+e)*2, hole_dist_y+(inner_radius+e)*2, 4, 10, 7, 10, grid_width, top_grid_height+e);

			rounded_block(top_thickness, outer_radius);
			difference()
			{
				translate([0,0,-top_edge_height])
				rounded_block(top_edge_height+e, inner_radius-top_edge_margin);
				translate([0,0,-top_edge_height-e])
				rounded_block(top_edge_height+2*e, inner_radius-top_edge_margin-top_edge_width);
			}
		}
			on_pcb() translate([0,0,screw_tension_gap]) at_holes() leg(wall_height-pcb_thickness-leg_height+e);
			led_locations() light_pipe_guide(3);
			leds_hub() light_pipe_guide(2);
		}

		union()
		{
		on_pcb()
		{
			at_top() usb_c_keepout();
			usb_a_locations() usb_a_keepout();
		}
		led_locations() light_pipe_keepout(3);
		leds_hub() light_pipe_keepout(2);
		}
	}
}

module flip()
{
	translate([0,hole_dist_y,bottom_thickness+wall_height+top_thickness]) rotate([180,0,0]) children();
}

module next()
{
	translate([-hole_dist_x-2*outer_radius-padding,0 , 0]) children();
}

preview()
{
	pcb();
	on_pcb()
	{
		at_top() usb_c();
		usb_a_locations() usb_a();
	}
	flip()
	next()
	{
		led_locations() light_pipe(3);
		leds_hub() light_pipe(2);
	}
}

case();
next() 
flip()
top();
