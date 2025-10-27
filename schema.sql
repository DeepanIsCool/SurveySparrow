-- Survey Sparrow Database Schema
-- MySQL-optimized version
-- Requires MySQL 5.7+ or MySQL 8.0+

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS survey_sparrow;
USE survey_sparrow;

SET FOREIGN_KEY_CHECKS = 0;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'creator', 'respondent') NOT NULL DEFAULT 'respondent',
    profile_picture_url TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Surveys Table
CREATE TABLE IF NOT EXISTS surveys (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    status ENUM('draft', 'published', 'closed') NOT NULL DEFAULT 'draft',
    created_by VARCHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    published_at DATETIME NULL,
    closed_at DATETIME NULL,
    welcome_message TEXT,
    thank_you_message TEXT,
    is_anonymous TINYINT(1) DEFAULT 0,
    INDEX idx_created_by (created_by),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Questions Table
CREATE TABLE IF NOT EXISTS questions (
    id VARCHAR(36) PRIMARY KEY,
    survey_id VARCHAR(36) NOT NULL,
    type ENUM('single-choice', 'multiple-choice', 'text-input', 'paragraph', 'dropdown', 'rating', 'likert', 'date', 'file-upload', 'matrix') NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    is_required TINYINT(1) DEFAULT 0,
    scale INT NULL,
    order_index INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_survey_id (survey_id),
    INDEX idx_order (survey_id, order_index),
    FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Question Options Table (for single-choice, multiple-choice, dropdown)
CREATE TABLE IF NOT EXISTS question_options (
    id VARCHAR(36) PRIMARY KEY,
    question_id VARCHAR(36) NOT NULL,
    label VARCHAR(500) NOT NULL,
    order_index INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_question_id (question_id),
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Likert Scale Statements Table
CREATE TABLE IF NOT EXISTS likert_statements (
    id VARCHAR(36) PRIMARY KEY,
    question_id VARCHAR(36) NOT NULL,
    statement TEXT NOT NULL,
    order_index INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_question_id (question_id),
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Likert Scale Choices Table
CREATE TABLE IF NOT EXISTS likert_choices (
    id VARCHAR(36) PRIMARY KEY,
    question_id VARCHAR(36) NOT NULL,
    choice VARCHAR(255) NOT NULL,
    order_index INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_question_id (question_id),
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Matrix Rows Table
CREATE TABLE IF NOT EXISTS matrix_rows (
    id VARCHAR(36) PRIMARY KEY,
    question_id VARCHAR(36) NOT NULL,
    label VARCHAR(500) NOT NULL,
    order_index INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_question_id (question_id),
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Matrix Columns Table
CREATE TABLE IF NOT EXISTS matrix_columns (
    id VARCHAR(36) PRIMARY KEY,
    question_id VARCHAR(36) NOT NULL,
    label VARCHAR(500) NOT NULL,
    order_index INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_question_id (question_id),
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Survey Responses Table
CREATE TABLE IF NOT EXISTS survey_responses (
    id VARCHAR(36) PRIMARY KEY,
    survey_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NULL,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT,
    completion_time INT NULL,
    INDEX idx_survey_id (survey_id),
    INDEX idx_user_id (user_id),
    INDEX idx_submitted_at (submitted_at),
    FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Response Answers Table (stores individual answers)
CREATE TABLE IF NOT EXISTS response_answers (
    id VARCHAR(36) PRIMARY KEY,
    response_id VARCHAR(36) NOT NULL,
    question_id VARCHAR(36) NOT NULL,
    answer_text TEXT,
    answer_number DECIMAL(10,2),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_response_id (response_id),
    INDEX idx_question_id (question_id),
    FOREIGN KEY (response_id) REFERENCES survey_responses(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Response Answer Options (for single-choice, multiple-choice, dropdown selections)
CREATE TABLE IF NOT EXISTS response_answer_options (
    id VARCHAR(36) PRIMARY KEY,
    answer_id VARCHAR(36) NOT NULL,
    option_id VARCHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_answer_id (answer_id),
    INDEX idx_option_id (option_id),
    FOREIGN KEY (answer_id) REFERENCES response_answers(id) ON DELETE CASCADE,
    FOREIGN KEY (option_id) REFERENCES question_options(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Response Matrix Answers (for matrix question responses)
CREATE TABLE IF NOT EXISTS response_matrix_answers (
    id VARCHAR(36) PRIMARY KEY,
    answer_id VARCHAR(36) NOT NULL,
    row_id VARCHAR(36) NOT NULL,
    column_id VARCHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_answer_id (answer_id),
    FOREIGN KEY (answer_id) REFERENCES response_answers(id) ON DELETE CASCADE,
    FOREIGN KEY (row_id) REFERENCES matrix_rows(id) ON DELETE CASCADE,
    FOREIGN KEY (column_id) REFERENCES matrix_columns(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Response Likert Answers (for likert scale responses)
CREATE TABLE IF NOT EXISTS response_likert_answers (
    id VARCHAR(36) PRIMARY KEY,
    answer_id VARCHAR(36) NOT NULL,
    statement_id VARCHAR(36) NOT NULL,
    choice_id VARCHAR(36) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_answer_id (answer_id),
    FOREIGN KEY (answer_id) REFERENCES response_answers(id) ON DELETE CASCADE,
    FOREIGN KEY (statement_id) REFERENCES likert_statements(id) ON DELETE CASCADE,
    FOREIGN KEY (choice_id) REFERENCES likert_choices(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- File Uploads Table (for file upload question responses)
CREATE TABLE IF NOT EXISTS response_file_uploads (
    id VARCHAR(36) PRIMARY KEY,
    answer_id VARCHAR(36) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    file_size INT NOT NULL,
    mime_type VARCHAR(100),
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_answer_id (answer_id),
    FOREIGN KEY (answer_id) REFERENCES response_answers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Survey Sharing/Collaboration Table (optional - for team features)
CREATE TABLE IF NOT EXISTS survey_collaborators (
    id VARCHAR(36) PRIMARY KEY,
    survey_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    permission ENUM('view', 'edit', 'admin') NOT NULL DEFAULT 'view',
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_survey_id (survey_id),
    INDEX idx_user_id (user_id),
    UNIQUE KEY unique_survey_user (survey_id, user_id),
    FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- Sample Queries for Testing

-- Insert a test user
-- INSERT INTO users (id, name, email, password_hash, role) 
-- VALUES (UUID(), 'Test User', 'test@example.com', 'hashed_password_here', 'creator');

-- Create a survey
-- INSERT INTO surveys (id, title, description, status, created_by) 
-- VALUES (UUID(), 'Customer Satisfaction Survey', 'Help us improve our service', 'draft', 'user_id_here');

-- View survey with response count
-- SELECT s.*, COUNT(DISTINCT sr.id) as response_count
-- FROM surveys s
-- LEFT JOIN survey_responses sr ON s.id = sr.survey_id
-- GROUP BY s.id;

-- Get all responses for a survey with answers
-- SELECT sr.*, ra.question_id, ra.answer_text, ra.answer_number
-- FROM survey_responses sr
-- LEFT JOIN response_answers ra ON sr.id = ra.response_id
-- WHERE sr.survey_id = 'survey_id_here'
-- ORDER BY sr.submitted_at DESC;