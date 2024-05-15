-- Active: 1704637861352@@127.0.0.1@5432@cinema
INSERT INTO Genres (genre_name) VALUES
('Action'),
('Drama'),
('Comedy'),
('Thriller'),
('Sci-Fi');


INSERT INTO Movies (title, duration, director, release_date) VALUES
('The Great Escape', 120, 'John Smith', '2023-05-15'),
('Love in the Time of Cholera', 150, 'Jane Doe', '2023-06-20'),
('Laugh Out Loud', 90, 'Jim Bean', '2023-07-25'),
('Night Crawler', 115, 'Alice Wonderland', '2023-08-30'),
('Star Quest', 140, 'George Lucas', '2023-09-15');

INSERT INTO Genres_Movies (genre_id, movie_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO Rooms (room_number, capacity) VALUES
(101, 50),
(102, 75),
(103, 100),
(104, 120);

INSERT INTO Shows (movie_id, room_id, start_time) VALUES
(1, 1, '2023-12-15 14:00:00'),
(2, 2, '2023-12-15 16:00:00'),
(3, 3, '2023-12-15 18:00:00'),
(4, 4, '2023-12-15 20:00:00');

INSERT INTO Persons (name, email, phone) VALUES
('John Doe', 'johndoe@example.com', '123-456-7890'),
('Jane Smith', 'janesmith@example.com', '987-654-3210'),
('Alice Johnson', 'alicej@example.com', '456-789-1234'),
('Bob Lee', 'boblee@example.com', '321-654-9870');

INSERT INTO Purchases (buyer_id, purchase_time, payment_method) VALUES
(1, '2023-12-10 10:00:00', 'Credit Card'),
(2, '2023-12-10 10:15:00', 'PayPal');

INSERT INTO Tickets (show_id, seat_number, purchase_id, price) VALUES
(1, 'A1', 1, 12.50),
(1, 'A2', 1, 12.50),
(2, 'B1', 2, 15.00),
(2, 'B2', 2, 15.00);
