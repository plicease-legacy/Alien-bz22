package My::ModuleBuild;

use strict;
use warnings;
use base qw( Module::Build );
use Config;
use Alien::bz2::Installer;
use File::Spec;
use FindBin ();

my $type = eval { require FFI::Raw } ? 'both' : 'compile';

# Note: for historical / hysterical reasons, the install type is one of:
# 1. system, use the system bz2
# 2. share, build your own bz2, both static and shared
#    the static version will be used for XS modules and the shared one
#    will be used for FFI modules.

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

sub new
{
  my($class, %args) = @_;

  my $system;

  unless(($ENV{ALIEN_BZ2} || 'system') eq 'share')
  {
    $system = eval {
      Alien::bz2::Installer->system_install(
        type  => $type,
        alien => 0,
      )
    };
  }

  unless(defined $system)
  {
    my $prereqs = Alien::bz2::Installer->build_requires;  
    while(my($mod,$ver) = each %$prereqs)
    {
      $args{build_requires}->{$mod} = $ver;
    }
  }

  my $self = $class->SUPER::new(%args);

  $self->config_data( name => 'bz2' );
  $self->config_data( already_built => 0 );
  $self->config_data( msvc => $^O eq 'MSWin32' && $Config{cc} =~ /cl(\.exe)?$/i ? 1 : 0 );
  
  $self->add_to_cleanup( '_alien', 'share/bz2012' );
  
  if(defined $system)
  {
    print "Found bz2 " . $system->version . " from system\n";
    print "You can set ALIEN_BZ2=share to force building from source\n";
    $self->config_data( install_type => 'system' );
    $self->config_data( cflags       => $system->cflags );
    $self->config_data( libs         => $system->libs );
    $self->config_data( version      => $system->version );
  }
  else
  {
    print "Did not find working bz2, will download and install from the Internet\n";
    $self->config_data( install_type => 'share' );
  }
  
  $self;
}

sub ACTION_build
{
  my $self = shift;
  
  if($self->config_data('install_type') eq 'share')
  {
    unless($self->config_data('already_built'))
    {
      my $build_dir = _catdir($FindBin::Bin, '_alien');
      mkdir $build_dir unless -d $build_dir;
      my $prefix = _catdir($FindBin::Bin, 'share', 'bz2012' );
      mkdir $prefix unless -d $prefix;
      my $build = Alien::bz2::Installer->build_install( $prefix, dir => $build_dir );
      $self->config_data( cflags => [grep !/^-I/, @{ $build->cflags }] );
      $self->config_data( libs =>   [grep !/^-L/, @{ $build->libs }] );
      if($self->config_data('msvc'))
      {
        $self->config_data( libs =>   [grep !/^(\/|-)libpath/i, @{ $build->libs }] );
      }
      $self->config_data( version => $build->version );

      printf "cflags: %s\n", join ' ', @{ $self->config_data('cflags') };
      printf "libs:   %s\n", join ' ', @{ $self->config_data('libs') };
      printf "msvc:   %d\n", $self->config_data('msvc');
      
      do {
        opendir my $dh, _catdir($prefix, 'dll');
        my @list = grep { ! -l _catfile($prefix, 'dll', $_) }
                   grep { /\.so/ || /\.(dll|dylib)$/ }
                   grep !/^\./,
                   sort
                   readdir $dh;
        closedir $dh;
        print "dlls:\n";
        print "  - $_\n" for @list;
        $self->config_data( dlls => \@list );
      };
      
      $self->config_data( already_built => 1 );
    }
  }
  
  $self->SUPER::ACTION_build(@_);
}

1;
