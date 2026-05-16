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
-- =====================================================
--  PART 3 — VIEWS & COMPANY INFORMATION QUERIES
--  Member 3
--  Paste your part3_views_and_info_queries.sql code below this line
-- =====================================================
 
 
 
 
-- =====================================================
--  PART 4 — FUNCTIONS & OPERATORS QUERIES
--  Member 4
--  Paste your part4_functions_queries.sql code below this line
-- =====================================================
 
 
 
 
-- =====================================================
--  PART 5 — AGGREGATES, JOINS & SUBQUERIES
--  Member 5
--  Paste your part5_aggregates_joins_subqueries.sql code below this line
-- =====================================================
 
