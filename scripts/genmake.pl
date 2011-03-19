#######################################################################################
# Copyright (c) 2006 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy of 
# this software and associated documentation files (the "Software"), to deal in 
# the Software without restriction, including without limitation the rights to use, 
# copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
# Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
#######################################################################################

#!/usr/bin/perl
# vim: set sw=8 ts=8 si et:
# written by: Rajesh pandry K
# contact id: pandry@hp.com
#

#############################################################################
=pod

=head1 NAME

genmake.pl -- Perl-based C/C++ makefile generator

=head1 SYNOPSIS

  genmake.pl -project kannada_char -profile default 
  creates the default makefile under running directory.

=head1 DESCRIPTION

input is command line option ; user has to provide proper option.

output msg is printed to the stdout.

=head1 CREDITS ANS MODIFICATIONS (HISTORY)

  Jul2005: pandry@hp.com 
           * first version *
  
=head1 AUTHORS

 (c)  Rajesh Pandry K  Mon Jul 11 2005
       <pandry@hp.com>

=head1 LICENSE


=head1 FEEDBACK

For any questions, problems, notes contact authors freely!
=head1 VERSION

$Id="genmake.pl,v 2.3.0 28/09/2005 10:04:22 pandry Exp $

=cut
#############################################################################
$Id="genmake.pl,v 2.3.0 28/09/2005 10:04:22 pandry";

use Cwd;
use File::stat;
use File::Find;
use File::Basename;
use Getopt::Long;

our @SECTIONS; # filled by push_maketarget()
our %buildTargets; # filled by push_maketarget()


#####Get all the environment variable needed for creating makefile.default#####

