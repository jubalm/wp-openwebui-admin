-- Create Authentik database and user
CREATE DATABASE IF NOT EXISTS authentik CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'authentik'@'%' IDENTIFIED BY 'authentik_password';
GRANT ALL PRIVILEGES ON authentik.* TO 'authentik'@'%';
FLUSH PRIVILEGES;