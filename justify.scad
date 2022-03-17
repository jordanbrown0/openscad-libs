use <default.scad>

// @brief       Given an [x,y] or an [x,y,z], return an [x,y,z].
// @param   a   A two- or three- element array
// @returns     A three-element array
function make3(a) =
    assert(len(a) == 2 || len(a) == 3)
    len(a) == 3 ? a : concat(a, 0);
    
// @brief       Given an [x,y] or an [x,y,z], return an [x,y],
//              discarding z.
// @param   a   A two- or three- element array
// @returns     A two-element array
function make2(a) =
    assert(len(a) == 2 || len(a) == 3)
    [ a[0], a[1] ];
    
// @brief        Justify children as specified by argument.
// @param center Equivalent to justify=[0,0,0].
// @param j      [jx,jy,jz]:
//                   +1 toward-positive
//                    0 center
//                   -1 toward-negative
// @param bb     Bounding box:
//                   [dimx,dimy,dimz]
//                   [ [ox,oy,oz], [dimx,dimy,dimz] ]
// @children     Object(s) to be justified.
// @note Works for two- or three- dimensional objects.
// @note If more than one object is supplied as a child, they
//       are all justified en mass with respect to the specified
//       bounding box.
module justify(center, j, bb) {
    origin = make3(
        assert(is_list(bb))
        is_list(bb[0])
            ? assert(len(bb) == 2) bb[0]
            : [0,0,0]
    );
    dims = make3(
            is_list(bb[0])
                ? bb[1]
                : bb
    );
    j = make3(default(j, center ? [0,0,0] : [1,1,1]));
    function o(flag, dim) = flag > 0 ? 0 :
        flag < 0 ? -dim :
        -dim/2;
    translate([o(j[0], dims[0]),
        o(j[1], dims[1]),
        o(j[2], dims[2])])
        translate(-origin)  // Move BB minima to [0,0,0]
        children();
}


// @brief        A justified cube
// @param dims   Dimensions of the cube
// @param center Equivalent to j=[0,0,0]
// @param j      As for justify() above
module jcube(dims, center, j) {
    justify(center=center, j=j, bb=dims) cube(dims);
}

module jsquare(dims, center, j) {
    justify(center=center, j=j, bb=dims) square(dims);
}

// OpenSCAD polygons have their radius/diameter
// measured to the vertices.  These functions
// give you the OD given the ID, and vice versa.
function poly_i_to_o(r, n) = r / cos(360/n/2);
function poly_o_to_i(r, n) = r * cos(360/n/2);

function _jcircle_assert_args(name, d, r, id, od, ir, or, d1, r1, id1, ir1, od1, or1) =
    let (c = count_defined([d, r, id, od, ir, or, d1, r1, id1, ir1, od1, or1]))
    assert(c > 0, str(name, ": no parameters"))
    assert(c < 2, str(name, ": too many parameters"))
    undef;

function _jcircle_diameter(name, fn, d, r, id, od, ir, or, d1, r1, id1, ir1, od1, or1)
        = let(junk=_jcircle_assert_args(name=name, d=d, r=r, id=id, od=od, ir=ir, or=or, d1=d1, r1=r1, id1=id1, ir1=ir1, od1=od1, or1=or1))
        !is_undef(od1) ? od1
        : !is_undef(id1) ? poly_i_to_o(id1, fn)
        : !is_undef(or1) ? or1*2
        : !is_undef(ir1) ? poly_i_to_o(ir1, fn)*2
        : !is_undef(d1) ? d1
        : !is_undef(r1) ? r1*2
        : !is_undef(od) ? od
        : !is_undef(id) ? poly_i_to_o(id, fn)
        : !is_undef(or) ? or*2
        : !is_undef(ir) ? poly_i_to_o(ir, fn)*2
        : !is_undef(d) ? d
        : !is_undef(r) ? r*2
        : undef;

// NEEDSWORK needs a j parameter, but note that the j parameter does
// not behave like a normal j.  j=0 needs to put the origin on the center of
// the circle, not on the midpoint of the bounding box.  The two are in
// different places when the number of sides is odd.
// With fn = n*4+2, the top and bottom faces are horizontal, and the left and right sides are vertices.  (Or the other way around, depending on rotation.)  Need to figure out which, and how justification interacts.
module jcircle(d, r, id, od, ir, or, j) {
    fn = !$fn ? 60 : $fn;
    d = _jcircle_diameter(name="d", fn=fn, d=d, r=r, id=id, od=od, ir=ir, or=or);
    vertex_mode = !is_undef(or) || !is_undef(od);
    rotate(vertex_mode ? 0 : 360/$fn/2) circle(d=d);
}

module jcylinder(h, d, r, id, od, ir, or, d1, d2, r1, r2, id1, id2, ir1, ir2, od1, od2, or1, or2, j) {
    fn = !$fn ? 60 : $fn;
    d1 = _jcircle_diameter(name="d1", fn=fn, d=d, r=r, id=id, od=od, ir=ir, or=or, d1=d1, r1=r1, id1=id1, ir1=ir1, od1=od1, or1=or1);
    d2 = _jcircle_diameter(name="d2", fn=fn, d=d, r=r, id=id, od=od, ir=ir, or=or, d1=d2, r1=r2, id1=id2, ir1=ir2, od1=od2, or1=or2);
    rotate([0,0,360/fn/2]) cylinder(h=h, d1=d1, d2=d2, $fn=fn);
}
// NEEDSWORK with odd (or non-multiple-of-4?) sides justification is
// not symmetrical.
// NEEDSWORK with $fn undefined you need the dimensions to derive it.
!jcylinder(h=10, od=10, $fn=6);

// Test/demos
for (xj=[-1:1], yj=[-1:1], zj=[-1:1]) {
    justify(j=[xj,yj,zj], bb=[[-10,-10,-10],[20,20,20]])
        color([(xj+1)/2, (yj+1)/2, (zj+1)/2]) sphere(r=10);
}

translate([30,0]) for (xj=[-1:1], yj=[-1:1]) {
    justify(j=[xj,yj], bb=[[-10,-10],[10,10]])
        color([(xj+1)/2, (yj+1)/2, 0]) circle(r=10);
}
