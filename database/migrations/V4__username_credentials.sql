CREATE TABLE t_username_credential (
  username VARCHAR(20) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  user_id BIGINT NOT NULL,
  password_hash VARCHAR(255) CHARACTER SET ascii NOT NULL,
  PRIMARY KEY (username),
  UNIQUE KEY uk_username_user (user_id),
  FOREIGN KEY (user_id) REFERENCES t_user (userid)
) ENGINE=InnoDB;
