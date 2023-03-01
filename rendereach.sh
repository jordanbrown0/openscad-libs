#! /bin/sh

case $# in
0|1)
    echo "usage: $0 outdir file.scad ..." >&2
    exit 1
    ;;
esac

d="$1"
shift

function parts()
{
    openscad -D "\$content_inventory=\"$2\"" -o junk.stl "$1" 2>&1 |
	tr -d '\r' |
	sed -n -e 's/^ECHO: "PART", "\(.*\)"$/\1/p' |
	sed 's/", "/ /g'
}

for i; do
    base=$(basename "$i" .scad)
    parts $i png |
	while read part camera; do
	    def="\$content_selected=\"$part\""
	    printf "%s %s png...\n" "$base" "$part"
	    openscad -D "$def" $camera -o "$d/$base.$part.png" "$i"
    	done
    parts $i stl |
	while read part; do
	    def="\$content_selected=\"$part\""
	    printf "%s %s stl...\n" "$base" "$part"
	    openscad -D "$def" -o "$d/$base.$part.stl" "$i"
	done
done
