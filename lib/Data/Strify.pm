#!perl
#
# Documentation, copyright and license is at the end of this file.
#
package  Data::Strify;

use 5.001;
use strict;
use warnings;
use warnings::register;

use Data::Dumper;
$Data::Dumper::Terse = 1;
use attributes;

use vars qw($VERSION $DATE $FILE);
$VERSION = '1.13';
$DATE = '2003/09/15';
$FILE = __FILE__;

use vars qw(@ISA @EXPORT_OK);
require Exporter;
@ISA=('Exporter');
@EXPORT_OK = qw(&stringify &arrayify_walk &arrayify);


#####
#
#
sub new
{

   #########
   # If class is an object with the same type of data storage,
   # $dataref, as the inherited class, the inherited class
   # simplys adds to the data storage of the sibling class.
   # 
   #
   my $class = shift;
   $class = ref($class) if( ref($class) );
   my $self = bless {}, $class;

   ########
   # Make  Data::Dumper variables visible to tech_config
   #
   $self->{Dumper}->{Terse} = \$Data::Dumper::Terse;
   $self->{Dumper}->{Indent} = \$Data::Indent;
   $self->{Dumper}->{Purity} = \$Data::Purity;
   $self->{Dumper}->{Pad} = \$Data::Pad;
   $self->{Dumper}->{Varname} = \$Data::Varname;
   $self->{Dumper}->{Useqq} = \$Data::Useqq;
   $self->{Dumper}->{Freezer} = \$Data::Freezer;
   $self->{Dumper}->{Toaster} = \$Data::Toaster;
   $self->{Dumper}->{Deepcopy} = \$Data::Deepcopy;
   $self->{Dumper}->{Quotekeys} = \$Data::Quotekeys;
   $self->{Dumper}->{Maxdepth} = \$Data::Maxdepth;

   $self->{DumperDefault}->{Terse} = $Data::Dumper::Terse;
   $self->{DumperDefault}->{Indent} = $Data::Indent;
   $self->{DumperDefault}->{Purity} = $Data::Purity;
   $self->{DumperDefault}->{Pad} = $Data::Pad;
   $self->{DumperDefault}->{Varname} = $Data::Varname;
   $self->{DumperDefault}->{Useqq} = $Data::Useqq;
   $self->{DumperDefault}->{Freezer} = $Data::Freezer;
   $self->{DumperDefault}->{Toaster} = $Data::Toaster;
   $self->{DumperDefault}->{Deepcopy} = $Data::Deepcopy;
   $self->{DumperDefault}->{Quotekeys} = $Data::Quotekeys;
   $self->{DumperDefault}->{Maxdepth} = $Data::Maxdepth;
   $self;
}


######
# Configure Date::Dumper
#
sub config
{
   my ($self, $key, $value) = @_;
   unless( defined $self->{Dumper}->{$key} ) {
       warn "Configuration item $key does not exist\n";
       return undef;
   } 
   my $result = ${$self->{Dumper}->{$key}};
   ${$self->{Dumper}->{$key}} = $value if( defined($result) && defined($value));
   $result;
}


####
#
#
sub DESTORY
{
   my $self = shift;
   $Data::Dumper::Terse = $self->{DumperDefault}->{Terse};
   $Data::Indent = $self->{DumperDefault}->{Indent};
   $Data::Purity = $self->{DumperDefault}->{Purity};
   $Data::Pad = $self->{DumperDefault}->{Pad};
   $Data::Varname = $self->{DumperDefault}->{Varname};
   $Data::Useqq = $self->{DumperDefault}->{Useqq};
   $Data::Freezer = $self->{DumperDefault}->{Freezer};
   $Data::Toaster = $self->{DumperDefault}->{Toaster};
   $Data::Deepcopy = $self->{DumperDefault}->{Deepcopy};
   $Data::Quotekeys = $self->{DumperDefault}->{Quotekeys};
   $Data::Maxdepth = $self->{DumperDefault}->{Maxdepth};
   
}

sub finish { DESTORY( @_ ); };

  
#####
# If the variable is not a scalar,
# stringify it.
#
sub stringify
{
     my $self= '';
     $self = shift @_ if UNIVERSAL::isa($_[0],__PACKAGE__);
     my $restore = 0; 
     unless($self) {  # subroutine call
        $self = new Data::Strify;
        $self->config( 'Terse', 1 );
        $restore = 1; # restore for subroutine call
     }

     my $var = arrayify(@_);
     return $var unless ref($var);
     my $result = Dumper( $var );
     $self->finish( ) if $restore;
     $result;

}


