# prerequisite
# chmod +x ./build_script.sh

set -e

PROJECT_NAME="SendbirdUserManager"
FRAMEWORK_NAME="${PROJECT_NAME}.framework"
XCFRAMEWORK_NAME="${PROJECT_NAME}.xcframework"

BUILD_DIR="build_artifacts"
IPHONEOS_FRAMEWORK_DIR="${BUILD_DIR}/iphone.xcarchive/Products/Library/Frameworks"
SIMULATOR_FRAMEWORK_DIR="${BUILD_DIR}/simulator.xcarchive/Products/Library/Frameworks"

echo "Removing Cache"

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

echo "Building project"

xcodebuild archive \
    -scheme $PROJECT_NAME \
    -configuration Release \
    -sdk iphoneos \
    -archivePath "./${BUILD_DIR}/iphone" \
    clean \
    SKIP_INSTALL=NO
        
xcodebuild archive \
    -scheme $PROJECT_NAME \
    -configuration Release \
    -sdk iphonesimulator \
    -archivePath "./${BUILD_DIR}/simulator" \
    clean \
    SKIP_INSTALL=NO

xcodebuild -create-xcframework \
    -framework "$(pwd)/${IPHONEOS_FRAMEWORK_DIR}/${FRAMEWORK_NAME}" \
    -framework "$(pwd)/${SIMULATOR_FRAMEWORK_DIR}/${FRAMEWORK_NAME}"  \
    -output "${BUILD_DIR}/${XCFRAMEWORK_NAME}"
    
cd $BUILD_DIR

echo "Finishing up..."
zip -r "../${XCFRAMEWORK_NAME}.zip" "${XCFRAMEWORK_NAME}" # Zip xcframework

cd ..

rm -rf $BUILD_DIR

