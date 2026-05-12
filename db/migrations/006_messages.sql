-- =======================================================
-- Conversation Table
-- =======================================================


CREATE TABLE conversations (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE conversation_participants (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    conversation_id INTEGER NOT NULL
        REFERENCES conversations(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL
        REFERENCES users(id) ON DELETE CASCADE,
    last_read_message_id INTEGER,
    CONSTRAINT unique_participant UNIQUE(conversation_id, user_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_convo_participants_user ON conversation_participants(user_id);
CREATE INDEX idx_convo_participants_convo ON conversation_participants(conversation_id);

-- =======================================================
-- Message table
-- =======================================================

CREATE TABLE messages (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    conversation_id INTEGER NOT NULL
        REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id INTEGER NOT NULL 
        REFERENCES users(id) ON DELETE CASCADE,
    
    content TEXT,
    message_type VARCHAR(20) DEFAULT 'text' NOT NULL,
    image_url VARCHAR(500),
    shared_post_id INTEGER REFERENCES posts(id) ON DELETE SET NULL,
    seen_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender ON messages(sender_id);

ALTER TABLE conversation_participants
    ADD CONSTRAINT fk_last_read_message
    FOREIGN KEY (last_read_message_id)
    REFERENCES messages(id)
    ON DELETE SET NULL;


CREATE OR REPLACE FUNCTION update_conversation_timestamp()
RETURNS TRIGGER AS $$
BEGIN
UPDATE conversations SET updated_at = NOW()
WHERE id = NEW.conversation_id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_message_updates_conversation
     AFTER INSERT ON messages
     FOR EACH ROW
     EXECUTE FUNCTION update_conversation_timestamp();