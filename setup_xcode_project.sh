#!/bin/bash

# Typist Xcode Project Setup Script
# Automatically creates a proper Xcode project if one doesn't exist

set -e  # Exit on any error

PROJECT_NAME="typist"
BUNDLE_ID="com.griffincancode.typist"
PROJECT_DIR=$(pwd)
XCODE_PROJECT_PATH="${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj"

echo "🔍 Checking for existing Xcode project..."

# Function to check if Xcode project is valid
is_valid_xcode_project() {
    local project_path="$1"
    if [ -d "$project_path" ] && [ -f "$project_path/project.pbxproj" ]; then
        # Check if project.pbxproj has proper content (not just a config file)
        if grep -q "PBXProject" "$project_path/project.pbxproj" 2>/dev/null; then
            return 0  # Valid project
        fi
    fi
    return 1  # Invalid or missing project
}

# Function to backup existing invalid project
backup_invalid_project() {
    if [ -e "$XCODE_PROJECT_PATH" ]; then
        echo "📦 Backing up invalid project file..."
        mv "$XCODE_PROJECT_PATH" "${XCODE_PROJECT_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Function to create new Xcode project
create_xcode_project() {
    echo "🏗️  Creating new Xcode project..."
    
    # Create temporary directory for new project
    TEMP_DIR=$(mktemp -d)
    
    # Create the project using command line tools
    cat > "$TEMP_DIR/create_project.swift" << 'EOF'
import Foundation
import Cocoa

// This would normally use Xcode's template system
// For now, we'll create the basic structure manually
EOF

    # Create the project structure manually
    mkdir -p "$XCODE_PROJECT_PATH"
    
    # Create basic project.pbxproj file
    cat > "$XCODE_PROJECT_PATH/project.pbxproj" << EOF
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 77;
	objects = {

/* Begin PBXBuildFile section */
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		2A000001000000000000001 /* ${PROJECT_NAME}.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = ${PROJECT_NAME}.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		2A000002000000000000001 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		2A000003000000000000001 = {
			isa = PBXGroup;
			children = (
				2A000004000000000000001 /* ${PROJECT_NAME} */,
				2A000005000000000000001 /* Products */,
			);
			sourceTree = "<group>";
		};
		2A000004000000000000001 /* ${PROJECT_NAME} */ = {
			isa = PBXGroup;
			children = (
			);
			path = ${PROJECT_NAME};
			sourceTree = "<group>";
		};
		2A000005000000000000001 /* Products */ = {
			isa = PBXGroup;
			children = (
				2A000001000000000000001 /* ${PROJECT_NAME}.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		2A000006000000000000001 /* ${PROJECT_NAME} */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 2A000007000000000000001 /* Build configuration list for PBXNativeTarget "${PROJECT_NAME}" */;
			buildPhases = (
				2A000008000000000000001 /* Sources */,
				2A000002000000000000001 /* Frameworks */,
				2A000009000000000000001 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			fileSystemSynchronizedGroups = (
			);
			name = ${PROJECT_NAME};
			packageProductDependencies = (
			);
			productName = ${PROJECT_NAME};
			productReference = 2A000001000000000000001 /* ${PROJECT_NAME}.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		2A000010000000000000001 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1700;
				LastUpgradeCheck = 1700;
				TargetAttributes = {
					2A000006000000000000001 = {
						CreatedOnToolsVersion = 17.0;
					};
				};
			};
			buildConfigurationList = 2A000011000000000000001 /* Build configuration list for PBXProject "${PROJECT_NAME}" */;
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 2A000003000000000000001;
			minimizedProjectReferenceProxies = 1;
			preferredProjectObjectVersion = 77;
			productRefGroup = 2A000005000000000000001 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				2A000006000000000000001 /* ${PROJECT_NAME} */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		2A000009000000000000001 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		2A000008000000000000001 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		2A000012000000000000001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"\$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG \$(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		2A000013000000000000001 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
			};
			name = Release;
		};
		2A000014000000000000001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = ${PROJECT_NAME}/${PROJECT_NAME}.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"${PROJECT_NAME}/Preview Content\"";
				DEVELOPMENT_TEAM = JBCP75H756;
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"\$(inherited)",
					"@executable_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID};
				PRODUCT_NAME = "\$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		2A000015000000000000001 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = ${PROJECT_NAME}/${PROJECT_NAME}.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"${PROJECT_NAME}/Preview Content\"";
				DEVELOPMENT_TEAM = JBCP75H756;
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"\$(inherited)",
					"@executable_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID};
				PRODUCT_NAME = "\$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		2A000007000000000000001 /* Build configuration list for PBXNativeTarget "${PROJECT_NAME}" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				2A000014000000000000001 /* Debug */,
				2A000015000000000000001 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		2A000011000000000000001 /* Build configuration list for PBXProject "${PROJECT_NAME}" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				2A000012000000000000001 /* Debug */,
				2A000013000000000000001 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 2A000010000000000000001 /* Project object */;
}
EOF

    # Create workspace content
    mkdir -p "$XCODE_PROJECT_PATH/project.xcworkspace"
    cat > "$XCODE_PROJECT_PATH/project.xcworkspace/contents.xcworkspacedata" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:${PROJECT_NAME}.xcodeproj">
   </FileRef>
</Workspace>
EOF

    echo "✅ Created basic Xcode project structure"
    
    # Clean up temp directory
    rm -rf "$TEMP_DIR"
}