if ($#ARGV == -1 ) 
{
    display_usage();
}

#####Get all the environment variable needed for creating makefile#####
my $g_ostype =  $^O ; #Get OS type
my $g_lipitk_root; 
my $g_proj_root =  $ENV{ 'PROJ_ROOT'}; 

my $g_major_version = "3";
my $g_minor_version = "0";
my $g_bugfix_version = "0";
my $g_sep="";
my $g_project_type="";
my $g_shape_recognizer="";
my $g_word_recognizer="";
my $g_shape_feature_extractor = "";
my $g_requires="";
my $g_project_dir="";
my $g_project_profile="";
my $makefile = "Makefile";
my @g_projects;

#####################################
$g_default_profile = "default";

#Added to support Easy customization
my $SHAPE_RECOGNIZER_STRING = "ShapeRecMethod";
my $FEATURE_EXTRACTOR_STRING = "FeatureExtractor";


GetOptions('project=s'   => \$g_project_dir,
           'ver|v'       => \$version,
        'help'      => \$helpRequired,
        'lipiroot=s' => \$g_lipitk_root,             
        'profile=s' => \$g_project_profile);



##### Check command line options #####

if($version)
{
     print "genmake script version : $g_major_version.$g_minor_version.$g_bugfix_version\n";
     exit;
}

if($helpRequired)
{
     display_usage();
     exit;
}

if($g_lipitk_root eq "")
{
     $g_lipitk_root = $ENV{'LIPI_ROOT'};
     if($g_lipitk_root eq "")
     {
          print "Error: LIPI_ROOT env variable is not set";
          exit;
     }
}

if ($g_project_dir eq "")
{
    logger( "warning: Wrong command line argument ($ARGV[0])" );
    exit;
}
my ( $argv0 ) = $0 =~ /([^\/]+)$/g;

#########################################################################
# Assume default profile if user does not specofy any on command line
#########################################################################
if ($g_project_profile eq "")
{
    $g_project_profile = $g_default_profile;
}

logger( "info: Project '$g_project_dir' uses ($g_project_profile) profile ok" );

my $C;

##### os related compiler option has to be filled properly #####
my %C;
if ($g_ostype eq "linux") {
    $g_sep = "/";
      %C = ( '_' =>  { 
                  'OS'             => 'linux',
                  'MAKE'           => 'make',
                  'CHDIR'          => 'cd',
                  'F'              => '-f',
            'MAKEFILE_LOCATION'    => 'linux/'
                   } );
}

##### Windows related compiler option has to be filled properly #####
if ($g_ostype eq "MSWin32") {
    $g_sep = "\\";
      %C = ( '_' =>  { 
                  'OS'    => 'win',
                  'MAKE'  => 'nmake',
                  'CHDIR' => 'cd',
                  'F'     => '/f',
            'MAKEFILE_LOCATION'    => 'windows\vc6.0'
                   } );
}

##### Lipi Tool Kit directory structure #####
my %g_lipi_tree = (
        lipiroot        => $g_lipitk_root,
        bin             => $g_lipitk_root.$g_sep.'bin',
        doc             => $g_lipitk_root.$g_sep.'doc',
        lib             => $g_lipitk_root.$g_sep.'lib',
        package         => $g_lipitk_root.$g_sep.'package',
        projdocs        => $g_lipitk_root.$g_sep.'projdocs',
        projects        => $g_lipitk_root.$g_sep.'projects',
        scripts         => $g_lipitk_root.$g_sep.'scripts',
        src             => $g_lipitk_root.$g_sep.'src',
        apps            => $g_lipitk_root.$g_sep.'src'.$g_sep.'apps',
        common          => $g_lipitk_root.$g_sep.'src'.$g_sep.'common',
        include         => $g_lipitk_root.$g_sep.'src'.$g_sep.'include',
        src_lib         => $g_lipitk_root.$g_sep.'src'.$g_sep.'lib',
        lipiengine      => $g_lipitk_root.$g_sep.'src'.$g_sep.'lipiengine',
        tools           => $g_lipitk_root.$g_sep.'src'.$g_sep.'tools',
        util            => $g_lipitk_root.$g_sep.'src'.$g_sep.'util',
        imgwriter       => $g_lipitk_root.$g_sep.'src'.$g_sep.'util'.$g_sep.'imgwriter',
        util_lib        => $g_lipitk_root.$g_sep.'src'.$g_sep.'util'.$g_sep.'lib',
        run             => $g_lipitk_root.$g_sep.'src'.$g_sep.'util'.$g_sep.'run',
        runshaperec     => $g_lipitk_root.$g_sep.'src'.$g_sep.'util'.$g_sep.'run'.$g_sep.'runshaperec',
        runwordrec      => $g_lipitk_root.$g_sep.'src'.$g_sep.'util'.$g_sep.'run'.$g_sep.'runwordrec',
        reco            => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco',
        shaperec        => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec',
        pca             => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'pca',
        nn              => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'nn',
        shapereccommon  => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'common',
        preprocessing   => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'preprocessing',
        featureextractorcommon     => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'featureextractor'.$g_sep.'common',
        pointfloatshapefeatureextractor     => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'featureextractor'.$g_sep.'pointfloat',
        s_tst           => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'tst',
        wordrec         => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'wordrec',
        boxfld          => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'wordrec'.$g_sep.'boxfld',
        wordreccommon   => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'wordrec'.$g_sep.'common',
        w_preprocessign => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'wordrec'.$g_sep.'preprocessing',
        w_tst           => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'wordrec'.$g_sep.'tst',
        reco_util       => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'util',
        hwdat           => $g_lipitk_root.$g_sep.'src'.$g_sep.'tools'.$g_sep.'hwdat',
        hwdct           => $g_lipitk_root.$g_sep.'src'.$g_sep.'tools'.$g_sep.'hwdct',
        multirecognizer => $g_lipitk_root.$g_sep.'src'.$g_sep.'tools'.$g_sep.'multirecognizer',
        shaperecognizer => $g_lipitk_root.$g_sep.'src'.$g_sep.'tools'.$g_sep.'shaperecognizer',
        wordrecognizer  => $g_lipitk_root.$g_sep.'src'.$g_sep.'tools'.$g_sep.'wordrec',
    );

##### Lipi ToolKit dependency structure #####
my %g_dependencies = (
        common          => $g_lipitk_root.$g_sep.'src'.$g_sep.'common',
        util_lib        => $g_lipitk_root.$g_sep.'src'.$g_sep.'util'.$g_sep.'lib',
        shapereccommon  => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'common',
        wordreccommon   => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'wordrec'.$g_sep.'common',
        featureextractorcommon     => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'featureextractor'.$g_sep.'common',
);

my %g_dynamiclibraries = (
        preprocessing => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'preprocessing',
        lipiengine      => $g_lipitk_root.$g_sep.'src'.$g_sep.'lipiengine',
);

##### find the configuration file located #####
#

########################################################################################################
# Validate project
# 1. Check the ProjectType in project.cfg
########################################################################################################

if ($g_project_dir) 
{
   my $proj_dir = search_attr_value("projects");
   my $project_cfg_path = $proj_dir.$g_sep.$g_project_dir.$g_sep."config".$g_sep."project.cfg";

   $g_project_type = read_project_config( $project_cfg_path, "ProjectType" );
   
   if (!$g_project_type) 
   {
      logger( "warning: check configuration file - attribute/value 'ProjectType' doesnot exist" );
      exit(1);
   }

   $proj_dir = search_attr_value("junk");
}

########################################################################################################
# Validate profile
#
########################################################################################################

if ($g_project_profile) 
{
   my $proj_dir = search_attr_value("projects");
   
   my $profile_dir_path = $proj_dir.$g_sep.$g_project_dir.$g_sep."config".$g_sep.$g_project_profile;
   my $profile_cfg_path = $profile_dir_path.$g_sep."profile.cfg";

   $g_shape_recognizer = read_project_config( $profile_cfg_path, $SHAPE_RECOGNIZER_STRING );

     &push_dependencies;

   if (!$g_shape_recognizer) 
   {
       $g_word_recognizer = read_project_config( $profile_cfg_path, "WordRecognizer" );
   
       if (!$g_word_recognizer) 
       {
         logger( "warning: check configuration file - attribute/value 'Shaperecognizer/WordRecognizer' doesnot exist" );
         exit(1);
       }
       
       push_maketarget(\%C ) or exit(1); 
       
       # Check the required projects
       $g_word_recognizer="";
       $g_requires = read_project_config( $profile_cfg_path, "RequiredProjects" );
       
       if (!$g_requires) 
       {
         logger( "warning: check configuration file - attribute/value 'RequiredProjects' doesnot exist" );
         exit(1);
       }
       $proj_dir = search_attr_value("junk");

       if ($g_requires) 
       {
           $project_separator=",";
           @required_projects_array = split ($project_separator, $g_requires);
           $p = 0;
           $number_required_projects = $#required_projects_array;
           $proj_dir = search_attr_value("projects");

        if ($number_required_projects) 
        {
              for ($p = 0; $p <= $number_required_projects; $p++) 
           {
            $required_projects_array[$p] = s/\)//;
                  ($g_required_project, $g_required_proj_profile) = split ('\(', $required_projects_array[$p]);
                  
            if ($g_required_proj_profile eq "") 
            {
                     logger( "info: Project '$proj_directory' uses (default) profile ok" );
                     $g_required_proj_profile = $g_default_profile;
                  }
                  
                  $dproj_dir = $proj_dir.$g_sep.$proj_directory.$g_sep."config".$g_sep.$profile_directory;
                  my $profile_cfg_path = $dproj_dir.$g_sep."profile.cfg";

                  $g_shape_recognizer = read_project_config( $profile_cfg_path, $SHAPE_RECOGNIZER_STRING );

                  if (!$g_shape_recognizer) 
            {
                    logger( "warning: check configuration file - attribute/value 'ShapeRecognizer' doesnot exist" );
                    exit(1);
                  }

            ######## Insert feature extractor name also in the makefile
                 # Get feature extractor name
            local $recognizer_cfg_path = $proj_dir.$g_sep.$g_shape_recognizer.".cfg";

            $g_shape_feature_extractor = read_project_config( $recognizer_cfg_path, $FEATURE_EXTRACTOR_STRING );

                 push_maketarget(\%C ) or exit(1);
                  $g_shape_recognizer = "";
            $g_shape_feature_extractor = "";
              }
           }
        else 
        {
               @g_projects =split ('\(', $g_requires);
               
               if ($#g_projects) {
                  $g_requires =$g_projects[0];
                  $g_projects[1] =~ s/\)//;
               }else {
                  logger( "info: Project '$g_requires' uses (default) profile ok" );
                  $g_projects[1] = "default";
               }
               $g_project_profile = $g_projects[1];
               $g_requires = $g_projects[0];

               $proj_dir = $proj_dir.$g_sep.$g_requires.$g_sep."config".$g_sep.$g_project_profile;
               my $profile_cfg_path = $proj_dir.$g_sep."profile.cfg";
               
            $g_shape_recognizer = read_project_config( $profile_cfg_path, $SHAPE_RECOGNIZER_STRING );

               if (!$g_shape_recognizer) 
            {
                   logger( "warning: check configuration file - attribute/value 'ShapeRecognizer' doesnot exist" );
                   exit(1);
               }
       
          ######## Insert feature extractor name also in the makefile
               # Get feature extractor name
          my $recognizer_cfg_path = $proj_dir.$g_sep.$g_shape_recognizer.".cfg";

          $g_shape_feature_extractor = read_project_config( $recognizer_cfg_path, $FEATURE_EXTRACTOR_STRING );

               push_maketarget(\%C ) or exit(1);
                $g_shape_recognizer = "";
          $g_shape_feature_extractor = "";
          }
       }
   }
   else 
   {
          ######## The project is shape recognition project

          ######## Insert feature extractor name also in the makefile
          # Get feature extractor name
          my $recognizer_cfg_path = $profile_dir_path.$g_sep.$g_shape_recognizer.".cfg";

          $g_shape_feature_extractor = read_project_config( $recognizer_cfg_path, $FEATURE_EXTRACTOR_STRING );
          push_maketarget(\%C ) or exit(1);

          $g_shape_recognizer = "";
     $g_shape_feature_extractor = "";
   }
}

