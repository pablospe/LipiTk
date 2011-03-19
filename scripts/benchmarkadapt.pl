###########################################################
# Copyright (c) 2006 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy of 
# this software and associated documentation files (the "Software"), to deal in 
# the Software without restriction, including without limitation the rights to use, 
# copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
# Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial 
# portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
#############################################################


#!/bin/perl -w
use Getopt::Long;
use Time::gmtime qw/:FIELDS/;
#use strict;
use Cwd;

###############################################################
#
#        Version information
#
###############################################################
my $Major_Version   = 3;
my $Minor_Version   = 0;
my $Bugfix_Version  = 0;

my $operatingSystem =  $^O ;

###############################################################
#
#        GLOBAL VARIBALES DECLARATION
#
###############################################################
my $numPrototypes   = "" ;   # number of prototypes per class for adaptation
my $iterationsReqd  = 1 ;
my $binSize         = "" ;  # binsize for eval
my $overlap         = "" ;
my $finalBin        = "" ;
my $version         = "";
my $helpRequired    = "";
my $dataRoot        = "";   # used for -indir arg of listfiles.pl
my $listfileConfig  = "";   # used for -config srg of listfile.pl
my $lipiRoot        = "";

#### Runshaperec arguments
my $projectName           = "";
my $profileName           = "default";
my $logLevel              = "ERROR";

my $runCount              = 0;
my $adaptResultsDir       = "adaptResults";
my $adaptFileName         = "adaptfile.txt";
my $runshaperecOutputFile = "";
my $comment               = "%";

my $evalInputFile         = "evalInputFile.txt"; 
my $evalOutputFile        = "evalOutputFile.txt"; 
my $evalDirectory         = "eval"; 
my @performanceArray      = ();
my $resultFileName        = "resultFile.txt";
my $resultFilePath        = "";
my @evalBinAccuracies = ();

my $separator             = "";

my $presentWorkingDir = "" ;

