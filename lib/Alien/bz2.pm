package Alien::bz2;

use strict;
use warnings;
use File::ShareDir ();
use File::Spec;
use Alien::bz2::ConfigData;
use constant _share_dir => File::ShareDir::dist_dir('Alien-bz2');
use constant _alien_bz2012 => 1;

# ABSTRACT: Build and make available bz2
# VERSION

my $cf = 'Alien::bz2::ConfigData';

sub _catfile {
  my $path = File::Spec->catfile(@_);
  $path =~ s{\\}{/}g if $^O eq 'MSWin32';
  $path;
}

sub _catdir {
  my $path = File::Spec->catdir(@_);
  $path =~ s{\\}{/}g if $^O eq 'MSWin32';
  $path;
}

=head1 SYNOPSIS

Build.PL

 use Alien::bz2;
 use Module::Build;
 
 my $alien = Alien::bz2->new;
 my $build = Module::Build->new(
   ...
   extra_compiler_flags => $alien->cflags,
   extra_linker_flags   => $alien->libs,
   ...
 );
 
 $build->create_build_script;

Makefile.PL

 use Alien::bz2;
 use ExtUtils::MakeMaker;
 
 my $alien = Alien::bz2;
 WriteMakefile(
   ...
   CFLAGS => $alien->cflags,
   LIBS   => $alien->libs,
 );

FFI::Raw

 use Alien::bz2;
 use FFI::Raw;
 
 my($dll) = Alien::bz2->new->dlls;
 FFI::Raw->new($dll, 'BZ2_bzlibVersion', FFI::Raw::str);

FFI::Sweet

 use Alien::bz2;
 use FFI::Sweet;
 
 ffi_lib( Alien::bz2->new->dlls );
 attach_function 'BZ2_bzlibVersion', [], _str;

=head1 DESCRIPTION

If you just want to compress or decompress bzip2 data in Perl you
probably want one of L<Compress::Bzip2>, L<Compress::Raw::Bzip2>
or L<IO::Compress::Bzip2>.

This distribution installs bz2 so that it can be used by other Perl
distributions.  If already installed for your operating system, and it can
be found, this distribution will use the bz2 that comes with your
operating system, otherwise it will download it from the internet, build
and install it.

If you set the environment variable ALIEN_BZ2 to 'share', this
distribution will ignore any system bz2 found, and build from
source instead.  This may be desirable if your operating system comes
with a very old version of bz2 and an upgrade path for the 
system bz2 is not possible.

=cut

sub new
{
  my($class) = @_;
  bless {}, $class;
}

=head1 METHODS

=head2 cflags

Returns the C compiler flags necessary to build against bz2.

Returns flags as a list in list context and combined into a string in
scalar context.

=cut

sub cflags
{
  my($class) = @_;
  my @cflags = @{ $cf->config("cflags") };
  unshift @cflags, '-I' . _catdir(_share_dir, 'bz2012', 'include' )
    if $class->install_type eq 'share';
  wantarray ? @cflags : "@cflags";
}

=head2 libs

Returns the library flags necessary to build against bz2.

Returns flags as a list in list context and combined into a string in
scalar context.

=cut

sub libs
{
  my($class) = @_;
  my @libs = @{ $cf->config("libs") };
  if($class->install_type eq 'share')
  {
    if($cf->config('msvc'))
    {
      unshift @libs, '/libpath:' . _catdir(_share_dir, 'bz2012', 'lib');
    }
    else
    {
      unshift @libs, '-L' . _catdir(_share_dir, 'bz2012', 'lib');
    }
  }
  wantarray ? @libs : "@libs";
}

=head2 dlls

Returns a list of dynamic libraries (usually a list of just one library)
that make up bz2.  This can be used for L<FFI::Raw>.

Returns just the first dynamic library found in scalar context.

=cut

sub dlls
{
  my($class) = @_;
  my @list;
  if($class->install_type eq 'system')
  {
    require Alien::bz2::Installer;
    @list = Alien::bz2::Installer->system_install( type => 'ffi', alien => 0 )->dlls;
  }
  else
  {
    @list = map { _catfile(_share_dir, 'bz2012', 'dll', $_) }
            @{ $cf->config("dlls") };
  }
  wantarray ? @list : $list[0];
}

=head2 version

Returns the version of bz2.

=cut

sub version
{
  $cf->config("version");
}

=head2 install_type

Returns the install type, one of either C<system> or C<share>.

=cut

sub install_type
{
  $cf->config("install_type");
}

=head1 SEE ALSO

=over 4

=item L<Alien::bz2::Installer>

=item L<Compress::Bzip2>

=item L<Compress::Raw::Bzip2>

=item L<IO::Compress::Bzip2>

=back

=cut

1;
