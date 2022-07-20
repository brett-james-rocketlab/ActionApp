# need PlistBuddy installed
appName=ActionApp
appTestName="${appName}Tests"
currentIOSPatchVersion=$(usr/libexec/PlistBuddy -c "Print :CFBundleVersion" ios/$appName/info.plist)
currentIOSVersion=$(usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" ios/$appName/info.plist)
currentAndroidVersion=$(cat android/app/build.gradle | grep -m1 'versionName' | cut -d '"' -f2)
currentVersionCode=$(cat android/app/build.gradle | grep -m1 'versionCode' | tr -s ' ' | cut -d ' ' -f3)

currentIOSFullVersion="$currentIOSVersion.$currentIOSPatchVersion"
currentIOSMajorVersion=${currentIOSVersion%.*}
currentIOSMinorVersion=${currentIOSVersion##*.}

echo "current ios major version: $currentIOSMajorVersion"
echo "current ios minor version: $currentIOSMinorVersion"
echo "current ios patch version: $currentIOSPatchVersion"
echo "current ios pbxproj patch version: $currentPbxProjPatchVersion"
echo "current ios version: $currentIOSFullVersion"
echo "current android version: $currentAndroidVersion"
echo "current android version code: $currentVersionCode"

# plistFiles=$(find ios/ -type f -name info.plist)
# echo "files $plistFiles"

increaseAndroidVersion() {
    newAndroidVersionCode=$(awk -F. '{ print ($1*10000000)+($2*100000+$3) }' <<< $1)
    # Set versionName and versionCode in app build.gradle for 3 digits
    sed -i -E 's/versionName "([0-9]+.[0-9]+.[0-9]+)"/versionName "'$1'"/' android/app/build.gradle
    # Works for code with 8 length
    sed -i -E "s/versionCode [0-9]{0,8}$/versionCode $newAndroidVersionCode/" android/app/build.gradle
    echo "version name: $1"
    echo "version code: $newAndroidVersionCode"
}

# increaseIOSVersion() {
#     newAndroidVersionCode=$(awk -F. '{ print ($1*10000000)+($2*100000+$3) }' <<< $1)
#     # Set patch version in IOS info.plist
#     /usr/libexec/PlistBuddy -c "Set :CFBundleVersion '${newPatchVersion}'" ios/$appName/info.plist

#     # Set patch version in IOS pbxproj
#     sed -i '' -e "s/CURRENT_PROJECT_VERSION \= [^\;]*\;/CURRENT_PROJECT_VERSION = ${newPatchVersion};/" ios/${appName}.xcodeproj/project.pbxproj
#     echo "version name: $1"
#     echo "version code: $newAndroidVersionCode"
# }

# setInitialVersion() {
#     # Set initial version name
#     sed -i '' -E 's/versionName "[0-9]"/versionName "1.0.0"/' android/app/build.gradle
#     # Set initial version code
#     sed -i '' -E "s/versionCode [0-9]$/versionCode 10000000/" android/app/build.gradle
#     # Set initial version in IOS info.plist
#     /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1" ios/$appName/info.plist
#     /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.1" ios/$appName/info.plist
#     /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1" ios/$appTestName/info.plist
#     /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.1" ios/$appTestName/info.plist
#     # Set initial version in IOS pbxproj
#     sed -i '' -e "s/CURRENT_PROJECT_VERSION \= [^\;]*\;/CURRENT_PROJECT_VERSION = 1;/" ios/${appName}.xcodeproj/project.pbxproj
# }

# increaseBuildNumber() {
#     if [ $1 == 'patch' ]; then
#         newPatchVersion=$(($currentIOSPatchVersion + 1))
#         currentMinorVersionCode=$(($currentIOSMinorVersion * 1000))

#         # Set patch version in IOS info.plist
#         # /usr/libexec/PlistBuddy -c "Set :CFBundleVersion '${newPatchVersion}'" ios/$appName/info.plist

#         # Set patch version in IOS pbxproj
#         # sed -i '' -e "s/CURRENT_PROJECT_VERSION \= [^\;]*\;/CURRENT_PROJECT_VERSION = ${newPatchVersion};/" ios/${appName}.xcodeproj/project.pbxproj

#         # Set versionName and versionCode in app build.gradle
#         sed -i '' -E 's/versionName "[0-9]?.[0-9]?.[0-9]"/versionName "'$currentIOSMajorVersion.$currentIOSMinorVersion.$newPatchVersion'"/' android/app/build.gradle
#         sed -i '' -E "s/versionCode [0-9]{0,8}$/versionCode $currentIOSMajorVersion$currentMinorVersionCode$newPatchVersion/" android/app/build.gradle

#         echo "new patch version $newPatchVersion"
#         echo "test patch $testPatch"
#     elif [ $1 == 'major' ]; then
#         newIOSMajorVersion=$(($currentIOSMajorVersion + 1))
#         newIOSVersion="$newIOSMajorVersion.$currentIOSMinorVersion"
#         /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString '${newIOSVersion}'" ios/$appName/info.plist
#         echo "new Version $newIOSVersion"
#     else
#         # newIOSMinorVersion=$(($currentIOSMinorVersion + 1))
#         # newIOSVersion="$currentIOSMajorVersion.$newIOSMinorVersion"
#         # /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString '${newIOSVersion}'" ios/$appName/info.plist
#         echo "please specify an increment version type"
#     fi
# }

increaseAndroidVersion "4.1.5"
# updatedIOSPatchVersion=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" ios/$appName/info.plist)
# updatedIOSVersion=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" ios/$appName/info.plist)
# updatedAndroidVersionCode=$(cat android/app/build.gradle | grep -m1 'versionCode' | tr -s ' ' | cut -d ' ' -f3)
# updatedIOSFullVersion="$updatedIOSVersion.$updatedIOSPatchVersion"
# echo "updated ios version: $updatedIOSFullVersion"
# echo "updated android version code: $updatedAndroidVersionCode"
# getVersion() {
#     currentIOSFullVersion="$currentIOSVersion.$currentIOSPatchVersion"
#     echo "current ios version: $currentIOSFullVersion"
#     echo "current android version: $currentAndroidVersion"
#     # [[ $currentIOSVersion == "1.0" ]] && echo "ios version got" || echo "ios version failed"
#     # [[ $currentAndroidVersion == "1.0" ]] && echo "android version got" || echo "android version failed"
#     if [ $currentAndroidVersion = $currentIOSFullVersion ]; then
#         echo "true"
#     else
#         echo "false"
#     fi
# }

# getVersion