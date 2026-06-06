-- Jalankan sekali di MySQL (database: genshinimport)

CREATE TABLE IF NOT EXISTS auth_tokens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  token VARCHAR(64) NOT NULL,
  expired_at DATETIME,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO users (username, email, password, role)
SELECT 'Admin', 'admin@genshinimport.com', 'admin123', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@genshinimport.com');

INSERT INTO users (username, email, password, role)
SELECT 'User Test', 'user@genshinimport.com', 'admin123', 'user'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'user@genshinimport.com');

INSERT INTO weapons (name, type, description, stock, price, image)
SELECT 'Sword of Descension', 'Sword', 'Pedang starter untuk traveler.', 10, 500, 'https://picsum.photos/seed/sword1/400'
WHERE NOT EXISTS (SELECT 1 FROM weapons WHERE name = 'Sword of Descension');

INSERT INTO weapons (name, type, description, stock, price, image)
SELECT 'Prototype Rancour', 'Sword', 'Pedang craftable dengan ATK fisik.', 5, 1200, 'https://picsum.photos/seed/sword2/400'
WHERE NOT EXISTS (SELECT 1 FROM weapons WHERE name = 'Prototype Rancour');

INSERT INTO weapons (name, type, description, stock, price, image)
SELECT 'Favonius Warbow', 'Bow', 'Bow untuk support elemental.', 8, 900, 'https://picsum.photos/seed/bow1/400'
WHERE NOT EXISTS (SELECT 1 FROM weapons WHERE name = 'Favonius Warbow');
