########################################################################################
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
# vim: set sw=4 ts=4 si et:
# written by: Rajesh pandry K
# contact id: pandry@hp.com
#
#############################################################################
=pod
=head1 NAME

package.pl -- Perl-based package maker

=head1 SYNOPSIS

  package.pl -pkg package.cf -pkgname boxedkannadareco.zip > makefile

=head1 DESCRIPTION

input is command line option ; user has to provide proper option.
output is printed to the stdout.

=head1 CREDITS ANS MODIFICATIONS (HISTORY)
  Jul2005: pandry@hp.com 
           * first version *
  
=head1 AUTHORS
 (c)  Rajesh Pandry K  Tue Jul 26 2005
       <pandry@hp.com>

=head1 LICENSE
=head1 FEEDBACK

For any questions, problems, notes contact authors freely!
=head1 VERSION

$Id=build.pl,v 2.3.0 26/09/2005  12:44:04 pandry Exp $
=cut
#############################################################################
$Id="build.pl,v 2.3.0 26/09/2005  12:44:04 pandry"; 
#use strict;
use Cwd;
use File::stat;
use File::Find;
use File::Copy;
use File::Basename;
use Fcntl ':flock'; # import LOCK_* constants
#use Compress::Zlib;
use Digest::MD5;
use Getopt::Long; #qw(no_ignore_case);
Archive::Tar;

