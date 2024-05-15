-- Active: 1704637861352@@127.0.0.1@5432@cinema
CREATE DATABASE cinema;
-- use this database!!!
CREATE TABLE Genres ( 
    genre_id SERIAL PRIMARY KEY, 
    genre_name NAME
); 

CREATE TABLE Movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    duration INT,
    director VARCHAR(255),
    release_date DATE
);

CREATE TABLE Genres_Movies (
    genre_id INT REFERENCES Genres(genre_id),
    movie_id INT REFERENCES Movies(movie_id),
    PRIMARY KEY(genre_id, movie_id)
);

CREATE TABLE Rooms (
    room_id SERIAL PRIMARY KEY,
    room_number INT,
    capacity INT
);

CREATE TABLE Shows (
    show_id SERIAL PRIMARY KEY,
    movie_id INT,
    room_id INT,
    start_time TIMESTAMP,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

CREATE TABLE Persons (
    person_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(15)
);

CREATE TABLE Purchases (
    purchase_id SERIAL PRIMARY KEY,
    buyer_id INT,
    purchase_time TIMESTAMP,
    payment_method VARCHAR(50),
    FOREIGN KEY (buyer_id) REFERENCES Persons(person_id)
);

CREATE TABLE Tickets (
    ticket_id SERIAL PRIMARY KEY,
    show_id INT,
    seat_number VARCHAR(10),
    purchase_id INT,
    price DECIMAL,
    FOREIGN KEY (show_id) REFERENCES Shows(show_id),
    FOREIGN KEY (purchase_id) REFERENCES Purchases(purchase_id)
);

