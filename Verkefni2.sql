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

DELIMITER $$
DROP FUNCTION IF EXISTS flight_booking_status $$
CREATE FUNCTION flight_booking_status(flight_code INT(11), form INT(1))
	RETURNS INT
	BEGIN
		DECLARE results INT;
		
		IF (form = 0)
		THEN
			SELECT count(seatingID)
			INTO results
			FROM passengers
			JOIN bookings ON passengers.bookingNumber = bookings.bookingNumber
			WHERE bookings.flightCode = flight_code;
		END IF;
		
		--TODO: needs a second function that calculates percentage of booked seats
		
		RETURN results;
	END $$
DELIMITER ;

-- Stored Procedures

DELIMITER $$
DROP PROCEDURE IF EXISTS list_free_windows $$
CREATE PROCEDURE list_free_windows
	(
		in flight_code INT(11)
	)
	BEGIN
		SELECT aircraftseats.seatID, seatPlacement
		FROM aircraftseats
		JOIN passengers ON aircraftseats.seatID = passengers.seatID
		JOIN bookings ON passengers.bookingNumber = bookings.bookingNumber
		JOIN flights ON bookings.flightCode = flights.flightCode
		WHERE seatPlacement = 'w'
		AND flights.flightCode = flight_code;
		--TODO: make it actually list free windows rather than all of them
	END $$
DELIMITER ;


