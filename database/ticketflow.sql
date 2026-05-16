-- =====================================================
--  EVENT TICKET BOOKING SYSTEM
--  PHASE 3: PHYSICAL DESIGN
--  MySQL Version
-- =====================================================
--  HOW TO USE THIS FILE:
--  Each member pastes their part in the correct section
--  below and commits their changes to GitHub.
--  Parts must be run in order: 1 → 2 → 3 → 4 → 5
-- =====================================================
 
 
-- =====================================================
--  PART 1 — SCHEMA (Tables & Indexes)
--  Member 1
--  Paste your part1_schema.sql code below this line
-- =====================================================
 SET FOREIGN_KEY_CHECKS = 0;
 
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS venue;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS role;
 
SET FOREIGN_KEY_CHECKS = 1;
 
 -- =====================================================
--           TABLES (with constraints & 3NF)
-- =====================================================
 
CREATE TABLE role (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);
 
CREATE TABLE users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    phone_number  VARCHAR(10) UNIQUE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    role_id       INT,
    CONSTRAINT fk_users_role
        FOREIGN KEY (role_id) REFERENCES role(id)
        ON DELETE SET NULL
);
 
CREATE TABLE category (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);
 
CREATE TABLE venue (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    name     VARCHAR(100) NOT NULL UNIQUE,
    address  VARCHAR(150) NOT NULL UNIQUE,
    capacity INT NOT NULL,
    CONSTRAINT chk_venue_capacity CHECK (capacity > 0)
);
 
CREATE TABLE event (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    description    TEXT NOT NULL,
    start_datetime DATETIME NOT NULL,
    end_datetime   DATETIME NOT NULL,
    ticket_price   DECIMAL(8,2) NOT NULL,
    event_capacity INT NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    organizer_id   INT,
    category_id    INT,
    venue_id       INT,
    CONSTRAINT chk_ticket_price    CHECK (ticket_price >= 0),
    CONSTRAINT chk_event_capacity  CHECK (event_capacity > 0),
    CONSTRAINT chk_event_dates     CHECK (end_datetime > start_datetime),
    CONSTRAINT fk_event_organizer
        FOREIGN KEY (organizer_id) REFERENCES users(id)
        ON DELETE SET NULL,
    CONSTRAINT fk_event_category
        FOREIGN KEY (category_id) REFERENCES category(id)
        ON DELETE SET NULL,
    CONSTRAINT fk_event_venue
        FOREIGN KEY (venue_id) REFERENCES venue(id)
        ON DELETE SET NULL
);
 
CREATE TABLE booking (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status       ENUM('in-progress', 'confirmed', 'cancelled', 'rejected') NOT NULL DEFAULT 'in-progress',
    user_id      INT,
    CONSTRAINT chk_booking_amount CHECK (total_amount >= 0),
    CONSTRAINT fk_booking_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE SET NULL
);
 
CREATE TABLE payment (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    payment_amount    DECIMAL(10,2) NOT NULL,
    payment_method    ENUM('Cash', 'Card', 'EFT') NOT NULL,
    transaction_ref   VARCHAR(100) UNIQUE,
    payment_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_status    ENUM('Pending', 'Completed', 'Failed', 'Refunded') NOT NULL DEFAULT 'Pending',
    booking_id        INT,
    CONSTRAINT chk_payment_amount CHECK (payment_amount > 0),
    CONSTRAINT fk_payment_booking
        FOREIGN KEY (booking_id) REFERENCES booking(id)
        ON DELETE SET NULL
);
 
CREATE TABLE ticket (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    seat_number   VARCHAR(10) NOT NULL,
    ticket_status ENUM('available', 'reserved', 'sold') NOT NULL DEFAULT 'available',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_id    INT,
    event_id      INT,
    CONSTRAINT uq_seat_event UNIQUE (seat_number, event_id),
    CONSTRAINT fk_ticket_booking
        FOREIGN KEY (booking_id) REFERENCES booking(id)
        ON DELETE SET NULL,
    CONSTRAINT fk_ticket_event
        FOREIGN KEY (event_id) REFERENCES event(id)
        ON DELETE SET NULL
);
-- =====================================================
--                      INDEXES
-- =====================================================
 
