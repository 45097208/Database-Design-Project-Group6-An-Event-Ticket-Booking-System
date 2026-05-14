
Added contribution for the online ticket booking system repository.

SELECT
    event_name,
    ticket_price
FROM Event
ORDER BY ticket_price DESC;

SELECT
    status,
    COUNT(*) AS TotalBookings
FROM Booking
GROUP BY status;

SELECT
    payment_method,
    payment_status
FROM Payment
WHERE payment_status = 'Paid';
