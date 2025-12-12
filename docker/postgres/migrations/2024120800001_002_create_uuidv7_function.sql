-- Sonik OS: Create UUIDv7 Function
-- Phase: 1 - Task 1.2
-- Date: 2025-12-08
-- Description: Time-ordered UUIDs for better index performance on high-volume tables
-- Source: https://gist.github.com/fabiolimace/515a0440e3e40efeb234e12644a6a346

CREATE OR REPLACE FUNCTION uuidv7() RETURNS uuid AS $$
DECLARE
  unix_ts_ms BIGINT;
  uuid_bytes BYTEA;
BEGIN
  unix_ts_ms := (EXTRACT(EPOCH FROM clock_timestamp()) * 1000)::BIGINT;
  uuid_bytes := decode(lpad(to_hex(unix_ts_ms), 12, '0'), 'hex');
  -- Supabase Cloud puts pgcrypto in 'extensions' schema
  uuid_bytes := uuid_bytes || extensions.gen_random_bytes(10);
  uuid_bytes := set_byte(uuid_bytes, 6, (get_byte(uuid_bytes, 6) & x'0f'::int) | x'70'::int);
  uuid_bytes := set_byte(uuid_bytes, 8, (get_byte(uuid_bytes, 8) & x'3f'::int) | x'80'::int);
  RETURN encode(uuid_bytes, 'hex')::uuid;
END;
$$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION uuidv7() IS 'Generate time-ordered UUIDv7 for better B-tree index performance';

-- Test the function
SELECT uuidv7() AS test_uuid;
