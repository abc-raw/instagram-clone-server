-- =======================================================
-- LIKES TABLE
-- =======================================================

CREATE TABLE likes (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INTEGER NOT NULL 
        REFERENCES users(id) ON DELETE CASCADE,
    post_id INTEGER NOT NULL
        REFERENCES posts(id) ON DELETE CASCADE,

    CONSTRAINT unique_like UNIQUE(user_id, post_id),

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_likes_user_post ON likes(user_id, post_id);
CREATE INDEX idx_likes_post on likes(post_id);


CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts
            SET likes_count = likes_count + 1
            WHERE id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts 
            SET likes_count = GREATEST(0, likes_count - 1)
            WHERE id = OLD.post_id;
        return OLD;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_post_likes_count
    AFTER INSERT OR DELETE ON likes
    FOR EACH ROW
    EXECUTE FUNCTION update_post_likes_count();