#!/usr/bin/env python3
"""
WhisperX Service for Typist
Handles local speech transcription using WhisperX with improved error handling and performance
"""

import sys
import json
import tempfile
import os
import logging
from pathlib import Path
from typing import Dict, Any, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stderr),
        logging.FileHandler('/tmp/whisperx_service.log', mode='a')
    ]
)
logger = logging.getLogger(__name__)

class WhisperXService:
    """Enhanced WhisperX service with error handling and proper resource management"""
    
    def __init__(self):
        self.model = None
        self.align_model = None
        self.metadata = None
        self.device = None
        self._setup_device()
    
    def __enter__(self):
        """Context manager entry"""
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit - ensures cleanup"""
        self.cleanup_models()
        return False  # Don't suppress exceptions
        
    def _setup_device(self):
        """Setup compute device with fallback handling"""
        try:
            import torch
            if torch.cuda.is_available():
                self.device = "cuda"
                logger.info(f"Using CUDA device: {torch.cuda.get_device_name()}")
            elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
                self.device = "mps"
                logger.info("Using Apple Metal Performance Shaders (MPS)")
            else:
                self.device = "cpu"
                logger.info("Using CPU device")
        except ImportError:
            self.device = "cpu"
            logger.warning("PyTorch not available, defaulting to CPU")
    
    def load_model(self, model_size: str = "base") -> bool:
        """Load WhisperX model and alignment model with error handling"""
        try:
            import whisperx
            
            # WhisperX may not support MPS yet, fallback to CPU if needed
            device_to_use = self.device
            if self.device == "mps":
                logger.info(f"Attempting WhisperX model loading on MPS, will fallback to CPU if needed")
                device_to_use = "cpu"  # Use CPU for better compatibility
            
            logger.info(f"Loading WhisperX model: {model_size} on device: {device_to_use}")
            
            # Load main model
            self.model = whisperx.load_model(model_size, device_to_use)
            logger.info("WhisperX main model loaded successfully")
            
            # Load alignment model for better accuracy
            try:
                self.align_model, self.metadata = whisperx.load_align_model(
                    language_code="en", 
                    device=device_to_use
                )
                logger.info("WhisperX alignment model loaded successfully")
            except Exception as e:
                logger.warning(f"Could not load alignment model: {e}")
                logger.info("Proceeding without alignment - transcription will still work")
                self.align_model = None
                self.metadata = None
            
            return True
            
        except Exception as e:
            logger.error(f"Error loading WhisperX models: {e}")
            return False
    
    def transcribe_audio(self, audio_file_path: str) -> Dict[str, Any]:
        """Transcribe audio file using WhisperX with comprehensive error handling"""
        try:
            # Validate audio file
            if not os.path.exists(audio_file_path):
                return {"success": False, "error": f"Audio file not found: {audio_file_path}"}
            
            file_size = os.path.getsize(audio_file_path)
            if file_size == 0:
                return {"success": False, "error": "Audio file is empty"}
            
            logger.info(f"Transcribing audio file: {audio_file_path} ({file_size} bytes)")
            
            # Load model if not already loaded
            if not self.model:
                if not self.load_model():
                    return {"success": False, "error": "Failed to load WhisperX model"}
            
            # Load and validate audio
            import whisperx
            audio = whisperx.load_audio(audio_file_path)
            
            if audio is None or len(audio) == 0:
                return {"success": False, "error": "Could not load audio data"}
            
            logger.info(f"Audio loaded: {len(audio)} samples")
            
            # Transcribe with optimized batch size based on device
            batch_size = self._get_optimal_batch_size()
            logger.info(f"Starting transcription with batch size: {batch_size}")
            
            result = self.model.transcribe(audio, batch_size=batch_size)
            
            if not result.get("segments"):
                return {"success": False, "error": "No speech detected in audio"}
            
            logger.info(f"Initial transcription completed: {len(result['segments'])} segments")
            
            # Apply alignment if available for better accuracy
            if self.align_model and self.metadata:
                try:
                    logger.info("Applying alignment for improved accuracy")
                    result = whisperx.align(
                        result["segments"], 
                        self.align_model, 
                        self.metadata, 
                        audio, 
                        self.device, 
                        return_char_alignments=False
                    )
                    logger.info("Alignment completed successfully")
                except Exception as e:
                    logger.warning(f"Alignment failed, using original result: {e}")
            
            # Extract and clean text
            full_text = self._extract_text(result["segments"])
            
            logger.info(f"Transcription completed: {len(full_text)} characters")
            
            return {
                "success": True,
                "text": full_text,
                "segments": len(result["segments"]),
                "language": result.get("language", "en"),
                "model_size": getattr(self.model, 'model_size', 'unknown'),
                "device": self.device
            }
            
        except ImportError as e:
            logger.error(f"WhisperX import error: {e}")
            return {"success": False, "error": "WhisperX not properly installed"}
        except Exception as e:
            logger.error(f"Transcription failed with error: {e}")
            return {"success": False, "error": f"Transcription failed: {str(e)}"}
    
    def _get_optimal_batch_size(self) -> int:
        """Get optimal batch size based on device capabilities"""
        if self.device == "cuda":
            try:
                import torch
                # Get GPU memory and adjust batch size accordingly
                memory_gb = torch.cuda.get_device_properties(0).total_memory / 1e9
                if memory_gb > 8:
                    return 32
                elif memory_gb > 4:
                    return 16
                else:
                    return 8
            except:
                return 16
        elif self.device == "mps":
            return 8  # Conservative for Apple Silicon
        else:
            return 4   # Conservative for CPU
    
    def _extract_text(self, segments: list) -> str:
        """Extract and clean text from segments"""
        full_text = ""
        for segment in segments:
            if "text" in segment and segment["text"]:
                # Clean up the text
                text = segment["text"].strip()
                if text:
                    # Add space if not starting with punctuation
                    if full_text and not text.startswith(('.', ',', '!', '?', ';', ':')):
                        full_text += " "
                    full_text += text
        
        return full_text.strip()
    
    def cleanup_models(self):
        """Properly cleanup models and free GPU/CPU memory"""
        try:
            import torch
            
            logger.info("Starting model cleanup...")
            
            # Clear model references
            if self.model is not None:
                logger.info("Cleaning up main WhisperX model")
                del self.model
                self.model = None
            
            if self.align_model is not None:
                logger.info("Cleaning up alignment model")
                del self.align_model
                self.align_model = None
            
            if self.metadata is not None:
                del self.metadata
                self.metadata = None
            
            # Force garbage collection
            import gc
            gc.collect()
            
            # Clear GPU cache if using CUDA
            if self.device == "cuda" and torch.cuda.is_available():
                torch.cuda.empty_cache()
                torch.cuda.synchronize()
                logger.info("CUDA cache cleared")
            
            # Clear MPS cache if using Apple Silicon
            elif self.device == "mps" and hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
                if hasattr(torch.mps, 'empty_cache'):
                    torch.mps.empty_cache()
                    logger.info("MPS cache cleared")
            
            logger.info("Model cleanup completed successfully")
            
        except Exception as e:
            logger.warning(f"Error during model cleanup: {e}")
    
    def __del__(self):
        """Destructor to ensure cleanup when instance is deleted"""
        try:
            self.cleanup_models()
        except:
            pass  # Ignore errors during destruction
    
    def get_system_info(self) -> Dict[str, Any]:
        """Get system information for debugging"""
        info = {
            "device": self.device,
            "python_version": sys.version,
            "platform": sys.platform
        }
        
        try:
            import torch
            info["pytorch_version"] = torch.__version__
            info["cuda_available"] = torch.cuda.is_available()
            if torch.cuda.is_available():
                info["cuda_version"] = torch.version.cuda
                info["gpu_count"] = torch.cuda.device_count()
                # Add GPU memory info
                if torch.cuda.device_count() > 0:
                    info["gpu_memory_allocated"] = f"{torch.cuda.memory_allocated() / 1e9:.2f} GB"
                    info["gpu_memory_reserved"] = f"{torch.cuda.memory_reserved() / 1e9:.2f} GB"
        except ImportError:
            info["pytorch_available"] = False
        
        try:
            import whisperx
            info["whisperx_available"] = True
        except ImportError:
            info["whisperx_available"] = False
        
        return info


def main():
    """Main entry point for the service"""
    if len(sys.argv) < 2:
        result = {"success": False, "error": "No audio file provided"}
        print(json.dumps(result))
        sys.exit(1)
    
    audio_file = sys.argv[1]
    
    # Handle special commands
    if audio_file == "--info":
        service = WhisperXService()
        info = service.get_system_info()
        print(json.dumps(info, indent=2))
        sys.exit(0)
    
    # Validate audio file
    if not os.path.exists(audio_file):
        result = {"success": False, "error": f"Audio file not found: {audio_file}"}
        print(json.dumps(result))
        sys.exit(1)
    
    # Process transcription using context manager for guaranteed cleanup
    try:
        with WhisperXService() as service:
            result = service.transcribe_audio(audio_file)
            print(json.dumps(result))
            
            # Exit with appropriate code (cleanup happens automatically via context manager)
            sys.exit(0 if result.get("success", False) else 1)
        
    except KeyboardInterrupt:
        result = {"success": False, "error": "Transcription interrupted by user"}
        print(json.dumps(result))
        sys.exit(1)
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        result = {"success": False, "error": f"Unexpected error: {str(e)}"}
        print(json.dumps(result))
        sys.exit(1)


if __name__ == "__main__":
    main()