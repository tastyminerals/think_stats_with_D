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
import ggplotd.geom;
import ggplotd.ggplotd : putIn, GGPlotD;
import ggplotd.legend: discreteLegend;

/++
Plots and saves a histogram of occurences of two distinct classes to {fileName}.svg
Accepts a tuple of real and string value pairs where a string is the name of a class.
+/
void histogramXOfTwoClasses(Tuple!(real, string)[] data, string fileName) {
    auto gg = data
        .map!((a) => aes!("x", "colour", "fill")(a[0], a[1], 0.45))
        .geomHist
        .putIn(GGPlotD());
    gg.put(discreteLegend(100, 50));
    gg.save(fileName~".svg");
}

/++
Plots and saves a line plot of probabilities of two distinct classes to {fileName}.svg
Accepts a tuple of two real values for x and y axis and a third string value is the name of a class.
+/
void filledLinesXYOfTwoClasses(Tuple!(real, real, string)[] data, string fileName) {
    auto gg = data
    .map!((a) => aes!("x", "y", "colour", "fill")(a[0], a[1], a[2], 0.45))
    .geomLine
    .putIn(GGPlotD());

    gg.put(discreteLegend(100, 50));
    gg.save(fileName~".svg");
}


/++
Plots and saves a line plot of probabilities of one class to {fileName}.svg
Accepts a tuple of two real values for x and y axis and a third string value is the name of a class.
+/
void linesXYOfTwoClasses(Tuple!(real, real)[] data, string fileName) {
    auto gg = data
    .map!((a) => aes!("x", "y")(a[0], a[1]))
    .geomLine
    .putIn(GGPlotD());
    gg.save(fileName~".svg");
}
