distance = 19.05;
key_1u = 18;

switch_width = 14.1;
switch_depth = 14.1;

values = [ [ 1.25, 1.5, 1.75, 1 ], [ 1, 1, 1, 1 ], [ 1, 1, 1, 1 ], [ 1, 1, 1, 1 ], [ 1, 1, 1, 1 ], [ 2, 1.5, 1, 1.5 ] ];



cumsum = [for (a = 0, b = values[0]; a < len(values); a = a + 1, b = b + (values[a] == undef ? [0] : values[a])) b];


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
        linear_extrude(3) projection() hull() matrix();
        cylinder(10, 6, 10, center = true);
    }
}



module case() {
    difference() {
        shell();
        minkowski(){
            linear_extrude(1)projection()hull()matrix(false);
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



module keyboard() {
    translate([ -190, 30, 0 ]) {
        color("#699") case(); 
        matrix(); 
    }
}



module plate() {
    mirror([ 0, 0, 1 ]) translate([ -190, 30, 0 ]) 
    {
        difference() {
            minkowski(){
                linear_extrude(2)projection()hull()matrix(switches = false);
                cylinder(1, 1.5, 1.5, center = true);
            }
            matrix();
        }
    }
}



rotation = 15;
pitch = 10;
render() {
    rotate([0,0,-rotation])rotate([pitch,0,0])plate();
    rotate([0,0,rotation])rotate([pitch,0,0])mirror([ 1, 0, 0 ]) plate();
}

rotate([0,0,-rotation])rotate([pitch,0,0])keyboard();
rotate([0,0,rotation])rotate([pitch,0,0])mirror([ 1, 0, 0 ]) keyboard();

