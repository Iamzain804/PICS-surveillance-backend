"""add unique constraint on events (video_id, track_id, frame_number)

Prevents duplicate Event rows for the same detection -- e.g. from a race
between concurrent parallel_runner.py chunk-worker subprocesses writing to
the same video's events, or from a retried/duplicated pipeline run.

Revision ID: 0002_events_unique
Revises: 0001_add_status
Create Date: 2026-08-27 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '0002_events_unique'
down_revision = '0001_add_status'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_unique_constraint(
        'uq_events_video_track_frame',
        'events',
        ['video_id', 'track_id', 'frame_number'],
    )


def downgrade() -> None:
    op.drop_constraint('uq_events_video_track_frame', 'events', type_='unique')
