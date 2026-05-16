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
--  PART 2 — SAMPLE DATA (All INSERT statements)
--  Member 2
--  Paste your part2_data.sql code below this line
-- =====================================================
 
 
 
 
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
 
