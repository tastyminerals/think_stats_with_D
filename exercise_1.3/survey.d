#!/usr/bin/env dub
/+ dub.sdl:
    name "survey"
	dependency "mir" version="~>3.2.0"
+/

/*
Reimplementation of survey.py from "Think Stats: Probability and Statistics for Programmers".
This script reads and parses "2002FemPreg.dat.gz" and "2002FemResp.dat.gz" files.

HOWTO:
    Build: dub build --compiler=ldc2 --single survey.d
    Run: ./survey
*/
import std.stdio;
import mir.ndslice;
import std.array;
import std.conv : to;
import std.math;

enum pregnancies2002 = "nsfg_dataset/2002FemPreg.dat";
enum respondents2002 = "nsfg_dataset/2002FemResp.dat";

struct Column
{
    string name;
    int start;
    int end;
}

auto PREGCOLS = [
    Column("caseid", 1, 12), Column("nbrnaliv", 22, 22), Column("babysex", 56,
            56), Column("birthwgt_lb", 57, 58), Column("birthwgt_oz", 59, 60),
    Column("prglength", 275, 276), Column("outcome", 277, 277),
    Column("birthord", 278, 279), Column("agepreg", 284, 287),
    Column("finalwgt", 423, 440)
];

auto RESPCOLS = [Column("caseid", 1, 12)];

static real toReal(string str)
{
    return str.length > 0 ? to!real(str) : NaN(0);
}

string[] readFileByLines(string fname)
{
    import std.file;

    return File(fname, "r").byLineCopy.array;
}

real[] convertLines(in string[] lines, in Column[] cols)
{
    import std.string;

    real[] records;
    records.reserve(lines.length * cols.length);
    string field;
    foreach (line; lines)
    {
        foreach (col; cols)
        {
            field = line[col.start - 1 .. col.end].strip;
            records ~= toReal(field);
        }
    }
    return records;
}

auto toDataSlice(string fileName, in Column[] cols)
{
    auto lines = readFileByLines(fileName);
    writeln(lines.length, " lines read");
    auto records = convertLines(lines, cols);
    writeln(records.length, " records created");
    // create a 2D ndarray from converted records
    auto dataSlice = records.sliced(lines.length, cols.length);
    return dataSlice;
}

void main()
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
    import std.algorithm;
    import std.range : enumerate;
    import std.typecons;

    auto pregSlice = toDataSlice(pregnancies2002, PREGCOLS);
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
    ulong[string] columnIdx = PREGCOLS.enumerate.array.map!(tup => tuple(tup[1].name,
            tup[0])).assocArray;

    auto res = pregSlice[0 .. $, columnIdx["outcome"]].filter!("a == 1").sum;
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
    auto outcome1 = pregSlice.filter!(row => row[columnIdx["outcome"]] == 1).array;
    auto birthordOther = outcome1.partition!(row => row[columnIdx["birthord"]] == 1);
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
    real averageBirthord1 = birthord1.map!(row => row[columnIdx["prglength"]])
        .sum / birthord1.length;
    writeln("Average pregnancy length for first baby (weeks): ", averageBirthord1);
    real averageBirthordOther = birthordOther.map!(row => row[columnIdx["prglength"]])
        .sum / birthordOther.length;
    writeln("Average pregnancy length for second and other babies (weeks): ", averageBirthordOther);
    writeln("Difference (days): ", abs(averageBirthord1 - averageBirthordOther) * 7);
}

unittest
{
    assert(readFileByLines(pregnancies2002) == 13_593);
    assert(readFileByLines(respondents2002) == 7642);
    assert(toDataSlice(pregnancies2002, PREGCOLS).shape == [13_593, 10]);
    assert(toDataSlice(respondents2002, RESPCOLS).shape == [7643, 1]);
}
