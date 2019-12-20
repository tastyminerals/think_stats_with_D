module pmf;

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

struct Map
{
    double[] data;
    double[double] dict;
    string name;

    // Histogram and PMF constructor
    this(double[] arr, double[double] aarr, string name)
    {
        this.name = name;
        this.data = arr;
        this.dict = aarr;
        if (this.dict is null)
        {
            this.data.each!(a => ++this.dict[a]);
        }
    }

    // create a new Map from a current one
    Map copy(string name = "")
    {
        this.name = name.length > 0 ? name : this.name;
        return Map(this.data, this.dict, this.name);
    }

    // get the getValuency of a given x value
    double getVal(double x)
    {
        return this.dict.get(x, 0);
    }

    // get an unsorted sequence of getValuencies
    auto getVals()
    {
        return this.dict.byValue;
    }

    // checks whether the keys of a given Map are a subset of the current one
    bool isSubset(Map otherHist)
    {
        return canFind(this.data, otherHist.data);
    }

    // get an unsorted sequence of keys
    auto keys()
    {
        return this.dict.byKey;
    }

    // get a sequence of value -> getValuency pairs
    auto items()
    {
        return this.dict.byKeyValue;
    }

    // generate a sorted sequence of podoubles suitable for plotting
    SortedRange!(Tuple!(double, double)[]) render() pure
    {
        return this.dict.byPair.map!(p => tuple(p.key, p.value)).array.sort;
    }

    string toString()
    {
        return this.render.map!(t => format("%s -> %s", t[0], t[1])).array.joiner("\n").to!string;
    }

    // given x value set its getValuency
    void set(double x, double y = 0)
    {
        this.dict[x] = y;
    }

    // given x value increment its getValuency
    void incr(double x, double term = 1)
    {
        this.dict[x] += term;
    }

    // substract the keys of a given Map from this Map
    void substactMap(Map otherHist)
    {
        foreach (pair; otherHist.items)
        {
            incr(pair.key, -pair.value);
        }
    }

    // scale given x value by the factor
    void mult(double x, double factor)
    {
        this.dict[x] *= factor;
    }

    // remove given x value
    void remove(double x)
    {
        this.dict.remove(x);
    }

    // get total number of getValuencies
    int total() const
    {
        return this.dict.length;
    }

    // return max freq/prob value from the Map
    double maxLike()
    {
        return this.dict.byValue.maxElement;
    }

    // normalize map so that sum of its keys equals to 1
    void normalize(float fraction = 1.0)
    {
        double factor = fraction / this.total;
        foreach (ref k; this.keys)
        {
            this.dict[k] *= factor;
        }
    }

    // choose a random key from the map
    double random()
    {
        int rndIdx = uniform(0, this.total);
        int i;
        double key;
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

    // compute PMF mean
    double pmfMean()
    {
        double mu = 0.0;
        foreach (ref p; this.items)
        {
            mu += p.key * p.value;
        }
        return mu;
    }

    // compute PMF variance
    double pmfVariance(double mu = 0)
    {
        if (mu == 0)
        {
            mu = this.pmfMean;
        }
        double variance;
        foreach (ref p; this.items)
        {
            variance += p.value * (p.key - mu) ^^ 2;
        }
        return variance;
    }

    // transform log probabilities
    void pmfLog()
    {
        double m = this.maxLike;
        foreach (p; this.items)
        {
            this.set(p.key, log(p.key / m));
        }
    }

    // exponentiate probabilities
    void pmfExp()
    {
        double m = this.maxLike;
        foreach (p; this.items)
        {
            this.set(p.key, exp(p.key - m));
        }
    }
}

void main()
{

}

unittest
{
    double[] arr = [1, 1, 1, 2, 2, 3];
    double[double] aarr;
    auto m = Map(arr, aarr, "m");
    assert(m.getVal(1) == 3);
    assert(m.getVals.array.length == 3);
    double[] arr2 = [1, 2];
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
    assert(m.total == 3);
    assert(m.maxLike == 10);
}
