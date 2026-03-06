create DATABASE abebe;
USE abebe ;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
);  
create table admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
);
create table times (
    id INT AUTO_INCREMENT PRIMARY KEY,
    time VARCHAR(255) NOT NULL
);
create table dates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date VARCHAR(255) NOT NULL
); 
create table appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    time_id INT NOT NULL,
    date_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (time_id) REFERENCES times(id),
    FOREIGN KEY (date_id) REFERENCES dates(id)
);
INSERT INTO users (username, password) VALUES ('abebe', 'abebe234');USE abebe;

-- dates: add DATE column, convert, drop old, rename
ALTER TABLE dates ADD COLUMN date_new DATE;
UPDATE dates SET date_new = STR_TO_DATE(date, '%Y-%m-%d');
SELECT id, date, date_new FROM dates;
ALTER TABLE dates DROP COLUMN date;
ALTER TABLE dates CHANGE COLUMN date_new date DATE;

-- times: add TIME column, convert, drop old, rename
ALTER TABLE times ADD COLUMN time_new TIME;
UPDATE times SET time_new = STR_TO_DATE(time, '%l:%i %p');
SELECT id, time, time_new FROM times;
ALTER TABLE times DROP COLUMN time;
ALTER TABLE times CHANGE COLUMN time_new time TIME;
INSERT INTO admin (username, password) VALUES ('admin', 'admin123');
INSERT INTO times (time) VALUES ('9:00 AM'), ('10:00 AM'),  
('11:00 AM'), ('12:00 PM'), ('1:00 PM'), ('2:00 PM'), ('3:00 PM'), ('4:00 PM'), ('5:00 PM');
INSERT INTO dates (date) VALUES ('2024-07-01'), ('2024-07-02'), ('2024-07-03'), ('2024-07-04'), ('2024-07-05'), ('2024-07-06'), ('2024-07-07'), ('2024-07-08'), ('2024-07-09');  
show tables;

// migrate_hashes.js
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');

const DB = { host: 'localhost', user: 'root', password: '', database: 'abebe' };
const SALT_ROUNDS = 10;

async function hashTable(table) {
  const conn = await mysql.createConnection(DB);
  try {
    const [rows] = await conn.query(`SELECT id, password FROM \`${table}\``);
    for (const r of rows) {
      if (!r.password) continue;
      const hash = await bcrypt.hash(r.password, SALT_ROUNDS);
      await conn.query(`UPDATE \`${table}\` SET password_hash = ? WHERE id = ?`, [hash, r.id]);
    }
  } finally {
    await conn.end();
  }
}

async function main() {
  const conn = await mysql.createConnection(DB);
  try {
    // add password_hash columns if missing
    await conn.query("ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255)");
    await conn.query("ALTER TABLE admin ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255)");
    await conn.end();
    await hashTable('users');
    await hashTable('admin');
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
  console.log('Password hashing migration complete. Verify and then remove plaintext columns.');
}

main();

USE abebe;
ALTER TABLE users DROP COLUMN password;
ALTER TABLE users CHANGE COLUMN password_hash password VARCHAR(255);
ALTER TABLE admin DROP COLUMN password;
ALTER TABLE admin CHANGE COLUMN password_hash password VARCHAR(255);