our @SECTIONS; # filled by read_config()
if ($#ARGV == -1  ) 
{
     display_usage();
}

##### Global env variables #####
  my $g_ostype =  $^O ; #Get OS type
  my $g_lipitk_root = ""; 
  my $g_proj_root =  $ENV{ 'PROJ_ROOT'}; 
  my $g_req_projects=0;
  my $g_major_version = "3";
  my $g_minor_version = "0";
  my $g_bugfix_version = "0";
  my $g_pkg_cfg = "";
  my $g_package_name = "";
  my $g_package_version = "";
  my $SHAPE_RECOGNIZER_STRING = "ShapeRecMethod";
  my $g_docfile = "";
  my $version = "";
  my $helpRequired = "";
  my $lipiStyleSheet = "lipitk.css";
  
  GetOptions('ver|v'     => \$version,
        'help'      => \$helpRequired,
        'pkg=s'       => \$g_pkg_cfg,
        'lipiroot=s' => \$g_lipitk_root,
        'pkgname=s'   => \$g_package_name,
        'pkgversion=s'=> \$g_package_version);


  if($version)
  {
      print "package script version : $g_major_version.$g_minor_version.$g_bugfix_version\n";
      exit;
  }

  if($helpRequired)
  {
      display_usage();
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

          #Check command line options;
  if ( ($g_pkg_cfg eq "") || ($g_package_name eq "") ){
      logger( "warning: Command line arguments are wrong" );
      exit;
  }  

#####Get all the packaging information from packagae.cfg#####
  my @g_projects;
  my @g_tools;
  my @g_srcs;
  my @g_internal = ();

#####linux related compiler option has to be filled properly#####
if ($g_ostype eq "linux") {
   $g_sep = "/";
   $g_pack_tar = "/bin/tar";
   $g_pack_ext = "tar.gz";
   $g_pack_opt = "-Pzcf";
   $g_tmp_install_path = "/tmp/js";
   $g_rm_dir = "/bin/rm -rf ";
}else {
   $g_ostype="win";
   $g_sep = "\\";
   $g_pack_tar = "cabarc";
   $g_pack_ext = "cab";
   $g_pack_opt = "-r -p n";
   $g_tmp_install_path = "/tmp/js";
   $g_rm_dir = $g_lipitk_root . $g_sep . "bin" . $g_sep . "deldir.exe";
}

  my @possiblePlatforms = ("Linux", "VC6.0", "VC2005","VC2008","wm5.0");
  my $TargetPlatform;

##### Lipi Tool Kit directory structure #####
  my %g_lipi_tree = (
        lipiroot        => $g_lipitk_root,
        bin             => $g_lipitk_root.$g_sep.'bin',
        doc             => $g_lipitk_root.$g_sep.'doc',
        lib             => $g_lipitk_root.$g_sep.'lib',
        package         => $g_lipitk_root.$g_sep.'package',
        projects        => $g_lipitk_root.$g_sep.'projects',
        scripts         => $g_lipitk_root.$g_sep.'scripts',
        src             => $g_lipitk_root.$g_sep.'src',
        utils           => $g_lipitk_root.$g_sep.'utils',
        include         => $g_lipitk_root.$g_sep.'src'.$g_sep.'include',
        apps            => $g_lipitk_root.$g_sep.'src'.$g_sep.'apps',
        common          => $g_lipitk_root.$g_sep.'src'.$g_sep.'common',
        src_lib         => $g_lipitk_root.$g_sep.'src'.$g_sep.'lib',
        tools           => $g_lipitk_root.$g_sep.'src'.$g_sep.'tools',
        util            => $g_lipitk_root.$g_sep.'src'.$g_sep.'util',
        dat             => $g_lipitk_root.$g_sep.'src'.$g_sep.'tools'.$g_sep.'dat',
        multirecognizer => $g_lipitk_root.$g_sep.'src'.$g_sep.'tools'.$g_sep.'multirecognizer',
        shaperecognizer => $g_lipitk_root.$g_sep.'src'.$g_sep.'tools'.$g_sep.'shaperecognizer',
        wordrecognizer  => $g_lipitk_root.$g_sep.'src'.$g_sep.'tools'.$g_sep.'wordrec',
        reco            => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco',
        shaperec        => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec',
        pca             => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'pca',
        dtw             => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'dtw',
        s_common        => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'common',
        s_holistic      => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'holistic',
        s_preprocessing => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'preprocessing',
        s_tst           => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'shaperec'.$g_sep.'tst',
        wordrec         => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'wordrec',
        boxfld          => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'wordrec'.$g_sep.'boxfld',
        w_common        => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'wordrec'.$g_sep.'w_common',
        w_preprocessign => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'wordrec'.$g_sep.'w_preprocessing',
        w_tst           => $g_lipitk_root.$g_sep.'src'.$g_sep.'reco'.$g_sep.'wordrec'.$g_sep.'w_tst',
    );

##### here make ready for print the target #####
sub findfile 
{
   # check for symlinks first since they can match files and dirs
   if ( -l $_ ) {
      $linkn++;
   }
   elsif ( -f $_ ) {

      if ($File::Find::name =~ m/(CVS?)|(svn?)|(\.o)|(\.plg)|(\.obj)$/i) {
              ;
      }
      elsif ($File::Find::name =~ m/VC|Linux/i )
      {
       if ( $File::Find::name =~ m/$TargetPlatform/i)
       {
           #### Check if the file is internal
           $flag = 0;

              foreach $member (@g_internal)
              {
                  $member =~ s/^\s+//g;
               $member =~ s/\s+$//g;
               local $nameOfFileFound = basename($File::Find::name);
                  if ($nameOfFileFound eq $member)
               {
                    print "the file name : $nameOfFileFound \n\n";
                  $flag = 1;
               }
              }

           if ($flag == 0)
           {
                  print FLIST "$File::Find::name\n";
                    $filen++;
           }

           #print FLIST "$File::Find::name\n";
           #$filen++;
       }
      }
      else
      {
     #### Check if the file is internal
     $flag = 0;

        foreach $member (@g_internal)
        {
            $member =~ s/^\s+//g;
         $member =~ s/\s+$//g;
         local $nameOfFileFound = basename($File::Find::name);
            if ($nameOfFileFound eq $member)
         {
              print "the file name : $nameOfFileFound \n\n";
            $flag = 1;
         }
        }

     if ($flag == 0)
     {
            print FLIST "$File::Find::name\n";
              $filen++;
     }
      }
 }
};

##### here make ready for print the target #####
sub findDocFile {
   
   # check for symlinks first since they can match files and dirs
   
   if ( -l $_ ) {
       #print "$File::Find::name\n";
      $linkn++;
   }
   elsif ( -f $_ ) {
     #logger( "info: $File::Find::name\n");
      if ($File::Find::name =~ /(CVS?)|(\.o)|(\.plg)|(\.obj)$/) {
              ;
      #  print "$File::Find::name\n";
      }
       else{ 
       if (($File::Find::name =~ /$g_docfile/)){
          #print "$File::Find::name\n";
          print FLIST "$File::Find::name\n";
          $filen++;
            }

     }
 }
};

##### here make ready for print the target headerfiles#####
sub findheaderfile {
   # check for symlinks first since they can match files and dirs
   if ( -l $_ ) {
       #print "$File::Find::name\n";
      $linkn++;
   }
   elsif ( -f $_ ) {
      #print "$File::Find::name\n";
      if ($File::Find::name =~ /(CVS?)|(\.o)|(\.obj)|(\.cpp)|(\.txt)|(Make?)|(\.plg)|(make?)|(\.dsp)$/) {
              ;
      #  print "$File::Find::name\n";
      }else {
          #print "$File::Find::name\n";
          print FLIST "$File::Find::name\n";
          $filen++;
     }
 }
};

##### here make ready for print the target files#####
sub findfile1 {
   # check for symlinks first since they can match files and dirs
   if ( -l $_ ) {
      #print "$File::Find::name\n";
      $linkn++;
   }
   elsif ( -f $_ ) {
      if ($File::Find::name =~ /(CVS?)|(\.o)|(\.plg)|(\.obj)$/) {
              ;
      #  print "$File::Find::name\n";
      }
      elsif ($File::Find::name =~ m/VC|Linux/i )
      {
       if ( $File::Find::name =~ m/$TargetPlatform/i)
       {
              print FLIST "$File::Find::name\n";
              $filen++;
       }
      }
      else
      {
     #### Check if the file is internal
     $flag = 0;

        foreach $member (@g_internal)
        {
      $member =~ s/^\s+//g;
      $member =~ s/\s+$//g;
            if ($File::Find::name =~ m/$member/i)
         {
            $flag = 1;
         }
        }

     if ($flag == 0)
     {
            print FLIST "$File::Find::name\n";
              $filen++;
     }
      }
 }
};

##### here find directory list #####
sub finddir {
    # ignore directories
      return if -l;
      if ($File::Find::name =~ m/(CVS?)|(svn?)|(Release?)|(Debug?)$/i) {
        #print "$File::Find::name\n";
              ;
      }
      elsif ($File::Find::name =~ m/VC|Linux|wm/i )
      {
		if ( $File::Find::name =~ m/$TargetPlatform/i)
		{
             -d && push @dlist, $File::Find::name;
		}
      }
      elsif ($File::Find::name =~ m/Windows/i )
      {
		if ( $TargetPlatform =~ m/VC/i)
		{
             -d && push @dlist, $File::Find::name;
		}
		elsif ( $TargetPlatform =~ m/wm/i)
		{
             -d && push @dlist, $File::Find::name;
		}
      }
      else 
      {
#### Check if the file is internal
     $flag = 0;

        foreach $member (@g_internal)
        {
            $member =~ s/^\s+//g;
         $member =~ s/\s+$//g;
         local $nameOfFileFound = basename($File::Find::name);
            if ($nameOfFileFound eq $member)
         {
            $flag = 1;
         }
        }

     if ($flag == 0)
     {
            -d && push @dlist, $File::Find::name;
     }
      }
};

##### here find directory list #####
sub finddir1 {
    # ignore directories
      return if -l;
      if ($File::Find::name =~ m/(CVS?)|(svn?)|(Release?)|(Debug?)$/i) {
        #print "$File::Find::name\n";
              ;
      }
      elsif ($File::Find::name =~ m/VC|Linux/i )
      {
       if ( $File::Find::name =~ m/$TargetPlatform/i)
       {
             -d && push @dlist, $File::Find::name;
       }
      }
      elsif ($File::Find::name =~ m/Windows/i )
      {
       if ( $TargetPlatform =~ m/VC/i)
       {
             -d && push @dlist, $File::Find::name;
       }
	   elsif ( $TargetPlatform =~ m/wm/i)
       {
             -d && push @dlist, $File::Find::name;
       }
      }
      else 
      {
        $File::Find::name =~  s/\.+$//;     # remove dot directory
        $File::Find::name =~  s/\.\///;     # remove dot extension Linux
        $File::Find::name =~  s/\.\\//;     # remove dot extension windows
        #print "FILE NAME = $File::Find::name\n";
        -d && push @dlist1, $File::Find::name;
      }
};

##### create LipiTk directory #####
sub MakeDir
{
    $dir_path=shift;
    $dir_name=shift;
    if ($g_ostype eq "linux") {
        @dirs=split(/\//,$g_lipitk_root);
    }else {
        @dirs=split(/\\/,$g_lipitk_root);
    }
     $i = 0;
     $nd=$#dirs;
     $path;
     for ($i = 0; $i < $nd; $i++) {
         if ( length($dirs[$i]) != 0 ) {
          if ($g_ostype eq "linux") {
              $path .= $g_sep;
              $path .=$dirs[$i] ;
           }else {
    #          print "path = $dirs[$i]\n";
              $path .=$dirs[$i] ;
              $path .= $g_sep;  
          }
         }
     }#end for

# creating LIPI root directory structure under $LIPI_ROOT/package/
    $g_lipi_base = $dirs[$i];
    #chdir "$path";
    if ($g_ostype eq "linux") {
        @c_dirs=split(/\//,$dir_path);
        @d_dirs=split(/\//,$dir_name);
    }else {
        @c_dirs=split(/\\/,$dir_path);
        @d_dirs=split(/\\/,$dir_name);
    }
     $i = 0;
     $flag = 0;
     $nd=$#c_dirs;
     $nd1=$#d_dirs;
     $pth =  $g_tmp_install_path;
     for ($i = 0; $i <= $nd; $i++) {
         if ( length($c_dirs[$i]) != 0 ) {
          if ($c_dirs[$i] eq $g_lipi_base) {
                  $flag = 1;
          }
          if ($flag eq 1 ) {
             $pth .= $g_sep . $c_dirs[$i];
               mkdir "$pth";
          }
         }
     }#end for
     for ($j = 0; $j < $nd1; $j++) {
         if ( length($d_dirs[$j]) != 0 ) {
             $pth .= $g_sep . $d_dirs[$j];
             $dir_path .= $g_sep . $d_dirs[$j];
              mkdir "$pth";
         }
     }#end for
     if ($nd1){
        $dir_name = $d_dirs[$j];        
     }
    chdir "$dir_path";
    #find(\&finddir, $dirs[$i]);
    @dlist=();
    find(\&finddir, $dir_name);
    #$path = $g_tmp_install_path;
    $path = $pth;
    for $dir (@dlist) {
        $ds = stat $dir;
        if ($ds) {
            # dir number:stat dir:dir
            if ( length($dir) != 0 ) {
               $path=$path . $g_sep . $dir;
               mkdir "$path";
               #$path = $g_tmp_install_path;
               $path = $pth;
            }
        }#end if ($ds)
    };#end for
}#end MakeDir

##### create directory provided by the abosolute path #####
sub CreateDir{
    $c_path = shift;;
    if ($g_ostype eq "linux") {
        @dirs=split(/\//,$g_lipitk_root);
    }else {
        @dirs=split(/\\/,$g_lipitk_root);
    }
     $i = 0;
     $nd=$#dirs;
     $path;
     for ($i = 0; $i < $nd; $i++) {
         if ( length($dirs[$i]) != 0 ) {
          if ($g_ostype eq "linux") {
              $path .= $g_sep;
              $path .=$dirs[$i] ;
           }else {
    #          print "path = $dirs[$i]\n";
              $path .=$dirs[$i] ;
              $path .= $g_sep;  
          }
         }
     }#end for

# creating LIPI root directory structure under $LIPI_ROOT/package/
    $g_lipi_base = $dirs[$i];
    #chdir "$path";
    if ($g_ostype eq "linux") {
        @c_dirs=split(/\//,$c_path);
    }else {
        @c_dirs=split(/\\/,$c_path);
    }
     $i = 0;
     $flag = 0;
     $nd=$#c_dirs;
     $pth =  $g_tmp_install_path;
     for ($i = 0; $i <= $nd; $i++) {
         if ( length($c_dirs[$i]) != 0 ) {
          if ($c_dirs[$i] eq $g_lipi_base) {
                  $flag = 1;
          }
          if ($flag eq 1 ) {
             $pth .= $g_sep . $c_dirs[$i];
               mkdir "$pth";
          }
         }
     }#end for
}
#####  copy files under provided path varaible #####
sub docFileCopy {
    $fname= shift; 
    $l_path= shift;
    $find_dir= shift;
    #log the error 
    open(FLIST, "+>$fname") || die "Error: could not create $fname\n";
    find(\&findDocFile, $find_dir);
    # rewind file and link list files
    seek FLIST,0,SEEK_SET;
    if ($g_ostype eq "linux") {
       @dirs=split(/\//,$l_path);
    }else {
       @dirs=split(/\\/,$l_path);
    }
    $i = 0;
    $nd=$#dirs;
    $path = $g_tmp_install_path;
    $flag = 0;
    for ($i = 0; $i <= $nd; $i++) {
        if ($dirs[$i]  eq $g_lipi_base ) {
           $flag = 1;
        }
        if ($flag == 1) {
           if (length($dirs[$i]) != 0 ) {
              $path .= $g_sep;
              $path .=$dirs[$i] ;
           }
        }#end of if (flag)
    } #end of for
    $message="Not-copied";
	
     close(FLIST);
     open(FLIST, "$fname") || die "Error: could not create $fname\n";
    while(<FLIST>) {
        chomp;
        $bile = $_;
        $i_path = $l_path . $g_sep . $bile;
        $o_path = $path . $g_sep . $bile;
        logger( "info: From = $i_path \nTO = $o_path \n\n");
        $message="Success";

        copy ($i_path , $o_path) or $message="Not-copied";
		logger( "\t$message");
    }#end of while
    $i_path = $o_path = "";
   close(FLIST);
   unlink $fname;
}#end of docFileCopy
#####  copy files under provided path varaible #####
sub fileCopy {
    $fname= shift; 
    $l_path= shift;
    $find_dir= shift;

    #log the error 
    open(FLIST, "+>$fname") || die "Error: could not create $fname\n";
    find(\&findfile, $find_dir);
    # rewind file and link list files
    seek FLIST,0,SEEK_SET;
    if ($g_ostype eq "linux") {
       @dirs=split(/\//,$l_path);
    }else {
       @dirs=split(/\\/,$l_path);
    }

    $i = 0;
    $nd=$#dirs;
    $path = $g_tmp_install_path;
    $flag = 0;
    for ($i = 0; $i <= $nd; $i++) {
        if ($dirs[$i]  eq $g_lipi_base ) {
           $flag = 1;
        }
    
        if ($flag == 1) {
           if (length($dirs[$i]) != 0 ) {
              $path .= $g_sep;
              $path .=$dirs[$i] ;
           }
        }#end of if (flag)
    } #end of for
    $message="Not-copied";
    while(<FLIST>) {
        chomp;
        $bile = $_;

        $i_path = $l_path . $g_sep . $bile;
        $o_path = $path . $g_sep . $bile;
     #print "From = $i_path \nTO = $o_path \n\n";
        $message="Success";
        
        copy ($i_path , $o_path) or $message="Not-copied";
    }#end of while

    $i_path = $o_path = "";
    close(FLIST);
    unlink $fname;

}#end of fileCopy

#####  copy headerfiles under provided path varaible #####
sub headerFileCopy{
    $fname= shift; 
    $l_path= shift;
    $find_dir= shift;
    #log the error 
    open(FLIST, "+>$fname") || die "Error: could not create $fname\n";
    find(\&findheaderfile, $find_dir);
    # rewind file and link list files
    seek FLIST,0,SEEK_SET;
    if ($g_ostype eq "linux") {
       @dirs=split(/\//,$l_path);
    }else {
       @dirs=split(/\\/,$l_path);
    }
    $i = 0;
    $nd=$#dirs;
    $path = $g_tmp_install_path;
    $flag = 0;
    for ($i = 0; $i <= $nd; $i++) {
        if ($dirs[$i]  eq $g_lipi_base ) {
           $flag = 1;
        }
        if ($flag == 1) {
           if (length($dirs[$i]) != 0 ) {
              $path .= $g_sep;
              $path .=$dirs[$i] ;
           }
        }#end of if (flag)
    } #end of for
    while(<FLIST>) {
        chomp;
        $bile = $_;
        $i_path = $l_path . $g_sep . $bile;
        $o_path = $path . $g_sep . $bile;
        #print "From = $i_path \nTO = $o_path \n\n";
        copy ($i_path , $o_path);
    }#end of while
    $i_path = $o_path = "";
   close(FLIST);
   unlink $fname;
}#headerFileCopy

#####  check project profile is exist or not #####
sub check_profile{
    $l_path = shift;
    $l_var = shift;
    $pfname = $l_path . $g_sep . $l_var . $g_sep . "profile.cfg";
    $pval = open ($PROFILE, "<$pfname") ;
    if ($pval ne 1 ){
        print "Error: Can't open $pfname\n";
        $del_path = $g_tmp_install_path . $g_sep . $g_lipi_base;
        system ("$g_rm_dir  $del_path ");
        exit(0);
    }
  close $PROFILE;
}

#####  copy projects directories #####
sub CopyProjDirs {
    $sep = shift;
    $projects =  shift;
    
    $s_path = search_attr_value("junk"); 
    $s_path = search_attr_value("scripts"); #get scripts directory path
    $filename = $s_path . $g_sep . "plist.txt";
    $p_path = search_attr_value("junk"); 
    $p_path = search_attr_value("projects"); #get project directory path
    my @array = split ($sep, $projects);
    if ($#array){
          $array[0] =~ s/^\s+//;               # no leading white
          $array[0] =~ s/\s+$//;               # no trailing white
       if (length($array[1]) != 0) {
          $l_var = $array[1];
          $l_var =~ s/^\s+//;               # no leading white
          $l_var =~ s/\s+$//;               # no trailing white
          $l_var =~ s/\)//;
#check all profile name will copy the whole project under the project name
          if ($l_var eq "all") {
            $l_path = $p_path . $g_sep;
            MakeDir($l_path, $array[0]);
            chdir $l_path;
            fileCopy($filename, $l_path, $array[0]);
          }else {
              if ($g_req_projects == 1){
                $l_path = $p_path . $g_sep;
                MakeDir($l_path, $array[0]);
                chdir $l_path;
                fileCopy($filename, $l_path, $array[0]);
              }else {
                $l_path = $p_path . $g_sep . $array[0] . $g_sep . "config";
                check_profile($l_path, $l_var);
                MakeDir($l_path, $l_var);
                chdir $l_path;
                fileCopy($filename, $l_path, $l_var);
                $i_path = $l_path . $g_sep . "project.cfg";
                $o_path = $path . $g_sep . "project.cfg";
                #print "From = $i_path \nTO = $o_path \n\n";
                copy ($i_path , $o_path);
             }
          }
          #$i_path="";
          #$o_path="";
       }#end of if (length($array[1]) != 0) 
       else{
          if (length($array[0]) != 0) {
             $array[0] =~ s/^\s+//;               # no leading white
             $array[0] =~ s/\s+$//;               # no trailing white
             $l_path = $p_path . $g_sep . $array[0];
             chdir $l_path;
             fileCopy($filename, $l_path, $array[0]);
          }#end if length
       }#end of if 
    }#end of if ($#array);
    else {
#user provided only the project name , default profile should be package
       if (length($projects) != 0) {
         #$l_path = $p_path . $g_sep;
           $projects =~ s/^\s+//;               # no leading white
           $projects =~ s/\s+$//;               # no trailing white
          #MakeDir($l_path, $projects);
          $l_path = $p_path . $g_sep . $projects . $g_sep . "config";
          $l_var="default";
          check_profile($l_path, $l_var);
          MakeDir($l_path, $l_var);
          chdir $l_path;
          logger( "info: Packaging default profile ok" );
          #fileCopy($filename, $l_path, $projects);
          fileCopy($filename, $l_path, $l_var);
          $i_path = $l_path . $g_sep . "project.cfg";
          $o_path = $path . $g_sep . "project.cfg";
          copy ($i_path , $o_path);
       }#end if length
    }#end of else
    $p_path="";
}#end of CopyProjDir;

#####  copy required projects directories #####
sub CopyReqProjDirs {
    $sep = shift;
    $projects =  shift;
    $projects =~ tr/A-Z/a-z/ ; #change upper case to lower case
    $projects =~ s/^\s+//;               # no leading white
    $projects =~ s/\s+$//;               # no trailing white
    $sep =~ s/^\s+//;               # no leading white
    $sep =~ s/\s+$//;               # no trailing white
    $r_path = search_attr_value("junk"); 
    $r_path = search_attr_value("projects"); #get project directory path
    my @array = split ($sep, $projects);
    if ($#array){
        ;
    }else {
        $array[0] = $projects;
        $array[1] = "default";
    }
       $array[0] =~ s/^\s+//;               # no leading white
       $array[0] =~ s/\s+$//;               # no trailing white
    if (length($array[1]) != 0 ) {
       $array[1] =~ tr/A-Z/a-z/ ; #change upper case to lower case
       $l_var = $array[1];
       $l_var =~ s/^\s+//;               # no leading white
       $l_var =~ s/\s+$//;               # no trailing white
       $l_var =~ s/\)//;
       if ($l_var ne "all") {
           $g_req_projects=0;
           copy_required_projects ($array[0], $l_var);
       }#if ne all
       else {
        $r_path = search_attr_value("junk"); 
        $r_path = search_attr_value("projects"); #get project directory path
        $r_path .= $g_sep . $array[0] . $g_sep .  "config";
        chdir $r_path;
        @dlist1=();
        find(\&finddir1, ".");
        for $dirs (@dlist1) {
            $dst = stat $dirs;
            if ($dst) {
                # dir number:stat dir:dir
                if ( length($dirs) != 0 && $dirs !~ m/eval/i) {
                    $g_req_projects=1;
                    copy_required_projects ($array[0], $dirs);
                }
            }#end if ($dst)
            };#end for
       }
    }#end of if (length($array[1]) != 0) 
}#end of CopyReqProjDir;

sub copy_required_projects {
    $r_projects =  shift;
    $l_var = shift;
    $r_projects =~ tr/A-Z/a-z/ ; #change upper case to lower case
    $r_projects =~ s/^\s+//;               # no leading white
    $r_projects =~ s/\s+$//;               # no trailing white
    $l_var =~ tr/A-Z/a-z/ ; #change upper case to lower case
    $l_var =~ s/^\s+//;               # no leading white
    $l_var =~ s/\s+$//;               # no trailing white
    $r_path = search_attr_value("junk"); 
    $r_path = search_attr_value("projects"); #get project directory path
    $l_path = $r_path . $g_sep . $r_projects . $g_sep . "config";
    $proj_dir = $r_path.$g_sep.$r_projects.$g_sep."config".$g_sep.$l_var.$g_sep."profile.cfg";
    $shape_recognizer = read_project_config( $proj_dir, $SHAPE_RECOGNIZER_STRING );
    if (!$shape_recognizer) {
        $word_recognizer = read_project_config( $proj_dir, "WordRecognizer" );
        if (!$word_recognizer) {
           logger( "warning: check configuration file - attribute/value 'Shaperecognizer/WordRecognizer' doesnot exist" );
           exit(1);
        }
        $word_recognizer="";
        $requires = read_project_config( $proj_dir, "RequiredProjects" );
        if (!$requires) {
           logger( "warning: check configuration file - attribute/value 'RequiredProjects' doesnot exist" );
           exit(1);
        }
        $proj_dir = "";
        if ($requires) {
           $p_sep=",";
           @proj_array = split ($p_sep, $requires);
           $r = 0;
           $proj_max = $#proj_array;
           $proj_dir = $p_path;
           if ($proj_max) {
              for ($r = 0; $r <= $proj_max; $r++) {
                  logger( "info: Packaging required projects $proj_array[$r] ok" );
                    CopyProjDirs('\(', $proj_array[$r]);
              }
           }else {
                 logger( "info: Packaging required projects $proj_array[$r] ok" );
                    #CopyProjDirs('\(', $proj_array[$r]);
           }
      }#end of if ($requires)
   }#end of if (!$shape_recognizer)
}

#####  copy source directories #####
sub CopySrcDirs {
    $l_srcs =  shift;
    $l_srcs =~ s/^\s+//;               # no leading white
    $l_srcs =~ s/\s+$//;               # no trailing white
    
    $s_path = search_attr_value("junk"); 
    $s_path = search_attr_value("scripts"); #get scripts directory Path
    $filename = $s_path . $g_sep . "slist.txt";
    print "$filename";
    $p_path = search_attr_value("junk"); 
    $p_path = search_attr_value("src"); #get src directory path
    $l_path = $p_path . $g_sep . $l_srcs;
    MakeDir($p_path, $l_srcs);
    chdir $p_path;
    fileCopy($filename, $p_path, $l_srcs);
    CopyIncs();
}#end of CopySrcDir;
#####  copy doc directories #####
sub CopyDocDir {
    $l_srcs =  shift;
    $l_srcs =~ s/^\s+//;               # no leading white
    $l_srcs =~ s/\s+$//;               # no trailing white
    
    $s_path = search_attr_value("junk"); 
    $s_path = search_attr_value("scripts"); #get scripts directory Path
    $filename = $s_path . $g_sep . "blist.txt";
    $p_path = search_attr_value("junk"); 
    $p_path = search_attr_value("doc"); #get src directory path
    $l_path = $p_path . $g_sep . $l_srcs;

    MakeDir($g_lipitk_root, "doc");
    chdir $g_lipitk_root;
    docFileCopy($l_path, $g_lipitk_root, "doc");
}#end of CopyDocDir;
#####  copy source files to destiantion src directoy #####
sub fCopy {
    $exename= shift; 
    $p_path= shift;
    $exe=shift;
    $exename =~ s/^\s+//;               # no leading white
    $exename =~ s/\s+$//;               # no trailing white
    $p_path =~ s/^\s+//;               # no leading white
    $p_path =~ s/\s+$//;               # no trailing white
    $exe =~ s/^\s+//;               # no leading white
    $exe =~ s/\s+$//;               # no trailing white
    if ($g_ostype eq "linux") {
        @dirs=split(/\//,$p_path);
     }else{
        @dirs=split(/\\/,$p_path);
     }
    $i = 0;
    $nd=$#dirs;
    $path = $g_tmp_install_path ;
    $flag = 0;
    for ($i = 0; $i <= $nd; $i++) {
        if ($dirs[$i]  eq $g_lipi_base ) {
           $flag = 1;
        }
        if ($flag == 1) {
          if (length($dirs[$i]) != 0 ) {
              $path .= $g_sep;
              $path .=$dirs[$i] ;
           }
        }#end of if (flag)
    } #end of for
   $i_path = $p_path . $g_sep . $exename.$exe;
   $o_path = $path . $g_sep . $exename.$exe ;
   $message="Success";
   #print "Copying $i_path to $o_path ########### \n";
   copy ($i_path , $o_path) or $message="Not-Copied";
   $mode = 0555;
   chmod $mode, $o_path;
   $p_path="";
}#end of fCopy

#####  copy binary files & directoy #####
sub CopyBinDirs {
    $bindir =  shift;
    $bindir =~ s/^\s+//;               # no leading white
    $bindir =~ s/\s+$//;               # no trailing white
    $s_path = search_attr_value("junk"); 
    $s_path = search_attr_value("scripts"); #get scripts directory path
    $filename = $s_path . $g_sep . "blist.txt";
    $p_path = search_attr_value("junk"); 
    $p_path = search_attr_value("bin"); #get tools directory path
    if ($g_ostype eq "linux") {
            $exe="";
    }else{
            $exe=".exe";
    }
    if ($bindir eq "hwdat") {
        $hwd_path = search_attr_value("junk"); 
        $hwd_path = search_attr_value("bin"); #get tools directory path
        MakeDir($hwd_path, $bindir);
        chdir $hwd_path;
        fileCopy($filename, $hwd_path, $bindir);
        $hwd_path .= $g_sep . $bindir . $g_sep . "bin" . $g_sep . $g_ostype . $g_sep ;
        chdir $hwd_path;
        $mode = 0777;
        chmod $mode, $bindir;
    }else {
        CreateDir($p_path);
        chdir $p_path;
        fCopy($bindir, $p_path, $exe);
    }
}#end of CopyBinDir;

#####  copy Package files and directory #####
sub CopyPackageDir {
    $bindir =  shift;
    $bindir =~ s/^\s+//;               # no leading white
    $bindir =~ s/\s+$//;               # no trailing white
    $s_path = search_attr_value("junk"); 
    $s_path = search_attr_value("scripts"); #get scripts directory path
    $filename = $s_path . $g_sep . "blist.txt";
    $p_path = search_attr_value("junk"); 
    $p_path = search_attr_value("package"); #get tools directory path
     $exe = "";
        CreateDir($p_path);
        chdir $p_path;
        fCopy($bindir, $p_path, $exe);
    
}#end of CopyPackageDir

#####  copy script files #####
sub CopyScripts {
    $script =  shift;
    $script =~ s/^\s+//;               # no leading white
    $script =~ s/\s+$//;               # no trailing white
    $s_path = search_attr_value("junk"); 
    $s_path = search_attr_value("scripts"); #get scripts directory path
    $filename = $s_path . $g_sep . "blist.txt";
     CreateDir($s_path);
     chdir $s_path;
     $exe="";
     fCopy($script, $s_path, $exe);
     if ( ($message eq "Success") && ($script eq "imagewriter.pl") ){
         CopyBinDirs("imagewriter");
     }
     $mode = 0777;
     chmod $mode, $script;
}#end of CopyScripts;

#####  copy lib files #####
sub CopyLibDirs {
    $libdir =  shift;
    $libdir =~ s/^\s+//;               # no leading white
    $libdir =~ s/\s+$//;               # no trailing white
    $s_path = search_attr_value("junk"); 
    $s_path = search_attr_value("scripts"); #get scripts directory path
    $filename = $s_path . $g_sep . "llist.txt";
    $p_path = search_attr_value("junk"); 
    $p_path = search_attr_value("lipiroot"); #get lipi root directory path
    #$p_path = search_attr_value("junk"); 
    #$pp_path = search_attr_value("lib"); #get lipi root directory path
    #CreateDir($pp_path);
    MakeDir($p_path, $libdir);
    chdir $p_path;
    fileCopy($filename, $p_path, $libdir);
    $p_path="";
}#end of CopyLibDir;

#####  copy include directory #####
sub CopyIncDirs {
    $incdir =  shift;
    $incdir =~ s/^\s+//;               # no leading white
    $incdir =~ s/\s+$//;               # no trailing white
    $s_path = search_attr_value("junk"); 
    $s_path = search_attr_value("scripts"); #get scripts directory path
    $filename = $s_path . $g_sep . "ilist.txt";
    $p_path = search_attr_value("junk"); 
    $p_path = search_attr_value("lipiroot"); #get lipi Root Directory Path
    MakeDir($p_path, $incdir);
    chdir $p_path;
    fileCopy($filename, $p_path, $incdir);
    $p_path="";
}#end of CopyIncDir;

#####  copy include util/header files #####
sub CopyIncs {
    $s_path = search_attr_value("junk"); 
    $s_path = search_attr_value("scripts"); #get scripts directory path
    $filename = $s_path . $g_sep . "ilist.txt";
    $p_path = search_attr_value("junk"); 
    $p_path = search_attr_value("src"); #get lipi Root Directory Path
    $inc="include";
    MakeDir($p_path, $inc);
    chdir $p_path;
    fileCopy($filename, $p_path, $inc);
    $p_path="";
    $p_path = search_attr_value("junk"); 
    $p_path = search_attr_value("util"); #get lipi Root Directory Path
    $inc="lib";
    MakeDir($p_path, $inc);
    chdir $p_path;
    headerFileCopy($filename, $p_path, $inc);
    $p_path="";
}#end of CopyIncDir;

#####  copy bin directory executebale files #####
sub CopyBinFile {
    $exeName =  shift;
    
    $exeName =~ s/^\s+//;               # no leading white
    $exeName =~ s/\s+$//;               # no trailing white
    $p_path = search_attr_value("junk"); 
    $p_path = search_attr_value("bin"); #get Bin Directory Path
    chdir $p_path;
    fCopy($exeName, $p_path, ".exe");
    $p_path="";
}#end of CopyBinFile;

#####  copy default  Makefiles to src directory #####
sub CopyGlobalMakefile {
    $makefile =  shift;
    
    $p_path = $ENV{ 'LIPI_ROOT'}; 
    #chdir $p_path;
    fCopy($makefile, $p_path, "");
    $p_path="";
}#end of CopyBinFile;

#####  copy package and package.cfg to install directory #####
sub postInstallation {
    $package_dir = $g_tmp_install_path . $g_sep . $g_lipi_base;
    chdir $package_dir;
    mkdir "package";
    $post_path = search_attr_value("junk"); 
    $post_path = search_attr_value("package"); #get Bin Directory Path
    $post_path .= $g_sep . "package.cfg";
    $package_dir .= $g_sep . "package";
    copy ($post_path , $package_dir);
    $package_dir = "";
}

#####  Create a final Tar/cab files #####
sub CreateTarBall {
    $tar_file_name = shift;
    $tar_dir_name =shift;
    $dest_dir = shift;
    #get lipitk version directory name from $g_lipitk_root env variable.   

    logger( "info: Packaging $tar_file_name ok" );
    chdir $dest_dir;
    if ($g_ostype eq "linux") {
        $tar_file_name=$tar_file_name . "-".$g_ostype . "." . $g_pack_ext;

        $command="mv";
        $tar_dir_name = "lipi";
        if ($g_package_version) {
          $tar_dir_name = $g_package_version;
        }
        $cmd = "$command $g_lipi_base $tar_dir_name";
        system($cmd);
        system ("$g_pack_tar $g_pack_opt $tar_file_name  $tar_dir_name");
        chdir $g_tmp_install_path;
        system ("$g_rm_dir  $tar_dir_name");
    }else {

        if ($TargetPlatform eq "vc6.0")
        {
            $tar_file_name=$tar_file_name . "-".$g_ostype. "vc6.0" . "." . $g_pack_ext;
        }
        elsif ($TargetPlatform eq "vc2005")
        {
            $tar_file_name=$tar_file_name . "-".$g_ostype. "vc2005" . "." . $g_pack_ext;
        }
		elsif ($TargetPlatform eq "vc2008")
        {
            $tar_file_name=$tar_file_name . "-".$g_ostype. "vc2008" . "." . $g_pack_ext;
        }
        elsif ($TargetPlatform eq "wm5.0")
		{
                 $tar_file_name=$tar_file_name . "-".$g_ostype. "wm5.0" . "." . $g_pack_ext;
        }

        $command="move";
        $lipi = "lipi";
        if ($g_package_version) {
          $lipi = $g_package_version;
        }
        
		$cmd = "$command $g_lipi_base $lipi";
        system($cmd);
        $g_lipi_base = $lipi;
        $g_rm_dir =  search_attr_value("junk"); 
        $g_rm_dir  = search_attr_value("bin"); #get bin directory path
        $g_rm_dir = $g_rm_dir . $g_sep . "deldir";
        chdir $g_tmp_install_path;
        $tar_dir= $g_lipi_base . $g_sep . "*.*";
        system ("$g_pack_tar $g_pack_opt $tar_file_name  $tar_dir");
        $tar_dir_name = $g_lipi_base;
        system ("$g_rm_dir  $tar_dir_name");
    }
}#end of CreatetarBall

sub display_usage
{
     print "\n\nUsage : package.pl\n";
     print "\npackage.pl\n";
     print "\n\t-pkg <packageing configuration file>\n";
     print "\n\t-pkgname <final output package name>\n";
     print "\n\t[-lipiroot <path of the lipiroot>]\n";
     print "\n\t[-ver or -v (displays the version)]\n";
     print "\n\t[-help (displays this list)]\n\n";
     exit;
}


#####  MAIN start here #####



#find the configuration file located 
    my ( $argv0 ) = $0 =~ /([^\/]+)$/g;
       
   $g_tmp_install_path = search_attr_value("package") ;
   #MakeDir();

   $proj_root = search_attr_value("lipiroot"); #get project root value from hash directory map
  # $proj_cfg = $g_tmp_install_path.$g_sep.$g_pkg_cfg;
   $proj_cfg = $g_pkg_cfg;
   print "PROJ CFG = $proj_cfg\n";

   my $projects = read_project_config( $proj_cfg, "PROJECTS" ) or 
        logger( "warning: package.cfg - 'Projects' attribute value is NULL - failed" );
   #print "PROJECTS = $projects \n";

   $tools = read_project_config( $proj_cfg, "TOOLS" ) or 
        logger( "warning: package.cfg - 'Tools' attribute value is NULL - failed" );
   #print "TOOLS = $tools \n";

   $scripts = read_project_config( $proj_cfg, "SCRIPTS" ) or 
        logger( "warning: package.cf - 'Scripts' attribute value is NULL - failed" );
   #print "SCRIPTS = $scripts \n";

   $src = read_project_config( $proj_cfg, "SRC" ) or 
        logger( "warning: package.cfg - 'Src' attribute value is NULL - failed" );
   #print "SOURCE = $src \n";

   $lib = read_project_config( $proj_cfg, "LIB" ) ;
   #print "LIB = $lib \n";

   $include = read_project_config( $proj_cfg, "INCLUDE" );
   #print "INCLUDE = $include \n";

   $doc  = read_project_config( $proj_cfg, "DOC" );
   #print "DOC = $doc \n";

   $package = read_project_config( $proj_cfg, "PACKAGE" );
   #print "PACKAGE = $package \n";

   $data = read_project_config( $proj_cfg, "DATA" );
   #print "PACKAGE = $package \n";

   $TargetPlatform = read_project_config( $proj_cfg, "TargetPlatform" );

   my $internalFile = read_project_config( $proj_cfg, "INTERNAL" );
   @g_internal = split(/,/,$internalFile);

   if ( ($projects eq "") && ($tools eq "") && ($scripts eq "") && ($src eq "") && ($include eq "") ) {
        logger( "error: package.cfg all the attributes values are NULL - failed" );
        exit;
   }

    if ($projects ne ""){
        read_export_config( $proj_cfg, "[EXPORT]" );
    }

   $sep = ",";
#PROJECTS Packgae
   @g_projects = split( $sep, $projects);
   if ($#g_projects) {
      $nprojs = $#g_projects;
      for ($p = 0; $p <= $nprojs; $p++) {
          logger( "info: Packaging projects $g_projects[$p] ok" );
          if ( length($g_projects[$p]) != 0 ) {
              $g_req_projects=0;
              CopyProjDirs('\(', $g_projects[$p]);
              CopyReqProjDirs('\(', $g_projects[$p]);
           }
     }
   }else {
         logger( "info: Packaging projects $projects ok" );
         $g_req_projects=0;
         CopyProjDirs('\(', $projects);
         CopyReqProjDirs('\(', $g_projects[$p]);
   }

#TOOLS Package
   $sep = ",";
   @g_tools = split( $sep, $tools);
   $ntools = $#g_tools;
   if ($ntools){
      for ($t = 0; $t <= $ntools; $t++) {
          if ( length($g_tools[$t]) != 0 ) {
              CopyBinDirs($g_tools[$t]);
              if($message eq "Success"){
                logger( "info: Packaging tools $g_tools[$t] ok" );
              }
              else {
                logger( "warning: Packaging tools $g_tools[$t] failed" );
              }
                $message="";
          }    
      }
      if ($g_ostype ne "linux") {
              CopyBinDirs("deldir");
      }
   } else {
         CopyBinDirs($tools);
         if ($message eq "Success"){
            logger( "info: Packaging tools $g_tools[$t] ok" );
         }
         else {
            logger( "warning: Packaging tools $g_tools[$t] failed" );
        }
            $message="";
        if ($g_ostype ne "linux") {
                CopyBinDirs("deldir");
        }
   }

#SCRIPTS Package
   $sep = ",";
   @g_scripts = split( $sep, $scripts);
   push(@g_scripts, $lipiStyleSheet);
   $nscripts = $#g_scripts;
   if ($nscripts){
      for ($s = 0; $s <= $nscripts; $s++) {
          if ( length($g_scripts[$s]) != 0 ) {
                CopyScripts($g_scripts[$s]);
                if ($message eq "Success"){
                   logger( "info: Packaging scripts $g_scripts[$s] ok" );
                }
                else {
                   logger( "warning: Packaging scripts $g_scripts[$s] failed" );
                }
                   $message="";
          }    
      }
   } else {
        logger( "info: Packaging scripts $scripts ok" );
        CopyScripts($scripts);
        if ($message eq "Success"){
            logger( "info: Packaging scripts $g_scripts[$s] ok" );
        }
        else {
            logger( "warning: Packaging scripts $g_scripts[$s] failed" );
        }
            $message="";
   }

#SOURCE Package
   $sep = ",";
   @g_srcs = split($sep, $src);
   $nsrcs = $#g_srcs;
   if ($nsrcs){
      for ($s = 0; $s <= $nsrcs; $s++) {
         logger( "info: Packaging source $g_srcs[$s] ok" );
          if ( length($g_srcs[$s]) != 0 ) {
              CopySrcDirs($g_srcs[$s]);
          }
      }
   } else {
         logger( "info: Packaging source $src ok" );
         CopySrcDirs($src);
   }

#LIB Package
   $sep = ",";
   @g_lib = split( $sep, $lib);
   $nlib = $#g_lib;
   if ($nlib){
      for ($l = 0; $l <= $nlib; $l++) {
         logger( "info: Packaging libs $g_lib[$l] ok" );
          if ( length($g_lib[$l]) != 0 ) {
              CopyLibDirs($g_lib[$l]);
          }    
      }
   } else {
         logger( "info: Packaging libs $lib ok" );
          CopyLibDirs($lib);
   }
# DATA Package
   $sep = ",";
   @g_data = split( $sep, $data);
   $ndata = $#g_data;
   if ($ndata){
      for ($l = 0; $l <= $ndata; $l++) {
         logger( "info: Packaging data $g_data[$l] ok" );
          if ( length($g_data[$l]) != 0 ) {
              CopyLibDirs($g_data[$l]);
          }
      }
   } else {
         logger( "info: Packaging data $data ok" );
          CopyLibDirs($data);
   }
#PACKAGE Package
   $sep = ",";
   #logger( "Packaging files $package" );
   @g_package = split( $sep, $package);
   $npackage = $#g_package;
   #logger( "#package files @g_package" );
   foreach (@g_package) {
         logger( "info: Packaging $_ ok" );
           
          if ( length($_) != 0 ) {
                #logger( "info: Calling  CopyPackageDir".$g_package[$i] );
              CopyPackageDir($_);

          }    
      }

#DOC Package
    $sep = ",";
    #logger( "Packaging files $doc" );
    @g_package = split( $sep, $doc);
    $ndoc = $#g_doc;
    #logger( "doc files @g_package" );
    foreach (@g_package) {
        logger( "info: Packaging $_ ok" );
        if ( length($_) != 0 ) {
            $g_docfile = $_;
            #logger( "info: Calling  CopyPackageDir".$g_package[$i] );
            $g_doc_dir =  search_attr_value("junk"); 
            $g_doc_dir  = search_attr_value("doc"); #get doc directory path
            CopyDocDir($g_docfile);
        }    
    }


#INCLUDE Package
   $sep = ",";
   @g_include = split( $sep, $include);
   $ninclude = $#g_include;
   if ($ninclude){
      for ($i = 0; $i <= $ninclude; $i++) {
         logger( "info: Packaging include $g_include[$i] ok" );
          if ( length($g_include[$i]) != 0 ) {
              CopyIncDirs($g_include[$i]);
          }    
      }
   } else {
         logger( "info: Packaging include $include ok" );
          CopyIncDirs($include);
   }
   if ($src ne "") {
        $src_lib="lib";
        CopyLibDirs($src_lib);
        $src_lib="src" . $g_sep . "lib";
        CopyLibDirs($src_lib);

     if ($TargetPlatform =~ m/VC/i)
     {
            CopyLibDirs("windows");
            CopyLibDirs("src/windows");
     }
     elsif($TargetPlatform =~ m/wm/i)
     {
            CopyLibDirs("windows");
            CopyLibDirs("src/windows");
     }
     else
     {
            CopyLibDirs("src/linux");
            CopyLibDirs("linux");
     }

        CopyGlobalMakefile("global.mk"); 
        CopyGlobalMakefile("global.winmk"); 
     CopyGlobalMakefile("readme.txt");
     CopyGlobalMakefile("contrib.txt");
     CopyGlobalMakefile("license.txt");
   }
    if ($g_ostype eq "linux") {
        @dirs=split(/\//,$g_lipitk_root);
    }else {
        @dirs=split(/\\/,$g_lipitk_root);
    }
   postInstallation();
   CreateTarBall($g_package_name, $dirs[$#dirs], $g_tmp_install_path);
exit(0);

#####  MAIN end here #####

#####  read configuration information #####
sub read_project_config
{
  $flname = shift;
  $attribute = shift;
  my $CONFIG;
  open ($CONFIG, "<$flname") or die "Error: Can't open config file $flname : $!\n";
  #$rval = open ($CONFIG, "<$flname") ;
  #if ($rval ne 1 ){
    #print "Error: Can't open $flname\n";
    #$del_path = $g_tmp_install_path . $g_sep . $g_lipi_base;
    #system ("$g_rm_dir  $del_path ");
    #exit(0);
  #}
  while (<$CONFIG>) {
      chomp;                  # no newline
      s/#.*//;                # no comments
      s/^\s+//;               # no leading white
      s/\s+$//;               # no trailing white
      next unless length;     # anything left?
     my ($var, $value) = split(/\s*=\s*/, $_, 2);
     #print "$var => $value\n";
      $var =~ tr/A-Z/a-z/ ; #change upper case to lower case
      $attribute =~ tr/A-Z/a-z/ ; #change upper case to lower case
     if ($var eq $attribute) {
        close $CONFIG;
    #    $value =~ tr/A-Z/a-z/ ; #change upper case to lower case
        return $value;}
     #$User_Preferences{$var} = $value;
  }
  close $CONFIG;
  return "";
}

#####  read export configuration information from package.cfg#####
sub read_export_config
{
  $flname = shift;
  $attribute = shift;
  my $CONFIG;
  $export_flag = 0;
  $ex_path = search_attr_value("junk"); 
  $ex_path = search_attr_value("projects"); #get Bin Directory Path
  CreateDir($ex_path);
  $ex_path = $pth;
  $ex_path .= $g_sep . "lipiengine.cfg";
  open ($CONFIG, "<$flname") or die "Error: Can't open $flname\n";
  open ($LIPI_CONFIG, ">$ex_path") or die "Error: Can't open $ex_path\n";
  while (<$CONFIG>) {
      chomp;                  # no newline
   #   s/#.*//;                # no comments
      s/^\s+//;               # no leading white
      s/\s+$//;               # no trailing white
      next unless length;     # anything left?
     my ($var, $value) = split(/\s*=\s*/, $_, 2);
     #print "$var => $value\n";
      $var =~ tr/A-Z/a-z/ ; #change upper case to lower case
      $attribute =~ tr/A-Z/a-z/ ; #change upper case to lower case
      if ($var eq $attribute) {
        $export_flag = 1;
        next;
     }
     if ($export_flag){
         print $LIPI_CONFIG "$_\n"
     }
  }
# if ($export_flag) {
# }
# else {
#          unlink $ex_path;
# }
  close $CONFIG;
  close $LIPI_CONFIG;
  return "";
}

#####  logger function used for loggin messages #####
sub logger
{
  my $msg = shift;
  print STDERR "$argv0: $msg\n";
}

#####  search attribute and value from config file #####
sub search_attr_value(){
    my $attr = shift;
    while ( my ($key, $value) = each(%g_lipi_tree) ) {
    #  print "$key => $value\n";
       if ($key eq $attr) {
          return $value;
        }
    }
}
### EOF #######################################################################

