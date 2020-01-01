module exercises.nsfg;

const string OUTCOME = "outcome";
const string BIRTHORD = "birthord";
const string PRGLENGTH = "prglength";

/// The exercises that work with mir.ndslice array generated from NSFG dataset.
void runExercises(real[][] pregsData, ulong[string]function() idxOf)
{
    /*
    Exercise 1.2
    In the directory where you put survey.py and the data files, create a file named first.py and type or paste in the following code:
        import survey
        table = survey.Pregnancies()
        table.ReadRecords()
        print 'Number of pregnancies', len(table.records)

    The result should be 13593 pregnancies.
    We follow the D implementation below.
    */
    import std.stdio : writeln;
    import std.array : array;
    import std.algorithm : each, sort, sum, partition, map, filter;
    import std.math : abs, sqrt;
    import std.format: format;
    
    assert(pregsData.length == 13_593);
    writeln("Number of pregnancies: ", pregsData.length);

    /*
    Exercise 1.3
    Write a loop that iterates table and counts the number of live births.
    Find the documentation of outcome and confirm that your result is consistent with the summary in the documentation.
    "outcome":
        Blank = Inapplicable
        1 = Live birth <--
        2 = Induced abortion
        3 = Stillbirth
        4 = Miscarriage
        5 = Ectopic pregnancy
        6 = Current pregnancy
    */

    auto res = pregsData.filter!(row => row[idxOf()[OUTCOME]] == 1).array;
    assert(res.length == 9148);
    writeln("Number of live births: ", res.length);

    /*
    Modify the loop to partition the live birth records into two groups, one for first babies and one for the others.
    Again, read the documentation of birthord to see if your results are consistent.
    When you are working with a new dataset, these kinds of checks are useful for finding errors and inconsistencies in the data,
    detecting bugs in your program, and checking your understanding of the way the fields are encoded.
    "birthord":
        1 if first and then +1;
    */
    auto liveBirths = pregsData.filter!(row => row[idxOf()[OUTCOME]] == 1).array;
    auto birthordOtherRows = liveBirths.partition!(row => row[idxOf()[BIRTHORD]] == 1);
    auto birthord1Rows = liveBirths[0 .. liveBirths.length - birthordOtherRows.length];
    writeln("First babies: ", birthord1Rows.length);
    writeln("Second and other babies: ", birthordOtherRows.length);

    /*
    Compute the average pregnancy length (in weeks) for first babies and others.
    Is there a difference between the groups? How big is it?
    "prglength":
        represented in weeks
    */
    const real averageBirthord1 = birthord1Rows.map!(row => row[idxOf()[PRGLENGTH]])
        .sum / birthord1Rows.length;
    writeln("Average pregnancy length for first baby (weeks): ", averageBirthord1);
    const real averageBirthordOther = birthordOtherRows.map!(
            row => row[idxOf()["prglength"]]).sum / birthordOtherRows.length;
    writeln("Average pregnancy length for second and other babies (weeks): ", averageBirthordOther);
    writeln("Difference (days): ", abs(averageBirthord1 - averageBirthordOther) * 7);

    /*
    Exercise 2.1, 2.2
    Compute std of gestation time for first and other babies.
    Does it look like the spread is the same for the two groups?
    "prglength":
        represented in weeks
    */
    import utils.thinkstats : variance;
    import exercises.figures;

    auto pregLengths1 = birthord1Rows.map!(row => row[idxOf()[PRGLENGTH]]).array;
    double pregLengths1Std = pregLengths1.variance.sqrt;
    writeln("First babies pregnancy length std (weeks): ", pregLengths1Std);
    auto pregLengthsOther = birthordOtherRows.map!(row => row[idxOf()[PRGLENGTH]]).array;
    double pregLengthsOtherStd = pregLengthsOther.variance.sqrt;
    writeln("Second and other babies pregnancy length std (weeks): ", pregLengthsOtherStd);
    writeln("Difference (days): ", abs(pregLengths1Std - pregLengthsOtherStd) * 7);
    generateFigure21(pregLengths1, pregLengthsOther);
    generateFigure22(pregLengths1, pregLengthsOther);

    /*
    Exercise 2.3
    Write a function called mode that takes a Histogram object and returns the most frequent value.
    */
    // instead of writing a separate function we implement mode as maxValueKey member function in Map struct
    import utils.pmf : Map;

    real[real] aarr;
    auto firstBabies = Map(pregLengths1, aarr, "pregLengths1");
    auto firstBabiesPMF = firstBabies;
    firstBabiesPMF.normalize;
    writeln("Most frequent pregnancy length (weeks): ", firstBabiesPMF.maxValueKey);
    generateFigure23(pregLengths1, pregLengthsOther);

    /*
    Exercise 2.6
    A baby is early if it is born during week 37 or earlier, on time if it is born during week 38, 39 or 40,
    and late if it is born during week 41 or later. Ranges like these are called bins.
    Write functions named probEarly, probOnTime, probLate that take a PMF and compute the fraction of births
    that fall into each bin.
    */
    import std.conv : to;

    auto otherBabies = Map(pregLengthsOther, aarr, "pregLengthsOther");
    auto otherBabiesPMF = otherBabies;
    otherBabiesPMF.normalize;

    auto liveBirthsMap = Map(liveBirths.map!(row => row[idxOf()[PRGLENGTH]]).array, aarr, "liveBirths");
    auto liveBirthsPMF = liveBirthsMap;
    liveBirthsPMF.normalize;
    
    // we can easily calculate the probs with just one function
    float birthProb(Map births, in int from, in int until) {
        auto weeks = births.keys.array.filter!(k => from <= k && k <= until);
        return weeks.map!(w => births.getVal(w)).sum * 100;
    }
    
    writeln("Birth probabilities:");
    writeln(format("First babies (early): %s%%", birthProb(firstBabiesPMF, -0, 37)));
    writeln(format("Other babies (early): %s%%", birthProb(otherBabiesPMF, -0, 37)));
    writeln(format("First babies (on time): %s%%", birthProb(firstBabiesPMF, 38, 40)));
    writeln(format("Other babies (on time): %s%%", birthProb(otherBabiesPMF, 38, 40)));
    auto firstMaxWeek = to!int(firstBabiesPMF.maxKey);
    auto otherMaxWeek = to!int(otherBabiesPMF.maxKey);
    writeln(format("First babies (late): %s%%", birthProb(firstBabiesPMF, 41, firstMaxWeek)));
    writeln(format("Other babies (late): %s%%", birthProb(otherBabiesPMF, 41, otherMaxWeek)));

}
