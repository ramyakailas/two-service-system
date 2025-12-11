-- Initialize database schema and seed data
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert seed data
INSERT INTO messages (content) VALUES ('Hello from PostgreSQL! This is the seeded string.');
INSERT INTO messages (content) VALUES ('Welcome to the two-service architecture system!');

