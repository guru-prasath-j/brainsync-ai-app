"""Add quiz tables

Revision ID: 003_quiz_tables
Revises: 001_initial_schema
Create Date: 2026-06-08
"""
from alembic import op
import sqlalchemy as sa

revision = '003_quiz_tables'
down_revision = '001_initial_schema'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        'quiz_sessions',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('note_id', sa.Integer(), sa.ForeignKey('notes.id'), nullable=False),
        sa.Column('difficulty', sa.String(), nullable=True, server_default='medium'),
        sa.Column('total_questions', sa.Integer(), nullable=True, server_default='0'),
        sa.Column('score', sa.Integer(), nullable=True, server_default='0'),
        sa.Column('completed', sa.Boolean(), nullable=True, server_default='false'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(timezone=True), onupdate=sa.func.now()),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index('ix_quiz_sessions_id', 'quiz_sessions', ['id'])
    op.create_index('ix_quiz_sessions_user_id', 'quiz_sessions', ['user_id'])

    op.create_table(
        'quiz_questions',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('session_id', sa.Integer(), sa.ForeignKey('quiz_sessions.id'), nullable=False),
        sa.Column('question_text', sa.String(), nullable=False),
        sa.Column('options', sa.JSON(), nullable=False),
        sa.Column('correct_index', sa.Integer(), nullable=False),
        sa.Column('explanation', sa.String(), nullable=True),
        sa.Column('difficulty', sa.String(), nullable=True, server_default='medium'),
        sa.Column('selected_index', sa.Integer(), nullable=True),
        sa.Column('is_correct', sa.Boolean(), nullable=True),
        sa.Column('order_index', sa.Integer(), nullable=True, server_default='0'),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index('ix_quiz_questions_id', 'quiz_questions', ['id'])
    op.create_index('ix_quiz_questions_session_id', 'quiz_questions', ['session_id'])


def downgrade() -> None:
    op.drop_table('quiz_questions')
    op.drop_table('quiz_sessions')