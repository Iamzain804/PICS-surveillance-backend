import os
import sys
import cv2
import easyocr
import numpy as np
from typing import Dict, Any, List, Optional

# Auto-resolve project root in sys.path when script is executed directly from subfolder
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")))

try:
    from ai.gpu_decoder import NVDECGPUVideoDecoder
except ImportError:
    from gpu_decoder import NVDECGPUVideoDecoder

class VideoOCRExtractor:
    """
    GPU-Accelerated Video OCR Extractor module.
    Decodes video frames using NVDEC GPU decoder and extracts text using EasyOCR.
    """
    def __init__(self, languages: List[str] = None, gpu: bool = True):
        if languages is None:
            languages = ['en']
        print(f"[OCR ENGINE] Initializing EasyOCR (Languages: {languages}, GPU: {gpu})...")
        self.reader = easyocr.Reader(languages, gpu=gpu)

    def preprocess_frame(self, frame_bgr: np.ndarray) -> np.ndarray:
        """
        Enhances image contrast and sharpens text for improved OCR accuracy.
        """
        gray = cv2.cvtColor(frame_bgr, cv2.COLOR_BGR2GRAY)
        # Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        enhanced = clahe.apply(gray)
        return enhanced

    def extract_from_video(
        self,
        video_path: str,
        frame_interval: int = 25,     # Process 1 frame every 1 sec (~25 frames)
        min_confidence: float = 0.35,  # Filter out low-confidence OCR text
        crop_roi: Optional[List[int]] = None # Optional [x1, y1, x2, y2] ROI
    ) -> Dict[str, Any]:
        if not os.path.exists(video_path):
            raise FileNotFoundError(f"Video file not found: {video_path}")

        video_name = os.path.basename(video_path)
        decoder = NVDECGPUVideoDecoder(video_path)
        
        frame_idx = 0
        text_summary: Dict[str, Dict[str, Any]] = {}

        print(f"[OCR PIPELINE] Extracting Text from Video: {video_name} (Interval: {frame_interval} frames)")

        try:
            while True:
                ret, frame = decoder.read()
                if not ret or frame is None:
                    break

                if frame_idx % frame_interval == 0:
                    # Crop Region of Interest if specified
                    if crop_roi and len(crop_roi) == 4:
                        x1, y1, x2, y2 = crop_roi
                        h, w, _ = frame.shape
                        x1, y1 = max(0, x1), max(0, y1)
                        x2, y2 = min(w, x2), min(h, y2)
                        target_image = frame[y1:y2, x1:x2]
                    else:
                        target_image = frame

                    # Preprocess for contrast
                    processed = self.preprocess_frame(target_image)

                    # EasyOCR Detection
                    results = self.reader.readtext(processed)

                    for (bbox, text, conf) in results:
                        text_clean = text.strip()
                        # Filter out noise (too short or low confidence)
                        if len(text_clean) >= 2 and conf >= min_confidence:
                            if text_clean in text_summary:
                                text_summary[text_clean]["count"] += 1
                                text_summary[text_clean]["confidence"] = max(text_summary[text_clean]["confidence"], round(float(conf), 4))
                                text_summary[text_clean]["last_frame_seen"] = frame_idx
                            else:
                                text_summary[text_clean] = {
                                    "text": text_clean,
                                    "confidence": round(float(conf), 4),
                                    "first_frame_seen": frame_idx,
                                    "last_frame_seen": frame_idx,
                                    "count": 1
                                }

                frame_idx += 1

        finally:
            decoder.release()

        # Sorted by highest frequency / confidence
        sorted_texts = sorted(list(text_summary.values()), key=lambda x: (x["count"], x["confidence"]), reverse=True)

        return {
            "video_name": video_name,
            "total_frames_processed": frame_idx,
            "total_unique_texts_found": len(sorted_texts),
            "extracted_texts": sorted_texts
        }

# =======================================================================
# CENTRALIZED OCR LOGIC FOR THE PIPELINE
# =======================================================================

_SHARED_OCR_READER = None

def get_shared_ocr_reader(languages: List[str] = None, gpu: bool = True):
    """
    Singleton getter for EasyOCR reader. 
    Ensures the model is loaded into GPU memory only once.
    """
    global _SHARED_OCR_READER
    if _SHARED_OCR_READER is None:
        if languages is None:
            languages = ['en']
        print(f"[OCR ENGINE] Initializing Global EasyOCR (Languages: {languages}, GPU: {gpu})...")
        _SHARED_OCR_READER = easyocr.Reader(languages, gpu=gpu)
    return _SHARED_OCR_READER

import re
from datetime import datetime

