#!/usr/bin/env dub
/+ dub.sdl:
    name "survey"
	dependency "mir" version="~>3.2.0"
+/
module survey;

/*
Reimplementation of survey.py from "Think Stats: Probability and Statistics for Programmers".
This script reads and parses "2002FemPreg.dat.gz" and "2002FemResp.dat.gz" files.

HOWTO:
    Build: dub build --compiler=ldc2 --single survey.d
    Run: ./survey
*/
import std.stdio;
import mir.ndslice;
import std.range : enumerate;
import std.array;
import std.conv : to;
import std.math;
import std.typecons;

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
    auto records = convertLines(lines, cols);
    writeln(records.length, " records created");
    // create a 2D ndarray from converted records
    auto dataSlice = records.sliced(lines.length, cols.length);
    return dataSlice;
}

void main()
{
    import first_babies.first : getFirstBabies;

    auto pregSlice = toDataSlice(pregnancies2002, PREGCOLS);
    writeln(typeof(pregSlice).stringof);
    getFirstBabies(pregSlice, &getColIndex);
}

unittest
{
    assert(readFileByLines(pregnancies2002) == 13_593);
    assert(readFileByLines(respondents2002) == 7642);
    assert(toDataSlice(pregnancies2002, PREGCOLS).shape == [13_593, 10]);
    assert(toDataSlice(respondents2002, RESPCOLS).shape == [7643, 1]);
}
