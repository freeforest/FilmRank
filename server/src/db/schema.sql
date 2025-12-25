CREATE DATABASE IF NOT EXISTS filmrank DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE filmrank;

CREATE TABLE IF NOT EXISTS users (
  user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('user','admin') DEFAULT 'user',
  status ENUM('active','banned') DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS movies (
  movie_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  tmdb_id BIGINT NULL,
  title VARCHAR(200) NOT NULL,
  original_title VARCHAR(200) NULL,
  release_date DATE NULL,
  year SMALLINT NULL,
  runtime_minutes SMALLINT NULL,
  language VARCHAR(30) NULL,
  country VARCHAR(50) NULL,
  description TEXT NULL,
  poster_url VARCHAR(500) NULL,
  source ENUM('local','tmdb') DEFAULT 'local',
  last_fetched_at DATETIME NULL,
  status ENUM('active','inactive') DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_movies_tmdb(tmdb_id),
  INDEX idx_movies_title(title),
  INDEX idx_movies_year(year),
  INDEX idx_movies_release(release_date),
  INDEX idx_movies_source_fetched(source, last_fetched_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS genres (
  genre_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) UNIQUE NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS movie_genres (
  movie_id BIGINT NOT NULL,
  genre_id INT NOT NULL,
  PRIMARY KEY (movie_id, genre_id),
  INDEX idx_movie_genres_genre(genre_id, movie_id),
  CONSTRAINT fk_movie_genres_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
  CONSTRAINT fk_movie_genres_genre FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS rating_policy (
  policy_id INT PRIMARY KEY AUTO_INCREMENT,
  min_score DECIMAL(3,1) NOT NULL,
  max_score DECIMAL(3,1) NOT NULL,
  step DECIMAL(3,1) NOT NULL,
  allow_update BOOLEAN DEFAULT TRUE,
  effective_from DATETIME DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ratings (
  rating_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  movie_id BIGINT NOT NULL,
  score DECIMAL(3,1) NOT NULL,
  rated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_user_movie(user_id, movie_id),
  INDEX idx_ratings_user(user_id, rated_at),
  INDEX idx_ratings_movie(movie_id, score),
  CONSTRAINT fk_ratings_user FOREIGN KEY (user_id) REFERENCES users(user_id),
  CONSTRAINT fk_ratings_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS reviews (
  review_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  movie_id BIGINT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  status ENUM('visible','hidden') DEFAULT 'visible',
  INDEX idx_reviews_movie(movie_id, created_at),
  INDEX idx_reviews_user(user_id, created_at),
  CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users(user_id),
  CONSTRAINT fk_reviews_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS watch_history (
  watch_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  movie_id BIGINT NOT NULL,
  watched_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  watch_seconds INT NULL,
  progress DECIMAL(5,2) NULL,
  is_finished BOOLEAN DEFAULT FALSE,
  device VARCHAR(30) NULL,
  INDEX idx_watch_user(user_id, watched_at),
  INDEX idx_watch_movie(movie_id, watched_at),
  CONSTRAINT fk_watch_user FOREIGN KEY (user_id) REFERENCES users(user_id),
  CONSTRAINT fk_watch_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS recommendation_batches (
  batch_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  algorithm ENUM('cf','content','hot','hybrid') NOT NULL,
  generated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  params_json JSON NULL,
  status ENUM('success','failed') DEFAULT 'success',
  INDEX idx_batch_algo_time(algorithm, generated_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS recommendations (
  batch_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  movie_id BIGINT NOT NULL,
  `rank` INT NOT NULL,
  score DOUBLE NOT NULL,
  reason VARCHAR(255) NULL,
  PRIMARY KEY (batch_id, user_id, movie_id),
  UNIQUE KEY uniq_batch_user_rank(batch_id, user_id, rank),
  INDEX idx_reco_user(user_id, batch_id),
  INDEX idx_reco_movie(movie_id),
  CONSTRAINT fk_reco_batch FOREIGN KEY (batch_id) REFERENCES recommendation_batches(batch_id) ON DELETE CASCADE,
  CONSTRAINT fk_reco_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_reco_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO rating_policy (min_score, max_score, step, allow_update, is_active)
SELECT * FROM (SELECT 0.0, 10.0, 0.5, TRUE, TRUE) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM rating_policy WHERE is_active = TRUE);
