use ExtUtils::MakeMaker;

WriteMakefile('NAME' => 'Irssi::Irc',
              'LIBS' => '',
	      'OBJECT' => '$(O_FILES)',
              'TYPEMAPS' => ['../common/typemap'],
              'INC' => '-I../../.. -I../../../src -I../../../src/core -I../../../src/irc/core -I../../../src/irc -I/sw/include/glib-2.0 -I/sw/lib/glib-2.0/include  ',
	      'VERSION_FROM' => './Irc.pm');