if ($#ARGV == -1 )
{
    displayUsage();
    exit;
}

GetOptions('prototypes=i'   => \$numPrototypes,
           'runs=i'         => \$iterationsReqd,
           'binsize=i'      => \$binSize,
           'overlap=i'      => \$overlap,
           'finalbin=i'     => \$finalBin,
           'lipiroot=s'     => \$lipiRoot,
           'indir=s'        => \$dataRoot,
           'config=s'       => \$listfileConfig,
           'project=s'      => \$projectName,
           'profile=s'      => \$profileName,
           'loglevel=s'     => \$logLevel);

validateCmdLineArgs();

#####linux related compiler option has to be filled properly#####
if ($operatingSystem eq "linux")
{
   $separator = "/";
}
else
{
   $separator = "\\";
}

($presentWorkingDir = getcwd ) =~  s#/#$separator#;
chomp $presentWorkingDir;


my $listFileScriptPath = "$lipiRoot${separator}scripts${separator}listfiles.pl";

my $evalScriptPath = "$lipiRoot${separator}scripts${separator}evalAdapt.pl";

my $runshaperecPath = "$lipiRoot${separator}bin${separator}runshaperec";

my $systemTime = getDate();
$adaptResultsDir = "${presentWorkingDir}${separator}${adaptResultsDir}_${systemTime}";
mkdir $adaptResultsDir;
chdir $adaptResultsDir;

$runshaperecOutputFile = "${adaptResultsDir}${separator}runshaperec.out";

for ($runCount=0; $runCount < $iterationsReqd ;$runCount ++)
{
    my $runDirectory = "run$runCount";
    mkdir $runDirectory;
    chdir $runDirectory;
    
    print "Creating adaptfile for run count $runCount\n";
    
    my $command = "perl $listFileScriptPath -indir $dataRoot -config $listfileConfig -output $adaptFileName -adapt y -prototypes $numPrototypes";
    
    my $exitStatus = system($command);
    
    if ($exitStatus != 0 )
    {
        print "Error while executing listfils.pl. Aborting...\n";
        exit;
    }
    
    print "Calling runshaperec...\n";
    
    $command = "$runshaperecPath -adapt $adaptFileName -project $projectName -profile $profileName -lipiroot $lipiRoot ";
    $exitStatus = system($command);
    
    if ($exitStatus != 0)
    {
    print "\n\n\n Error training the shape recognizer. Please see the log file for more details\n\n\n";
    exit;
    }
    
    ### Call eval
    evaluateResults();

    chdir $adaptResultsDir;

}
    computeAverage();


chdir $presentWorkingDir;

#############################################################
#
# Function name : computeAverage
#
# Arguments : None
#
# Reponsibility   : 
# 1. Open the resultfile.txt for writing
# 2. Compute the average accross all runs
# 	index 0 = average of ( $evalBinAccuracies[0][0], $evalBinAccuracies[1][0]...
# 	index 1 = average of ( $evalBinAccuracies[0][1], $evalBinAccuracies[1][1]...
# 	index 2 = average of ( $evalBinAccuracies[0][2], $evalBinAccuracies[1][2]...
#
#
#############################################################

sub computeAverage
{
    my @finalAccuracyArray = ();
    my $finalAccuracyCount = 0;

    open(HANDLE, ">$resultFileName" ) || warn "could not open results file to write average accuracy\n\n";

    my $iterationCount    = 0;
    my $searchDirectory = "";
    for($iterationCount = 0; $iterationCount <= $#performanceArray ; $iterationCount++)
    {
	my $averageAccuracy = computeAverageAtIndex($iterationCount);

	$finalAccuracyArray[$finalAccuracyCount] = $averageAccuracy;
	$finalAccuracyCount++;

	print HANDLE "$averageAccuracy,";
    }

    close HANDLE;

}

#############################################################
#
# Function name : computeAverageAtIndex
#
# Arguments : Index for which accuracy should be computed
#
# Reponsibility   : 
# 1. Compute the average for a given index accross all runs
# 
#   for index i = average of ( $evalBinAccuracies[0][i], $evalBinAccuracies[1][i]...
#
#############################################################

sub computeAverageAtIndex
{
    my $index          = shift;
    my $iterationCount = 0;
    my $sum            = 0;
    my $average        = 0;

    for($iterationCount = 0; $iterationCount < $iterationsReqd ; $iterationCount++)
    {
	$sum += $evalBinAccuracies[$iterationCount][$index];
    }

    $average = $sum/$iterationsReqd ;

    return $average;

}

#############################################################
#
# Function name : evaluateResults
#
# Arguments : None
#
# Reponsibility   : 
# 1. Call evalAdapt.pl
# 2. Populate the two dimensional array evalBinAccuracies
#    with the accury results.
#
#############################################################

sub evaluateResults
{
    my $command = "perl $evalScriptPath -input $runshaperecOutputFile -outdir $evalDirectory -binsize $binSize -overlap $overlap -finalbin $finalBin -lipiroot $lipiRoot -resultfile $resultFileName ";
	
    my $exitStatus = system($command);

    if ($exitStatus != 0)
    {
	 print "Error in eval.pl. Aborting... \n\n";
	 exit;
    }


    $resultFilePath = "${evalDirectory}${separator}${resultFileName}";

    open TEMP, "<$resultFilePath" || die "Could not open $resultFilePath for evaluating average accuracy\n\n";

    my @tempArray = <TEMP>;
    close TEMP;

    @performanceArray = split(/,/,$tempArray[0]);
    $evalBinAccuracies[$runCount] = \@performanceArray;
}




#############################################################
#
# Function name : validateCmdLineArgs
# Reponsibility   : validates command line arguments
# Arguments : None
#
#############################################################
sub validateCmdLineArgs
{
    if($version)
    {
        print "List Files script Version : $Major_Version.$Minor_Version.$Bugfix_Version\n";
        exit;
    }

    if($helpRequired)
    {
        displayUsage();
        exit;
    }
    
    #lipi root
    if($lipiRoot eq "")
    {
        $lipiRoot = $ENV{'LIPI_ROOT'};
        if($lipiRoot eq "")
        {
            print "Error: LIPI_ROOT env variable is not set";
            exit;
        }
    }
    
    # number of prototypes
    if ($numPrototypes <= 0)
    {
        print "Atleast one prototype per class is required for adaptation\n";
        exit;
    }
    
    #data root
    if ($dataRoot eq "")
    {
        print "Error : Input directory missing. Enter the input directory using -indir option\n";
        displayUsage();
        exit;
    }
    
    #map file
    if($listfileConfig eq "")
    {
        print "Error : Missing map file. Input map file using -config option\n";
        displayUsage();
        exit;
    }
    
    validateRunshaperecArguments();
    
    if ($finalBin == 0)
    {
        print "final bin must be non zero\n\n";
        exit;
    }

    if ($binSize == 0)
    {
        print "bin size must be non zero\n\n";
        exit;
    }

    if ($binSize <= $overlap)
    {
        print "Binsize must be greater than overlap\n\n";
        exit;
    }
}

#############################################################
#
# Function name : validateRunshaperecArguments
# Reponsibility    : Validates the runshaperec arguments
# Arguments : None
#
#############################################################
sub validateRunshaperecArguments
{
    if ($projectName eq "")
	{
		print "\n\n\nError : No project mentioned. Please enter the project name using -project option\n\n\n";
		exit;
	}
    
    if ($profileName eq "")
	{
		print "warning : No profile mentioned . Using default profile\n";
		$profileName = "default";
	}
    
    if ($logLevel eq "")
	{
		print "warning : No log level mentioned . Assuming default log level = $logLevel\n";
	}
}
#############################################################
#
# Function name : getDate
# Reponsibility   : Returns system date and time in a string
# Arguments : None
#
#############################################################
sub getDate
{
    my $date = "";
    gmtime;
	$date = join('_',$tm_mday,($tm_mon+1),($tm_year+1900),($tm_hour),($tm_min),($tm_sec));
    chomp $date;
    
    return $date;
}
#############################################################
#
# Function name : displayUsage
# Reponsibility   : Writes the script usage on stdout
# Arguments : None
#
#############################################################
sub displayUsage
{
    print "\n\nUsage : benchmarkAdapt.pl\n";
    print "\nbenchmarkAdapt.pl\n";
    print "\n\t-project <project name>\n";
    print "\n\t-indir <root path of the dataset>\n";
    print "\n\t-config <config file containing the regular expression map>\n";
    print "\n\t-prototypes <Number of prototypes per class for adaptation>\n";
    print "\n\t-runs <number of iterations required>\n";
    print "\n\t-binsize <the number of samples per bin on which accuracy has to be computed>\n";
    print "\n\t-overlap <overlap value for each bin>\n";
    print "\n\t-finalbin <the size of the final bin on which final accuracy has to be calculated>\n";
    print "\n\t[-profile <profile name>]\n";
    print "\n\t[-loglevel  <log level: Debug|Error|info|all>]\n";
    print "\n\t[-ver or -v (displays the version)]\n";
    print "\n\t[-help (displays this list)]\n\n";
    exit;
}