################
# This subroutine walks a data structure, arrayify each level.
#
sub arrayify
{

     ######
     # This subroutine uses no object data; therefore,
     # drop any class or object.
     #
     shift @_ if UNIVERSAL::isa($_[0],__PACKAGE__);

     my %dups = ();

     my @args = @_; # do not want to modify @_ so make a copy
     my $var = (1 < @args) ? arrayify_var( \@args) : arrayify_var( @args );
     return $var unless ref($var) eq 'ARRAY';

     #########
     # Return an array, so going to walk the array, looking
     # for hash and array references to arrayify
     #
     # Use a stack for the walk instead of recusing. Easier
     # to maintain when the data is on a separate stack instead
     # of the call (return) stack and only the pertient data
     # is stored on the separate stack. The return stack does
     # not grow. Instead the separate recure stack grows.
     #
     my @stack = (); 
     my $i = 0;
     for(;;) {

        while($i < @$var) {
             my $ref = ( ref($var->[$i]) ) ? "$var->[$i]"  : '';
             if( $dups{$ref} ) {
                  $var->[$i++] = $dups{$ref};
                  next;
             }
                
             $var->[$i] = arrayify_var( $var->[$i] );
             ####
             # If a HASH or ARRAY reference was found,
             # it was arrayify. Save the place on the
             # current array, and look for HASH and
             # ARRAY references in the new array.
             #
             if(ref($var->[$i]) eq 'ARRAY' ) {
                 $dups{$ref} = $var->[$i] if $ref;
                 push @stack, ($var, $i);
                 $var = $var->[$i];
                 $i = 0;
                 next;
             }
             $i++;
         }

         #####
         # At the end of the current array, so go back
         # working on any array whose work was interupted
         # to work on the current array.
         #
         last unless @stack;   
         $i = pop @stack;
         $i++;  
         $var = pop @stack;
    }
    $var;

}


###########
# The keys for hashes are not sorted. In order to
# establish a canonical form for the  hash, sort
# the hash and convert it to an array with a two
# leading control elements in the array. 
#
# The elements determine if the data is an array
# or a hash and its reference.
#
sub arrayify_var
{

     ######
     # This subroutine uses no object data; therefore,
     # drop any class or object.
     #
     shift @_ if UNIVERSAL::isa($_[0],__PACKAGE__);
     my $var = shift @_;
     use attributes;

     if( ref($var) ) {

         my @array = (); 
         my $class;
         if ( attributes::reftype($var) eq 'HASH') {
             $class = (ref($var) ne 'HASH') ? ref($var) : '';
             @array = ($class,'HASH');
             foreach my $key (sort keys %$var ) {
                 push @array, ($key, $var->{$key} );
             }
             return  \@array;
         }

         elsif( attributes::reftype($var), 'ARRAY') {
             $class = (ref($var) ne 'ARRAY') ? ref($var) : '';
             @array = ($class,'ARRAY');
             push @array, @$var;  
             return \@array;
         }
     }

     $var;

}

1

__END__

=head1 NAME
  
Data::Strify - canoncial string for nested data

=head1 SYNOPSIS

 #####
 # Subroutine interface
 #  
 use Data::Strify qw(stringify arrayify_walk arrayify);

 $string = stringify( @arg );
 @array = arrayify( @arg );
 @array = arrayify_var( @arg );

 #####
 # Class interface
 #
 use Data::Strify;

 $string = Data::Strify->stringify( @arg );
 @array = Data::Strify->arrayify( @arg );
 @array = Data::Strify->arrayify_var( $var );
 
 ##### 
 # Inherit by another class
 #
 use Data::Strify
 use vars qw(@ISA);
 @ISA = qw(Data::Strify);

 $string = __PACKAGE__->stringify( @arg );
 @array = __PACKAGE__->arrayify( @arg );
 @array = __PACKAGE__->arrayify_var( $var );

=head1 DESCRIPTION

The 'Data::Strify' module provides a canoncial string for data
no matter how many nests of arrays and hashes it contains.

=head2 arrayify_var subroutine/method