CREATE INDEX idx_users_email      ON users(email);
CREATE INDEX idx_event_date       ON event(start_datetime);
CREATE INDEX idx_event_organizer  ON event(organizer_id);
CREATE INDEX idx_booking_user     ON booking(user_id);
CREATE INDEX idx_booking_status   ON booking(status);
CREATE INDEX idx_ticket_event     ON ticket(event_id);
CREATE INDEX idx_payment_booking  ON payment(booking_id);

 
-- =====================================================
--  PART 2 — SAMPLE DATA (All INSERT statements)
--  Member 2
--  Paste your part2_data.sql code below this line
-- =====================================================
-- =====================================================
--                       SAMPLE DATA
-- =====================================================
 
INSERT INTO role (name) VALUES ('Admin'), ('Organizer'), ('Customer');
 
INSERT INTO category (name) VALUES ('Music'), ('Sports'), ('Comedy'), ('Theatre'), ('Conference');
 
INSERT INTO venue (name, address, capacity) VALUES
('City Hall',           '123 Main Street, Johannesburg',    500),
('FNB Stadium',        '45 Stadium Road, Soweto',          1000),
('Sandton Convention',  '161 Maude Street, Sandton',        2000),
('Theatre on Square',   'Nelson Mandela Square, Sandton',   300),
('Coca Cola Dome',      'Northgate, Johannesburg',          5000);
 
INSERT INTO users (first_name, last_name, email, password_hash, phone_number, role_id) VALUES
('Mr LI',    'Phiri',      '36151262@mynwu.ac.za',     'Phiri001', '0680952852', 2),
('Mr LB',    'Zwane',    '38061813@mynwu.ac.za',     'Zwane002', '0788543586', 3),
('MR QN',   'Kumane',    '45097208@mynwu.ac.za',    'Kumane003', '0734567890', 2),
('Ms MP',   'Rikhotso',  '42910692@mynwu.ac.za',    'Rikhotso004', '0745678901', 3),
('Mr TJ',  'Sithole',  '51636654@mynwu.ac.za',   'Sithole005', '0756789012', 3),
('Ms SD',   'Mafifi',  '29873339@mynwu.ac.za',    'Mafifi006', '0614657675', 2),
('Ms K',  'Kgaticwe',    '46768440@mynwu.ac.za',   'Kgaticwe007', '0763260429', 3),
('Ms SP',   'Mbongozi',     '43759955@mynwu.ac.za',    'Mbongozi008', '0763198342', 1); 
 
 INSERT INTO event (name, description, start_datetime, end_datetime, ticket_price, event_capacity, organizer_id, category_id, venue_id) VALUES
('Soul Session',          'Live jazz music evening',          '2026-06-01 18:00:00', '2026-06-01 22:00:00', 150.00, 500,  1, 1, 1),
('Spain vs Cape Verde',        'World Cup Match Live',  '2026-06-15 15:00:00', '2026-06-15 17:00:00', 200.00, 1000, 3, 2, 2),
('Business Summit',     'Annual business conference',       '2026-07-01 09:00:00', '2026-07-01 17:00:00', 850.00, 2000, 6, 5, 3),
('PNC Special Nights',        'Stand-up comedy show',             '2026-07-20 20:00:00', '2026-07-20 22:30:00', 350.00, 300,  1, 3, 4),
('Scorpion Kings',   'Biggest Amapiano event of 2026',   '2026-08-10 17:00:00', '2026-08-11 02:00:00', 450.00, 5000, 6, 1, 5),
('Red Bull Symphonic',        'Musical Festival',   '2026-09-05 19:00:00', '2026-09-05 22:00:00', 680.00, 300,  3, 4, 4);

INSERT INTO booking (total_amount, status, user_id) VALUES
(150.00,  'confirmed',   2),
(200.00,  'confirmed',   4),
(700.00,  'confirmed',   5),
(350.00,  'confirmed',   7),
(450.00,  'in-progress', 2),
(680.00,  'cancelled',   4),
(850.00,  'confirmed',   5),
(300.00,  'rejected',    7);

INSERT INTO payment (payment_amount, payment_method, transaction_ref, payment_status, booking_id) VALUES
(150.00, 'Card', 'TXN-001', 'Completed', 1),
(200.00, 'EFT',  'TXN-002', 'Completed', 2),
(700.00, 'Card', 'TXN-003', 'Completed', 3),
(350.00, 'Cash', 'TXN-004', 'Completed', 4),
(680.00, 'Card', 'TXN-006', 'Refunded',  6),
(850.00, 'EFT',  'TXN-007', 'Completed', 7);