# here make ready for print the target 

#push_maketarget(\%C ) or exit(1);

#############################################################################
$dir = getcwd;
open (MAKEFD, ">$makefile") or die "Cant open $makefile\n";

printf MAKEFD  comment( "### GENMAKE STARTS HERE #" );
printf MAKEFD  comment( "### Created by genmake.pl on " . localtime(time()) . " #" );

# put default values
my $OS     = $C{ '_' }{ 'OS' };
my $MAKE   = $C{ '_' }{ 'MAKE' };
my $CHDIR  = $C{ '_' }{ 'CHDIR' };
my $F      = $C{ '_' }{ 'F' };

my $MKDIR  = $C{ '_' }{ 'MKDIR' };
my $RMDIR  = $C{ '_' }{ 'RMDIR' };
my $RMFILE = $C{ '_' }{ 'RMFILE' };
my $MAKEFILE_LOCATION = $C{ '_' }{ 'MAKEFILE_LOCATION' };

my @MODULES = split /\s+/, $C{ '_' }{ 'MODULES' };

my @TARGETS = @SECTIONS;


printf MAKEFD  comment( "### GLOBAL TARGETS #" );

my $_lipi_root = "LIPITK_SRC_DIR=".$g_lipitk_root."/src";
printf MAKEFD "$_lipi_root\n";
printf MAKEFD "OS=$OS\n";  #print OS type
printf MAKEFD "MAKE=$MAKE\n";  #print MAKE type
printf MAKEFD "CHDIR=$CHDIR\n";  #print CHDIR type
printf MAKEFD "F=$F\n\n";  #print F type

