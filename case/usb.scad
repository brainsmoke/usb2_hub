e=.001;
$fn=48;

usb_c_depth = 7.35;
usb_c_width = 8.45;
usb_c_height = 2.56;
usb_c_z = .25;
usb_c_edge_radius = .93;
usb_c_front_from_origin = 6.77-3.13;
usb_c_plug_end = 1.77-3.13;

usb_c_plug_depth = 7;
usb_c_plug_width = 8;
usb_c_plug_height = 2;

usb_c_plug_shroud_width = 12.5;
usb_c_plug_shroud_height = 6.25;
usb_c_plug_shroud_depth = 15;
usb_c_plug_shroud_radius = .5;

usb_a_depth = 10;
usb_a_width = 13.2;
usb_a_height = 5.7;
usb_a_edge_radius = .5;
usb_a_z = 1.;
usb_a_overlap = .65;
usb_a_plastic_depth = 4.5;
usb_a_plastic_width = 14.5;
usb_a_plastic_height = 4;
usb_a_plastic_z = usb_a_z + 1.;



usb_a_plug_depth = 12.5;
usb_a_plug_width = 12.1;
usb_a_plug_height = 4.5;
usb_a_plug_radius = .5;
usb_a_plug_end = -8;

usb_a_plug_shroud_width = 16;
usb_a_plug_shroud_height = 8;
usb_a_plug_shroud_depth = 25;
usb_a_plug_shroud_radius = .5;

module rounded_rect(w, h, r, center=false)
{
	off_x = center ? w/2 : 0 ;
	off_y = center ? h/2 : 0 ;
	hull()
	{
		for (x=[r,w-r])
		for (y=[r,h-r])
		translate([off_x+x,off_y+y])
		circle(r=r);
	}
}

module usb_c_keepout()
{
	color([.9,.9,.9])
	{
		translate([-10, -9.2/2.+1.25, 0])
			cube([20, 9.2-2.5, 3.2]);
		
		for (y=[-9.2/2.+1.25, 9.2/2.-1.25])
			translate([-10, y, 1.6])
				rotate([0,90,0])
					scale([1.6,1.25,1])
						cylinder(h=20, r=1);
	}
}

module usb_c_plug(margin=0)
{
color([.97,.97,.97])

translate([-usb_c_plug_width/2-margin,
            usb_c_plug_depth+margin,
           -usb_c_plug_height/2-margin ])
rotate([90,0,0])
linear_extrude(usb_c_plug_depth+2*margin+e) rounded_rect(usb_c_plug_width+2*margin, usb_c_plug_height+2*margin, usb_c_plug_height/2+margin);
	
color([.3,.3,.3])

translate([-usb_c_plug_shroud_width/2-margin,
            usb_c_plug_depth+usb_c_plug_shroud_depth+margin,
           -usb_c_plug_shroud_height/2-margin ])
rotate([90,0,0])
linear_extrude(usb_c_plug_shroud_depth+2*margin+e) rounded_rect(usb_c_plug_shroud_width+2*margin, usb_c_plug_shroud_height+2*margin, usb_c_plug_shroud_radius+margin);
	

}

module usb_c_type_c31_m12(margin=0)
{
	translate([0,0,usb_c_z])
	{
		color([.9,.9,.9])
			translate([-usb_c_width/2-margin,usb_c_front_from_origin+margin,-margin ])
				rotate([90,0,0])
					linear_extrude(usb_c_depth+2*margin) rounded_rect(usb_c_width+2*margin, usb_c_height+2*margin, usb_c_edge_radius+margin);

		translate([0,usb_c_plug_end,usb_c_height/2])
			children();
	}
}


module usb_a_shou_han(margin=0)
{
	color([.9,.9,.9])
	{
translate([-usb_a_width/2-margin,usb_a_overlap+margin,usb_a_z -margin ])
rotate([90,0,0])
linear_extrude(usb_a_depth+2*margin) rounded_rect(usb_a_width+2*margin, usb_a_height+2*margin, usb_a_edge_radius+margin);
	}
	color([.1,.1,.1])
	{
translate([-usb_a_plastic_width/2-margin,usb_a_overlap+margin-usb_a_depth+usb_a_plastic_depth+e,usb_a_plastic_z -margin ])
rotate([90,0,0])
cube([usb_a_plastic_width+2*margin, usb_a_plastic_height+2*margin, usb_a_plastic_depth+2*margin]);
	}
	translate([0,usb_a_plug_end/*+8.65*/,usb_a_height/2+usb_a_z]) children();

}


module usb_a_plug(margin=0)
{
color([.97,.97,.97])

translate([-usb_a_plug_width/2-margin,
            usb_a_plug_depth+margin,
           -usb_a_plug_height/2-margin ])
rotate([90,0,0])
linear_extrude(usb_a_plug_depth+2*margin+e) rounded_rect(usb_a_plug_width+2*margin, usb_a_plug_height+2*margin, usb_a_plug_radius+margin);
	
color([.3,.3,.3])

translate([-usb_a_plug_shroud_width/2-margin,
            usb_a_plug_depth+usb_a_plug_shroud_depth+margin,
           -usb_a_plug_shroud_height/2-margin ])
rotate([90,0,0])
linear_extrude(usb_a_plug_shroud_depth+2*margin+e) rounded_rect(usb_a_plug_shroud_width+2*margin, usb_a_plug_shroud_height+2*margin,usb_a_plug_shroud_radius+margin);
	

}


translate([20,0,0])usb_c_type_c31_m12(margin=0) usb_c_plug(margin=0);

usb_a_shou_han(margin=0) usb_a_plug(margin=0);
