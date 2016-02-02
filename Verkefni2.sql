USE 1212962259_FreshAir_International;

-- Functions

DELIMITER $$
DROP FUNCTION IF EXISTS profits $$
CREATE FUNCTION profits(flight_code INT(11))
	RETURNS INT
	BEGIN
		DECLARE profit INT;
		
		SELECT sum(amount)
		INTO profit
		FROM prices
		JOIN passengers ON prices.priceID = passengers.priceID
		JOIN bookings on passengers.bookingNumber = bookings.bookingNumber
		WHERE bookings.flightCode = flight_code;
		
		RETURN profit;
	END $$
DELIMITER ;


-- Stored Procedures

