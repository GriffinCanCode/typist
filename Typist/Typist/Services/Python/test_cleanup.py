#!/usr/bin/env python3
"""
Test script to demonstrate forceful model cleanup
"""
import sys
import os
sys.path.insert(0, '.')

from whisperx_service import WhisperXService
import time

print("🧪 FORCEFUL MODEL CLEANUP TEST")
print("=" * 40)

print("\n1️⃣ Creating WhisperX service instance...")
service = WhisperXService()

print(f"✅ Service created with device: {service.device}")

print("\n2️⃣ Loading model (this will allocate GPU/MPS memory)...")
success = service.load_model("base")
if success:
    print("✅ Model loaded successfully - memory now allocated")
else:
    print("❌ Model loading failed")
    sys.exit(1)

print(f"\n📊 Model status:")
print(f"   Main model loaded: {service.model is not None}")
print(f"   Alignment model loaded: {service.align_model is not None}")

print("\n3️⃣ FORCING AGGRESSIVE CLEANUP...")
service.cleanup_models()

print(f"\n📊 Post-cleanup status:")
print(f"   Main model loaded: {service.model is not None}")
print(f"   Alignment model loaded: {service.align_model is not None}")

print("\n✅ Forceful cleanup demonstration completed!")
