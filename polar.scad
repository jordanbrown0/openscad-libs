// Given an [x,y] or [x,y,z], transform to a
// [rho, theta] or [rho, theta, phi].
// Note that in mathematical spherical coordinates,
// phi is measured down from vertical.  This is as
// opposed to geographic coordinates, where latitude
// is measured up from the equator.
function topolar(p) =
    len(p) == 3 ? topolar3(p) : topolar2(p);

function topolar2(p) = [
    norm(p),
    atan2(p.y, p.x)
];

function topolar3(p) = [
    norm(p),
    atan2(p.y, p.x),
    atan2(norm([p.x,p.y]), p.z)
];

// Given a [rho, theta] or [rho, theta, phi], transform to
// an [x,y] or [x,y,z].
function torect(p) =
    len(p) == 3 ? torect3(p) : torect2(p);

function torect2(p) = [
    p[0] * cos(p[1]),
    p[0] * sin(p[1])
];

function torect3(p) = [
    p[0] * cos(p[1]) * sin(p[2]),
    p[0] * sin(p[1]) * sin(p[2]),
    p[0] * cos(p[2])
];

echo(topolar([10,0]));
echo(topolar([10,1]));
echo(topolar([10,10]));
echo(topolar([-10,10]));
echo(topolar([-10,-10]));
echo(topolar([10,-10]));
echo();
echo(topolar([10,0,0]));
echo(topolar([10,1,0]));
echo(topolar([10,10,10]));
echo(topolar([-10,10,10]));
echo(topolar([-10,-10,10]));
echo(topolar([10,-10,10]));
echo();

rho = 100;
for (theta = [0:10:70]) for (phi=[0:10:70]) translate(torect([rho, theta, phi])) cube(1);