#!perl
#
#
use 5.001;
use strict;
use warnings;
use warnings::register;

use vars qw($VERSION $DATE $FILE);
$VERSION = '0.01';   # automatically generated file
$DATE = '2003/09/15';
$FILE = __FILE__;

use Getopt::Long;
use Cwd;
use File::Spec;

##### Test Script ####
#
# Name: Strify.t
#
# UUT: Data::Strify
#
# The module Test::STDmaker generated this test script from the contents of
#
# t::Data::Strify;
#
# Don't edit this test script file, edit instead
#
# t::Data::Strify;
#
#	ANY CHANGES MADE HERE TO THIS SCRIPT FILE WILL BE LOST
#
#       the next time Test::STDmaker generates this script file.
#
#

######
#
# T:
#
# use a BEGIN block so we print our plan before Module Under Test is loaded
#
BEGIN { 
   use vars qw( $__restore_dir__ @__restore_inc__);

   ########
   # Working directory is that of the script file
   #
   $__restore_dir__ = cwd();
   my ($vol, $dirs) = File::Spec->splitpath(__FILE__);
   chdir $vol if $vol;
   chdir $dirs if $dirs;
   ($vol, $dirs) = File::Spec->splitpath(cwd(), 'nofile'); # absolutify

   #######
   # Add the library of the unit under test (UUT) to @INC
   # It will be found first because it is first in the include path
   #
   use Cwd;
   @__restore_inc__ = @INC;

   ######
   # Find root path of the t directory
   #
   my @updirs = File::Spec->splitdir( $dirs );
   while(@updirs && $updirs[-1] ne 't' ) { 
       chdir File::Spec->updir();
       pop @updirs;
   };
   chdir File::Spec->updir();
   my $lib_dir = cwd();

   #####
   # Add this to the include path. Thus modules that start with t::
   # will be found.
   # 
   $lib_dir =~ s|/|\\|g if $^O eq 'MSWin32';  # microsoft abberation
   unshift @INC, $lib_dir;  # include the current test directory

   #####
   # Add lib to the include path so that modules under lib at the
   # same level as t, will be found
   #
   $lib_dir = File::Spec->catdir( cwd(), 'lib' );
   $lib_dir =~ s|/|\\|g if $^O eq 'MSWin32';  # microsoft abberation
   unshift @INC, $lib_dir;

   #####
   # Add tlib to the include path so that modules under tlib at the
   # same level as t, will be found
   #
   $lib_dir = File::Spec->catdir( cwd(), 'tlib' );
   $lib_dir =~ s|/|\\|g if $^O eq 'MSWin32';  # microsoft abberation
   unshift @INC, $lib_dir;
   chdir $dirs if $dirs;
 
   #####
   # Add lib under the directory where the test script resides.
   # This may be used to place version sensitive modules.
   #
   $lib_dir = File::Spec->catdir( cwd(), 'lib' );
   $lib_dir =~ s|/|\\|g if $^O eq 'MSWin32';  # microsoft abberation
   unshift @INC, $lib_dir;

   ##########
   # Pick up a output redirection file and tests to skip
   # from the command line.
   #
   my $test_log = '';
   GetOptions('log=s' => \$test_log);

   ########
   # Using Test::Tech, a very light layer over the module "Test" to
   # conduct the tests.  The big feature of the "Test::Tech: module
   # is that it takes a expected and actual reference and stringify
   # them by using "Data::Dumper" before passing them to the "ok"
   # in test.
   #
   # Create the test plan by supplying the number of tests
   # and the todo tests
   #
   require Test::Tech;
   Test::Tech->import( qw(plan ok skip skip_tests tech_config) );
   plan(tests => 11);

}



END {

   #########
   # Restore working directory and @INC back to when enter script
   #
   @INC = @__restore_inc__;
   chdir $__restore_dir__;
}

   # Perl code from C:
    use File::Package;
    my $fp = 'File::Package';

    use Data::Dumper;

    my $uut = 'Data::Strify';
    my $loaded;

