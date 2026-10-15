CREATE TABLE messages (
  id INTEGER AUTO_INCREMENT PRIMARY KEY,
  timestamp INTEGER,
  user_id BIGINT,
  username VARCHAR(255),
  message TEXT ,
  server VARCHAR(255),
  channel VARCHAR(255),
  message_id BIGINT
) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE learned (
  id INTEGER AUTO_INCREMENT PRIMARY KEY,
  timestamp BIGINT,
  user_id BIGINT,
  message TEXT,
  server VARCHAR(255),
  channel VARCHAR(255),
  message_id BIGINT
) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE train_accidents (
  id INTEGER AUTO_INCREMENT PRIMARY KEY,
  timestamp BIGINT,
  user_id BIGINT,
  server VARCHAR(255),
  channel VARCHAR(255)
) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE announcements (
  id INTEGER AUTO_INCREMENT PRIMARY KEY,
  server VARCHAR(255),
  channel VARCHAR(255),
  day INTEGER,
  month INTEGER,
  year INTEGER,
  message TEXT,
  guild_scheduled_event_id BIGINT,
  google_calendar_id VARCHAR(255),
  url TEXT,
  calendar_summary TEXT,
  calendar_description TEXT,
  calendar_start_time BIGINT,
  calendar_end_time BIGINT,
  timestamp BIGINT,
  cancelled_timestamp BIGINT
) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE redis_0 (
  `key` VARCHAR(255),
  value TEXT,
  timestamp BIGINT
) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE message_metadata (
  message_id VARCHAR(255),
  type VARCHAR(255),
  value TEXT,
  PRIMARY KEY (message_id, type)
) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;
