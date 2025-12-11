-- Sonik OS: Add Vector Embeddings to Existing Tables
-- Phase: 3 - Task 3.3
-- Date: 2025-12-08
-- Description: Add Qwen 3 embedding columns to organizations, customers, and events for semantic search

-- Add embedding to organizations (for "find similar organizers")
ALTER TABLE market.organizations ADD COLUMN embedding VECTOR(1024);

-- Add embedding to customers (for customer clustering/segmentation)
ALTER TABLE market.customers ADD COLUMN embedding VECTOR(1024);

-- Add embedding to events (for event recommendation)
ALTER TABLE finance.events ADD COLUMN embedding VECTOR(1024);

-- Create HNSW vector indexes for fast approximate nearest neighbor search
CREATE INDEX idx_orgs_embedding ON market.organizations
    USING hnsw (embedding vector_cosine_ops);

CREATE INDEX idx_customers_embedding ON market.customers
    USING hnsw (embedding vector_cosine_ops);

CREATE INDEX idx_events_embedding ON finance.events
    USING hnsw (embedding vector_cosine_ops);

COMMENT ON COLUMN market.organizations.embedding IS 'Qwen 3 embedding (1024D) for semantic similarity search';
COMMENT ON COLUMN market.customers.embedding IS 'Qwen 3 embedding (1024D) for customer segmentation and clustering';
COMMENT ON COLUMN finance.events.embedding IS 'Qwen 3 embedding (1024D) for event recommendation';
