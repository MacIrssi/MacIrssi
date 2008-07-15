use ExtUtils::MakeMaker;

WriteMakefile('NAME' => 'Irssi',
              'LIBS' => '',
	      'OBJECT' => '$(O_FILES)',
              'INC' => '-I../../.. -I../../.. -I../../../src -I../../../src/core -I/sw/include/glib-2.0 -I/sw/lib/glib-2.0/include  ',
	      'VERSION_FROM' => './Irssi.pm');
