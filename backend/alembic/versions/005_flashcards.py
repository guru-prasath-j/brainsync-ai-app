"""flashcards table

Revision ID: 005_flashcards
Revises: 004_summaries
Create Date: 2026-06-19
"""
from alembic import op
import sqlalchemy as sa

revision = '005_flashcards'
down_revision = '004_summaries'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        'flashcards',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('note_id', sa.Integer(), sa.ForeignKey('notes.id', ondelete='CASCADE'), nullable=False),
        sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('question', sa.String(), nullable=False),
        sa.Column('answer', sa.String(), nullable=False),
        sa.Column('known', sa.Boolean(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index('ix_flashcards_note_id', 'flashcards', ['note_id'])
    op.create_index('ix_flashcards_user_id', 'flashcards', ['user_id'])


def downgrade():
    op.drop_table('flashcards')
