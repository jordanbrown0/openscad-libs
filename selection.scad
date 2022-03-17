// Display all of the models in a grid or, if only one is selected,
// leave it at the origin.
module contents(d=100) {
    nx = ceil(sqrt($children));
    ny = ceil($children/nx);
    for (xi=[0:nx-1], yi=[0:ny-1]) {
        i = xi + yi*nx;
        if (i < $children) {
            if (is_undef($content_selected)
                || $content_selected == "all") {
                translate([xi*d, yi*d, 0]) children(i);
            } else {
                children(i);
            }
        }
    }
}

// Render or describe a particular item.
// In normal mode, render the children if this item is selected, or if
// rendering all items.
// In inventory mode, describe the item.
//
// name - item's name
// png - generate a PNG of this item
// stl - generate a STL of this item
// distance, xrot, zrot, z - camera parameters for PNG
module item(name, png=true, stl=true, distance, xrot, zrot, z) {
    if (is_undef($content_inventory)) {
        if (is_undef($content_selected)
            || $content_selected == "all"
            || $content_selected == name) {
                children();
        }
    } else {
        _distance = default(distance, 150);
        _zrot = default(zrot, 30);
        _xrot = default(xrot, 60);
        _z = default(z, 15);
        camera = is_undef(distance) && is_undef(zrot) && is_undef(z) && is_undef(xrot)
            ? "--viewall"
            : str("--camera 0,0,", _z, ",", _xrot, ",0,", _zrot, ",", _distance);
        if ($content_inventory == "all")
            echo("PART", name);
        else if ($content_inventory == "png" && png)
            echo("PART", name, camera);
        else if ($content_inventory == "stl" && stl)
            echo("PART", name);
    }
}

// Render part p of the model if rendering all, or if it's selected.
module ifpart(p) {
    if (is_undef($part) || $part == "all" || $part == p) {
        children();
    }
}

// Render part p of the model only if it's specifically selected.
module ifpartonly(p) {
    if (!is_undef($part) && $part == p) {
        children();
    }
}

// Render the children only if all parts are selected.
module ifpartall() {
    if (is_undef($part) || $part == "all") {
        children();
    }
}

// Render the children if this variation is selected.
// This is really the same as a vanilla "if", but makes
// the intent a little clearer.
module ifvariation(selector, v) {
    if (selector == v) {
        children();
    }
}
