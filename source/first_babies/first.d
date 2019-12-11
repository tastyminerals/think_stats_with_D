#!/usr/bin/env dub
/+ dub.sdl:
    name "first"
	dependency "mir" version="~>3.2.0"
+/

module first_babies.first;

import mir.ndslice;

void getFirstBabies(Slice!(real*, 2LU, cast(mir_slice_kind)2) pregSlice, ulong[string] function() idxOf)
{
    /*
    Task 1.
    In the directory where you put survey.py and the data files, create a file named first.py and type or paste in the following code:
        import survey
        table = survey.Pregnancies()
        table.ReadRecords()
        print 'Number of pregnancies', len(table.records)

    The result should be 13593 pregnancies.
    We follow the D implementation below.
    */
    import std.stdio;
    import std.array;
    import std.algorithm;
    import std.math : abs;

    assert(pregSlice.length == 13_593);
    writeln("Number of pregnancies: ", pregSlice.length);

    /*
    Task 2.
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

    auto res = pregSlice[0 .. $, idxOf()["outcome"]].filter!("a == 1").sum;
    assert(res == 9148);
    writeln("Number of live births: ", res);

    /*
    Task 3.
    Modify the loop to partition the live birth records into two groups, one for first babies and one for the others.
    Again, read the documentation of birthord to see if your results are consistent.
    When you are working with a new dataset, these kinds of checks are useful for finding errors and inconsistencies in the data,
    detecting bugs in your program, and checking your understanding of the way the fields are encoded.
    "birthord":
        1 if first and then +1;
    */
    auto outcome1 = pregSlice.filter!(row => row[idxOf()["outcome"]] == 1).array;
    auto birthordOther = outcome1.partition!(row => row[idxOf()["birthord"]] == 1);
    auto birthord1 = outcome1[0 .. outcome1.length - birthordOther.length];
    writeln("First babies: ", birthord1.length);
    writeln("Second and other babies: ", birthordOther.length);

    /*
    Task 4.
    Compute the average pregnancy length (in weeks) for first babies and others.
    Is there a difference between the groups? How big is it?
    "prglength":
        represented in weeks
    */
    real averageBirthord1 = birthord1.map!(row => row[idxOf()["prglength"]])
        .sum / birthord1.length;
    writeln("Average pregnancy length for first baby (weeks): ", averageBirthord1);
    real averageBirthordOther = birthordOther.map!(row => row[idxOf()["prglength"]])
        .sum / birthordOther.length;
    writeln("Average pregnancy length for second and other babies (weeks): ", averageBirthordOther);
    writeln("Difference (days): ", abs(averageBirthord1 - averageBirthordOther) * 7);
}
