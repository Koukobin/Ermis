PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS server_info (server_url TEXT NOT NULL, last_used TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(server_url));

CREATE TABLE IF NOT EXISTS server_accounts (
    server_url TEXT NOT NULL,
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    device_uuid TEXT NOT NULL,
    last_used TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(server_url, email),
    FOREIGN KEY (server_url) REFERENCES server_info(server_url) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS chat_sessions (
    server_url TEXT NOT NULL,
    chat_session_id INTEGER NOT NULL,
    PRIMARY KEY(server_url, chat_session_id),
    FOREIGN KEY(server_url) REFERENCES server_info(server_url) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS chat_messages (
    server_url TEXT NOT NULL,
    chat_session_id INTEGER NOT NULL,
    message_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    text TEXT,
    file_name TEXT,
    file_content_id TEXT,
    content_type INTEGER NOT NULL,
    ts_entered TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(server_url, chat_session_id, message_id),
    CHECK (text IS NOT NULL OR file_content_id IS NOT NULL),
    FOREIGN KEY (server_url, chat_session_id) REFERENCES chat_sessions(server_url, chat_session_id) ON DELETE CASCADE
);
