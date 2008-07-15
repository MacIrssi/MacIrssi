use ExtUtils::MakeMaker;

WriteMakefile('NAME' => 'Irssi::UI',
              'LIBS' => '',
	      'OBJECT' => '$(O_FILES)',
              'TYPEMAPS' => ['../common/typemap'],
              'INC' => '-I../../.. -I../../../src -I../../../src/core -I../../../src/fe-common/core -I/sw/include/glib-2.0 -I/sw/lib/glib-2.0/include  ',
	      'VERSION_FROM' => './UI.pm');
