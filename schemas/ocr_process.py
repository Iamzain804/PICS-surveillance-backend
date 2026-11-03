from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any

class VideoOCRRequest(BaseModel):
    video_path: str = Field(..., description="Path to input video file")
    frame_interval: int = Field(default=25, ge=1, description="Sample interval in frames for OCR extraction")
    min_confidence: float = Field(default=0.35, ge=0.0, le=1.0, description="Minimum confidence threshold for OCR text")
    crop_roi: Optional[List[int]] = Field(default=None, description="Optional bounding box [x1, y1, x2, y2] ROI for OCR")

class OCRTextDetail(BaseModel):
    text: str
    confidence: float
    first_frame_seen: int
    last_frame_seen: int
    count: int

class VideoOCRResponse(BaseModel):
    video_name: str
    total_frames_processed: int
    total_unique_texts_found: int
    extracted_texts: List[OCRTextDetail]
