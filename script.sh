#!/bin/bash

set -and

source .env

set +a

get_android_version() {
    currentAndroidVersion=$(cat android/app/build.gradle | grep -m1 'versionName' | cut -d '"' -f2)
    currentVersionCode=$(cat android/app/build.gradle | grep -m1 'versionCode' | tr -s ' ' | cut -d ' ' -f3)

    echo "current android version: $currentAndroidVersion"
    echo "current android version code: $currentVersionCode"
}

get_ios_version() {
    currentIOSPatchVersion=$(cat ios/ActionApp/Info.plist | awk '/CFBundleVersion/{getline; print}' | awk -F "[<>]" '{print $3}')
    currentIOSVersion=$(cat ios/ActionApp/Info.plist | awk '/CFBundleShortVersionString/{getline; print}' | awk -F "[<>]" '{print $3}')

    currentIOSFullVersion="$currentIOSVersion.$currentIOSPatchVersion"
    currentIOSMajorVersion=${currentIOSVersion%.*}
    currentIOSMinorVersion=${currentIOSVersion##*.}

    echo "current ios version: $currentIOSFullVersion"
}

increase_android_version() {
    newAndroidVersionCode=$(awk -F. '{ print ($1*10000000)+($2*100000+$3) }' <<< $1)
    # Set versionName and versionCode in app build.gradle for 3 digits
    sed -i.bak -E 's/versionName "([0-9]+.[0-9]+.[0-9]+)"/versionName "'$1'"/' android/app/build.gradle
    # Works for code with 8 digits or less
    sed -i.bak -E "s/versionCode [0-9]{0,8}$/versionCode $newAndroidVersionCode/" android/app/build.gradle

    rm android/app/build.gradle.bak
    echo "Updated Android Version Name: $1"
    echo "Updated Android Version Code: $newAndroidVersionCode"
}

increase_ios_version() {
    newVersion=$1
    semver=( ${newVersion//./ } )
    updatedShortVersion="${semver[0]}.${semver[1]}"
    updatedPatchVersion="${semver[2]:-0}"
    # Set IOS info.plist
    sed -i.bak -E "/<key>CFBundleVersion<\/key>/{n;s/<string>([0-9]+)*<\/string>/<string>$updatedPatchVersion<\/string>/;}" ios/$APP_NAME/Info.plist
    sed -i.bak -E "/<key>CFBundleShortVersionString<\/key>/{n;s/<string>[0-9]+(\.[0-9]+)*<\/string>/<string>$updatedShortVersion<\/string>/;}" ios/$APP_NAME/Info.plist
    sed -i.bak -E "/<key>CFBundleVersion<\/key>/{n;s/<string>([0-9]+)*<\/string>/<string>$updatedPatchVersion<\/string>/;}" ios/$APP_TEST_NAME/Info.plist
    sed -i.bak -E "/<key>CFBundleShortVersionString<\/key>/{n;s/<string>[0-9]+(\.[0-9]+)*<\/string>/<string>$updatedShortVersion<\/string>/;}" ios/$APP_TEST_NAME/Info.plist
    
    # Set initial version in IOS pbxproj
    sed -i.bak -E "s/CURRENT_PROJECT_VERSION \= [^\;]*\;/CURRENT_PROJECT_VERSION = $updatedPatchVersion;/" ios/$APP_NAME.xcodeproj/project.pbxproj

    rm ios/$APP_NAME/Info.plist.bak ios/$APP_TEST_NAME/Info.plist.bak ios/$APP_NAME.xcodeproj/project.pbxproj.bak
    echo "Updated IOS Version: $1"
}

increase_build_selection() {
    currentIOSPatchVersion=$(cat ios/ActionApp/Info.plist | awk '/CFBundleVersion/{getline; print}' | awk -F "[<>]" '{print $3}')
    currentIOSVersion=$(cat ios/ActionApp/Info.plist | awk '/CFBundleShortVersionString/{getline; print}' | awk -F "[<>]" '{print $3}')
    currentIOSFullVersion="$currentIOSVersion.$currentIOSPatchVersion"
    currentIOSMajorVersion=${currentIOSVersion%.*}

    if [ $1 = 'major' ]; then
        newIOSMajorVersion=$(($currentIOSMajorVersion + 1))
        # Reset minor and patch to zero when major version updated
        updatedVersion="$newIOSMajorVersion.0.0"

        increase_android_version $updatedVersion
        increase_ios_version $updatedVersion

        echo "New Build Version $updatedVersion"
    elif [ $1 = 'minor' ]; then
        currentIOSMinorVersion=${currentIOSVersion##*.}
        newIOSMinorVersion=$(($currentIOSMinorVersion + 1))
        # Reset patch to zero when minor version updated
        updatedVersion="$currentIOSMajorVersion.$newIOSMinorVersion.0"

        increase_android_version $updatedVersion
        increase_ios_version $updatedVersion

        echo "New Build Version $updatedVersion"
    elif [ $1 = 'patch' ]; then
        newPatchVersion=$(($currentIOSPatchVersion + 1))
        updatedVersion="$currentIOSVersion.$newPatchVersion"

        increase_android_version $updatedVersion
        increase_ios_version $updatedVersion

        echo "New Build Version $updatedVersion"
    else
        echo "Please input the increment type"
    fi
}

increase_app_version() {
    currentIOSPatchVersion=$(cat ios/ActionApp/Info.plist | awk '/CFBundleVersion/{getline; print}' | awk -F "[<>]" '{print $3}')
    currentIOSVersion=$(cat ios/ActionApp/Info.plist | awk '/CFBundleShortVersionString/{getline; print}' | awk -F "[<>]" '{print $3}')
    currentAndroidVersion=$(cat android/app/build.gradle | grep -m1 'versionName' | cut -d '"' -f2)
    currentIOSFullVersion="$currentIOSVersion.$currentIOSPatchVersion"

    echo "current ios version: $currentIOSFullVersion"
    echo "current android version: $currentAndroidVersion"

    if [ $currentAndroidVersion = $currentIOSFullVersion ]; then
        echo "version length: ${#currentAndroidVersion}"
        if [ ${#currentAndroidVersion} -lt 5 ]; then
            increase_android_version "1.0.0"
            increase_ios_version "1.0.0"
        else
            increase_build_selection $1
        fi
    else
        echo "Please fix mismatched IOS ${currentIOSFullVersion} and Android ${currentAndroidVersion} version"
    fi
}

help()
{
   # Display Help
   echo "Available commands"
   echo
   echo "Syntax: ./script.sh [command]"
   echo
   echo "Commands:"
   echo "get-android-version -> Get the current Android version number" 
   echo "(eg: ./script.sh get-android-version)"
   echo 
   echo "get-ios-version -> Get the current IOS version number" 
   echo "(eg: ./script.sh get-ios-version)"
   echo
   echo "set-android-version [version] -> Set the Android version to passed version number" 
   echo "(eg: ./script.sh set-android-version 1.0.1)"
   echo 
   echo "set-ios-version [version]-> Set the IOS version to passed version number" 
   echo "(eg: ./script.sh set-ios-version 1.0.1)"
   echo 
   echo "increase-app-version [major|minor|patch] -> Increase both the IOS and Android version depends on the increment type" 
   echo "(eg: ./script.sh increase-app-version patch)"
   echo
   echo "h -> Show help"
}

if [ "$1" = "-h" ]; then help; exit; fi
if [ "$1" = "set-android-version" ]; then increase_android_version $2; exit; fi
if [ "$1" = "set-ios-version" ]; then increase_ios_version $2; exit; fi
if [ "$1" = "increase-app-version" ]; then increase_app_version $2; exit; fi
if [ "$1" = "get-android-version" ]; then get_android_version; exit; fi
if [ "$1" = "get-ios-version" ]; then get_ios_version; exit; fi