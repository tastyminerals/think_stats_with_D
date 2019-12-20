module thinkstats;

/*
A collection of simple helper functions.
D adaptation of Python thinkstats.py version available here: thinkstats.com/thinkstats.py
*/

import mir.ndslice;
import std.algorithm : map, sort, sum;
import std.array;
import std.conv : to;
import std.range : drop, dropBack;
import std.stdio;
import std.typecons;
import std.random : uniform, Random;

alias MirSlice = Slice!(real*, 2LU, cast(mir_slice_kind) 2);
alias MirArr = mir_slice!(real*, 1LU, cast(mir_slice_kind) 2)[];

// Compute a simple mean of a slice. D std library has a build-in mean which is more sophisticated.
double simpleMean(T)(T[] arr)
{
    return arr.sum / arr.length;
}

// Compute the variance of a slice.
double variance(T)(T[] arr, double mu = 0)
{
    mu = mu == 0 ? arr.simpleMean : mu;
    // return arr.map!(a => (a - mu) ^^ 2).array.simpleMean;
    return arr.map!(a => (a - mu) ^^ 2).array.simpleMean;
}

// Compute and return both simpleMean and variance as a named tuple.
Tuple!(double, "mu", double, "var") meanVar(T)(T[] arr)
{
    alias NamedTuple = Tuple!(double, "mu", double, "var");
    NamedTuple t;
    t.mu = arr.simpleMean;
    t.var = arr.variance(t.mu);
    return t;
}

// Drop min/max values from the head and tail.
T[] trim(T)(T[] arr, double p = 0.01)
{
    const int n = to!int(arr.length * p);
    return arr.sort.drop(n).dropBack(n).array;
}

// Jitter the values by adding a uniform variate (-jitter, jitter).
T[] jitter(T)(T[] arr, double jitter = 0.5)
{
    return arr.map!(a => a + uniform(-jitter, jitter)).array;
}

// Compute trimmed simpleMean of a slice. Sorts the slice as a side-effect.
double trimmedMean(T)(T[] arr, double p = 0.01)
{
    return arr.trim(p).simpleMean;
}

// Compute trimmed simpleMean and variance of a slice. Sorts the slice as a side-effect.
Tuple!(double, "mu", double, "var") trimmedMeanVar(T)(T[] arr, double p = 0.01)
{
    return arr.trim(p).simpleMeanVar;
}

int fac(int i)()
{
    return i * fac!(i - 1)();
}

// template specialization to terminate template function recursion
int fac(int i : 1)()
{
    return 1;
}

// Compute binomial coefficient "n choose k".
// This is a template so it gets executed at compile time.
int binomialCoefficient(int n, int k)()
{
    static if (n <= k)
    {
        return 0;
    }
    else
    {
        return fac!(n) / (fac!(k) * fac!(n - k));
    }
}

struct Interpolator(T)
{
    T[] sortedXs;
    T[] sortedYs;

    T lookup(T)(T x)
    {
        return bisect(x);
    }

    T reverseLookup(T)(T y)
    {
        return bisect(y);
    }

    private T bisect(T x)
    {
        const int idx = this.sortedXs.count!(a => a <= x);
        const double frac = (x - sortedXs[idx - 1]) / (sortedXs[idx] - sortedXs[idx - 1]);
        return sortedYs[idx - 1] + frac * (sortedYs[idx] - sortedYs[idx - 1]);
    }

}

// void main() { }

unittest
{
    assert(variance([1, 2, 3, 2, 1]) == 0.56);
    assert(simpleMeanVar([1, 2, 3, 2, 1]) == tuple(1.8, 0.56));
    assert(trim([1, 2, 3, 2, 1], 0.2) == [1, 2, 2]);
    assert(trimmedMean([1, 2, 3, 2, 1], 0.4) == 2.0);
    assert(binomialCoefficient!(12, 3) == 220);
}
