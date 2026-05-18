## TicketFlow — Event Ticket Booking System

![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=flat&logo=mysql&logoColor=white)
![Node.js](https://img.shields.io/badge/Backend-Node.js-339933?style=flat&logo=nodedotjs&logoColor=white)
![JavaScript](https://img.shields.io/badge/Frontend-JavaScript-F7DF1E?style=flat&logo=javascript&logoColor=black)
![HTML](https://img.shields.io/badge/Frontend-HTML%2FCSS-E34F26?style=flat&logo=html5&logoColor=white)
![License](https://img.shields.io/badge/License-Academic-blue?style=flat)

> A fully functional event ticket booking system built with a MySQL relational database, a Node.js Express backend API, and a modern web-based frontend. Users can register, browse upcoming events, select seats, book tickets and receive a confirmation receipt — all connected live to the database.


## System Overview

```
┌─────────────────────────────────────────────────────────┐
│                    TICKETFLOW SYSTEM                    │
├─────────────────┬───────────────────┬───────────────────┤
│   FRONTEND      │     BACKEND       │     DATABASE      │
│   index.html    │    server.js      │      MySQL        │
│                 │                   │                   │
│  • Events page  │  • REST API       │  • 8 Tables       │
│  • Auth system  │  • 8 Endpoints    │  • 7 Indexes      │
│  • Booking flow │  • Transactions   │  • 4 Views        │
│  • Receipts     │  • Error handling │  • 3NF Design     │
│  • My Tickets   │  • JWT Sessions   │  • Constraints    │
└─────────────────┴───────────────────┴───────────────────┘
```



## Features

- 🔐 **User Authentication** — Register and log in securely before booking
- 🎭 **Event Browsing** — View all upcoming events with venue, price and capacity
- 🔍 **Category Filtering** — Filter events by Music, Sports, Comedy, Theatre and Conference
- 💺 **Seat Selection** — Choose from available seats or enter a custom seat number
- 💳 **Ticket Booking** — Complete bookings with Card, EFT or Cash payment
- 🧾 **Booking Receipt** — Auto-generated receipt from a 7-table JOIN query
- 📋 **My Tickets** — View complete booking history per user
- 📊 **Live Database** — Every action reflects immediately in MySQL


##  Database Design

The database was designed in **Third Normal Form (3NF)** with the following structure:

| Table | Description |
|
| `role`       | User roles — Admin, Organiser, Customer |
| `users`      | All registered users with role assignment |
| `category`   | Event categories |
| `venue`      | Venue details and seating capacity |
| `event`      | Events with price, schedule and capacity |
| `booking`    | Booking records with status tracking |
| `payment`    | Payment records linked to bookings |
| `ticket`     | Tickets with seat numbers and status |

### Database Views
| View   |     Purpose |
|
| `vw_event_details` | Full event info with venue, category and organiser |
| `vw_booking_summary` | Booking with customer and payment details |
| `vw_ticket_details` | Ticket with event, venue and customer info |
| `vw_category_revenue` | Revenue summary per event category |

---

## Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Database | MySQL 8.0 | Data storage and management |
| Backend | Node.js + Express | REST API and business logic |
| Frontend | HTML5 + CSS3 + JavaScript | User interface |
| Libraries | mysql2, cors, uuid | Database connection, security, IDs |

---

## 📁 Project Structure

```
ticketflow/
│
├── 📁 database/
│   └── ticketflow.sql          ← Full database script (Parts 1–5)
│
├── 📁 backend/
│   ├── server.js               ← Node.js Express API server
│   └── package.json            ← Backend dependencies
│
├── 📁 frontend/
│   └── index.html              ← Complete web application
│
├── .gitignore                  ← Excludes node_modules
└── README.md                   ← This file
```

---

##  Getting Started

### Prerequisites
Make sure you have the following installed:
- [MySQL Workbench](https://www.mysql.com/products/workbench/) — Community Edition
- [Node.js](https://nodejs.org/) — LTS Version (v18 or higher)
- [VS Code](https://code.visualstudio.com/) — Recommended editor
- [Git](https://git-scm.com/) — For cloning the repository

---

### Step 1 — Clone the Repository
```bash
git clone https://github.com/45097208/Database-Design-Project-Group6-An-Event-Ticket-Booking-System.git
cd ticketflow
```

---

### Step 2 — Set Up the Database
1. Open **MySQL Workbench** and connect to your local instance
2. Open a new query tab and run:
```sql
CREATE DATABASE ticketflow;
USE ticketflow;
```
3. Open `database/ticketflow.sql` and run the full script (`Ctrl + Shift + Enter`)
4. Verify all 8 tables were created:
```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'ticketflow';
```

---

### Step 3 — Configure the Backend
Open `backend/server.js` and update the database credentials:
```javascript
const dbConfig = {
  host:     'localhost',
  user:     'root',
  password: '',        // ← Add your MySQL password here
  database: 'ticketflow',
  port:     3306
};
```
---

### Step 4 — Install Dependencies
```bash
cd backend
npm install
```

---

### Step 5 — Start the Backend Server
```bash
node server.js
```
You should see:
```
🎟️  TicketFlow Backend running on http://localhost:3001
📡  API ready — test: http://localhost:3001/api/health
```
Confirm the database is connected by visiting:
```
http://localhost:3001/api/health
```
Expected response:
```json
{"status":"ok","message":"Database connected!"}
```

---

### Step 6 — Open the Website
Navigate to `frontend/index.html` and open it in your browser.
The website will load and automatically fetch all events from the database. ✅


## Endpoints

| Method       | Endpoint |       Description |
|---|---|---|
| `GET` | `/api/health`             | Test database connection |
| `GET` | `/api/events`             | Fetch all upcoming events |
| `GET` | `/api/events/:id`         | Fetch a single event |
| `GET` | `/api/events/:id/seats`   | Fetch seats for an event |
| `POST` | `/api/users/register`    | Register a new user |
| `POST` | `/api/users/login`       | Authenticate a user |
| `POST` | `/api/bookings`          | Create a booking, payment and ticket |
| `GET` | `/api/users/:id/bookings` | Fetch all bookings for a user |

##  Sample Login Credentials

These accounts are pre-loaded from the database script:

| Email - Password - Role 

| 380061813@mynwu.ac.za - Zwane002 - Customer 
| 42910692@mynwu.ac.za - Rikhotso004 - Customer 
| 51636654@mynwu.ac.za - Sithole005 - Customer 
| 46768440@mynwu.ac.za - Kgaticwe007 - Customer 
| 36151262@mynwu.ac.za - Phiri001 - Organiser 
| 29873339@mynwu.ac.za - Mafifi006 - Organiser 


## Team Members

| Student Name &  Student Number |
|
| LB Zwane : 38061813 
| MP Rikhotso : 42910692 
| TJ Sithole : 51636654 
| SD Mafifi : 29873339 
| K Kgaticwe : 46768440 
| LI Phiri : 36151262 
| SP Mbongozi : 43759955 
| QN Kumane : 45097208 

---

## Academic Information

| Detail 
|
| Institution : North-West University (NWU) 
| Module : CMPG 311 
| Assignment | Phase 3 — Physical Design 
| Database Tool : MySQL

---

## Important Notes

- The `node_modules` folder is excluded from this repository via `.gitignore`
- Run `npm install` inside the `backend` folder after cloning
- Each developer must add their own MySQL password to `server.js` locally
- The SQL script must be run in full before starting the backend
- Keep the VS Code terminal running `node server.js` open while using the website



## Business Rules Implemented

1. Customers must register and log in before booking tickets
2. Each user is assigned exactly one role
3. Each event is organised by exactly one user
4. An event can have many tickets — each ticket belongs to one event
5. A user can make many bookings — each booking belongs to one user
6. A booking contains one or more tickets
7. A booking must have a linked payment
8. A booking records the seat number and booking date
9. Each event has a defined capacity, time schedule and ticket price

---

*Built with 💜 by the TicketFlow Team — NWU Database Module Phase 3*