printf MAKEFD "default: all\n\n";
printf MAKEFD  "re: rebuild\n\n";
#print MAKEFD "li: link\n\n";

my $_all = "all: ";
my $_clean = "clean: ";
my $_rebuild = "rebuild: ";
my $_phony = ".PHONY: ";

if ( @MODULES )
{
  $_all .= "modules ";
  $_clean .= "clean-modules ";
  $_rebuild .= "rebuild-modules ";
}

for( @TARGETS )
{
  $_ =~ tr/A-Z/a-z/ ; #change upper case to lower case 
  $_all .= "$_ ";
  $_phony .= "$_ ";
  $_clean .= "clean-$_ ";
  $_rebuild .= "rebuild-$_ ";
}

printf MAKEFD "$_all\n\n$_clean\n\n$_rebuild\n\n$_phony\n\n";

my $n = 1;
make_target( $n++, $_, $C{ $_ } ) for ( @TARGETS );

if ( @MODULES )
{
  printf MAKEFD comment( "### MODULES #" );
  make_module( "" );
  make_module( "clean" );
  make_module( "rebuild" );
}
close(MAKEFD);
printf  MAKEFD comment( "### GENMAKE ENDS HERE #" );


###############################################################################
##### create a target option #####
sub make_target
{
  my $n = shift; # name/number
  my $t = shift; # target id
  my $d = shift; # data

  my $CC       = $d->{ 'CC' };
  my $LD       = $d->{ 'LD' };
  my $AR       = $d->{ 'AR' };
  my $RANLIB   = $d->{ 'RANLIB' };
  my $CCFLAGS  = $d->{ 'CCFLAGS' } . ' ' . $d->{ 'CFLAGS' };
  my $LDFLAGS  = $d->{ 'LDFLAGS' };
  my $DEPFLAGS = $d->{ 'DEPFLAGS' };
  my $ARFLAGS  = $d->{ 'ARFLAGS' };
  my $TARGET   = $d->{ 'TARGET' };
  my $SRC      = $d->{ 'SRC' };
  my $OBJDIR   = ".OBJ.$t";

  if ( ! $TARGET )
  {
      $TARGET = $t;
      logger( "warning: using target name as output ($t)" );
  }
  printf  MAKEFD comment( "### TARGET $n: $TARGET #" );

  printf MAKEFD "TARGET_$n   = $TARGET\n";

  my $target_link;
  my $srcPath = search_attr_value("src");

  printf MAKEFD  "\n\n";
  printf MAKEFD "\$(TARGET_$n):\n";
  my $target_dir_path =  search_attr_value("junk"); #some bugs - extracting the dir path so this line is added 
  my $target_dir_path =  search_attr_value($TARGET); #some bugs - extracting the dir path so this line is added 
  $t_path =  $target_dir_path;

  #if ($target_dir_path =~ m/reco${g_sep}shaperec/)
  #{
      #$t_path =  search_attr_value("junk"); #some bugs - extracting the dir path so this line is added 
      #$t_path =  search_attr_value("shaperec");
      #$target_dep = $TARGET;
  #}

  #if ($target_dir_path =~ m/reco${g_sep}wordrec/)
  #{
      #$t_path =  search_attr_value("junk"); #some bugs - extracting the dir path so this line is added 
      #$t_path =  search_attr_value("wordrec");
      #$target_dep = $TARGET;
  #}

  my $target_dir_path =  search_attr_value("junk"); #some bugs - extracting the dir path so this line is added 

  if ($OS eq "linux")
  {
      $target_link = "\t@(\$(CHDIR) $t_path; \$(CHDIR) $MAKEFILE_LOCATION;\$(MAKE) \$(F) Makefile.\$(OS) all)\n\n";
  }
  else 
  {
      $target_link = "\t\$(CHDIR) $t_path\n\t\$(CHDIR) $MAKEFILE_LOCATION\n\t\$(MAKE) \$(F) Makefile.\$(OS) all\n\t\$(CHDIR) $srcPath\n";
  }

  printf MAKEFD  $target_link;
  
  $t =~ tr/A-Z/a-z/ ; #change upper case to lower case 
  
  if ($OS eq "linux")
  {
      $target_link = "\t@(\$(CHDIR) $t_path; \$(CHDIR) $MAKEFILE_LOCATION; \$(MAKE) \$(F) Makefile.\$(OS) clean)\n\n";
  }
  else 
  {
      $target_link = "\t\$(CHDIR) $t_path\n\t\$(CHDIR) $MAKEFILE_LOCATION\n\t\$(MAKE) \$(F) Makefile.\$(OS) clean\n\t\$(CHDIR) $srcPath\n";
  }
  
  printf MAKEFD "clean-$t: \n" ;
  printf MAKEFD $target_link;
  printf MAKEFD "rebuild-$t: clean-$t \n\n";
  printf MAKEFD "\n";
  
  logger( "info: target $t ($TARGET) ok" );
}

