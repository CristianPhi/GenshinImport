-- Add orders table
CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  weapon_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  total_price DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (weapon_id) REFERENCES weapons(id) ON DELETE CASCADE
);

-- Add sample user (bukan admin)
INSERT INTO users (name, email, password_hash, role)
SELECT 'User Test', 'user@genshinimport.com', '$2a$10$Lv4U8xHBUgQbf/5h6hT44eGqlfL5L/OjiFjFyVq2NAgwYG2Gzfk4m', 'user'
WHERE NOT EXISTS (
  SELECT 1 FROM users WHERE email = 'user@genshinimport.com'
);
