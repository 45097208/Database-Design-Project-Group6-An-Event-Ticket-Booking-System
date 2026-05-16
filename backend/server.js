// =====================================================
//   TICKETFLOW - Express Backend Server
//   Connects to your MySQL Event Ticket Booking DB
// =====================================================

const express = require('express');
const mysql   = require('mysql2/promise');
const cors    = require('cors');
const { v4: uuidv4 } = require('uuid');

const app  = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());
app.use(express.static('../frontend'));   // serve your HTML files

// ── Database Connection ─────────────────────────────
// ⚠️  UPDATE THESE VALUES to match your MySQL setup
const dbConfig = {
  host:     'localhost',
  user:     'root',        // your MySQL username
  password: 'LeseGO@1',         // your MySQL password
  database: 'ticketflow',  // the name you gave your database (run the SQL script first)
  port:     3306
};

async function getDb() {
  return mysql.createConnection(dbConfig);
}

// ── Health Check ────────────────────────────────────
app.get('/api/health', async (req, res) => {
  try {
    const db = await getDb();
    await db.execute('SELECT 1');
    await db.end();
    res.json({ status: 'ok', message: 'Database connected!' });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// ── GET all upcoming events ─────────────────────────
app.get('/api/events', async (req, res) => {
  try {
    const db = await getDb();
    const [rows] = await db.execute(`
      SELECT
        e.id,
        e.name            AS event_name,
        e.description,
        e.start_datetime,
        e.end_datetime,
        e.ticket_price,
        e.event_capacity,
        v.name            AS venue_name,
        v.address         AS venue_address,
        c.name            AS category_name,
        CONCAT(u.first_name,' ',u.last_name) AS organizer_name,
        (SELECT COUNT(*) FROM ticket t
           WHERE t.event_id = e.id AND t.ticket_status = 'sold') AS tickets_sold
      FROM event e
      JOIN venue    v ON e.venue_id     = v.id
      JOIN category c ON e.category_id  = c.id
      JOIN users    u ON e.organizer_id = u.id
      WHERE e.start_datetime > NOW()
      ORDER BY e.start_datetime ASC
    `);
    await db.end();
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── GET single event by ID ──────────────────────────
app.get('/api/events/:id', async (req, res) => {
  try {
    const db = await getDb();
    const [rows] = await db.execute(`
      SELECT
        e.id,
        e.name            AS event_name,
        e.description,
        e.start_datetime,
        e.end_datetime,
        e.ticket_price,
        e.event_capacity,
        v.name            AS venue_name,
        v.address         AS venue_address,
        c.name            AS category_name,
        CONCAT(u.first_name,' ',u.last_name) AS organizer_name
      FROM event e
      JOIN venue    v ON e.venue_id     = v.id
      JOIN category c ON e.category_id  = c.id
      JOIN users    u ON e.organizer_id = u.id
      WHERE e.id = ?
    `, [req.params.id]);
    await db.end();
    if (!rows.length) return res.status(404).json({ error: 'Event not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── GET available seats for an event ───────────────
app.get('/api/events/:id/seats', async (req, res) => {
  try {
    const db = await getDb();
    const [rows] = await db.execute(`
      SELECT seat_number, ticket_status
      FROM ticket
      WHERE event_id = ?
      ORDER BY seat_number
    `, [req.params.id]);
    await db.end();
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── POST register a new user ────────────────────────
app.post('/api/users/register', async (req, res) => {
  const { first_name, last_name, email, password, phone_number } = req.body;
  if (!first_name || !last_name || !email || !password) {
    return res.status(400).json({ error: 'All fields required' });
  }
  try {
    const db = await getDb();
    // Check email uniqueness
    const [existing] = await db.execute(
      'SELECT id FROM users WHERE email = ?', [email]
    );
    if (existing.length) {
      await db.end();
      return res.status(409).json({ error: 'Email already registered' });
    }
    // Insert user with Customer role (id = 3)
    const [result] = await db.execute(`
      INSERT INTO users (first_name, last_name, email, password_hash, phone_number, role_id)
      VALUES (?, ?, ?, ?, ?, 3)
    `, [first_name, last_name, email, password, phone_number || null]);
    await db.end();
    res.status(201).json({ id: result.insertId, message: 'Registered successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── POST login ──────────────────────────────────────
app.post('/api/users/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const db = await getDb();
    const [rows] = await db.execute(`
      SELECT u.id, u.first_name, u.last_name, u.email, u.phone_number, r.name AS role
      FROM users u
      LEFT JOIN role r ON u.role_id = r.id
      WHERE u.email = ? AND u.password_hash = ?
    `, [email, password]);
    await db.end();
    if (!rows.length) return res.status(401).json({ error: 'Invalid credentials' });
    res.json({ user: rows[0], message: 'Login successful' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── POST create a booking + payment + ticket ────────
app.post('/api/bookings', async (req, res) => {
  const { user_id, event_id, seat_number, payment_method } = req.body;
  if (!user_id || !event_id || !seat_number || !payment_method) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  const db = await getDb();
  try {
    await db.beginTransaction();

    // Get event price
    const [events] = await db.execute(
      'SELECT ticket_price, name FROM event WHERE id = ?', [event_id]
    );
    if (!events.length) throw new Error('Event not found');
    const { ticket_price, name: event_name } = events[0];

    // Check seat availability
    const [seats] = await db.execute(
      'SELECT id, ticket_status FROM ticket WHERE seat_number = ? AND event_id = ?',
      [seat_number, event_id]
    );

    let seatExists = seats.length > 0;
    if (seatExists && seats[0].ticket_status !== 'available') {
      throw new Error('Seat is no longer available');
    }

    // Create booking
    const [bookingResult] = await db.execute(`
      INSERT INTO booking (total_amount, status, user_id)
      VALUES (?, 'confirmed', ?)
    `, [ticket_price, user_id]);
    const booking_id = bookingResult.insertId;

    // Create payment
    const txn_ref = 'TXN-' + uuidv4().substring(0, 8).toUpperCase();
    await db.execute(`
      INSERT INTO payment (payment_amount, payment_method, transaction_ref, payment_status, booking_id)
      VALUES (?, ?, ?, 'Completed', ?)
    `, [ticket_price, payment_method, txn_ref, booking_id]);

    // Create or update ticket
    if (seatExists) {
      await db.execute(
        'UPDATE ticket SET ticket_status="sold", booking_id=? WHERE id=?',
        [booking_id, seats[0].id]
      );
    } else {
      await db.execute(`
        INSERT INTO ticket (seat_number, ticket_status, booking_id, event_id)
        VALUES (?, 'sold', ?, ?)
      `, [seat_number, booking_id, event_id]);
    }

    await db.commit();

    // Return full receipt
    const [receipt] = await db.execute(`
      SELECT
        b.id                                        AS booking_id,
        b.booking_time,
        b.total_amount,
        b.status                                    AS booking_status,
        CONCAT(u.first_name,' ',u.last_name)        AS customer_name,
        u.email                                     AS customer_email,
        u.phone_number,
        e.name                                      AS event_name,
        e.start_datetime,
        e.end_datetime,
        v.name                                      AS venue_name,
        v.address                                   AS venue_address,
        c.name                                      AS category_name,
        t.seat_number,
        p.payment_method,
        p.payment_status,
        p.transaction_ref,
        p.payment_timestamp
      FROM booking b
      JOIN users   u ON b.user_id    = u.id
      JOIN ticket  t ON t.booking_id = b.id
      JOIN event   e ON t.event_id   = e.id
      JOIN venue   v ON e.venue_id   = v.id
      JOIN category c ON e.category_id = c.id
      JOIN payment p ON p.booking_id = b.id
      WHERE b.id = ?
    `, [booking_id]);

    await db.end();
    res.status(201).json({ receipt: receipt[0], message: 'Booking confirmed!' });

  } catch (err) {
    await db.rollback();
    await db.end();
    res.status(500).json({ error: err.message });
  }
});

// ── GET user booking history ────────────────────────
app.get('/api/users/:id/bookings', async (req, res) => {
  try {
    const db = await getDb();
    const [rows] = await db.execute(`
      SELECT
        b.id            AS booking_id,
        b.booking_time,
        b.total_amount,
        b.status,
        e.name          AS event_name,
        e.start_datetime,
        v.name          AS venue_name,
        t.seat_number,
        p.payment_method,
        p.transaction_ref,
        p.payment_status
      FROM booking b
      JOIN ticket  t ON t.booking_id = b.id
      JOIN event   e ON t.event_id   = e.id
      JOIN venue   v ON e.venue_id   = v.id
      LEFT JOIN payment p ON p.booking_id = b.id
      WHERE b.user_id = ?
      ORDER BY b.booking_time DESC
    `, [req.params.id]);
    await db.end();
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── Start Server ────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n🎟️  TicketFlow Backend running on http://localhost:${PORT}`);
  console.log(`📡  API ready — test: http://localhost:${PORT}/api/health\n`);
});