INSERT INTO ticket (seat_number, ticket_status, booking_id, event_id) VALUES
('A1', 'sold',      1, 1),
('B3', 'sold',      2, 2),
('C5', 'sold',      3, 3),
('D2', 'sold',      4, 4),
('E1', 'available', NULL, 5),
('E2', 'available', NULL, 5),
('F1', 'sold',      7, 3),
('A2', 'available', NULL, 1),
('B1', 'reserved',  NULL, 2),
('G3', 'sold',      6, 6);

-- =====================================================
--  PART 3 — VIEWS & COMPANY INFORMATION QUERIES
--  Member 3
--  Paste your part3_views_and_info_queries.sql code below this line
-- =====================================================
 -- =====================================================
--                       VIEWS
-- =====================================================
 
-- Full event details with venue, category and organizer
CREATE OR REPLACE VIEW vw_event_details AS
SELECT
    e.id                                    AS event_id,
    e.name                                  AS event_name,
    e.description,
    e.start_datetime,
    e.end_datetime,
    e.ticket_price,
    e.event_capacity,
    v.name                                  AS venue_name,
    v.address                               AS venue_address,
    v.capacity                              AS venue_capacity,
    c.name                                  AS category_name,
    CONCAT(u.first_name, ' ', u.last_name)  AS organizer_name
FROM event e
JOIN venue    v ON e.venue_id    = v.id
JOIN category c ON e.category_id = c.id
JOIN users    u ON e.organizer_id = u.id;
 
-- Booking summary showing customer, payment and booking info
CREATE OR REPLACE VIEW vw_booking_summary AS
SELECT
    b.id                                    AS booking_id,
    b.booking_time,
    b.total_amount,
    b.status                                AS booking_status,
    CONCAT(u.first_name, ' ', u.last_name)  AS customer_name,
    u.email                                 AS customer_email,
    p.payment_method,
    p.payment_status,
    p.transaction_ref
FROM booking b
JOIN  users   u ON b.user_id    = u.id
LEFT JOIN payment p ON p.booking_id = b.id;
 
-- Ticket details with event and seat info
CREATE OR REPLACE VIEW vw_ticket_details AS
SELECT
    t.id                                    AS ticket_id,
    t.seat_number,
    t.ticket_status,
    e.name                                  AS event_name,
    e.start_datetime,
    v.name                                  AS venue_name,
    CONCAT(u.first_name, ' ', u.last_name)  AS customer_name
FROM ticket t
JOIN  event   e ON t.event_id   = e.id
JOIN  venue   v ON e.venue_id   = v.id
LEFT JOIN booking b ON t.booking_id = b.id
LEFT JOIN users   u ON b.user_id    = u.id;
 
-- Revenue summary per category
CREATE OR REPLACE VIEW vw_category_revenue AS
SELECT
    c.name                  AS category_name,
    COUNT(e.id)             AS total_events,
    AVG(e.ticket_price)     AS avg_ticket_price,
    MAX(e.ticket_price)     AS max_ticket_price,
    MIN(e.ticket_price)     AS min_ticket_price
FROM event e
JOIN category c ON e.category_id = c.id
GROUP BY c.name;
 
-- =====================================================
--                       QUERIES
-- =====================================================
 
-- ── Company Information Queries ─────────────────
 
-- Show all upcoming events with venue and category
SELECT
    e.name          AS event_name,
    e.start_datetime,
    e.ticket_price,
    v.name          AS venue,
    c.name          AS category
FROM event e
JOIN venue    v ON e.venue_id    = v.id
JOIN category c ON e.category_id = c.id
WHERE e.start_datetime > NOW()
ORDER BY e.start_datetime ASC;
 
-- Show all confirmed bookings with customer details
SELECT
    b.id            AS booking_id,
    CONCAT(u.first_name, ' ', u.last_name) AS customer,
    b.total_amount,
    b.status,
    b.booking_time
FROM booking b
JOIN users u ON b.user_id = u.id
WHERE b.status = 'confirmed'
ORDER BY b.booking_time DESC;
 
-- Show all tickets that are sold with event and customer info
SELECT
    t.seat_number,
    e.name          AS event_name,
    v.name          AS venue,
    CONCAT(u.first_name, ' ', u.last_name) AS customer
FROM ticket t
JOIN event   e ON t.event_id   = e.id
JOIN venue   v ON e.venue_id   = v.id
JOIN booking b ON t.booking_id = b.id
JOIN users   u ON b.user_id    = u.id
WHERE t.ticket_status = 'sold';
 
 
 
