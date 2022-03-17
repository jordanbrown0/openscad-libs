use <justify.scad>

inch = 1;
lumber2 = 1.5*inch;
lumber3 = 2.5*inch;
lumber4 = 3.5*inch;
lumber6 = 5.5*inch;
lumber8 = 7.25*inch;

function lumber2() = lumber2;
function lumber3() = lumber3;
function lumber4() = lumber4;
function lumber6() = lumber6;
function lumber8() = lumber8;

module 2x3(length, j) {
    dims=[length, lumber3, lumber2];
    lumber(j=j, dims=dims);
}
module 2x4(length, j) {
    dims=[length, lumber4, lumber2];
    lumber(j=j, dims=dims);
}
module 2x6(length, j) {
    dims=[length, lumber6, lumber2];
    lumber(j=j, dims=dims);
}
module 2x8(length, j) {
    dims=[length, lumber8, lumber2];
    lumber(j=j, dims=dims);
}
module 4x4(length, j) {
    dims=[length, lumberfour, lumbertwo];
    lumber(j=j, dims=dims);
}

module lumber(dims, j) {
    chamfer = inch/8;
    color("SandyBrown")
        justify(bb=dims, j=j)
        rotate([90,0,90])
        linear_extrude(height=dims.x) {
        polygon([
            [chamfer,0],
            [dims.y - chamfer, 0],
            [dims.y, chamfer],
            [dims.y, dims.z - chamfer],
            [dims.y - chamfer, dims.z],
            [chamfer, dims.z],
            [0, dims.z - chamfer],
            [0, chamfer]
        ]);
    }
}

//scale(1/inch) lumber([96*inch,3.5*inch,1.5*inch]);
//scale(1/inch) 2x4(96*inch);