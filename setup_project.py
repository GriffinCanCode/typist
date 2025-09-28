#!/usr/bin/env python3
"""
Typist Xcode Project Auto-Setup
Automatically detects and creates a proper Xcode project if needed
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path
import tempfile
from datetime import datetime

PROJECT_NAME = "typist"
BUNDLE_ID = "com.griffincancode.typist"

def check_valid_xcode_project(project_path):
    """Check if a valid Xcode project exists"""
    pbxproj_path = project_path / "project.pbxproj"
    
    if not project_path.exists() or not project_path.is_dir():
        return False
        
    if not pbxproj_path.exists():
        return False
        
    # Check if project.pbxproj has proper content
    try:
        with open(pbxproj_path, 'r') as f:
            content = f.read()
            if "PBXProject" in content and len(content) > 1000:  # Basic validation
                return True
    except:
        pass
        
    return False

def backup_invalid_project(project_path):
    """Backup existing invalid project"""
    if project_path.exists():
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = Path(f"{project_path}.backup.{timestamp}")
        print(f"📦 Backing up invalid project to {backup_path}")
        shutil.move(str(project_path), str(backup_path))

def run_xcodegen_if_available():
    """Try to use XcodeGen if available"""
    try:
        result = subprocess.run(['which', 'xcodegen'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print("🔧 Found XcodeGen, attempting to use it...")
            
            # Create basic project.yml for XcodeGen
            project_yml = f"""
name: {PROJECT_NAME}
options:
  bundleIdPrefix: {BUNDLE_ID}
  deploymentTarget:
    macOS: "14.0"
settings:
  MARKETING_VERSION: "1.0"
  CURRENT_PROJECT_VERSION: "1"
targets:
  {PROJECT_NAME}:
    type: application
    platform: macOS
    sources:
      - path: {PROJECT_NAME}
        name: {PROJECT_NAME}
        type: group
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: {BUNDLE_ID}
      INFOPLIST_FILE: {PROJECT_NAME}/Info.plist
"""
            
            with open('project.yml', 'w') as f:
                f.write(project_yml)
            
            result = subprocess.run(['xcodegen', 'generate'], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                os.remove('project.yml')
                return True
    except:
        pass
    
    return False

def create_basic_xcode_project():
    """Create basic Xcode project manually"""
    print("🏗️  Creating new Xcode project manually...")
    
    project_path = Path(f"{PROJECT_NAME}.xcodeproj")
    project_path.mkdir(exist_ok=True)
    
    # Create minimal working project.pbxproj
    pbxproj_content = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 77;
	objects = {{

/* Begin PBXFileReference section */
		A1000001000000000000001 /* {PROJECT_NAME}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {PROJECT_NAME}.app; sourceTree = BUILT_PRODUCTS_DIR; }};
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		A1000002000000000000001 /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		A1000003000000000000001 = {{
			isa = PBXGroup;
			children = (
				A1000004000000000000001 /* {PROJECT_NAME} */,
				A1000005000000000000001 /* Products */,
			);
			sourceTree = "<group>";
		}};
		A1000004000000000000001 /* {PROJECT_NAME} */ = {{
			isa = PBXGroup;
			children = (
			);
			path = {PROJECT_NAME};
			sourceTree = "<group>";
		}};
		A1000005000000000000001 /* Products */ = {{
			isa = PBXGroup;
			children = (
				A1000001000000000000001 /* {PROJECT_NAME}.app */,
			);
			name = Products;
			sourceTree = "<group>";
		}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		A1000006000000000000001 /* {PROJECT_NAME} */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = A1000007000000000000001;
			buildPhases = (
				A1000008000000000000001 /* Sources */,
				A1000002000000000000001 /* Frameworks */,
				A1000009000000000000001 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = {PROJECT_NAME};
			productName = {PROJECT_NAME};
			productReference = A1000001000000000000001;
			productType = "com.apple.product-type.application";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		A1000010000000000000001 /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				LastSwiftUpdateCheck = 1700;
				LastUpgradeCheck = 1700;
			}};
			buildConfigurationList = A1000011000000000000001;
			compatibilityVersion = "Xcode 15.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = A1000003000000000000001;
			productRefGroup = A1000005000000000000001;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				A1000006000000000000001,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		A1000009000000000000001 /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		A1000008000000000000001 /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		A1000012000000000000001 /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			}};
			name = Debug;
		}};
		A1000013000000000000001 /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
			}};
			name = Release;
		}};
		A1000014000000000000001 /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = JBCP75H756;
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID};
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			}};
			name = Debug;
		}};
		A1000015000000000000001 /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = JBCP75H756;
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID};
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		A1000007000000000000001 = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				A1000014000000000000001 /* Debug */,
				A1000015000000000000001 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		A1000011000000000000001 = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				A1000012000000000000001 /* Debug */,
				A1000013000000000000001 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */
	}};
	rootObject = A1000010000000000000001 /* Project object */;
}}
"""
    
    # Write project.pbxproj
    with open(project_path / "project.pbxproj", 'w') as f:
        f.write(pbxproj_content)
    
    # Create workspace
    workspace_path = project_path / "project.xcworkspace"
    workspace_path.mkdir(exist_ok=True)
    
    workspace_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:{PROJECT_NAME}.xcodeproj">
   </FileRef>