# Function to organize existing Swift files
organize_swift_files() {
    echo "📁 Organizing existing Swift files..."
    
    # Create the main source directory in project
    mkdir -p "${PROJECT_DIR}/${PROJECT_NAME}"
    
    # Move existing source files to project directory if they exist outside it
    if [ -d "App" ] && [ ! -d "${PROJECT_NAME}/App" ]; then
        echo "   Moving App/ directory..."
        cp -r "App" "${PROJECT_NAME}/"
    fi
    
    if [ -d "UI" ] && [ ! -d "${PROJECT_NAME}/UI" ]; then
        echo "   Moving UI/ directory..."
        cp -r "UI" "${PROJECT_NAME}/"
    fi
    
    if [ -d "Services" ] && [ ! -d "${PROJECT_NAME}/Services" ]; then
        echo "   Moving Services/ directory..."
        cp -r "Services" "${PROJECT_NAME}/"
    fi
    
    if [ -d "Utilities" ] && [ ! -d "${PROJECT_NAME}/Utilities" ]; then
        echo "   Moving Utilities/ directory..."
        cp -r "Utilities" "${PROJECT_NAME}/"
    fi
    
    if [ -d "Resources" ] && [ ! -d "${PROJECT_NAME}/Resources" ]; then
        echo "   Moving Resources/ directory..."
        cp -r "Resources" "${PROJECT_NAME}/"
    fi
    
    # Create basic Assets.xcassets if it doesn't exist
    if [ ! -d "${PROJECT_NAME}/Assets.xcassets" ]; then
        echo "   Creating Assets.xcassets..."
        mkdir -p "${PROJECT_NAME}/Assets.xcassets/AppIcon.appiconset"
        mkdir -p "${PROJECT_NAME}/Assets.xcassets/AccentColor.colorset"
        
        cat > "${PROJECT_NAME}/Assets.xcassets/Contents.json" << EOF
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
        
        cat > "${PROJECT_NAME}/Assets.xcassets/AppIcon.appiconset/Contents.json" << EOF
{
  "images" : [
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
        
        cat > "${PROJECT_NAME}/Assets.xcassets/AccentColor.colorset/Contents.json" << EOF
{
  "colors" : [
    {
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    fi
    
    echo "✅ Organized Swift source files"
    
    # Create entitlements file if it doesn't exist
    if [ ! -f "${PROJECT_NAME}/${PROJECT_NAME}.entitlements" ]; then
        echo "   Creating entitlements file..."
        mkdir -p "${PROJECT_NAME}"
        cat > "${PROJECT_NAME}/${PROJECT_NAME}.entitlements" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.files.user-selected.read-only</key>
	<true/>
	<key>com.apple.security.device.microphone</key>
	<true/>
</dict>
</plist>
EOF
    fi
}

# Function to test build
test_build() {
    echo "🔨 Testing build..."
    if xcodebuild -project "$XCODE_PROJECT_PATH" -scheme "$PROJECT_NAME" -configuration Debug build -quiet; then
        echo "✅ Build successful!"
        return 0
    else
        echo "⚠️  Build had issues (this is normal for initial setup)"
        echo "   You may need to add files manually in Xcode"
        return 1
    fi
}

# Main execution
main() {
    echo "🚀 Typist Xcode Project Setup"
    echo "=============================="
    
    # Check for existing projects in common locations
    POSSIBLE_LOCATIONS=(
        "$PROJECT_DIR/$PROJECT_NAME.xcodeproj"      # Root level
        "$PROJECT_DIR/$PROJECT_NAME/$PROJECT_NAME.xcodeproj"  # Nested
    )
    
    for project_location in "${POSSIBLE_LOCATIONS[@]}"; do
        if is_valid_xcode_project "$project_location"; then
            echo "✅ Valid Xcode project already exists: $project_location"
            echo "   No action needed. You can build with:"
            echo "   xcodebuild -project '$project_location' -scheme $PROJECT_NAME build"
            exit 0
        fi
    done
    
    echo "❌ No valid Xcode project found. Setting up automatically..."
    
    # Set the project path to the existing nested location if it exists
    if [ -d "$PROJECT_DIR/$PROJECT_NAME" ]; then
        XCODE_PROJECT_PATH="$PROJECT_DIR/$PROJECT_NAME/$PROJECT_NAME.xcodeproj"
        echo "📁 Found existing project structure, using: $XCODE_PROJECT_PATH"
    else
        XCODE_PROJECT_PATH="$PROJECT_DIR/$PROJECT_NAME.xcodeproj"
        echo "📁 Using root level location: $XCODE_PROJECT_PATH"
    fi
    
    backup_invalid_project
    create_xcode_project
    organize_swift_files
    
    echo ""
    echo "🎉 Setup complete!"
    echo "   Project: $XCODE_PROJECT_PATH"
    echo "   Build with: xcodebuild -project $XCODE_PROJECT_PATH -scheme $PROJECT_NAME build"
    echo "   Or open in Xcode: open $XCODE_PROJECT_PATH"
    
    if ! test_build; then
        echo ""
        echo "💡 Next steps:"
        echo "   1. Open the project in Xcode: open $XCODE_PROJECT_PATH"
        echo "   2. Add your Swift files to the project target"
        echo "   3. Build with ⌘+B"
    fi
}

# Run the main function
main "$@"
