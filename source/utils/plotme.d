module utils.plotme;
/*
Small plotting utilities using ggplotD library.
*/

import std.stdio;
import std.array;
import std.algorithm;
import std.range;
import std.random;
import std.typecons;

import ggplotd.aes : aes;
import ggplotd.geom : geomHist;
import ggplotd.ggplotd : putIn, GGPlotD;

void plotMeHistogram(Tuple!(real, string)[] data) {
    // auto gg = data.map!((a) => aes!("x", "colour", "fill")(a[0], a[1], 0.45)).geomHist.putIn(GGPlotD());
    // writeln(typeof(gg).stringof);
    auto xs = iota(0,50,1).map!((x) => uniform(0.0,5)+uniform(0.0,5)).array;
    auto cols = "a".repeat(25).chain("b".repeat(25));
    auto gg = xs.zip(cols)
        .map!((a) => aes!("x", "colour", "fill")(a[0], a[1], 0.45))
        .geomHist
        .putIn(GGPlotD());
}

