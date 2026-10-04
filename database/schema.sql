-- FireSight Sports Database Schema

-- Example table for matches
CREATE TABLE IF NOT EXISTS matches (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    sport VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Example table for gesture events
CREATE TABLE IF NOT EXISTS gesture_events (
    id VARCHAR(36) PRIMARY KEY,
    match_id VARCHAR(36) REFERENCES matches(id),
    gesture_type VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
