#!/usr/bin/env perl

# default parameters
$suitename = "diff";                # test classification
$xmlout = "diff.test_report.xml";   # XML output filename (should be $suitename.test_report.xml?)
$outfiledir = ".";                  # location of test-generated files
$chkfiledir = ".";                  # location of test reference files
$outsuffix = "out";                 # suffix of test-generated output file
$chksuffix = "chk";                 # suffix of successful test reference file
$verbose = 0;                       # diff debugging info
@results = ();                      # list of test-generated and test reference file base names
@failing_results = ();              # list of "diff -u..." failed exit statuses

while (@ARGV > 0) {
    $arg = shift;
    if ($arg eq "--xmlout") {
        # XML output filename (default "diff.test_report.xml")
        $xmlout = shift;
    }
    elsif ($arg eq "--outfiledir") {
        # location of test-generated output file
        $outfiledir = shift;
    }
    elsif ($arg eq "--chkfiledir") {
        # location of successful test reference file
        $chkfiledir = shift;
    }
    elsif ($arg eq "--outsuffix") {
        # suffix of test-generated output file
        $outsuffix = shift;
    }
    elsif ($arg eq "--chksuffix") {
        # suffix of successful test reference file
        $chksuffix = shift;
    }
    elsif ($arg eq "--suitename") {
        # "suite name"/test classification (default="diff")
        $suitename = shift;
    }
    elsif ($arg eq "--verbose") {
        # debugging verbosity flag
        $verbose = 1;
    }
    else {
        # leftover args are results
        $results[$#results+1] = $arg;
    }
}

$ntest = 0;  # number of tests
$nfail = 0;  # number of failed tests

# for each specified results file
for $result (@results) {
    $outfile = "$outfiledir/$result.$outsuffix";           # default: ./(result).out
    $chkfile = "$chkfiledir/$result.$chksuffix";           # default: ./(result).chk
    open(DIFF,"diff -u $outfile $chkfile|");               # grab diff outfile against reference
    $difftext{$result} = "";  # reset difftext
    while (<DIFF>) {
        # slurp all lines in DIFF output to difftext{$result}
        $difftext{$result} = "$difftext{$result}$_";
    }
    # capture diff exit status (0=no difference, 1=differences, 2=error)
    $match{$result} = close(DIFF);
    $ntest = $ntest + 1;
    # if diff exit status shows files differ
    if (! $match{$result}) {
        # note failures
        $nfail = $nfail + 1;
        $failing_results[$#failing_results+1] = $result;
    }
}

# Create Bamboo-compatible XML output file
open(XMLOUT, ">$xmlout");

#  Write XML header
print XMLOUT "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print XMLOUT "<testsuite";
print XMLOUT " name=\"$suitename\"";
print XMLOUT " tests=\"$ntest\"";
print XMLOUT " failures=\"$nfail\"";
print XMLOUT ">\n";

# For each result 
for $result (@results) {
    $outfile = "$outfiledir/$result.$outsuffix";
    $chkfile = "$chkfiledir/$result.$chksuffix";
    if ($match{$result}) { # if test passes (matches reference file), log it as "run"
        print XMLOUT "  <testcase name=\"$result\" status=\"run\"/>\n";
    }
    else { # else if test failure (differs from reference file), log reason
        $escaped_difftext = $difftext{$result};
        # if encounter a "/]]", work around it.
        $escaped_difftext =~ s/]]>/]]>]]&gt;<![CDATA[/g;
        print XMLOUT "  <testcase name=\"$result\" status=\"run\">\n";
        print XMLOUT "    <failure message=\"files $outfile and $chkfile differ\">";
        print XMLOUT "<![CDATA[$escaped_difftext]]></failure>\n";
        print XMLOUT "  </testcase>\n";
        if ($verbose) {
            print "========================================================================\n";
            print "files $outfile and $chkfile differ:\n";
            print "------------------------------------------------------------------------\n";
            print "$difftext{$result}";
        }
    }
}

print XMLOUT "</testsuite>\n";

# Close XML file
close(XMLOUT);

# Report passes/fails
print "========================================================================\n";
print "\"$suitename\": ran $ntest tests and found $nfail failures\n";
print "------------------------------------------------------------------------\n";
if ($nfail > 0) {
    print "failing cases:\n";
    for $failing_result (@failing_results) {
        print "  $failing_result\n";
    }
print "========================================================================\n";
}

exit 1 if ($nfail > 0)
