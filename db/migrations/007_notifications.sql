-- =======================================================
-- NOTIFICATION TABLE
-- =======================================================

CREATE TABLE notifications (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    recipient_id INTEGER NOT NULL 
        REFERENCES users(id) ON DELETE CASCADE,
    actor_id INTEGER NOT NULL
        REFERENCES users(id) ON DELETE CASCADE,

    type VARCHAR(50) NOT NULL,

    entity_type VARCHAR(50),
    entity_id INTEGER,
    message TEXT,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notifications_recipient ON notifications(recipient_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON notifications(recipient_id)
    WHERE read_at IS NULL;