</Workspace>
"""
    
    with open(workspace_path / "contents.xcworkspacedata", 'w') as f:
        f.write(workspace_content)

def setup_basic_assets():
    """Set up basic Assets.xcassets and entitlements if they don't exist"""
    assets_path = Path(PROJECT_NAME) / "Assets.xcassets"
    
    if not assets_path.exists():
        print("📁 Creating basic Assets.xcassets...")
        
        # Create directory structure
        assets_path.mkdir(parents=True, exist_ok=True)
        (assets_path / "AppIcon.appiconset").mkdir(exist_ok=True)
        (assets_path / "AccentColor.colorset").mkdir(exist_ok=True)
        
        # Create Contents.json files
        with open(assets_path / "Contents.json", 'w') as f:
            f.write('{\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}')
        
        # AppIcon Contents.json
        appicon_content = """{
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
}"""
        
        with open(assets_path / "AppIcon.appiconset" / "Contents.json", 'w') as f:
            f.write(appicon_content)
        
        # AccentColor Contents.json
        accent_content = """{
  "colors" : [
    {
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}"""
        
        with open(assets_path / "AccentColor.colorset" / "Contents.json", 'w') as f:
            f.write(accent_content)
    
    # Create entitlements file if it doesn't exist
    entitlements_path = Path(PROJECT_NAME) / f"{PROJECT_NAME}.entitlements"
    if not entitlements_path.exists():
        print("🔐 Creating entitlements file...")
        entitlements_path.parent.mkdir(parents=True, exist_ok=True)
        
        entitlements_content = '''<?xml version="1.0" encoding="UTF-8"?>
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
</plist>'''
        
        with open(entitlements_path, 'w') as f:
            f.write(entitlements_content)

def test_build():
    """Test if project builds successfully"""
    print("🔨 Testing build...")
    try:
        result = subprocess.run([
            'xcodebuild', '-project', f'{PROJECT_NAME}.xcodeproj', 
            '-scheme', PROJECT_NAME, '-configuration', 'Debug', 'build', '-quiet'
        ], capture_output=True, text=True, timeout=60)
        
        if result.returncode == 0:
            print("✅ Build successful!")
            return True
        else:
            print("⚠️  Build had issues (normal for initial setup)")
            return False
    except subprocess.TimeoutExpired:
        print("⏱️  Build timeout (this can happen on first build)")
        return False
    except Exception as e:
        print(f"❌ Build test failed: {e}")
        return False

def main():
    """Main setup function"""
    print("🚀 Typist Xcode Project Auto-Setup")
    print("=" * 40)
    
    current_dir = Path.cwd()
    
    # Check for existing project in common locations
    possible_locations = [
        current_dir / f"{PROJECT_NAME}.xcodeproj",  # Root level
        current_dir / PROJECT_NAME / f"{PROJECT_NAME}.xcodeproj",  # Nested
    ]
    
    for project_path in possible_locations:
        if check_valid_xcode_project(project_path):
            print(f"✅ Valid Xcode project already exists: {project_path}")
            print(f"   Build with: xcodebuild -project '{project_path}' -scheme {PROJECT_NAME} build")
            return 0
    
    # Determine where to create the project
    if (current_dir / PROJECT_NAME).exists():
        project_path = current_dir / PROJECT_NAME / f"{PROJECT_NAME}.xcodeproj"
        print(f"📁 Found existing project structure, using: {project_path}")
    else:
        project_path = current_dir / f"{PROJECT_NAME}.xcodeproj"
        print(f"📁 Using root level location: {project_path}")
    
    print("❌ No valid Xcode project found. Setting up automatically...")
    
    # Backup invalid project if exists
    backup_invalid_project(project_path)
    
    # Try XcodeGen first, fallback to manual creation
    if not run_xcodegen_if_available():
        create_basic_xcode_project()
    
    # Set up basic assets
    setup_basic_assets()
    
    print("\n🎉 Setup complete!")
    print(f"   Project: {project_path}")
    print(f"   Build: xcodebuild -project {project_path} -scheme {PROJECT_NAME} build")
    print(f"   Open: open {project_path}")
    
    # Test build (optional)
    if not test_build():
        print("\n💡 Next steps:")
        print("   1. Open project in Xcode")
        print("   2. Add your Swift files to the project target")
        print("   3. Build with ⌘+B")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
