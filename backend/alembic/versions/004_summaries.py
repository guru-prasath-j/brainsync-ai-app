"""Add summaries table

Revision ID: 004_summaries
Revises: 003_chat
Create Date: 2026-06-18
"""
from alembic import op
import sqlalchemy as sa

revision = '004_summaries'
down_revision = '003_chat'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        'summaries',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('note_id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('tldr', sa.Text(), nullable=True),
        sa.Column('key_points', sa.JSON(), nullable=True),
        sa.Column('concepts', sa.JSON(), nullable=True),
        sa.Column('model_used', sa.String(length=50), nullable=True, server_default='gpt-4o-mini'),
        sa.Column('generated_at', sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(timezone=True), onupdate=sa.func.now()),
        sa.ForeignKeyConstraint(['note_id'], ['notes.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('note_id'),
    )
    op.create_index('ix_summaries_id', 'summaries', ['id'])
    op.create_index('ix_summaries_note_id', 'summaries', ['note_id'])


def downgrade() -> None:
    op.drop_index('ix_summaries_note_id', table_name='summaries')
    op.drop_index('ix_summaries_id', table_name='summaries')
    op.drop_table('summaries')
