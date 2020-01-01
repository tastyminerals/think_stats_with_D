module exercises.figures;
/**
Code to generate various "Think Stats" figures. 
*/

import utils.pmf : Map;
import std.array;
import std.algorithm: map;
import std.range : enumerate, chain, zip, repeat;
import std.conv : to;
import std.typecons : Tuple, tuple;
import std.format : format;
import utils.plotme;

/// Figure 2.1: plot and create a historgam of pregnancy lengths
void generateFigure21(real[] pregLengths1, real[] pregLengthsOther)
{
    // Figure 2.1: histogram of pregnancy lengths
    auto pregs21 = pregLengths1.chain(pregLengthsOther);
    auto pregs21Cols = "1".repeat(pregLengths1.length).chain("2".repeat(pregLengthsOther.length));
    assert(pregs21.length == pregs21Cols.length);
    Tuple!(real, string)[] fig21Data = pregs21.zip(pregs21Cols).array;
    histogramXOfTwoClasses(fig21Data, "Figure_2.1");
}

/// Figure 2.2: plot and create a filled line plot of pregnancy length probabilities.
void generateFigure22(real[] pregLengths1, real[] pregLengthsOther)
{
    real[real] aarr;
    auto pregs1 = Map(pregLengths1, aarr, "pregLengths1");
    auto prg1Pmf = pregs1;
    prg1Pmf.normalize;

    auto prgOther = Map(pregLengthsOther, aarr, "pregLengthsOther");
    auto prgOtherPmf = prgOther;
    prgOtherPmf.normalize;

    Tuple!(real, real)[] pregs1Probs = prg1Pmf.render.array;
    Tuple!(real, real)[] pregsOtherProbs = prgOtherPmf.render.array;
    auto pregs22 = pregs1Probs.chain(pregsOtherProbs);
    auto pregs22Cols = "1".repeat(pregs1Probs.length).chain("2".repeat(pregsOtherProbs.length));
    assert(pregs22.length == pregs22Cols.length);
    Tuple!(real, real, string)[] pregs22Data = pregs22.zip(pregs22Cols)
        .map!(t => tuple(t[0][0], t[0][1], t[1])).array;
    filledLinesXYOfTwoClasses(pregs22Data, "Figure_2.2");
}

/// Figure 2.3: plot and create a line plot of preg. length differences between first babies and others.
void generateFigure23(real[] pregLengths1, real[] pregLengthsOther)
{
    import utils.thinkstats : trim;

    real[real] aarr;
    auto pregs1 = Map(pregLengths1, aarr, "pregLengths1");
    auto prg1Pmf = pregs1;
    prg1Pmf.normalize;

    auto prgOther = Map(pregLengthsOther, aarr, "pregLengthsOther");
    auto prgOtherPmf = prgOther;
    prgOtherPmf.normalize;

    auto trPregs1 = Map(trim!real(pregLengths1), aarr, "pregLengths1-trimmed");
    auto trPregsOther = Map(trim!real(pregLengthsOther), aarr,
            "pregLengthsOther-trimmed");
    auto trPregs1Pmf = trPregs1;
    trPregs1Pmf.normalize;
    auto trPregsOtherPmf = trPregsOther;
    trPregsOtherPmf.normalize;
    trPregs1Pmf.substactMap(trPregsOtherPmf);

    Tuple!(real, real)[] pregs23Data = trPregs1Pmf.render.array;
    linesXYOfTwoClasses(pregs23Data, "Figure_2.3");
}
