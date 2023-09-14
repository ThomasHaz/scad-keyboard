/* [Leave as Default] */
// default: 19.05
distance = 19.05; // 0.01
// default: 18
key_1u = 18; // 0.01
// default: 14
switch_width = 14; // 0.01
// default: 14
switch_depth = 14; // 0.01

/* [Config Options] */

// smoother outer edge
hull = false;

// outter support
rim_width = 3; // 0.1
// space under plate
rim_height = 2; // 0.1

/* [Display Options] */
display_matrix = true;
display_keys = true;
display_switches = true;

rotation = 12;
pitch = 0;

cross_section = false;
cross_section_offset = 0;


col1 = [ 1.25, 1.5, 1.75, 1 ]; // 0.25
col2 = [ 1, 1, 1, 1 ]; // 0.25
col3 = [ 1, 1, 1, 1 ]; // 0.25
col4 = [ 1, 1, 1, 1 ]; // 0.25
col5 = [ 1, 1, 1, 1 ]; // 0.25
col6 = [ 2, 1.5, 1, 1.5 ]; // 0.25

values = [ col1, col2, col3, col4, col5, col6 ];


cumsum = [for (a = 0, b = values[0]; a < len(values); a = a + 1, b = b + (values[a] == undef ? [0] : values[a])) b];

function plate_offset(o) = o - 1;

function key(u) = key_1u + distance * (u - 1);




module keycap(u = 1)
{
    translate([ 0, 0, 8 ]) cube([ key(u), key(1), 7 ], center = true);
}



module switch_hole()
{
    intersection()
    {
        cube([ distance - 2, distance - 1, 7 ], center = true);
        union()
        {
            cube([ switch_width, switch_depth, 10 ], center = true);
            translate([ 0, 6, 1.2 ]) rotate([ 45, 0, 0 ]) cube([ 6, 10, 5 ], center = true);
            mirror([ 0, 1, 0 ]) translate([ 0, 6, 1.2 ]) rotate([ 45, 0, 0 ]) cube([ 6, 10, 5 ], center = true);
        }
    }
}



module shell()
{
    mirror([ 0, 0, 1 ]) minkowski()
    {
        linear_extrude(3) projection() {
            if(hull) {
                hull() matrix();
            } else {
                matrix();
            }
        }
        cylinder(10, 6, 10, center = true);
    }
}



module case() {
    difference() {
        shell();
        minkowski(){
            linear_extrude(1) projection() {
                if(hull) {
                    hull() matrix(false);
                } else {
                    matrix(false);
                }
            }
            cylinder(9, 1.5, 1.5, center = true);
        }
    }
}




module matrix(switches = true, keycaps = true) {

    for (a = [ 1 : len(values) ])
    {
        row = values[a - 1];

        for (b = [1:len(row)])
        {
            translate([ distance + key(cumsum[a - 1][b - 1] - values[a - 1][b - 1]), b * distance, 0 ])
            {
                translate([ key(values[a - 1][b - 1]) / 2, 0, 0 ])
                {
                    if (values[a - 1][b - 1] >= 1)
                    {
                        if (switches)
                        {
                            switch_hole();
                        }
                        if (keycaps) {
                            color("#fff") keycap(values[a - 1][b - 1]);
                        }
                    }
                }
            }
        }
    }
}



module keyboard(matrix = display_matrix, case = true, rim = true ) {
    translate([ -190, 30, 0 ]) {
        if (case)
            color("#699") case();
        if(matrix)
            translate([0,0,plate_offset(rim_height)])matrix(switches = display_switches, keycaps = display_keys); 
        if (rim) 
            rim();
    }
}



module plate() {
    mirror([ 0, 0, 1 ]) translate([ -190, 30, 0 ]) 
    {
        difference() {
            minkowski(){
                linear_extrude(3)projection() {
                    if(hull) {
                        hull() matrix(switches = false);
                    } else {
                        matrix(switches = false);
                    }
                }
                cylinder(1, 1.5, 1.5, center = true);
            }
            matrix();
        }
    }
}

module rim(rim_offset = -rim_width) {
    module x() {
        offset(2)projection() 
        {
            if(hull) 
            {
                hull() matrix(switches = true, keycaps = true);
            } else {
                matrix(switches = true);
            }
        }
    }
    
    module keys() {
        projection() {
            matrix(keycaps = false);
        }
    }
    
    
    translate([0,0,-4.5])linear_extrude(rim_height)difference() {
    x();
    offset(rim_offset)x();
    keys();
    }
    //matrix(keycaps = false);
    
    
}





module arrange_plates() {
    rotate([0,0,-rotation])rotate([pitch,0,0]) plate();
    rotate([0,0,rotation])rotate([pitch,0,0])mirror([ 1, 0, 0 ]) plate();
}

module arrange_cases() {
    rotate([0,0,-rotation])rotate([pitch,0,0]) keyboard(matrix = display_matrix);
    
    rotate([0,0,rotation])rotate([pitch,0,0])mirror([ 1, 0, 0 ])keyboard(matrix = display_matrix);
}

module intersect() {
    translate([0, cross_section_offset, 0])color("#fff")cube([500, 200, 100], center = true);
}
intersection() {
if(cross_section)intersect();
arrange_cases();
}
render() {
    translate([0,0,plate_offset(rim_height)]) intersection() {
        if(cross_section)intersect();
         arrange_plates();
    }
}
