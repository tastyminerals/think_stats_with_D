module exercises.nsfg;

import utils.pmf : Map;
import std.stdio : writeln, writefln;
import std.array : array;
import std.algorithm : each, sort, sum, partition, map, filter;
import std.range : iota;
    
const string OUTCOME = "outcome";
const string BIRTHORD = "birthord";
const string PRGLENGTH = "prglength";

/// Calculate probability of birth given a time range in weeks.
float birthProb(Map births, in int from, in int until) {
    auto weeks = births.keys.array.filter!(k => from <= k && k <= until);
    return weeks.map!(w => births.getVal(w)).sum * 100;
}

/// Condition PMF probabilities on a specific week.
Map conditionOnWeek(Map pmf, in int week) {
    iota(0, week).each!(a => pmf.removeKey(a));
    pmf.normalize;
    return pmf;
}

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
    const double pregLengths1Std = pregLengths1.variance.sqrt;
    writeln("First babies pregnancy length std (weeks): ", pregLengths1Std);
    auto pregLengthsOther = birthordOtherRows.map!(row => row[idxOf()[PRGLENGTH]]).array;
    const double pregLengthsOtherStd = pregLengthsOther.variance.sqrt;
    writeln("Second and other babies pregnancy length std (weeks): ", pregLengthsOtherStd);
    writeln("Difference (days): ", abs(pregLengths1Std - pregLengthsOtherStd) * 7);
    generateFigure21(pregLengths1, pregLengthsOther);
    generateFigure22(pregLengths1, pregLengthsOther);

    /*
    Exercise 2.3
    Write a function called mode that takes a Histogram object and returns the most frequent value.
    */
    // instead of writing a separate function we implement mode as maxValueKey member function in Map struct

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

    // we can easily calculate the probs with just one birthProb function

    writeln("------[Birth probabilities]------");
    writeln(format("First babies (early): %s%%", birthProb(firstBabiesPMF, -0, 37)));
    writeln(format("Other babies (early): %s%%", birthProb(otherBabiesPMF, -0, 37)));
    writeln(format("First babies (on time): %s%%", birthProb(firstBabiesPMF, 38, 40)));
    writeln(format("Other babies (on time): %s%%", birthProb(otherBabiesPMF, 38, 40)));
    auto firstMaxWeek = to!int(firstBabiesPMF.maxKey);
    auto otherMaxWeek = to!int(otherBabiesPMF.maxKey);
    writeln(format("First babies (late): %s%%", birthProb(firstBabiesPMF, 41, firstMaxWeek)));
    writeln(format("Other babies (late): %s%%", birthProb(otherBabiesPMF, 41, otherMaxWeek)));

    /**
    Exercise 2.7
    Write a function that computes a conditional probability that a baby will be born during Week 39,
    given that it was not born prior to Week 39.
    
    Generalize the function to compute the probability that a baby will be born during Week x,
    given that it was not born prior to Week x, for all x.
    Plot the value as a function of x for first babies and others.
    */

    auto firstBabiesPMF2 = firstBabies;
    firstBabiesPMF2.normalize;
    auto otherBabiesPMF2 = otherBabies;
    otherBabiesPMF2.normalize;

    writeln("------[Conditional birth probabilities from Week 39]------");
    writefln("First babies (early): %s%%", birthProb(conditionOnWeek(firstBabiesPMF2, 38), -0, 37));
    writefln("Other babies (early): %s%%", birthProb(conditionOnWeek(otherBabiesPMF2, 38), -0, 37));
    writefln("First babies (on time): %s%%", birthProb(conditionOnWeek(firstBabiesPMF2, 38), 38, 40));
    writefln("Other babies (on time): %s%%", birthProb(conditionOnWeek(otherBabiesPMF2, 38), 38, 40));
    writefln("First babies (late): %s%%", birthProb(conditionOnWeek(firstBabiesPMF2, 38), 41, firstMaxWeek));
    writefln("Other babies (late): %s%%", birthProb(conditionOnWeek(otherBabiesPMF2, 38), 41, otherMaxWeek));
    generateFigureFor27(pregLengths1, pregLengthsOther);

    /**
    Exercise 2.8
    Based on the results from the previous exercises, suppose you were asked to summarize what you learned 
    about whether first babies arrive late. Which summary statistics would you use if you wanted to get a
    story on the evening news? Which ones would you use if you wanted to reassure an anxious patient?
    Finally, imagine that you are Cecil Adams, author of The Straight Dope (http://straightdope.com), and 
    your job is to answer the question, “Do first babies arrive late?” 
    Write a paragraph that uses the results in this chapter to answer the question clearly, precisely, 
    and accurately.
    */
    writeln(msg);

}

const string msg = q"EOS

Evening news story
    >>> Expecting your first baby is a patience test! <<<
    Waiting for you firstborne to arrive into this world might turn out to be your biggest exercise in patience
    this year. Yes! First babies arrive late and this is a statistical fact now! -- scientists say. They
    collected and analyzed over 15k pregnancy records and arrived at the conclusion that statistically first
    babies are born later than the second babies with up to three weeks difference! So, buckle up novice
    parents, the first road trip will be bumpy.

Anxious patient story
    Don't worry about the evening news article. It was written to attract attention and nothing more. The 
    actual probability of having the first baby later is less than 10%! You can as well write off such results
    as a statistical error. Moreover, first babies actually tend to arrive earlier until 39-th week so in the end
    it really is a mixed bag of opinions where genetic reasons might be playing a bigger role.

Do first babies arrive late?
    There is a difference in birth due dates depending on whether it is the first baby or not. First babies 
    tend to arrive earlier or later rather than on time. Second and other babies tend to be more on time than  
    earlier and later. However, the difference although statistically significant is not that big.    

    Concretely:
    First babies (early): 18.2416% +1.4%
    Other babies (early): 16.8321%
    First babies (on time): 66.2135% -7.6%
    Other babies (on time): 73.7909%
    First babies (late): 15.545% +6.2%
    Other babies (late): 9.37698%
    
    So, I would say that the first babies are less likely to arrive on time and more likely to arrive late.
    But then again, on average. There is a high chance that in your paticular case this claim won't be supported.
EOS";
