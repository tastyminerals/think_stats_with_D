module utils.pmf;

/*
Map (value -> getValuency map) and PMF (value -> probability map) implementations (CLI verision).
D adaptation of Python Pmf.py version available here: thinkstats.com/Pmf.py
Here we use just one struct that can represent both Hisogram and PMF.
*/
import std.stdio;
import std.algorithm : canFind, each, joiner, map, maxElement, sort, sum;
import std.array;
import std.conv : to;
import std.format;
import std.math : exp, log;
import std.random : uniform;
import std.range;
import std.typecons : Tuple, tuple;

/// General struct to represent both Histogram and PMF
struct Map
{
    /// A simple array that is used to initialize associative array "dict"
    real[] data;
    /// Associative array that is initialized from "data" if empty
    real[real] dict;
    /// An arbitrary name of the struct
    string name;

    /// Histogram and PMF constructor
    this(real[] arr, real[real] aarr, string name)
    {
        this.name = name;
        this.data = arr;
        this.dict = aarr;
        if (this.dict is null)
        {
            this.data.each!(a => ++this.dict[a]);
        }
    }

    this(this)
    {
        data = data.dup;
        dict = dict.dup;
    }

    // get the getValuency of a given x value
    real getVal(real x)
    {
        return this.dict.get(x, 0);
    }

    /// Get an unsorted sequence of frequencies/probabilities
    auto values()
    {
        return this.dict.byValue;
    }

    /// Checks whether the keys of a given Map are a subset of the current one
    bool isSubset(Map otherHist)
    {
        return canFind(this.data, otherHist.data);
    }

    /// Get an unsorted sequence of keys
    auto keys()
    {
        return this.dict.byKey;
    }

    /// Get a sequence of key -> value pairs
    auto items()
    {
        return this.dict.byKeyValue;
    }

    /// Generate a sorted sequence of points suitable for plotting
    SortedRange!(Tuple!(real, real)[]) render() pure
    {
        return this.dict.byPair.map!(p => tuple(p.key, p.value)).array.sort;
    }

    string toString() const
    {
        return this.render.map!(t => format("%s -> %s", t[0], t[1])).array.joiner("\n").to!string;
    }

    /// Given x key set its value
    void set(real x, real y = 0)
    {
        this.dict[x] = y;
    }

    /// Given x key increment its value
    void incr(real x, real term = 1)
    {
        this.dict[x] += term;
    }

    /// Substract the keys of a given Map from this Map
    void substactMap(Map otherHist)
    {
        foreach (pair; otherHist.items)
        {
            incr(pair.key, -pair.value);
        }
    }

    /// Scale given x key value by the factor
    void mult(real x, real factor)
    {
        this.dict[x] *= factor;
    }

    /// Remove given x key value
    void remove(real x)
    {
        this.dict.remove(x);
    }

    /// Get total number of freqs/probs
    real total()
    {
        return this.values.sum;
    }

    /// Return max freq/prob value from the Map
    real maxValue()
    {
        return this.dict.byValue.maxElement;
    }

    /// Return the key of the max freq/prob value from the Map
    real maxValueKey()
    {
        return this.items.maxElement!(pair => pair.value).key;
    }

    /// Normalize map so that sum of its keys equals to 1
    void normalize(float fraction = 1.0)
    {
        const real factor = fraction / this.total;
        foreach (ref k; this.keys)
        {
            this.dict[k] *= factor;
        }
    }

    /// Choose a random key from the map
    real random()
    {
        const ulong rndIdx = uniform(0, this.dict.length);
        int i;
        real key;
        foreach (ref k; this.keys)
        {
            if (i == rndIdx)
            {
                key = k;
                break;
            }
            ++i;
        }
        return key;
    }

    /// Compute PMF mean
    real pmfMean()
    {
        real mu = 0.0;
        foreach (ref p; this.items)
        {
            mu += p.key * p.value;
        }
        return mu;
    }

    /// Compute PMF variance
    real pmfVariance(real mu = 0)
    {
        if (mu == 0)
        {
            mu = this.pmfMean;
        }
        real variance;
        foreach (ref p; this.items)
        {
            variance += p.value * (p.key - mu) ^^ 2;
        }
        return variance;
    }

    /// Transform log probabilities
    void pmfLog()
    {
        real m = this.maxValue;
        foreach (p; this.items)
        {
            this.set(p.key, log(p.key / m));
        }
    }

    /// Exponentiate probabilities
    void pmfExp()
    {
        real m = this.maxValue;
        foreach (p; this.items)
        {
            this.set(p.key, exp(p.key - m));
        }
    }
}

// void main() { }

unittest
{
    real[] arr = [1, 1, 1, 2, 2, 3];
    real[real] aarr;
    auto m = Map(arr, aarr, "m");
    assert(m.getVal(1) == 3);
    assert(m.values.array.length == 3);
    real[] arr2 = [1, 2];
    auto m2 = Map(arr2, aarr, "m2");
    assert(m.isSubset(m2));
    assert(m.keys.array.length == 3);
    assert(m.items.map!(p => [p.key, p.value]).array.length == 3);
    m.set(10, 5);
    assert(m.getVal(10) == 5);
    m.incr(10, 1);
    assert(m.getVal(10) == 6);
    m.substactMap(m2);
    assert(m.getVal(1) == 2);
    m.mult(1, 5);
    assert(m.getVal(1) == 10);
    m.remove(10);
    assert(m.getVal(10) == 0);
    assert(m.total == 12);
    assert(m.maxValue == 10);
    m2.normalize;
    assert(m2.getVal(1) == 0.5);
}
