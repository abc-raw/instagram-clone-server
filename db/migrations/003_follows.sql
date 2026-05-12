-- =======================================================
-- FOLLOWS TABLE
-- represents the "FOLLOWER FOLLOWS FOLLOWING" relationship
-- =======================================================

CREATE TABLE follows(
    follower_id INTEGER NOT NULL
        REFERENCES users(id) ON DELETE CASCADE,

    following_id INTEGER NOT NULL
        REFERENCES users(id) on DELETE CASCADE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    PRIMARY KEY (follower_id, following_id),

    CONSTRAINT no_self_follow
        CHECK (follower_id <> following_id)
);

CREATE INDEX idx_follows_following ON follows(following_id);
CREATE INDEX idx_follows_follower ON follows(follower_id);

CREATE OR REPLACE FUNCTION update_follow_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN

        UPDATE users SET followers_count = followers_count + 1
        WHERE id = NEW.following_id;
        UPDATE users SET following_count = following_count + 1
        WHERE id = NEW.follower_id;
        RETURN NEW;
    
    ELSIF TG_OP = 'DELETE' THEN

        UPDATE users SET followers_count = GREATEST(0, followers_count - 1)
            WHERE id = OLD.following_id;
        UPDATE users SET following_count = GREATEST(0, following_count - 1)
            WHERE id = OLD.follower_id;
        RETURN OLD;
    END IF;
END 
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_follow_counts
    AFTER INSERT OR DELETE ON follows
    FOR EACH ROW
    EXECUTE FUNCTION update_follow_counts();