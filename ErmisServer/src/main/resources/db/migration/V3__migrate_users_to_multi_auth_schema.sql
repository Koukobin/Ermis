/* Copyright (C) 2026 Ilias Koukovinis <ilias.koukovinis@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

BEGIN;

-- Preserve legacy users table for later migration
ALTER TABLE IF EXISTS users RENAME TO users_legacy;
DROP INDEX IF EXISTS users_client_id_index;
DROP INDEX IF EXISTS users_email_index;

-- Create new multi-auth users schema architecture
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'auth_method_enum') THEN
        CREATE TYPE auth_method_enum AS ENUM ('email');
    END IF;
END
$$;

CREATE TABLE IF NOT EXISTS users (
    client_id INTEGER NOT NULL, -- IDs are generated manually within server
    auth_method auth_method_enum NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (client_id)
);

-- Email + password login
CREATE TABLE IF NOT EXISTS user_auth_email (
    client_id INTEGER NOT NULL REFERENCES users(client_id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    password_hash CHAR(22) NOT NULL,
    backup_verification_codes CHAR(12)[3] NOT NULL,
    salt CHAR(12) NOT NULL,
    password_last_updated_at TIMESTAMP DEFAULT now(),
    PRIMARY KEY (client_id)
);

CREATE INDEX IF NOT EXISTS idx_users_client_id ON users (client_id);
CREATE INDEX IF NOT EXISTS idx_user_email_client_id ON user_auth_email (client_id);

-- Repoint dependent foreign keys.
--    Postgres foreign keys track the referenced table by OID,
--    not by name, so table `users` RENAME to `users_legacy` carried
--    every existing FK that pointed at `users` along with it.
-- 	  They now silently point at `users_legacy` instead of the new `users` table.
--    This finds every such constraint and recreates it against
--    the new `users` table.
DO $$
DECLARE
    r RECORD;
    new_def TEXT;
BEGIN
    FOR r IN
        SELECT c.oid,
               c.conname,
               c.conrelid::regclass AS table_name,
               pg_get_constraintdef(c.oid) AS def
        FROM pg_constraint c
        WHERE c.contype = 'f'
          AND c.confrelid = 'users_legacy'::regclass
    LOOP
        new_def := replace(r.def, 'users_legacy', 'users');
 
        EXECUTE format('ALTER TABLE %s DROP CONSTRAINT %I', r.table_name, r.conname);
        EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I %s', r.table_name, r.conname, new_def);
 
        RAISE NOTICE 'Repointed constraint % on table % to reference users', r.conname, r.table_name;
    END LOOP;
END
$$;

-- Ensure user has at least ONE registered registration method
CREATE OR REPLACE FUNCTION check_user_has_registered_method()
RETURNS TRIGGER AS $$
DECLARE
    has_email BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM user_auth_email WHERE client_id = NEW.client_id) INTO has_email;

    IF NOT (has_email) THEN
        RAISE EXCEPTION 'User % has no registered authentication method', NEW.client_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Deferred so check does not fire prematurely
CREATE CONSTRAINT TRIGGER trg_user_has_auth_method
    AFTER INSERT ON users
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE FUNCTION check_user_has_registered_method();

-- ACTUAL MIGRATION

-- Migrate legacy users to new system
INSERT INTO users (client_id, auth_method, created_at)
OVERRIDING SYSTEM VALUE
SELECT client_id, 'email'::auth_method_enum, created_at
FROM users_legacy;

INSERT INTO user_auth_email (client_id, email, password_hash, salt, backup_verification_codes, password_last_updated_at)
SELECT client_id,
       email,
       password_hash,
       salt,
       backup_verification_codes,
       password_last_updated_at
FROM users_legacy;

COMMIT;