def parse_filename_timestamp(filename):
    """Dynamically parses YYYYMMDDHHMMSS or YYYYMMDD_HHMMSS from any video filename."""
    if not filename: return None, None
    # Pattern 1: YYYYMMDDHHMMSS or YYYYMMDD_HHMMSS
    m = re.search(r'(\d{4})(\d{2})(\d{2})[_\s]*(\d{2})(\d{2})(\d{2})', filename)
    if m:
        year, month, day, hour, minute, sec = m.groups()
        dt_str = f"{day}-{month}-{year} {hour}:{minute}:{sec}"
        try:
            dt_obj = datetime.strptime(dt_str, "%d-%m-%Y %H:%M:%S")
            return dt_obj, dt_str
        except Exception:
            pass

    # Pattern 2: DDMMYYYY_HHMMSS or DD-MM-YYYY HH:MM:SS
    m2 = re.search(r'(\d{2})[-_\.](\d{2})[-_\.](\d{4})[_\s]*(\d{2})[:\._](\d{2})[:\._](\d{2})', filename)
    if m2:
        day, month, year, hour, minute, sec = m2.groups()
        dt_str = f"{day}-{month}-{year} {hour}:{minute}:{sec}"
        try:
            dt_obj = datetime.strptime(dt_str, "%d-%m-%Y %H:%M:%S")
            return dt_obj, dt_str
        except Exception:
            pass

    return None, None

def extract_video_metadata_from_frame(frame, reader=None, filename=None):
    """
    Extracts camera date/time stamp and camera name via OCR.
    """
    if frame is None:
        return None, None, None
        
    try:
        if reader is None:
            reader = get_shared_ocr_reader()
            
        h, w, _ = frame.shape
        
        # Crop Top Region (Full Width) for Timestamp and Bottom-Left for Camera Name
        top_crop = frame[0:int(h * 0.35), 0:w]
        bottom_left_crop = frame[int(h * 0.7):h, 0:int(w * 0.6)]
        
        # Preprocess using CLAHE (improves contrast)
        gray_tr = cv2.cvtColor(top_crop, cv2.COLOR_BGR2GRAY)
        gray_bl = cv2.cvtColor(bottom_left_crop, cv2.COLOR_BGR2GRAY)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        proc_tr = clahe.apply(gray_tr)
        proc_bl = clahe.apply(gray_bl)
        
        # 1. Extract Timestamp
        dt_obj = None
        dt_str = None
        
        tr_results = reader.readtext(proc_tr)
        for (_, text, conf) in tr_results:
            text_clean = text.strip()
            
            # Match Full Date + 6-digit Time or Time with separators (:, ., ,, space)
            m = re.search(r'(\d{2}[-/\.]\d{2}[-/\.]\d{4})[\s,_]*(\d{2})[,\:\.\s]?(\d{2})[,\:\.\s]?(\d{2})', text_clean)
            if m:
                date_str = m.group(1).replace('.', '-').replace('/', '-')
                hh = m.group(2).zfill(2)
                mm = m.group(3).zfill(2)
                ss = m.group(4).zfill(2)
                dt_str = f"{date_str} {hh}:{mm}:{ss}"
                break

            m2 = re.search(r'(\d{2}[-/\.]\d{2}[-/\.]\d{4})\s*(\d{1,2})[\:\.\,]+(\d{1,2})(?:[\:\.\,]+(\d{1,2}))?', text_clean)
            if m2:
                date_str = m2.group(1).replace('.', '-').replace('/', '-')
                hh = m2.group(2).zfill(2)
                mm = m2.group(3).zfill(2)
                ss = (m2.group(4) or '00').zfill(2)
                dt_str = f"{date_str} {hh}:{mm}:{ss}"
                break
                
            # Match Date only (fallback)
            elif re.search(r'\d{2}[-/\.]\d{2}[-/\.]\d{4}', text_clean):
                dt_str = text_clean
                break
                
        if dt_str:
            try:
                dt_obj = datetime.strptime(dt_str, "%d-%m-%Y %H:%M:%S")
            except ValueError:
                try:
                    dt_obj = datetime.strptime(dt_str, "%Y-%m-%d %H:%M:%S")
                except ValueError:
                    pass

        if not dt_obj and filename:
            dt_obj, dt_str = parse_filename_timestamp(filename)

        # 2. Extract Camera Name
        cam_name = None
        bl_results = reader.readtext(proc_bl)
        for (_, text, conf) in bl_results:
            text_clean = text.strip()
            if any(k in text_clean.lower() for k in ['cam', 'main', 'ent', 'door', 'gate', 'outdoor', 'indoor']):
                cam_name = text_clean
                break
            elif not cam_name and len(text_clean) > 3:
                cam_name = text_clean
                
        return dt_obj, dt_str, cam_name
        
    except Exception as e:
        print(f"[OCR TIMESTAMP WARNING] Timestamp extraction skipped: {e}")
        return None, None, None
