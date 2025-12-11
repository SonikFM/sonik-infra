-- Sonik OS: Enable PostgreSQL Extensions
-- Phase: 1 - Task 1.1
-- Date: 2025-12-08
-- Description: Enable required PostgreSQL extensions for vector search and UUID generation

-- Enable pgcrypto for gen_random_bytes() used by UUIDv7
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Enable pgvector for embeddings (Phase 3)
CREATE EXTENSION IF NOT EXISTS vector;

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Verify extensions
SELECT extname, extversion FROM pg_extension WHERE extname IN ('pgcrypto', 'vector', 'uuid-ossp');
