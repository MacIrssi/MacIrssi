#!/bin/sh

# Fix so that the executable links against the bundled libraries
echo "Fixing library name paths"

LIBPATH=$SRCROOT/Frameworks/MILibs/build/Release/lib

#MacIrssi
install_name_tool -change $LIBPATH/libgmodule-2.0.0.dylib @executable_path/../Frameworks/libgmodule-2.0.0.dylib "$TARGET_BUILD_DIR/MacIrssi.app/Contents/MacOS/MacIrssi"
install_name_tool -change $LIBPATH/libglib-2.0.0.dylib @executable_path/../Frameworks/libglib-2.0.0.dylib "$TARGET_BUILD_DIR/MacIrssi.app/Contents/MacOS/MacIrssi"
install_name_tool -change $LIBPATH/libintl.8.dylib @executable_path/../Frameworks/libintl.8.0.2.dylib "$TARGET_BUILD_DIR/MacIrssi.app/Contents/MacOS/MacIrssi"

#libglib
install_name_tool -change $LIBPATH/libintl.8.dylib @executable_path/../Frameworks/libintl.8.0.2.dylib "$TARGET_BUILD_DIR/MacIrssi.app/Contents/Frameworks/libglib-2.0.0.dylib"

#libgmodule
install_name_tool -change $LIBPATH/libglib-2.0.0.dylib @executable_path/../Frameworks/libglib-2.0.0.dylib "$TARGET_BUILD_DIR/MacIrssi.app/Contents/Frameworks/libgmodule-2.0.0.dylib"
install_name_tool -change $LIBPATH/libintl.8.dylib @executable_path/../Frameworks/libintl.8.0.2.dylib "$TARGET_BUILD_DIR/MacIrssi.app/Contents/Frameworks/libgmodule-2.0.0.dylib"

exit 0
