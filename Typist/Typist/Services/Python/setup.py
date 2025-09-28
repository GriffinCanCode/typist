#!/usr/bin/env python3
"""
Setup script for WhisperX service dependencies
Handles virtual environment creation and dependency installation
"""

import os
import sys
import subprocess
import venv
from pathlib import Path

def run_command(command, cwd=None):
    """Run a command and return success status"""
    try:
        result = subprocess.run(
            command, 
            shell=True, 
            cwd=cwd,
            capture_output=True, 
            text=True,
            check=True
        )
        print(f"✓ {command}")
        if result.stdout:
            print(f"  {result.stdout.strip()}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ {command}")
        print(f"  Error: {e.stderr.strip()}")
        return False

def create_virtual_environment(venv_path):
    """Create a virtual environment"""
    try:
        venv.create(venv_path, with_pip=True)
        print(f"✓ Created virtual environment at {venv_path}")
        return True
    except Exception as e:
        print(f"✗ Failed to create virtual environment: {e}")
        return False

def main():
    """Main setup function"""
    print("🎤 Setting up WhisperX Service for Typist")
    print("=" * 50)
    
    # Get current directory
    current_dir = Path(__file__).parent.absolute()
    venv_path = current_dir / "venv"
    requirements_path = current_dir / "requirements.txt"
    
    print(f"Working directory: {current_dir}")
    print(f"Virtual environment: {venv_path}")
    
    # Check if virtual environment already exists
    if venv_path.exists():
        print("ℹ️  Virtual environment already exists")
        recreate = input("Recreate it? (y/N): ").lower().strip()
        if recreate == 'y':
            import shutil
            shutil.rmtree(venv_path)
            print("🗑️  Removed existing virtual environment")
        else:
            print("Using existing virtual environment")
    
    # Create virtual environment if it doesn't exist
    if not venv_path.exists():
        print("\n📦 Creating virtual environment...")
        if not create_virtual_environment(venv_path):
            print("❌ Setup failed")
            return False
    
    # Determine the correct paths for the virtual environment
    if sys.platform == "win32":
        pip_path = venv_path / "Scripts" / "pip"
        python_path = venv_path / "Scripts" / "python"
    else:
        pip_path = venv_path / "bin" / "pip"
        python_path = venv_path / "bin" / "python"
    
    # Upgrade pip
    print("\n🔄 Upgrading pip...")
    if not run_command(f'"{python_path}" -m pip install --upgrade pip'):
        print("❌ Failed to upgrade pip")
        return False
    
    # Install requirements
    print("\n📚 Installing requirements...")
    if not requirements_path.exists():
        print(f"❌ Requirements file not found: {requirements_path}")
        return False
    
    install_cmd = f'"{pip_path}" install -r "{requirements_path}"'
    if not run_command(install_cmd):
        print("❌ Failed to install requirements")
        return False
    
    # Test installation
    print("\n🧪 Testing WhisperX installation...")
    test_cmd = f'"{python_path}" -c "import whisperx; print(\\"WhisperX version:\\", whisperx.__version__)"'
    if not run_command(test_cmd):
        print("❌ WhisperX test failed")
        return False
    
    # Test PyTorch
    print("\n🔥 Testing PyTorch installation...")
    torch_test_cmd = f'"{python_path}" -c "import torch; print(\\"PyTorch version:\\", torch.__version__); print(\\"CUDA available:\\", torch.cuda.is_available())"'
    run_command(torch_test_cmd)  # Don't fail on this, it's informational
    
    # Create activation script
    if sys.platform != "win32":
        activation_script = current_dir / "activate.sh"
        with open(activation_script, 'w') as f:
            f.write(f'''#!/bin/bash
# Activation script for WhisperX service
source "{venv_path}/bin/activate"
echo "WhisperX virtual environment activated"
echo "Python: $(which python)"
echo "Pip: $(which pip)"
''')
        os.chmod(activation_script, 0o755)
        print(f"✓ Created activation script: {activation_script}")
    
    print("\n✅ Setup completed successfully!")
    print("\n📋 Next steps:")
    print("1. Test the service:")
    print(f'   "{python_path}" whisperx_service.py --info')
    print("\n2. To use the virtual environment manually:")
    if sys.platform == "win32":
        print(f'   "{venv_path}\\Scripts\\activate"')
    else:
        print(f'   source "{venv_path}/bin/activate"')
        print(f'   # or: source activate.sh')
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
