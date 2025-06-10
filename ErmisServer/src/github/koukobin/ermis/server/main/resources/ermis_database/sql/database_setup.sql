/* Copyright (C) 2022-2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    email TEXT NOT NULL UNIQUE,
    password_hash CHAR(PASSWORD_HASH_LENGTH) NOT NULL,
    client_id INTEGER NOT NULL, -- IDs are generated manually within server
    backup_verification_codes CHAR(BACKUP_VERIFICATION_CODES_LENGTH)[BACKUP_VERIFICATION_CODES_AMOUNT] NOT NULL,
    salt CHAR(SALT_LENGTH) NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    password_last_updated_at TIMESTAMP DEFAULT now(),
    PRIMARY KEY (client_id)
);

CREATE INDEX IF NOT EXISTS users_client_id_index ON users (client_id);
CREATE INDEX IF NOT EXISTS users_email_index ON users (email);

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
    client_id INTEGER NOT NULL REFERENCES users(client_id) ON DELETE CASCADE,
    display_name VARCHAR(DISPLAY_LENGTH) NOT NULL,
    about VARCHAR(128) NOT NULL,
    profile_photo_id TEXT, -- Hallmark name of profile photo bytes stored on local storage
    last_updated_at TIMESTAMP DEFAULT now(),
    display_name_updated_at TIMESTAMP DEFAULT now(),
    about_updated_at TIMESTAMP DEFAULT now(),
    profile_photo_updated_at TIMESTAMP DEFAULT now(),
    PRIMARY KEY (client_id)
);

CREATE INDEX IF NOT EXISTS user_profiles_display_name_index ON user_profiles (display_name);
CREATE INDEX IF NOT EXISTS user_profiles_about_index ON user_profiles (about);

-- Create trigger for "user_profiles" to ensure that "last_updated_at" 
-- is automatically renewed whenever the row is modified
CREATE OR REPLACE FUNCTION update_last_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    IF row(NEW.*) IS DISTINCT FROM row(OLD.*) THEN
        NEW.last_updated_at = now();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_update_last_updated_at
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION update_last_updated_at();

-- Create device type enum table
--DO $$
--BEGIN
--    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'device_type_enum') THEN
--        CREATE TYPE device_type_enum AS ENUM ('MOBILE', 'DESKTOP');
--    END IF;
--END
--$$;

-- Create user_ips table
CREATE TABLE IF NOT EXISTS user_ips (
    client_id INTEGER NOT NULL REFERENCES users(client_id) ON DELETE CASCADE,
    ip_address TEXT NOT NULL,
    device_type INTEGER NOT NULL,
    os_name TEXT NOT NULL,
    logged_in_at TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (client_id, ip_address)
);

-- Create chat_requests tables
CREATE TABLE IF NOT EXISTS chat_requests (
    chat_request_id SERIAL,
    receiver_client_id INTEGER NOT NULL REFERENCES users(client_id) ON DELETE CASCADE,
    sender_client_id INTEGER NOT NULL REFERENCES users(client_id) ON DELETE CASCADE,
    PRIMARY KEY (receiver_client_id, sender_client_id)
);

-- Create chat_sessions table
CREATE TABLE IF NOT EXISTS chat_sessions (
    chat_session_id INTEGER NOT NULL PRIMARY KEY, -- IDs are generated manually within server
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS chat_sessions_chat_session_id_index ON chat_sessions (chat_session_id);

-- Create chat_session_members table
CREATE TABLE IF NOT EXISTS chat_session_members (
    chat_session_id INTEGER NOT NULL REFERENCES chat_sessions(chat_session_id) ON DELETE CASCADE,
    member_id INTEGER NOT NULL REFERENCES users(client_id) ON DELETE CASCADE,
    joined_at TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (chat_session_id, member_id) -- Ensures unique member-session relationships
);

CREATE INDEX IF NOT EXISTS chat_session_members_chat_session_id_member_id_index ON chat_session_members (chat_session_id, member_id);

-- Create trigger for "users" to ensure that chat sessions
-- associated with a user account are automatically deleted 
-- when aforementioned user account is deleted
CREATE OR REPLACE FUNCTION delete_private_chats_on_user_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete chat sessions where the deleted user was a member
    -- and the session has only one member remaining.
    DELETE FROM chat_sessions
    WHERE chat_session_id IN (
        SELECT chat_session_id
        FROM chat_session_members
        WHERE member_id = OLD.client_id
    )
    AND (SELECT COUNT(*)
         FROM chat_session_members
         WHERE chat_session_id = chat_sessions.chat_session_id) = 1;
     RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_delete_private_chats_on_user_delete
AFTER DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION delete_private_chats_on_user_delete();

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
    ts_entered TIMESTAMP NOT NULL DEFAULT now(),
    message_id INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    chat_session_id INTEGER NOT NULL REFERENCES chat_sessions (chat_session_id) ON DELETE CASCADE,
    client_id INTEGER NOT NULL REFERENCES users (client_id) ON DELETE CASCADE,
    text TEXT,
    file_name TEXT,
    file_content_id TEXT, -- Hallmark identifier of file bytes stored on local storage
    content_type INTEGER NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE, -- "is_received" would be a more appropriate/suitable name; but I am too lazy to make the change..
    PRIMARY KEY (chat_session_id, message_id),
    CHECK (text IS NOT NULL OR file_content_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS chat_messages_message_id_index ON chat_messages (message_id);

-- Create voice/video calls table
CREATE TABLE IF NOT EXISTS voice_call_history (
	voice_call_history_id INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
	ts_debuted TIMESTAMP NOT NULL DEFAULT now(),
	ts_ended TIMESTAMP,
	chat_session_id INTEGER NOT NULL REFERENCES chat_sessions (chat_session_id) ON DELETE CASCADE,
	initiator_client_id INTEGER NOT NULL REFERENCES users (client_id) ON DELETE CASCADE,
	PRIMARY KEY (voice_call_history_id)
);

CREATE INDEX IF NOT EXISTS voice_call_history_voice_call_history_id_index ON voice_call_history (voice_call_history_id);

CREATE TABLE IF NOT EXISTS voice_call_history_participants (
	voice_call_history_id INTEGER NOT NULL REFERENCES voice_call_history (voice_call_history_id) ON DELETE CASCADE,
	client_id INTEGER NOT NULL REFERENCES users (client_id) ON DELETE CASCADE,
	PRIMARY KEY (voice_call_history_id, client_id)
);

CREATE INDEX IF NOT EXISTS voice_call_history_participants_voice_call_history_id_client_id_index ON voice_call_history_participants (voice_call_history_id, client_id);
