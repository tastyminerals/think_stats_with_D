#!/usr/bin/env dub
/*
Reimplementation of survey.py from "Think Stats: Probability and Statistics for Programmers".
This script reads and parses "2002FemPreg.dat.gz" and "2002FemResp.dat.gz" files.

HOWTO:
    Build: dub build --compiler=ldc2
    Run: ./survey
*/
import std.stdio;
import std.range : enumerate, chunks;
import std.algorithm;
import std.array;
import std.conv : to;
import std.math;
import std.typecons;
import std.format;

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

ulong[string] getColIndex()
{
    return PREGCOLS.enumerate.array.map!(tup => tuple(tup[1].name, tup[0])).assocArray;
}

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
    real[] records = convertLines(lines, cols);
    writeln(records.length, " records created");
    auto matrix = records.chunks(cols.length).array;
    return matrix;
}


void pumpkins() {
    import utils.thinkstats : meanVar;
    int[] pums = [1, 1, 1, 3, 3, 591];
    auto tup = meanVar(pums);
    double q = tup.var.sqrt;
    writeln(format("\nPumpkins! mean: %s, variance: %s, std: %s\n", tup.mu, tup.var, q));
}



void main()
{
    import nsfg = exercises.nsfg: runExercises;
    // import other = exercises.other: runExercises;

    real[][] pregSlice = toDataSlice(pregnancies2002, PREGCOLS);
    nsfg.runExercises(pregSlice, &getColIndex);
    // mod2.runExercises;
    

}

unittest
{
    assert(readFileByLines(pregnancies2002) == 13_593);
    assert(readFileByLines(respondents2002) == 7642);
    assert(toDataSlice(pregnancies2002, PREGCOLS).shape == [13_593, 10]);
    assert(toDataSlice(respondents2002, RESPCOLS).shape == [7643, 1]);
}