The purpose of the 'arrayify_var' subroutine/method is
to provide a canoncial representation of hashes with
the keys sorted. This is accomplished by converting
a hash to an array of key value pairs with the keys
sorted. The variable reference is added as the first
member of a arary or arrayified hash to distinguish
a hash from a array in the unlikely event there are 
two data structures, one an array and the other a hash
where the array has the same member as an arrayified
hash.

The 'arrayify_var' subroutine/method converts $var into
an array as follows:

=over

=item reference with underlying 'HASH' data type

Converts a reference whose underlying data type is a 'HASH'
to array whose first member is ref($var), 
and the rest of the members the hash key, value pairs, sorted
by key

=item reference with underlying 'ARRAY' data type

Converts a reference whose underlying data type is a 'ARRAY'
to array whose first member is ref($var), 
and the rest of the members the members of the array

=item otherwise

Leaves $var as is.

=back

=head2 arrayify subroutine/method

The 'arrayify' subroutine/method walks a data structure and
converts all underlying array and hash references to arrays
by applying the 'arrayify_var' subroutine/method.

=head2 stringify subroutine/method

The 'stringify' subroutine/method stringifies a data structure
by applying '&Dump::Dumper' to a data structure arrayified by
the 'arrayify' subroutine/method

=head1 REQUIREMENTS

The requirements are coming.

=head1 DEMONSTRATION

 ~~~~~~ Demonstration overview ~~~~~

Perl code begins with the prompt

 =>

The selected results from executing the Perl Code 
follow on the next lines. For example,

 => 2 + 2
 4

 ~~~~~~ The demonstration follows ~~~~~

 =>     use File::Package;
 =>     my $fp = 'File::Package';

 =>     use Data::Dumper;

 =>     my $uut = 'Data::Strify';
 =>     my $loaded;
 => $uut->import( 'stringify' )
 => stringify( 'string' )
 'string'

 => stringify( 2 )
 2

 => stringify( '2', 'hello', 4 )
 '[
           '',
           'ARRAY',
           '2',
           'hello',
           4
         ]
 '

 => stringify( '2', ['hello', 'world'], 4 )
 '[
           '',
           'ARRAY',
           '2',
           [
             '',
             'ARRAY',
             'hello',
             'world'
           ],
           4
         ]
 '

 => my $obj = bless { To => 'nobody', From => 'nobody'}, 'Class::None'
 => stringify( '2', { msg => ['hello', 'world'] , header => $obj } )
 '[
           '',
           'ARRAY',
           '2',
           [
             '',
             'HASH',
             'header',
             [
               'Class::None',
               'HASH',
               'From',
               'nobody',
               'To',
               'nobody'
             ],
             'msg',
             [
               '',
               'ARRAY',
               'hello',
               'world'
             ]
           ]
         ]
 '

 => my $array1 = ['Class::None', 'HASH', 'From', 'nobody', 'To', 'nobody' ]
 => stringify( { msg => ['hello', 'world'] , header => $obj }, {msg => [ 'body' ], header => $obj} )
 '[
           '',
           'ARRAY',
           [
             '',
             'HASH',
             'header',
             [
               'Class::None',
               'HASH',
               'From',
               'nobody',
               'To',
               'nobody'
             ],
             'msg',
             [
               '',
               'ARRAY',
               'hello',
               'world'
             ]
           ],
           [
             '',
             'HASH',
             'header',
             $VAR1->[2][3],
             'msg',
             [
               '',
               'ARRAY',
               'body'
             ]
           ]
         ]
 '

 =>      $Data::Dumper::Terse = 0;
 =>      my $strify = new Data::Strify;
 =>  $strify->config('Terse', 1 )
 0

 =>  0
 0

 => $strify->config( 'Terse' )
 1

 =>  0
 0

 => $Data::Dumper::Terse
 1

 => $strify->finish( )
 => $Data::Dumper::Terse
 0


=head1 QUALITY ASSURANCE

Running the test script 'Strify.t' found in
the "Data-Strify-$VERSION.tar.gz" distribution file verifies
the requirements for this module.

All testing software and documentation
stems from the 
Software Test Description (L<STD|Docs::US_DOD::STD>)
program module 't::Data::Strify',
found in the distribution file 
"Data-Strify-$VERSION.tar.gz". 

The 't::Data::Strify' L<STD|Docs::US_DOD::STD> POD contains
a tracebility matix between the
requirements established above for this module, and
the test steps identified by a
'ok' number from running the 'Strify.t'
test script.

