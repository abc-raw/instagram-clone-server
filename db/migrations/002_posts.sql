-- =======================================================
-- POSTS table
-- =======================================================

CREATE TABLE posts  (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
-- user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE SET NULL,

    caption TEXT,

    location VARCHAR(255),

    likes_count INTEGER DEFAULT 0 NOT NULL,
    comments_count INTEGER DEFAULT 0 NOT NULL,

    deleted_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()

);

CREATE INDEX idx_posts_user_id ON posts(user_id);

CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

CREATE INDEX idx_posts_user_active ON posts(user_id, created_at DESC)
    WHERE deleted_at IS NULL;

CREATE TRIGGER trigger_post_updated_at
BEFORE UPDATE ON posts
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

-- =======================================================
-- POST IMAGES TABLE
-- One post can have multiple images (carousel posts)
-- =======================================================

CREATE TABLE post_images (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    display_order INTEGER DEFAULT 0,
    width INTEGER,
    height INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_post_images_post_id ON post_images(post_id);

CREATE OR REPLACE FUNCTION update_posts_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE users 
            SET posts_count = posts_count + 1
        WHERE id = NEW.user_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE users
            SET posts_count = GREATEST (0, posts_count - 1)
            WHERE id = OLD.user_id;
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_posts_counts
    AFTER INSERT OR DELETE ON posts
    FOR EACH ROW
    EXECUTE FUNCTION update_posts_count();