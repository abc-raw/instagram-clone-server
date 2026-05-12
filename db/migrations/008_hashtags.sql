-- =======================================================
--  HASHTAGS
-- =======================================================

CREATE TABLE Hashtags(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    posts_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_hashtags_name ON hashtags(name);

CREATE TABLE post_hashtags (
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    hashtag_id INTEGER NOT NULL REFERENCES hashtags(id) ON DELETE CASCADE,

    PRIMARY KEY (post_id, hashtag_id)
);

CREATE INDEX idx_post_hashtags_hastag ON post_hashtags(hashtag_id);

CREATE OR REPLACE FUNCTION update_hashtag_count()
RETURNS TRIGGER AS $$
BEGIN 
    IF TG_OP = 'INSERT' THEN
        UPDATE hashtags SET posts_count = posts_count + 1
            WHERE id = NEW.hashtag_id;
            RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE hashtags SET posts_count = GREATEST(0, posts_count - 1)
        WHERE id = OLD.hashtag_id;
        RETURN OLD;
    END IF;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_hashtag_count 
    AFTER INSERT OR DELETE ON post_hashtags
    FOR EACH ROW
    EXECUTE FUNCTION update_hashtag_count();