use strict;
use warnings;
use Test::More;
use Alien::bz2;

BEGIN {
  plan skip_all => 'test requires Test::CChecker'
    unless eval q{ use Test::CChecker; 1 };
}

plan tests => 1;

compile_with_alien 'Alien::bz2';

compile_output_to_note;

compile_run_ok do { local $/; <DATA> }, "basic compile test";

__DATA__

#include <bzlib.h>
#include <stdio.h>

int
main(int argc, char *argv[])
{
  printf("version = %s\n", BZ2_bzlibVersion());
  return 0;
}
