USE 1212962259_FreshAir_International;

-- Framework provided by teacher:


DELIMITER $$
DROP FUNCTION IF EXISTS Carrier $$

CREATE FUNCTION Carrier(flight_number CHAR(5), flight_date DATE)
  RETURNS CHAR(6)
  BEGIN
    RETURN (SELECT aircraftID
            FROM Flights
            WHERE flightNumber = flight_number AND flightDate = flight_date);
  END $$

DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS FlightCode $$
CREATE FUNCTION FlightCode(flight_number CHAR(5), flight_date DATE)
  RETURNS CHAR(6)
  BEGIN
    RETURN (SELECT flightCode
            FROM Flights
            WHERE flightNumber = flight_number AND flightDate = flight_date);
  END $$
DELIMITER ;


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

    SELECT (booked_seats / maxNumberOfPassangers) * 100
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
    IN flight_code INT(11)
  )
  BEGIN
    SELECT
      aircraftseats.seatID,
      aircraftseats.seatPlacement
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


-- TODO: write SP that finds two empty seats side by side in a specified flight


DELIMITER $$
DROP PROCEDURE IF EXISTS TwoSideBySide $$
CREATE PROCEDURE TwoSideBySide(flight_number CHAR(5), flight_date DATE)
  BEGIN
    -- variables holding the seats being investigated
    DECLARE first_seat INT;
    DECLARE second_seat INT;

    -- loop control variable
    DECLARE done INT DEFAULT FALSE;

    -- The cursor itself if declared containing the query code
    DECLARE vacantSeatsCursor CURSOR FOR
      SELECT seatID
      FROM AircraftSeats
      WHERE seatID NOT IN (SELECT AircraftSeats.seatid
                           FROM AircraftSeats
                             INNER JOIN Passengers ON AircraftSeats.seatID = Passengers.seatID
                             INNER JOIN Bookings ON Passengers.bookingNumber = Bookings.bookingNumber
                                                    AND Bookings.flightCode = FlightCode(flight_number, flight_date))
            AND aircraftID = Carrier(flight_number, flight_date)
      ORDER BY seatID;

    -- when the cursor reaches the end of it's data, the done variable is set to true
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET first_seat = NULL;
    SET second_seat = NULL;

    -- The query is executed by opening the cursor. After this statement
    -- the data is in the cursor and accessible.
    OPEN vacantSeatsCursor;

    read_loop: LOOP
      IF first_seat IS NULL
      THEN
        FETCH vacantSeatsCursor
        INTO first_seat;
      ELSEIF second_seat IS NULL
        THEN
          FETCH vacantSeatsCursor
          INTO second_seat;
          -- we've loaded two seatID's that are in the cursor rows.
          -- Furthermore we have these two seatID's in the variables.
          -- Now we need to investigate if they are in fact side by side
          -- on board the airplane.
          -- ============================== -- oo0oo -- ================================
          -- This is probably where your code begins
          -- Remember to set done to true only if you have found two seats side by side
          --  Think about how you will tackle the situation if no seats(side by side) are found
          IF (first_seat + 1 = second_seat AND (SELECT rowNumber
                                                FROM aircraftseats
                                                WHERE seatID = first_seat) = (SELECT rowNumber
                                                                              FROM aircraftseats
                                                                              WHERE seatID = second_seat))
          THEN
            SET done = TRUE;
          ELSE
          	SET first_seat = NULL;
          	SET second_seat = NULL;
          END IF;
      -- ============================== -- oo0oo -- ================================
      END IF;

      -- Check to seethe status og the done variable.
      IF done
      THEN
        LEAVE read_loop;
      END IF;
    END LOOP;
    CLOSE vacantSeatsCursor;

    SELECT
      first_seat as'First seat',
      second_seat as 'Second seat';
  END $$
DELIMITER ;


-- TODO: write SP that books a flight/shows booking for a flight?
-- very vague instructions. Should it insert into a row, or just show the information
-- based on some parameter the user puts in?