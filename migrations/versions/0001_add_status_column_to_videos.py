"""add status column to videos

Revision ID: 0001_add_status
Revises: 
Create Date: 2026-08-04 18:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '0001_add_status'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column('videos', sa.Column('status', sa.String(length=50), nullable=True, server_default='pending'))


def downgrade() -> None:
    op.drop_column('videos', 'status')