-- =====================================================
--  PART 4 — FUNCTIONS & OPERATORS QUERIES
--  Member 4
--  Paste your part4_functions_queries.sql code below this line
-- =====================================================
 -- ── Query Limitations (specific rows & columns) ─
 
-- Show only the first 3 upcoming events (LIMIT)
SELECT name, start_datetime, ticket_price
FROM event
ORDER BY start_datetime ASC
LIMIT 3;
 
-- Show only event name and price (column limitation)
SELECT name, ticket_price
FROM event;
 
-- ── Sorting Operations ───────────────────────────
 
--  Sort events by ticket price highest to lowest
SELECT name, ticket_price, event_capacity
FROM event
ORDER BY ticket_price DESC;
 
-- Sort users alphabetically by last name
SELECT first_name, last_name, email
FROM users
ORDER BY last_name ASC, first_name ASC;
  
 -- ── LIKE, AND, OR Operators ─────────────────────
 
-- Find users whose email contains 'example'
SELECT first_name, last_name, email
FROM users
WHERE email LIKE '%example%';
 
-- Find events that are Music OR Sports category
SELECT e.name, e.ticket_price, c.name AS category
FROM event e
JOIN category c ON e.category_id = c.id
WHERE c.name = 'Music' OR c.name = 'Sports';
 
-- Find confirmed bookings with amount greater than R300
SELECT id, total_amount, status, booking_time
FROM booking
WHERE status = 'confirmed' AND total_amount > 300.00;
 
-- Find venues with capacity between 300 and 2000
SELECT name, address, capacity
FROM venue
WHERE capacity >= 300 AND capacity <= 2000;
 
-- Find events with names that start with the letter 'J' or 'A'
SELECT name, start_datetime, ticket_price
FROM event
WHERE name LIKE 'J%' OR name LIKE 'A%';
   
-- ── Variables & Character Functions ─────────────
 
-- Use a variable to find bookings above a set amount
SET @min_amount = 500.00;
SELECT id, total_amount, status
FROM booking
WHERE total_amount >= @min_amount;
 
-- Character functions - uppercase, lowercase, length
SELECT
    UPPER(name)                             AS event_upper,
    LOWER(name)                             AS event_lower,
    LENGTH(name)                            AS name_length,
    CONCAT('Event: ', name)                 AS full_label,
    SUBSTRING(name, 1, 5)                   AS short_name
FROM event;
 
-- Format customer full name with character functions
SELECT
    CONCAT(UPPER(first_name), ' ', UPPER(last_name))    AS full_name_upper,
    LOWER(email)                                         AS email_lower,
    LENGTH(CONCAT(first_name, last_name))                AS name_length
FROM users;
 
-- ── Rounding & Truncation ────────────────────────
 
-- Round and truncate ticket prices
SELECT
    name,
    ticket_price,
    ROUND(ticket_price, 0)          AS price_rounded,
    TRUNCATE(ticket_price, 0)       AS price_truncated,
    ROUND(ticket_price * 1.15, 2)   AS price_with_vat
FROM event;
 
-- Round average payment amounts
SELECT
    payment_method,
    ROUND(AVG(payment_amount), 2)   AS avg_payment_rounded,
    TRUNCATE(AVG(payment_amount), 0) AS avg_payment_truncated
FROM payment
GROUP BY payment_method;

-- ── Date Functions ───────────────────────────────
 
-- Show how many days until each event
SELECT
    name,
    start_datetime,
    DATEDIFF(start_datetime, NOW())             AS days_until_event,
    DATE_FORMAT(start_datetime, '%d %M %Y')     AS formatted_date,
    DAYNAME(start_datetime)                     AS day_of_week,
    MONTHNAME(start_datetime)                   AS month_name,
    YEAR(start_datetime)                        AS event_year
FROM event
ORDER BY start_datetime ASC;
 
-- Show bookings made in the last 30 days (from sample data time)
SELECT
    id,
    booking_time,
    total_amount,
    status,
    DATE_FORMAT(booking_time, '%d-%m-%Y %H:%i') AS formatted_time
FROM booking
ORDER BY booking_time DESC;
 
-- Extract month and year from payment timestamps
SELECT
    transaction_ref,
    payment_amount,
    MONTH(payment_timestamp)    AS payment_month,
    YEAR(payment_timestamp)     AS payment_year,
    NOW()                       AS current_datetime
FROM payment;
 -- =====================================================
--  PART 5 — AGGREGATES, JOINS & SUBQUERIES
--  Member 5
--  Paste your part5_aggregates_joins_subqueries.sql code below this line
-- =====================================================
 
