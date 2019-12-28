module utils.plotme;
/*
Simple plotting functions that make use of gnuplot library and command line.
*/

import std.stdio;
import std.typecons;
import std.array : array;
import std.algorithm : map;
import std.range : repeat, iota, chain, zip;
import std.random : uniform;

import ggplotd.aes : aes;
import ggplotd.geom : geomHist;
import ggplotd.ggplotd : putIn, GGPlotD;
import ggplotd.legend: discreteLegend;

/++
Plots and saves a histogram of two distinct classes to {fileName}.svg
Accepts a tuple of real and string value pairs where a string is the name of a class.
+/
void histogramOfTwoClasses(Tuple!(real, string)[] data, string fileName) {
    auto gg = data
        .map!((a) => aes!("x", "colour", "fill")(a[0], a[1], 0.45))
        .geomHist
        .putIn(GGPlotD());
    gg.put(discreteLegend(100, 50));
    gg.save(fileName~".svg");
}

