/* Copyright (C) 2024 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ErmisDB {
  static DBConnection? _conn;

  ErmisDB._() {
    throw Exception(
        "Database cannot be constructed since it is statically initialized!");
  }

  static DBConnection getConnection() {
    _conn ??= DBConnection._create();
    return _conn!;
  }
}

class DBConnection {
  final Future<Database> _database;
  Future<Database> get database => _database;

  const DBConnection._(this._database);

  factory DBConnection._create() {
    final database = _initializeDB();
    return DBConnection._(database);
  }

  static Future<Database> _initializeDB() async {
    // "Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required." by flutter documentation
    // P.S. I don't know exactly why this is necessary, but the documentation said so
    WidgetsFlutterBinding.ensureInitialized();

    final String databaseFolderPath = await getDatabasesPath();
    final String path = join(databaseFolderPath, 'ermis_sqlite_database_6.db');

    Database db = await openDatabase(
      path,
      readOnly: false,
      singleInstance: true,
      onCreate: (Database db, int version) async {},
      onDowngrade: (Database db, int oldVersion, int newVersion) async {},
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion != newVersion) {
          await db.execute('DROP TABLE IF EXISTS server_profiles;');
          await db.execute('DROP TABLE IF EXISTS server_accounts;');
          await db.execute('DROP TABLE IF EXISTS members;');
          await db.execute('DROP TABLE IF EXISTS chat_session_members;');
          await db.execute('DROP TABLE IF EXISTS chat_sessions;');
          await db.execute('DROP TABLE IF EXISTS chat_messages;');
        }
      },
      version: 8,
    );

    // Create the 'servers' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS servers (
        server_url TEXT NOT NULL,
        last_used DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (server_url)
      );
    ''');

    // Create 'server_accounts' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS server_accounts (
        server_url TEXT NOT NULL REFERENCES servers(server_url) ON DELETE CASCADE,
        email TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        device_uuid TEXT NOT NULL,
        last_used DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (server_url, email)
      );
    ''');

    // Create the 'servers_network_usage' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS servers_network_usage (
        server_url TEXT NOT NULL,
        total_bytes_sent INTEGER NOT NULL DEFAULT 0,
        total_bytes_received INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (server_url)
      );
    ''');

    // Create 'server_accounts' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS server_accounts_key_pairs (
        server_url TEXT NOT NULL REFERENCES servers(server_url) ON DELETE CASCADE,
        email TEXT NOT NULL REFERENCES server_accounts(email) ON DELETE CASCADE,
        public_key TEXT NOT NULL,
        private_key TEXT NOT NULL,
        PRIMARY KEY (server_url, email)
      );
    ''');

    // await db.execute('''
    //   DROP TABLE server_profiles;
    // ''');

    // Create 'server_profiles' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS server_profiles (
        server_url TEXT NOT NULL REFERENCES servers(server_url) ON DELETE CASCADE,
        email TEXT NOT NULL REFERENCES server_accounts(email) ON DELETE CASCADE,
        display_name TEXT NOT NULL,
        client_id INTEGER NOT NULL,
        profile_photo BLOB NOT NULL,
        last_updated_at TIMESTAMP NOT NULL,
        PRIMARY KEY (server_url, email, client_id)
      );
    ''');

    // await db.execute('''
    //   DROP TABLE members;
    // ''');
    // await db.execute('''
    //   DROP TABLE chat_session_members;
    // ''');
    // await db.execute('''
    //   DROP TABLE chat_sessions;
    // ''');

    // 'chat_sessions' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_sessions (
        server_url TEXT NOT NULL REFERENCES servers(server_url) ON DELETE CASCADE,
        chat_session_id INTEGER NOT NULL,
        PRIMARY KEY (server_url, chat_session_id)
      );
    ''');

    // 'members' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS members (
        server_url TEXT NOT NULL REFERENCES servers(server_url) ON DELETE CASCADE,
        display_name TEXT NOT NULL,
        client_id INTEGER NOT NULL,
        profile_photo BLOB NOT NULL,
        last_updated_at TIMESTAMP NOT NULL,
        PRIMARY KEY (server_url, client_id)
      );
    ''');

    // 'chat_session_members' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_session_members (
        server_url TEXT NOT NULL REFERENCES members(server_url) ON DELETE CASCADE,
        chat_session_id INTEGER NOT NULL REFERENCES chat_sessions (chat_session_id) ON DELETE CASCADE,
        client_id INTEGER NOT NULL REFERENCES members (client_id) ON DELETE CASCADE,
        PRIMARY KEY (server_url, chat_session_id, client_id)
      );
    ''');

    // await db.execute('''
    //   DROP TABLE chat_messages;
    // ''');

    // 'chat_messages' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        server_url TEXT NOT NULL,
        chat_session_id INTEGER NOT NULL,
        display_name TEXT NOT NULL REFERENCES members (display_name) ON DELETE CASCADE,
        message_id INTEGER NOT NULL,
        client_id INTEGER NOT NULL,
        text TEXT,
        file_name TEXT,
        file_content_id TEXT,
        content_type INTEGER NOT NULL,
        delivery_status INT NOT NULL,
        ts_entered TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (server_url, chat_session_id, message_id),
        CHECK (text IS NOT NULL OR file_content_id IS NOT NULL),
        FOREIGN KEY (server_url, chat_session_id)
            REFERENCES chat_sessions (server_url, chat_session_id) ON DELETE CASCADE
      );
    ''');

    // 'unread_messages' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS unread_messages (
        server_url TEXT NOT NULL,
        chat_session_id INTEGER NOT NULL,
        message_id INTEGER NOT NULL,
        PRIMARY KEY (server_url, chat_session_id, message_id),
        FOREIGN KEY (server_url, chat_session_id, message_id)
            REFERENCES chat_messages (server_url, chat_session_id, message_id) ON DELETE CASCADE
      );
    ''');

    return db;
  }

}

