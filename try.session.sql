CREATE DATABASE IF NOT EXISTS school_db;
USE school_db;
CREATE TABLE IF NOT EXISTS students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    age INT,
    city VARCHAR(50)
);

-- INSERT (run once only!)
INSERT INTO students (name, age, city) VALUES
('Bishu', 20, 'Arba Minch'),
('Sara', 22, 'Addis Ababa'),
('Kedir', 21, 'Hawassa');

-- QUERIES (run these as many times as you want)
SELECT * FROM students;