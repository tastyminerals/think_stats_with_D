module exercises.nsfg;

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

    auto res = pregsData.filter!(row => row[idxOf()["outcome"]] == 1).array;
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
    auto liveBirths = pregsData.filter!(row => row[idxOf()["outcome"]] == 1).array;
    auto birthordOtherRows = liveBirths.partition!(row => row[idxOf()["birthord"]] == 1);
    auto birthord1Rows = liveBirths[0 .. liveBirths.length - birthordOtherRows.length];
    writeln("First babies: ", birthord1Rows.length);
    writeln("Second and other babies: ", birthordOtherRows.length);

    /*
    Compute the average pregnancy length (in weeks) for first babies and others.
    Is there a difference between the groups? How big is it?
    "prglength":
        represented in weeks
    */
    const real averageBirthord1 = birthord1Rows.map!(row => row[idxOf()["prglength"]])
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

    auto prglength1 = birthord1Rows.map!(row => row[idxOf()["prglength"]]).array;
    double prglength1Std = prglength1.variance.sqrt;
    writeln("First babies pregnancy length std (weeks): ", prglength1Std);
    auto prglengthOther = birthordOtherRows.map!(row => row[idxOf()["prglength"]]).array;
    double prglengthOtherStd = prglengthOther.variance.sqrt;
    writeln("Second and other babies pregnancy length std (weeks): ", prglengthOtherStd);
    writeln("Difference (days): ", abs(prglength1Std - prglengthOtherStd) * 7);
    generateFigure21(prglength1, prglengthOther);
    generateFigure22(prglength1, prglengthOther);

    /*
    Exercise 2.3
    Write a function called mode that takes a Histogram object and returns the most frequent value.
    */
    // instead of writing a separate function we implement mode as maxValueKey member function in Map struct
    import utils.pmf : Map;

    real[real] aarr;
    auto pregs1 = Map(prglength1, aarr, "prglength1");
    auto prg1Pmf = pregs1;
    prg1Pmf.normalize;
    writeln("Most frequent pregnancy length (weeks): ", prg1Pmf.maxValueKey);
    generateFigure23(prglength1, prglengthOther);
 }