###############################################################################
sub make_module
{
  my $target = shift;

  my $modules_list = "";
  for( @MODULES )
  {
    $modules_list .= "\tmake -C $_ $target\n";
  }
  $target .= "-" if $target;
  printf MAKEFD $target . "modules:\n$modules_list\n";
}

###############################################################################

sub file_deps
{
  my $fname = shift;
  my $depflags = shift;
  my $deps = `$CC -MM $depflags $fname 2> /dev/null`;
  $deps =~ s/^[^:]+://;
  $deps =~ s/[\n\r]$//;
  return $deps;
}

#############################################################################
sub push_dependencies
{
     # pushing dependencies
     foreach $key (keys(%g_dependencies))
     {
          push @SECTIONS, $key;
     }

     # PUShing dependencies
     foreach $key (keys(%g_dynamiclibraries))
     {
          push @SECTIONS, $key;
     }
}

sub push_maketarget
{
  #my $fn = shift;
  my $hr = shift;
  my $sec = '_';
  
     if ($g_shape_recognizer)
     {
        push @SECTIONS, $g_shape_recognizer;

          push @SECTIONS, "runshaperec";
        #test program
     }

     if ($g_shape_feature_extractor)
     {
        push @SECTIONS, $g_shape_feature_extractor;
        #test program
     }

     if ($g_word_recognizer)
     {
        push @SECTIONS, $g_word_recognizer;
        #test program

          push @SECTIONS, "runwordrec";
     }
  return 1;
}