skip_tests( 1 ) unless ok(
      $loaded = $fp->is_package_loaded($uut), # actual results
       '1', # expected results
      "",
      "UUT loaded as Part of Test::Tech"); 

#  ok:  1

   # Perl code from C:
$uut->import( 'stringify' );

ok(  stringify( 'string' ), # actual results
     'string', # expected results
     "",
     "stringify scalar string");

#  ok:  2

ok(  stringify( 2 ), # actual results
     2, # expected results
     "",
     "stringify scalar number");

#  ok:  3

ok(  stringify( '2', 'hello', 4 ), # actual results
     Dumper (['', 'ARRAY', '2', 'hello', 4 ]), # expected results
     "",
     "stringify array");

#  ok:  4

ok(  stringify( '2', ['hello', 'world'], 4 ), # actual results
     Dumper (['', 'ARRAY', '2', ['', 'ARRAY', 'hello', 'world'] , 4 ]), # expected results
     "",
     "stringify array with an array ref");

#  ok:  5

   # Perl code from C:
my $obj = bless { To => 'nobody', From => 'nobody'}, 'Class::None';

ok(  stringify( '2', { msg => ['hello', 'world'] , header => $obj } ), # actual results
     Dumper (
      ['', 'ARRAY', '2',
        ['', 'HASH', 'header',
          ['Class::None', 'HASH', 'From', 'nobody', 'To', 'nobody' ],
           'msg', ['','ARRAY','hello','world' ]
        ]
      ] ), # expected results
     "",
     "stringify array with nested hashes, arrays, objects");

#  ok:  6

   # Perl code from C:
my $array1 = ['Class::None', 'HASH', 'From', 'nobody', 'To', 'nobody' ];

ok(  stringify( { msg => ['hello', 'world'] , header => $obj }, {msg => [ 'body' ], header => $obj} ), # actual results
     Dumper (
      [ '', 'ARRAY',
        [ '', 'HASH', 
          'header',  $array1,
           'msg', ['','ARRAY','hello','world' ]
        ],

        [ '', 'HASH', 
          'header',  $array1,
          'msg', ['','ARRAY','body' ]
        ]

      ] ), # expected results
     "",
     "stringify array with nested hashes, arrays, common object");

#  ok:  7

   # Perl code from C:
     $Data::Dumper::Terse = 0;
     my $strify = new Data::Strify;

ok(   $strify->config('Terse', 1 ), # actual results
     0, # expected results
     "",
     "config read");

#  ok:  8

ok(  $strify->config( 'Terse' ), # actual results
     1, # expected results
     "",
     "config write 1");

#  ok:  9

ok(  $Data::Dumper::Terse, # actual results
     1, # expected results
     "",
     "config write 2");

#  ok:  10

   # Perl code from C:
$strify->finish( );

ok(  $Data::Dumper::Terse, # actual results
     0, # expected results
     "",
     "retore Data::Dumper on finish");

#  ok:  11


=head1 NAME

Strify.t - test script for Data::Strify

=head1 SYNOPSIS

 Strify.t -log=I<string>

=head1 OPTIONS

All options may be abbreviated with enough leading characters
to distinguish it from the other options.

=over 4

=item C<-log>

Strify.t uses this option to redirect the test results 
from the standard output to a log file.

=back

=head1 COPYRIGHT

copyright © 2003 Software Diamonds.

Software Diamonds permits the redistribution
and use in source and binary forms, with or
without modification, provided that the 
following conditions are met: 

\=over 4

\=item 1

Redistributions of source code, modified or unmodified
must retain the above copyright notice, this list of
conditions and the following disclaimer. 

\=item 2

Redistributions in binary form must 
reproduce the above copyright notice,
this list of conditions and the following 
disclaimer in the documentation and/or
other materials provided with the
distribution.

\=back

SOFTWARE DIAMONDS, http://www.SoftwareDiamonds.com,
PROVIDES THIS SOFTWARE 
'AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
SHALL SOFTWARE DIAMONDS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL,EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE,DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING USE OF THIS SOFTWARE, EVEN IF
ADVISED OF NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

## end of test script file ##

