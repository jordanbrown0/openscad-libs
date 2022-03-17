function default(val, def) = is_undef(val) ? def : val;
function assert_defined(name, val) = assert(!is_undef(val), str(name, " not defined")) val;
function count_defined(a, n)
    = is_undef(n)
        ? count_defined(a, len(a))
        : assert(n >= 0) n == 0
            ? 0
            : count_defined(a, n-1)
                + (is_undef(a[n-1]) ? 0 : 1);

assert(count_defined([]) == 0);
assert(count_defined([0]) == 1);
assert(count_defined([undef, 0]) == 1);
assert(count_defined([0, undef]) == 1);
assert(count_defined([0, false]) == 2);
