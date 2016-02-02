USE 1212962259_FreshAir_InternatiONal;

-- FunctiONs

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
		JOIN bookings ON passengers.bookingNumber = bookings.bookingNumber
		WHERE bookings.flightCode = flight_code;
		
		RETURN profit;
	END $$
DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS flight_booking_status $$
CREATE FUNCTION flight_booking_status(flight_code INT(11), form INT(1))
	RETURNS INT
	BEGIN
		DECLARE booked_seats INT;
		DECLARE results INT;
		
		SELECT count(seatingID)
		INTO booked_seats
		FROM passengers
		JOIN bookings ON passengers.bookingNumber = bookings.bookingNumber
		WHERE bookings.flightCode = flight_code;

		SELECT (booked_seats/maxNumberOfPassangers) * 100
		INTO results
		FROM flights
		INNER JOIN aircrafts ON flights.aircraftID = aircrafts.aircraftID
		WHERE flights.flightCode = flight_code;

		IF (form = 0)
		THEN
			RETURN booked_seats;

		ELSEIF (form = 1)
		THEN
			RETURN results;
		END IF;

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
		SELECT aircraftseats.seatID, aircraftseats.seatPlacement
		FROM bookings
		INNER JOIN passengers ON bookings.bookingNumber = passengers.bookingNumber
		RIGHT JOIN aircraftseats ON passengers.seatID = aircraftseats.seatID
		INNER JOIN aircrafts ON aircraftseats.aircraftID = aircrafts.aircraftID
		INNER JOIN flights ON aircrafts.aircraftID = flights.aircraftID
		WHERE seatPlacement = 'w'
		AND passengers.seatingID IS NULL
		AND flights.flightCode = flight_code;
	END $$
DELIMITER ;


