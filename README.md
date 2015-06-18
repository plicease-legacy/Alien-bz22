# Alien::bz2

Build and make available bz2

# SYNOPSIS

Build.PL

    use Alien::bz2;
    use Module::Build;
    
    my $alien = Alien::bz2->new;
    my $build = Module::Build->new(
      ...
      extra_compiler_flags => [$alien->cflags],
      extra_linker_flags   => [$alien->libs],
      ...
    );
    
    $build->create_build_script;

Makefile.PL

    use Alien::bz2;
    use ExtUtils::MakeMaker;
    
    my $alien = Alien::bz2;
    WriteMakefile(
      ...
      CCFLAGS => scalar $alien->cflags,
      LIBS   => [$alien->libs],
    );

FFI::Platypus

    use Alien::bz2;
    use FFI::Platypus;
    
    my $ffi = FFI::Platypus->new(lib => [Alien::bz2->new->dlls]);
    $ffi->attach( BZ2_bzlibVersion => [] => 'string' );

# DESCRIPTION

If you just want to compress or decompress bzip2 data in Perl you
probably want one of [Compress::Bzip2](https://metacpan.org/pod/Compress::Bzip2), [Compress::Raw::Bzip2](https://metacpan.org/pod/Compress::Raw::Bzip2)
or [IO::Compress::Bzip2](https://metacpan.org/pod/IO::Compress::Bzip2).

This distribution installs bz2 so that it can be used by other Perl
distributions.  If already installed for your operating system, and it can
be found, this distribution will use the bz2 that comes with your
operating system, otherwise it will download it from the Internet, build
and install it.

If you set the environment variable `ALIEN_BZ2` to 'share', this
distribution will ignore any system bz2 found, and build from
source instead.  This may be desirable if your operating system comes
with a very old version of bz2 and an upgrade path for the 
system bz2 is not possible.

This distribution also honors the `ALIEN_FORCE` environment variable used
by [Alien::Base](https://metacpan.org/pod/Alien::Base).  Setting `ALIEN_FORCE` has the same effect as setting
`ALIEN_BZ2` to 'share'.

# METHODS

## cflags

Returns the C compiler flags necessary to build against bz2.

Returns flags as a list in list context and combined into a string in
scalar context.

## libs

Returns the library flags necessary to build against bz2.

Returns flags as a list in list context and combined into a string in
scalar context.

## dlls

Returns a list of dynamic libraries (usually a list of just one library)
that make up bz2.  This can be used for [FFI::Raw](https://metacpan.org/pod/FFI::Raw).

Returns just the first dynamic library found in scalar context.

## version

Returns the version of bz2.

## install\_type

Returns the install type, one of either `system` or `share`.

# SEE ALSO

- [Alien::bz2::Installer](https://metacpan.org/pod/Alien::bz2::Installer)
- [Compress::Bzip2](https://metacpan.org/pod/Compress::Bzip2)
- [Compress::Raw::Bzip2](https://metacpan.org/pod/Compress::Raw::Bzip2)
- [IO::Compress::Bzip2](https://metacpan.org/pod/IO::Compress::Bzip2)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
