module exercises.other;
/*
Other exercises that do not directly involve NSFG dataset.
*/

import std.stdio;
import utils.pmf;
import std.algorithm : filter;
import std.random : uniform;
import std.range;
import std.array;
import std.typecons;
import std.conv : to;

Map remainingLifetime(Map pmf, int age)
{
    real[real] aarr;
    foreach (pair; pmf.items)
    {
        if (pair.key >= age)
        {
            aarr[pair.key] = pair.value;
        }
    }
    real[] arr;
    return Map(arr, aarr, "remaining lifetimes");
}

void runExercises()
{
    /*
    Exercise 2.4
    Write a function called remainingLifetime that takes a pmf of lifetimes and an age, and returns a new pmf.
    The new pmf represents the distribution of remaining lifetimes.
    */
    real[] arr;
    // key = age, value = lifetime
    auto aarr = generate!(() => tuple(to!real(uniform(1, 10)), to!real(uniform(0, 30)))).take(100)
        .assocArray;
    auto pmf1 = Map(arr, aarr, "lifetimes");
    auto pmf2 = remainingLifetime(pmf1, 5);
    writeln("Remaining lifetimes for age 5:\n", pmf2);

    /*
    Exercise 2.5
    Write functions called pmfMean and pmfVar that take a pmf object and compute the mean and variance.
    */

    // already implemented in pmf.d
}
