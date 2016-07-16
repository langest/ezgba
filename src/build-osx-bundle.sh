#!/usr/bin/env bash

function make_info_plist() {
    local write_path="${1}"

    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "${write_path}"
    echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" >> "${write_path}"
    echo "<plist version=\"1.0\">" >> "${write_path}"
    echo "<dict>" >> "${write_path}"
    echo "    <key>CFBundleDisplayName</key>" >> "${write_path}"
    echo "    <string>${CFBUNDLE_DISPLAY_NAME}</string>" >> "${write_path}"
    echo "    <key>CFBundleName</key>" >> "${write_path}"
    echo "    <string>${CFBUNDLE_NAME}</string>" >> "${write_path}"
    echo "    <key>CFBundleExecutable</key>" >> "${write_path}"
    echo "    <string>${CFBUNDLE_EXECUTABLE_WRAPPER}</string>" >> "${write_path}"
    echo "    <key>CFBundleIdentifier</key>" >> "${write_path}"
    echo "    <string>${CFBUNDLE_IDENTIFIER}</string>" >> "${write_path}"
    echo "    <key>CFBundleVersion</key>" >> "${write_path}"
    echo "    <string>${CFBUNDLE_VERSION}</string>" >> "${write_path}"
    echo "    <key>CFBundlePackageType</key>" >> "${write_path}"
    echo "    <string>APPL</string>" >> "${write_path}"
    echo "    <key>CFBundleSignature</key>" >> "${write_path}"
    echo "    <string>${CFBUNDLE_SIGNATURE}</string>" >> "${write_path}"
    echo "    <key>CFBundleIconFile</key>" >> "${write_path}"
    echo "    <string>${CFBUNDLE_NAME}.icns</string>" >> "${write_path}"
    echo "</dict>" >> "${write_path}"
    echo "</plist>" >> "${write_path}"
}

function make_executable_wrapper() {
    local write_path="${1}"
    echo "#!/usr/bin/env bash" > "${write_path}"
    echo "\"\${0%/*}/${CFBUNDLE_EXECUTABLE}\"" >> "${write_path}"
}


CFBUNDLE_EXECUTABLE="app"
CFBUNDLE_EXECUTABLE_WRAPPER="_app"
CFBUNDLE_DISPLAY_NAME="ezgba"
CFBUNDLE_IDENTIFIER="com.foobar_.ezgba"
CFBUNDLE_VERSION="@ezgba_VERSION@"
CFBUNDLE_NAME="ezgba"
CFBUNDLE_SIGNATURE="????"

READ_EXECUTABLE="${1}"
READ_ICNS="${2}"
BUNDLE_PATH="${3}"

: "${BUNDLE_PATH:?Bundle path not set.}"

[ -d "${BUNDLE_PATH}" ] && [ -n "${BUNDLE_PATH}" ] && rm -rf "${BUNDLE_PATH}"
mkdir -p "${BUNDLE_PATH}/Contents/MacOS"
mkdir -p "${BUNDLE_PATH}/Contents/Resources"
chmod 755 "${BUNDLE_PATH}/Contents/MacOS"
chmod 755 "${BUNDLE_PATH}/Contents/Resources"

# For some reason, a wrapper is needed to make the bundle executable.
make_executable_wrapper "${BUNDLE_PATH}/Contents/MacOS/${CFBUNDLE_EXECUTABLE_WRAPPER}"
chmod 755 "${BUNDLE_PATH}/Contents/MacOS/${CFBUNDLE_EXECUTABLE_WRAPPER}"

cp -f "${READ_EXECUTABLE}" "${BUNDLE_PATH}/Contents/MacOS/${CFBUNDLE_EXECUTABLE}"
chmod 755 "${BUNDLE_PATH}/Contents/MacOS/${CFBUNDLE_EXECUTABLE}"

cp -f "${READ_ICNS}" "${BUNDLE_PATH}/Contents/Resources/${CFBUNDLE_NAME}.icns"
chmod 644 "${BUNDLE_PATH}/Contents/Resources/${CFBUNDLE_NAME}.icns"

# PkgInfo is optional, but improves Finder performance.
echo "APPL${CFBUNDLE_SIGNATURE}" > "${BUNDLE_PATH}/Contents/PkgInfo"
chmod 644 "${BUNDLE_PATH}/Contents/PkgInfo"

make_info_plist "${BUNDLE_PATH}/Contents/Info.plist"
chmod 644 "${BUNDLE_PATH}/Contents/Info.plist"

# This makes Finder refresh its icons.
mv "${BUNDLE_PATH}" "${BUNDLE_PATH}.refresh"
mv "${BUNDLE_PATH}.refresh" "${BUNDLE_PATH}"
touch "${BUNDLE_PATH}"
