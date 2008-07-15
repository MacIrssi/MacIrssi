#!/bin/sh

# Fix so that the executable links against the bundled libraries
echo "Fixing library name paths"

#MacIrssi
install_name_tool -change /usr/local/lib/libgmodule-2.0.0.dylib @executable_path/../Frameworks/libgmodule-2.0.dylib ./build/Development/MacIrssi.app/Contents/MacOS/MacIrssi
install_name_tool -change /usr/local/lib/libglib-2.0.0.dylib @executable_path/../Frameworks/libglib-2.0.dylib ./build/Development/MacIrssi.app/Contents/MacOS/MacIrssi
install_name_tool -change /sw/lib/libiconv.2.dylib @executable_path/../Frameworks/libiconv.dylib ./build/Development/MacIrssi.app/Contents/MacOS/MacIrssi
install_name_tool -change /sw/lib/libintl.3.dylib @executable_path/../Frameworks/libintl.dylib ./build/Development/MacIrssi.app/Contents/MacOS/MacIrssi

#Theme preview daemon
install_name_tool -change /usr/local/lib/libgmodule-2.0.0.dylib @executable_path/../Frameworks/libgmodule-2.0.dylib ./build/Development/MacIrssi.app/Contents/ThemePreviewDaemon/ThemePreviewDaemon
install_name_tool -change /usr/local/lib/libglib-2.0.0.dylib @executable_path/../Frameworks/libglib-2.0.dylib ./build/Development/MacIrssi.app/Contents/ThemePreviewDaemon/ThemePreviewDaemon
install_name_tool -change /sw/lib/libiconv.2.dylib @executable_path/../Frameworks/libiconv.dylib ./build/Development/MacIrssi.app/Contents/ThemePreviewDaemon/ThemePreviewDaemon
install_name_tool -change /sw/lib/libintl.3.dylib @executable_path/../Frameworks/libintl.dylib ./build/Development/MacIrssi.app/Contents/ThemePreviewDaemon/ThemePreviewDaemon

#libglib
install_name_tool -change /sw/lib/libiconv.2.dylib @executable_path/../Frameworks/libiconv.dylib ./build/Development/MacIrssi.app/Contents/Frameworks/libglib-2.0.dylib
install_name_tool -change /sw/lib/libintl.3.dylib @executable_path/../Frameworks/libintl.dylib ./build/Development/MacIrssi.app/Contents/Frameworks/libglib-2.0.dylib

#libgmodule
install_name_tool -change /usr/local/lib/libglib-2.0.0.dylib @executable_path/../Frameworks/libglib-2.0.dylib ./build/Development/MacIrssi.app/Contents/Frameworks/libgmodule-2.0.dylib
install_name_tool -change /sw/lib/libiconv.2.dylib @executable_path/../Frameworks/libiconv.dylib ./build/Development/MacIrssi.app/Contents/Frameworks/libgmodule-2.0.dylib
install_name_tool -change /sw/lib/libintl.3.dylib @executable_path/../Frameworks/libintl.dylib ./build/Development/MacIrssi.app/Contents/Frameworks/libgmodule-2.0.dylib

#libintl
install_name_tool -change /sw/lib/libiconv.2.dylib @executable_path/../Frameworks/libiconv.dylib ./build/Development/MacIrssi.app/Contents/Frameworks/libintl.dylib

exit 0
