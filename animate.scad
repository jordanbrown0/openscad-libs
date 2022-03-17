// Given a value and a table of value/position pairs, interpolate a
// position for that value.
// It seems like lookup() should do this sort of vector interpolation
// on its own, but it doesn't seem to.
function xyzinterp(v, table) =
    let (x= [for (i=[0:len(table)-1]) [table[i][0], table[i][1][0]]])
    let (y= [for (i=[0:len(table)-1]) [table[i][0], table[i][1][1]]])
    let (z= [for (i=[0:len(table)-1]) [table[i][0], table[i][1][2]]])
        [lookup(v, x), lookup(v, y), lookup(v,z)];

// Given a table of animation time values (from zero to one) and
// positions for each of those time values, translate the children
// to the appropriate position.
module atranslate(table) {
    translate(xyzinterp($t, table)) children();
}

// Given a table of animation time values (from zero to one) and
// rotations for each of those time values, rotate the children
// to the appropriate position.
module arotate(table) {
    rotate(xyzinterp($t, table)) children();
}

// Given a start point and an end point, translate the children
// from the start to the end and back in each animation cycle.
// Pause briefly at the start and end.
module a2translate(p1, p2) {
    atranslate([[0.05, p1], [0.45, p2], [0.55, p2], [0.95, p1]]) children();
}

// Given a start rotation and an end rotation, rotate the children
// from the start to the end and back in each animation cycle.
// Pause briefly at the start and end.
module a2rotate(p1, p2) {
    arotate([[0.05, p1], [0.45, p2], [0.55, p2], [0.95, p1]]) children();
}