#############################################################################
sub read_project_config
{
  my $fname = shift;
  my $attribute = shift;

  my $CONFIG;
  open ($CONFIG, "<$fname") or die "Cant open $fname\n";
  while (<$CONFIG>) {
      chomp;                  # no newline
      s/#.*//;                # no comments
      s/^\s+//;               # no leading white
      s/\s+$//;               # no trailing white
      next unless length;     # anything left?
     my ($var, $value) = split(/\s*=\s*/, $_, 2);
     #print "$var => $value\n";
     $var =~ tr/A-Z/a-z/ ; #change upper case to lower case 
     $attribute=~ tr/A-Z/a-z/ ; #change upper case to lower case 
     if ($var eq $attribute) {
        close $CONFIG;
        $value =~ tr/A-Z/a-z/ ; #change upper case to lower case
        return $value;
     }
     #$User_Preferences{$var} = $value;
  }
  close $CONFIG;
  return "";
}

###############################################################################
sub fixval
{
  my $s = shift;
  $s =~ s/^\s+//;
  $s =~ s/\s+$//;
  $s =~ s/^["'](.+)['"]$/$1/;
  return $s;
}

###############################################################################
sub comment
{
  my $s = shift;
  $s .= '#' x 80;
  $s = substr( $s, 0, 80 );
  return "\n$s\n\n";
}

###############################################################################
sub find_config
{
  for ( @_ )
    {
    return $_ if -e $_;
    };
  return undef;
}

###############################################################################
sub logger
{
  my $msg = shift;
  print STDERR "$argv0: $msg\n";
}


###############################################################################
sub search_attr_value(){
    my $attr = shift;
    while ( my ($key, $value) = each(%g_lipi_tree) ) {
    #  print "$key => $value\n";
       if ($key eq $attr) {
          return $value;
        }
    }
}
###############################################################################
sub display_usage
{

     print "\n\nUsage : genmake.pl\n";
     print "\ngenmake.pl\n";
     print "\n\t-project <name of the project to be build>\n";
     print "\n\t-profile <name of the project profile to be build> \n\t (if not provided always uses default profile)\n";
     print "\n\t[-lipiroot <path of the lipiroot>]\n"; 
     print "\n\t[-ver or -v (displays the version)]\n";
     print "\n\t[-help (displays this list)]\n\n";
     exit;
}
### EOF #######################################################################


