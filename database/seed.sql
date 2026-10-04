-- FireSight Sports Database Seed Data

INSERT INTO matches (id, title, sport, status) VALUES
('match-001', 'Sample Match 1', 'Basketball', 'completed'),
('match-002', 'Sample Match 2', 'Soccer', 'live');

INSERT INTO gesture_events (id, match_id, gesture_type) VALUES
('evt-001', 'match-001', 'SWIPE_LEFT'),
('evt-002', 'match-001', 'THUMBS_UP');
