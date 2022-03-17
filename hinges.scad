use <justify.scad>
use <selection.scad>
use <default.scad>

$content_selected = "all"; // [all, filament-1, filament-2, flat, double ]
length=72;
nseg=5; // [3:2:11]
a=0;    // [-180:10:180]

contents() {
    item("filament-1") {
        difference() {
            hinge_filament(length=length, nseg=nseg, a=a, w=20, plate_t=2, corner=false, cut=false, vertical=true, $part="inner");
            hinge_filament(length=length, nseg=nseg, a=a, w=20, plate_t=2, corner=false, cut=true, vertical=true, $part="outer");
        }

        difference() {
            hinge_filament(length=length, nseg=nseg, a=a, w=20, plate_t=2, corner=false, cut=false, vertical=true, $part="outer");
            hinge_filament(length=length, nseg=nseg, a=a, w=20, plate_t=2, corner=false, cut=true, vertical=true, $part="inner");
        }
    }
    item("filament-2") {
        plate_t = 2;
        hinge_t = 2;
        w = 40;
        difference() {
            hinge_filament(length=length, nseg=nseg, a=a, w=w, plate_t=plate_t, hinge_t=hinge_t, corner=false, cut=false, vertical=false, $part="inner");
            hinge_filament(length=length, nseg=nseg, a=a, w=w, plate_t=plate_t, hinge_t=hinge_t, corner=false, cut=true, vertical=false, $part="outer");
        }

        difference() {
            hinge_filament(length=length, nseg=nseg, a=a, w=w, plate_t=plate_t, hinge_t=hinge_t, corner=false, cut=false, vertical=false, $part="outer");
            hinge_filament(length=length, nseg=nseg, a=a, w=w, plate_t=plate_t, hinge_t=hinge_t, corner=false, cut=true, vertical=false, $part="inner");
        }
    }
    item("flat") hinge_flat(h=length, w=20, t=2, nseg=nseg, a=a);
    item("double") hinge_flat_double(h=length, w=10, t=3, nseg=nseg, a=a);
}

// A hinge that uses a piece of filament as a hinge pin.
//
// length - total length of the hinge
// w - total width of the hinge (both sides)
// a - angle between two sides
// nseg - number of segments (odd is best because then you can glue both ends)
// hinge_t - thickness of hinge barrel
// plate_t - thickness of plate (the section that mates to the model)
// fd - filament diameter
// gap - gap between parts and between filament and hinge
// corner - true to set origin to the point where the hinge planes intersect
// cut - true to select the negative object to cut away from the model for
//     hinge clearance.
// pos2 - vec2 of z-start and z-length of plate section
// vertical - true to apply a diagonal cut to make the hinge maybe be printable
//     vertically.  (Not tested in real printing!)
// $part - "outer" to select the odd-numbered segments, "inner" to select the
//     even-numbered segments.  (The names make sense if there's an odd number
//     of segments, but not if there's an even number.)
module hinge_filament(length, w=20, a=0, nseg=5, hinge_t=1, plate_t=1, fd=1.75, gap=0.2, corner=false, cut=false, pos2, vertical=false) {
    module hole_circle() {
        jcircle(id = (fd+gap*2), $fn=8);
    }
    module seg(i, s) {
        fn = cut ? 12 : 4;
        seg_h = cut ? seglen + 2*gap : seglen;
        cut_d = poly_i_to_o(d + 2*gap, 4);
        seg_d = cut ? cut_d : d;
        origin = cut ? [0,0,-gap] : [0,0,0];
        translate(origin+[0,0,(i-1)*(seglen+gap)]) {
            linear_extrude(height=seg_h, convexity=10) {
                difference() {
                    union() {
                        jcircle(id=seg_d, $fn=fn);
                        polygon([
                            [0, -seg_d/2],
                            [s*seg_d/2, -seg_d/2],
                            [s*(seg_d/2+seg_d), seg_d/2],
                            [-s*seg_d/2, seg_d/2],
                            [-s*seg_d/2, 0]
                        ]);
                    }
                    if (!cut) {
                        hole_circle();
                    }
                }
            }
            if (vertical && cut) {
                translate([0,0,seglen]) rotate(0)
                    vertical_printability_cut(s, d, cut_d);
            }
        }
    }
    module plate(s, pos) {
        pos = default(pos, [0, length]);
        or = poly_i_to_o(d, 8)/2;
        translate([s*(or+gap), d/2, pos[0]])
            jcube([w/2 - (or+gap), plate_t, pos[1]], j=[s, -1, 1]);
    }
    module vertical_printability_cut(s, d, cut_d) {
        rotate([90,0,90+s*90]) linear_extrude(height=d*3, center=true) {
            translate([-cut_d/2,0,0]) polygon([
                [0,0],
                [cut_d, 0],
                [0, cut_d]
            ]);
        }
    }
    module segs(start, s, pos) {
        for (i = [start:2:nseg]) {
            seg(i, s);
        }
        if (cut) {
            // NEEDSWORK is this necessary, given the hole_circle()
            // above?  Or maybe that's not necessary?
            hole();
        } else {
            plate(s, pos);
        }
    }
    module outer() {
        segs(1, 1);
    }
    module inner() {
        segs(2, -1, pos=pos2);
    }
    module hole() {
        translate([0,0,-1]) {
            linear_extrude(height=length+2) hole_circle();
        }
    }
    