The t::Data::Strify' L<STD|Docs::US_DOD::STD>
program module '__DATA__' section contains the data 
to perform the following:

=over 4

=item *

to generate the test script 'Strify.t'

=item *

generate the tailored 
L<STD|Docs::US_DOD::STD> POD in
the 't::Data::Strify' module, 

=item *

generate the 'Strify.d' demo script, 

=item *

replace the POD demonstration section
herein with the demo script
'Strify.d' output, and

=item *

run the test script using Test::Harness
with or without the verbose option,

=back

To perform all the above, prepare
and run the automation software as 
follows:

=over 4

=item *

Install "Test_STDmaker-$VERSION.tar.gz"
from one of the respositories only
if it has not been installed:

=over 4

=item *

http://www.softwarediamonds/packages/

=item *

http://www.perl.com/CPAN-local/authors/id/S/SO/SOFTDIA/

=back
  
=item *

manually place the script tmake.pl
in "Test_STDmaker-$VERSION.tar.gz' in
the site operating system executable 
path only if it is not in the 
executable path

=item *

place the 't::Data::Strify' at the same
level in the directory struture as the
directory holding the 'Data::Strify'
module

=item *

execute the following in any directory:

 tmake -test_verbose -replace -run -pm=t::Data::Strify

=back

=head1 NOTES

=head2 FILES

The installation of the
"Data-Strify-$VERSION.tar.gz" distribution file
installs the 'Docs::Site_SVD::Data_Strify'
L<SVD|Docs::US_DOD::SVD> program module.

The __DATA__ data section of the 
'Docs::Site_SVD::Data_Strify' contains all
the necessary data to generate the POD
section of 'Docs::Site_SVD::Data_Strify' and
the "Data-Strify-$VERSION.tar.gz" distribution file.

To make use of the 
'Docs::Site_SVD::Data_Strify'
L<SVD|Docs::US_DOD::SVD> program module,
perform the following:

=over 4

=item *

install "ExtUtils-SVDmaker-$VERSION.tar.gz"
from one of the respositories only
if it has not been installed:

=over 4

=item *

http://www.softwarediamonds/packages/

=item *

http://www.perl.com/CPAN-local/authors/id/S/SO/SOFTDIA/

=back

=item *

manually place the script vmake.pl
in "ExtUtils-SVDmaker-$VERSION.tar.gz' in
the site operating system executable 
path only if it is not in the 
executable path

=item *

Make any appropriate changes to the
__DATA__ section of the 'Docs::Site_SVD::Data_Strify'
module.
For example, any changes to
'Data::Strify' will impact the
at least 'Changes' field.

=item *

Execute the following:

 vmake readme_html all -pm=Docs::Site_SVD::Data_Strify

=back

=head2 AUTHOR

The holder of the copyright and maintainer is

E<lt>support@SoftwareDiamonds.comE<gt>

=head2 COPYRIGHT NOTICE

Copyrighted (c) 2002 Software Diamonds

All Rights Reserved

=head2 BINDING REQUIREMENTS NOTICE

Binding requirements are indexed with the
pharse 'shall[dd]' where dd is an unique number
for each header section.
This conforms to standard federal
government practices, L<US DOD 490A 3.2.3.6|Docs::US_DOD::STD490A/3.2.3.6>.
In accordance with the License, Software Diamonds
is not liable for any requirement, binding or otherwise.

=head2 LICENSE

Software Diamonds permits the redistribution
and use in source and binary forms, with or
without modification, provided that the 
following conditions are met: 

=over 4

=item 1

Redistributions of source code must retain
the above copyright notice, this list of
conditions and the following disclaimer. 

=item 2

Redistributions in binary form must 
reproduce the above copyright notice,
this list of conditions and the following 
disclaimer in the documentation and/or
other materials provided with the
distribution.

=back

SOFTWARE DIAMONDS, http::www.softwarediamonds.com,
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

=for html
<p><br>
<!-- BLK ID="NOTICE" -->
<!-- /BLK -->
<p><br>
<!-- BLK ID="OPT-IN" -->
<!-- /BLK -->
<p><br>
<!-- BLK ID="EMAIL" -->
<!-- /BLK -->
<p><br>
<!-- BLK ID="COPYRIGHT" -->
<!-- /BLK -->
<p><br>
<!-- BLK ID="LOG_CGI" -->
<!-- /BLK -->
<p><br>

=cut

### end of file ###