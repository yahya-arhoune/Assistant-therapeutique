-- =============================
-- Sample Users
-- =============================
--INSERT INTO user (id, username, email, password) VALUES
--(1, 'yahya', 'yahya@mail.com', '$2a$10$CwTycUXWue0Thq9StjUM0uJ8m3a.F3h0/9b0b6cX3Zx9t8/f1yNqW'); -- password: 123456

-- =============================
-- Sample Emotion Entries
-- =============================
--INSERT INTO emotion_entry (id, mood, intensity, note, created_at, user_id) VALUES
--(1, 'happy', 4, 'Feeling good today', NOW(), 1),
--(2, 'stressed', 3, 'Exam preparation', NOW(), 1),
--(3, 'sad', 2, 'Missed a deadline', NOW(), 1);

-- =============================
-- Sample Chat Messages
-- =============================
--INSERT INTO chat_message (id, sender, message, timestamp, user_id) VALUES
--(1, 'user', 'I feel anxious', NOW(), 1),
--(2, 'ai', 'It is normal to feel anxious. Take a deep breath.', NOW(), 1);