    seglen = (length - gap*(nseg-1)) / nseg;
    d = fd + 2*(gap+hinge_t);

    if (corner) {
        assert(a < 180);
    }

    origin = corner ? [d/2*tan(a/2),-d/2,0]
        : [ 0,0,0 ];
    
    translate(origin) {
        ifpart("outer") {
            rotate(cut ? a : 0) /*color("red")*/ outer();
        }
        ifpart("inner") {
            rotate(cut ? 0 : a) {
                /*color("blue")*/ inner();
            }
        }
        ifpartonly("hole") color("black") {
            hole();
        }
    }
}

// A simple flat print-in-place hinge that uses cones for hinge pins
//
// h - total height of the hinge
// w - width of each side of the hinge
// t - thickness of the hinge
// overlap - amount that the two sides overlap in the middle
// xgap - gap between the two sides in X
// ygap - gap between the two sides in Y
// nseg - number of segments
// pin_h - height of the pin cones
// pin_gap gap between the pin cone and the hollow it fits into
// pin_t - diameter of the base of the pin cones
module hinge_flat(h, w, t, overlap, xgap=0.4, ygap=0.2, nseg=3, pin_h, pin_gap=0.2, pin_t, a=0) {
    overlap = default(overlap, t);
    pin_h = default(pin_h, t/2);
    pin_t = default(pin_t, t-pin_gap*2);

    seglen = (h - (nseg-1)*ygap)/nseg;

    difference() {
        union() {
            // Fingers from +X that extend into -X
            for (i = [1:2:nseg]) {
                translate([-overlap/2,(i-1)*(seglen+ygap),0])
                    jcube([w, seglen, t], j=[1,1,0]);
            }
            // Fingers from -X that extend into +X
            rotate([0,a,0]) for (i = [2:2:nseg]) {
                translate([overlap/2, (i-1)*(seglen+ygap), 0])
                    jcube([w, seglen, t], j=[-1,1,0]);
            }
        }
        // hollows for the pins
        for (i=[2:nseg]) {
            translate([0, (i-1)*(seglen+ygap), 0])
                rotate([-90,0,0]) cylinder(h=pin_h+pin_gap, d1=pin_t+pin_gap*2, d2=0);
        }
    }

    // +X plate
    translate([overlap/2+xgap, 0,0])
        jcube([w-overlap/2-xgap, h, t], j=[1,1,0]);
    // -X plate
    rotate([0,a,0]) translate([-overlap/2-xgap, 0, 0])
        jcube([w-overlap/2-xgap, h, t], j=[-1,1,0]);

    // Pins
    for (i = [1:nseg-1]) {
        translate([0, seglen + (i-1)*(seglen+ygap), 0]) {
            rotate([-90,0,0]) cylinder(h=pin_h, d1=pin_t, d2=0);
        }
    }
}

// A double print-in-place hinge (can be folded all the way to 180 degrees).
// Uses cones for pins.
//
// h - total height of the hinge
// w - width of each side of the hinge
// t - thickness of the hinge
// overlap - amount that the sides overlap with the middle pieces
// xgap - gap between the two sides in X
// ygap - gap between the two sides in Y
// nseg - number of segments (must be odd)
// pin_h - height of the pin cones
// pin_gap gap between the pin cone and the hollow it fits into
// pin_t - diameter of the base of the pin cones
// middle - gap between the sides when folded to 180 degrees
module hinge_flat_double(h, w, t, overlap, xgap=0.4, ygap=0.2, nseg=3, pin_h, pin_gap=0.2, pin_t, middle=0.4, a=0) {
    assert(nseg > 2);
    assert(nseg%2 == 1, "nseg must be odd");

    overlap = default(overlap, t);
    pin_h = default(pin_h, t/2);
    pin_t = default(pin_t, t-pin_gap*2);

    seglen = (h - (nseg-1)*ygap)/nseg;

    difference() {
        union() {
            // for each side
            for (s = [-1,1]) {
                // Fingers that extend to the middle
                for (i = [1:2:nseg]) {
                    dx = xgap/2;
                    translate([s*dx,(i-1)*(seglen+ygap),0])
                        jcube([w-dx, seglen, t], j=[s,1,1]);
                }
                // Plate.  (Union is just for variable scoping, and
                // to have a consistent pattern.)
                union () {
                    dx = middle/2 + overlap + xgap;
                    translate([s*dx, 0, 0])
                        jcube([w-dx, h, t], j=[s,1,1]);
                }
            }
            // Floating pieces in the middle
            for (i = [2:2:nseg]) {
                translate([0, (i-1)*(seglen+ygap), 0])
                    jcube([overlap+middle+overlap, seglen, t], j=[0,1,1]);
            }
        }
        // Hollows for the pins
        for (s=[-1,1], i=[2:nseg]) {
            dx = middle/2 + overlap/2;
            translate([s*dx, (i-1)*(seglen+ygap), t/2])
                rotate([-90,0,0]) cylinder(h=pin_h+pin_gap, d1=pin_t+pin_gap*2, d2=0);
        }
    }

    // Pins
    for (s=[-1,1], i = [1:nseg-1]) {
        dx = middle/2 + overlap/2;
        translate([s*dx, seglen + (i-1)*(seglen+ygap), t/2]) {
            rotate([-90,0,0]) cylinder(h=pin_h, d1=pin_t, d2=0);
        }
    }
}
