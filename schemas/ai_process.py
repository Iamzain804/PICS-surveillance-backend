from pydantic import BaseModel, Field
from typing import List, Optional, Any, Dict

class VideoProcessRequest(BaseModel):
    video_path: str = Field(..., description="Path to video file for processing")
    conf_threshold: float = Field(default=0.35, ge=0.0, le=1.0, description="YOLO detection confidence threshold")
    show_live: bool = Field(default=False, description="Whether to display OpenCV window during processing")
    empty_frame_skip: int = Field(default=5, ge=1, description="Frames to skip when no person detected")
    recheck_interval_frames: int = Field(default=25, description="Frames between face re-verification attempts")
    max_observation_sec: float = Field(default=30.0, description="Max observation window in seconds before marking unauthorized")

class TrackDetail(BaseModel):
    track_id: int
    master_track_id: int
    status: str
    person_name: str
    person_id: Optional[str] = None
    confidence: float
    total_hits: int

class VideoProcessResponse(BaseModel):
    video_name: str
    total_frames_processed: int
    total_unique_tracks: int
    authorized_unique_persons_count: int
    authorized_persons_list: List[str]
    unauthorized_unique_persons_count: int
    tracks: List[Dict[str, Any]]
