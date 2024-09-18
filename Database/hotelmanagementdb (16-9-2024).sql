-- phpMyAdmin SQL Dump
-- version 4.8.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 16, 2024 at 05:13 AM
-- Server version: 10.1.33-MariaDB
-- PHP Version: 7.2.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hotelmanagementdb`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_booking` (IN `in_booking_id` VARCHAR(30), IN `in_room_no` VARCHAR(5), IN `in_guest_id` VARCHAR(20), IN `in_check_in` DATETIME, IN `in_stay_duration_nights` INT, IN `in_stay_duration_hours` INT)  BEGIN
    DECLARE check_out DATETIME;
    DECLARE v_room_type_id VARCHAR(3);
    DECLARE last_accepted_date DATETIME;

    -- Calculate check-out date and time
    SET check_out = DATE_ADD(in_check_in, INTERVAL in_stay_duration_nights DAY);
    SET check_out = DATE_ADD(check_out, INTERVAL in_stay_duration_hours HOUR);
    SET last_accepted_date = DATE_ADD(in_check_in, INTERVAL 1 DAY);

    -- Retrieve the room type ID
    SELECT room_type_id INTO v_room_type_id
    FROM room 
    WHERE room.room_no = in_room_no;

    -- Handle the case where no room type ID is found
    IF v_room_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room not found.';
    END IF;

    -- Insert into the booking table
    INSERT INTO booking (
        booking_id, room_no, room_type_id, guest_id, check_in, check_out, 
        last_accepted_date, stay_duration_nights, stay_duration_hours, booking_status
    ) 
    VALUES (
        in_booking_id, in_room_no, v_room_type_id, in_guest_id, in_check_in, check_out, 
        last_accepted_date, in_stay_duration_nights, in_stay_duration_hours, 'Booked'
    );

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_food_and_update_stock` (IN `p_order_food_id` VARCHAR(30), IN `roomNo` VARCHAR(5), IN `p_food_id` INT, IN `p_food_quantity` INT)  BEGIN
	DECLARE v_booking_id varchar(30);
    DECLARE v_current_stock int;
    
    SELECT booking_id INTO v_booking_id
	FROM booking
	WHERE CURRENT_DATE BETWEEN booking.check_in AND booking.check_out AND room_no = roomNo;
    
    SELECT current_stock INTO v_current_stock
    FROM stock
    WHERE food_id = p_food_id;
    
    IF v_current_stock >= p_food_quantity THEN
    
    	INSERT INTO order_food(order_food_id,food_id,food_quantity,booking_id,room_no) VALUES (p_order_food_id,p_food_id,p_food_quantity,v_booking_id,roomNo);
    
    	UPDATE stock
    	SET current_stock = current_stock - p_food_quantity
    	WHERE food_id = p_food_id;
   	ELSE
    	
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock available for this food item';
   	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_food_menu` (IN `food_name` VARCHAR(50), IN `food_price` DECIMAL(10,2), IN `food_category` TEXT)  NO SQL
BEGIN 

INSERT INTO food(food_name, food_price, food_category, stock_status) VALUES (food_name, food_price, food_category,
'No stock added');

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_food_stock` (IN `food_id` INT, IN `f_stock` INT)  BEGIN
	
	UPDATE stock
    SET stock.current_stock = f_stock WHERE stock.food_id = food_id;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_room` (IN `room_no` VARCHAR(5), IN `room_type_id` VARCHAR(3), IN `floor` INT)  NO SQL
BEGIN 
	BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    ROLLBACK;
    RESIGNAL;
    END;
    
    START TRANSACTION;
    INSERT INTO room VALUES(room_no, room_type_id, floor, 'Available');
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_service` (IN `service_name` VARCHAR(50), IN `service_price` DECIMAL(10,2), IN `service_description` TEXT)  NO SQL
BEGIN 

INSERT INTO service(service_name, service_price, description) VALUES (service_name, service_price, service_description);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_user` (IN `user_name` VARCHAR(50), IN `privilege` VARCHAR(20), IN `pass_word` VARCHAR(20))  BEGIN
	 
	INSERT INTO user(user_name, privilege, pass_word) VALUES (user_name,  privilege, pass_word);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cancel_booking_auto` (IN `booking_id` VARCHAR(30))  BEGIN
	UPDATE booking
    SET booking_status = 'Canceled'
    WHERE booking.booking_id = booking_id;
    
    UPDATE room
    SET room_status = 'Available' 
    WHERE room.room_no = room_no;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cancel_booking_manually` (IN `booking_id` VARCHAR(30), IN `room_no` VARCHAR(5))  NO SQL
BEGIN

	UPDATE booking
    SET booking_status = 'Canceled'
    WHERE booking.booking_id = booking_id AND booking.room_no = room_no;
    
    UPDATE room
    SET room_status = 'Available' 
    WHERE room.room_no = room_no;
    
    UPDATE room_charges_table
    SET room_charges = room_charges * (SELECT deposite_rate FROM deposite)
    WHERE booking_id = room_charges_table.booking_id AND room_no = room_charges_table.room_no;
    
    UPDATE booking_charges
    SET total_room_charges = (SELECT SUM(room_charges) FROM room_charges_table WHERE room_charges_table.booking_id = booking_id)
    WHERE booking_charges.booking_id = booking_id;
    
    UPDATE booking_charges
    SET total_booking_charges = total_room_charges + total_order_charges
    WHERE booking_charges.booking_id = booking_id;
    
    UPDATE booking_charges
    SET remaining_amount = total_booking_charges - deposite_amount
    WHERE booking_charges.booking_id = booking_id;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `change_food_detail` (IN `name` VARCHAR(50), IN `price` DECIMAL(10,2), IN `category` TEXT)  BEGIN 
	UPDATE food 
    SET food_price = price, food_category = category, stock_status = 'No item added'  WHERE food.food_name = name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `change_room_price` (IN `p_room_type_id` VARCHAR(3), IN `p_price_per_night` DECIMAL(10,2), IN `p_price_per_hour` DECIMAL(10,2))  BEGIN
	UPDATE room_price_table 
    SET price_per_night = p_price_per_night WHERE room_type_id = p_room_type_id;
    
    UPDATE room_price_table 
    SET price_per_hour = p_price_per_hour WHERE room_type_id = p_room_type_id;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `change_room_status` (IN `roomNo` VARCHAR(5), IN `roomStatus` VARCHAR(30))  BEGIN
	UPDATE room
    SET room_status = roomStatus WHERE room_no = roomNo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `comfirm_booking_all_rooms` (IN `booking_id` VARCHAR(30))  BEGIN
DECLARE matched INT;

SELECT COUNT(*) INTO matched
FROM booking
WHERE booking_id = bookingId AND room_no = roomNo;

IF matched = 0 THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Error: Booking id and room no do not matched';
	ELSE
		
        UPDATE booking
    	SET booking_status = 'Arrived'
    	WHERE booking.booking_id = bookingId;
        
		UPDATE room
		SET room_status = 'Unavailable'
		WHERE room_no = roomNo;
	
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `comfirm_booking_manually` (IN `bookingId` VARCHAR(30), IN `roomNo` VARCHAR(5))  NO SQL
    COMMENT 'BEGIN DECLARE matched INT;  SELECT COUNT(*) INTO matched FROM b'
BEGIN
DECLARE matched INT;

SELECT COUNT(*) INTO matched
FROM booking
WHERE booking_id = bookingId AND room_no = roomNo;

IF matched = 0 THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Error: Booking id and room no do not matched';
	ELSE
		
        UPDATE booking
    	SET booking_status = 'Arrived'
    	WHERE booking.booking_id = bookingId AND booking.room_no = roomNo;
        
		UPDATE room
		SET room_status = 'Unavailable'
		WHERE room_no = roomNo;
	
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_food_menu` (IN `p_food_name` VARCHAR(50))  BEGIN
	DECLARE f_food_id int;
    SELECT food_id INTO f_food_id FROM food 
    WHERE food.food_name = p_food_name;
    
	DELETE FROM stock WHERE stock.food_id = f_food_id;
	DELETE FROM food WHERE food.food_name = p_food_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `guest_entry` (IN `guest_id` VARCHAR(20), IN `guest_name` VARCHAR(50), IN `ph_no` VARCHAR(25), IN `id_card` VARCHAR(50), `email` VARCHAR(255))  BEGIN
INSERT INTO customer VALUES (guest_id, guest_name, ph_no, id_card, email);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `order_service` (IN `order_service_id` VARCHAR(30), IN `booking_id` VARCHAR(30), IN `room_no` VARCHAR(5), IN `service_id` VARCHAR(10), IN `service_times` INT)  INSERT INTO order_service(order_service_id, booking_id, room_no, service_id, service_times)
VALUES(order_service_id, booking_id, room_no, service_id, service_times)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `perform_payment` (IN `booking_id` VARCHAR(30), IN `amount` DECIMAL(10,2), IN `payment_method` VARCHAR(30))  BEGIN

	INSERT INTO payment(booking_id, amount, payment_date, payment_method) VALUES(booking_id, amount, CURRENT_TIME, payment_method);
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `search_available_rooms_within_date` (IN `start_date` DATE, IN `end_date` DATE)  NO SQL
BEGIN
SELECT room.room_no, roomtype.description, room.floor FROM room JOIN roomtype ON room.room_type_id = roomtype.room_type_id WHERE 
room_no NOT IN (
    SELECT room_no
    FROM booking
    WHERE (check_in<end_date AND check_out>start_date));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `search_booking` (IN `id_card` VARCHAR(50))  NO SQL
SELECT booking_id, room_no,description, guest_name, identity_card FROM booking JOIN customer JOIN roomtype ON booking.guest_id = customer.guest_id AND booking.room_type_id=roomtype.room_type_id WHERE customer.identity_card =id_card$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `search_by_guest_name` (IN `cusName` VARCHAR(50))  NO SQL
BEGIN
SELECT customer.guest_name, customer.identity_card, customer.phone_no, book_details.room_no, book_details.floor FROM customer JOIN book_details ON customer.guest_id=book_details.guest_id WHERE customer.guest_name=cusName;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `search_by_roomNo` (IN `roomNo` VARCHAR(5))  NO SQL
BEGIN
SELECT customer.guest_name, customer.identity_card, customer.phone_no, book_details.room_no, book_details.floor FROM customer JOIN book_details ON customer.guest_id=book_details.guest_id AND book_details.check_in <= CURRENT_TIMESTAMP AND book_details.check_out >= CURRENT_TIMESTAMP WHERE book_details.room_no=roomNo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `search_room_type` (IN `description` TEXT)  NO SQL
BEGIN
SELECT room.room_no, roomtype.description, room.floor FROM room JOIN roomtype ON room.room_type_id = roomtype.room_type_id WHERE roomtype.description = description;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `booking`
--

CREATE TABLE `booking` (
  `booking_id` varchar(30) NOT NULL,
  `room_no` varchar(5) NOT NULL,
  `room_type_id` varchar(3) NOT NULL,
  `guest_id` varchar(20) NOT NULL,
  `booking_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `check_in` datetime NOT NULL,
  `check_out` datetime NOT NULL,
  `last_accepted_date` datetime NOT NULL,
  `stay_duration_nights` int(11) NOT NULL,
  `stay_duration_hours` int(11) NOT NULL,
  `booking_status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `booking`
--

INSERT INTO `booking` (`booking_id`, `room_no`, `room_type_id`, `guest_id`, `booking_date`, `check_in`, `check_out`, `last_accepted_date`, `stay_duration_nights`, `stay_duration_hours`, `booking_status`) VALUES
('b001', '1', 'r1', 'c1', '2024-09-14 18:53:59', '2024-09-13 06:00:00', '2024-09-20 06:00:00', '2024-09-14 06:00:00', 7, 0, 'Canceled'),
('b002', '2', 'r1', 'c2', '2024-09-12 19:37:02', '2024-09-16 06:00:00', '2024-09-23 06:00:00', '2024-09-17 06:00:00', 7, 0, 'Booked'),
('b003', '3', 'r1', 'c3', '2024-09-13 02:43:49', '2024-09-12 00:00:00', '2024-09-12 00:00:00', '2024-09-13 00:00:00', 0, 0, 'Booked'),
('b004', '4', 'r2', 'c1', '2024-09-13 02:45:19', '2024-09-12 00:00:00', '2024-09-17 00:00:00', '2024-09-13 00:00:00', 5, 0, 'Booked'),
('b005', '5', 'r2', 'c3', '2024-09-13 04:06:14', '2024-09-10 00:00:00', '2024-09-20 00:00:00', '2024-09-11 00:00:00', 10, 0, 'Booked'),
('b006', '6', 'r2', 'c3', '2024-09-13 04:07:20', '2024-09-10 00:00:00', '2024-09-20 00:00:00', '2024-09-11 00:00:00', 10, 0, 'Canceled'),
('b006', '7', 'r1', 'c3', '2024-09-14 18:56:32', '2024-09-10 06:00:00', '2024-09-20 06:00:00', '2024-09-11 06:00:00', 10, 0, 'Arrived');

--
-- Triggers `booking`
--
DELIMITER $$
CREATE TRIGGER `calculate_and_insert_room_charges` AFTER INSERT ON `booking` FOR EACH ROW BEGIN
    
    INSERT INTO room_charges_table (Booking_ID, Room_no, room_type_id, Room_charges)
    VALUES (NEW.Booking_ID, NEW.Room_no, NEW.room_type_id, NEW.Stay_duration_nights * (SELECT Price_per_night
    FROM room_price_table
    WHERE room_type_id = NEW.room_type_id) + NEW.stay_duration_hours * (SELECT price_per_hour
    FROM room_price_table
    WHERE room_type_id = NEW.room_type_id));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `booking_charges`
--

CREATE TABLE `booking_charges` (
  `booking_id` varchar(30) NOT NULL,
  `total_room_charges` decimal(10,2) NOT NULL,
  `deposite_amount` decimal(10,0) NOT NULL,
  `total_order_charges` decimal(10,2) NOT NULL,
  `total_booking_charges` decimal(10,2) NOT NULL,
  `remaining_amount` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `booking_charges`
--

INSERT INTO `booking_charges` (`booking_id`, `total_room_charges`, `deposite_amount`, `total_order_charges`, `total_booking_charges`, `remaining_amount`) VALUES
('b001', '105000.00', '105000', '125000.00', '230000.00', '125000.00'),
('b002', '350000.00', '105000', '67000.00', '417000.00', '312000.00'),
('b003', '0.00', '0', '0.00', '0.00', '0.00'),
('b004', '500000.00', '150000', '210000.00', '710000.00', '560000.00'),
('b005', '1000000.00', '300000', '0.00', '1000000.00', '700000.00'),
('b006', '800000.01', '450000', '0.00', '800000.01', '350000.01');

-- --------------------------------------------------------

--
-- Stand-in structure for view `book_details`
-- (See below for the actual view)
--
CREATE TABLE `book_details` (
`guest_id` varchar(20)
,`room_no` varchar(5)
,`check_in` datetime
,`check_out` datetime
,`floor` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `charges_for_food`
--

CREATE TABLE `charges_for_food` (
  `booking_id` varchar(30) NOT NULL,
  `food_total_charges` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `charges_for_food`
--

INSERT INTO `charges_for_food` (`booking_id`, `food_total_charges`) VALUES
('b001', '125000.00'),
('b002', '60000.00'),
('b004', '205000.00');

--
-- Triggers `charges_for_food`
--
DELIMITER $$
CREATE TRIGGER `calculate_total_booking_charges_food_insert` AFTER INSERT ON `charges_for_food` FOR EACH ROW BEGIN

    UPDATE booking_charges
    SET total_order_charges = total_order_charges + 			NEW.food_total_charges 
    WHERE booking_id = NEW.booking_id;
    
    UPDATE booking_charges
    SET total_booking_charges = total_booking_charges + 		NEW.food_total_charges 
    WHERE booking_id = NEW.booking_id;

	UPDATE booking_charges
    SET remaining_amount = total_booking_charges - deposite_amount
    WHERE booking_id = NEW.booking_id;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `calculate_total_booking_charges_food_update` BEFORE UPDATE ON `charges_for_food` FOR EACH ROW BEGIN
	DECLARE p_food_total_charges decimal(10,2);
    SELECT food_total_charges INTO p_food_total_charges 	FROM charges_for_food 
    WHERE booking_id = NEW.booking_id;
    
    UPDATE booking_charges
    SET total_order_charges = total_order_charges - 		p_food_total_charges + NEW.food_total_charges 
    WHERE booking_id = NEW.booking_id;
    
    UPDATE booking_charges
    SET total_booking_charges = total_booking_charges - 	p_food_total_charges + NEW.food_total_charges 
    WHERE booking_id = NEW.booking_id;
	
    UPDATE booking_charges
    SET remaining_amount = total_booking_charges - deposite_amount
    WHERE booking_id = NEW.booking_id;


END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `charges_for_service`
--

CREATE TABLE `charges_for_service` (
  `booking_id` varchar(30) CHARACTER SET latin1 NOT NULL,
  `service_total_charges` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `charges_for_service`
--

INSERT INTO `charges_for_service` (`booking_id`, `service_total_charges`) VALUES
('b002', '7000.00'),
('b004', '5000.00');

--
-- Triggers `charges_for_service`
--
DELIMITER $$
CREATE TRIGGER `calculate_total_booking_charges_order_insert` AFTER INSERT ON `charges_for_service` FOR EACH ROW BEGIN

    UPDATE booking_charges
    SET total_order_charges = total_order_charges + 			NEW.service_total_charges 
    WHERE booking_id = NEW.booking_id;
    
    UPDATE booking_charges
    SET total_booking_charges = total_booking_charges + 		NEW.service_total_charges 
    WHERE booking_id = NEW.booking_id;
    
    UPDATE booking_charges
    SET remaining_amount = total_booking_charges - deposite_amount
    WHERE booking_id = NEW.booking_id;


END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `calculate_total_booking_charges_order_update` BEFORE UPDATE ON `charges_for_service` FOR EACH ROW BEGIN
	DECLARE p_service_total_charges decimal(10,2);
    SELECT service_total_charges INTO 						p_service_total_charges FROM charges_for_service
    WHERE booking_id = NEW.booking_id;
    
    UPDATE booking_charges
    SET total_order_charges = total_order_charges - 		p_service_total_charges + NEW.service_total_charges 
    WHERE booking_id = NEW.booking_id;
    
    UPDATE booking_charges
    SET total_booking_charges = total_booking_charges - 	p_service_total_charges + NEW.service_total_charges 
    WHERE booking_id = NEW.booking_id;

	UPDATE booking_charges
    SET remaining_amount = total_booking_charges - deposite_amount
    WHERE booking_id = NEW.booking_id;


END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `guest_id` varchar(20) NOT NULL,
  `guest_name` varchar(50) NOT NULL,
  `phone_no` varchar(25) NOT NULL,
  `identity_card` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`guest_id`, `guest_name`, `phone_no`, `identity_card`, `email`) VALUES
('c1', 'nomi', '09 78838393', 'NRC-1', 'nomi@gmail.com'),
('c2', 'nyein', '09 83897934', 'NRC-2', 'nyein@gmail.com'),
('c3', 'swun', '09 65345678', 'NRC-3', 'swun@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `deposite`
--

CREATE TABLE `deposite` (
  `deposite_rate` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `deposite`
--

INSERT INTO `deposite` (`deposite_rate`) VALUES
(0.3);

-- --------------------------------------------------------

--
-- Table structure for table `food`
--

CREATE TABLE `food` (
  `food_id` int(11) NOT NULL,
  `food_name` varchar(50) NOT NULL,
  `food_price` decimal(10,2) NOT NULL,
  `food_category` text NOT NULL,
  `stock_status` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `food`
--

INSERT INTO `food` (`food_id`, `food_name`, `food_price`, `food_category`, `stock_status`) VALUES
(1, 'cheese_burger', '5000.00', 'snack', 'No item added'),
(2, 'pizza', '5000.00', '', 'Low stock'),
(3, 'fried_potato', '3000.00', 'snack', 'Available stock'),
(4, 'potato', '2500.00', '', 'Available stock'),
(5, 'pasta', '4000.00', '', 'Available stock'),
(7, 'steak', '10000.00', 'main dish', 'Out of stock'),
(8, 'sushi', '15000.00', 'main dish', 'Available stock');

--
-- Triggers `food`
--
DELIMITER $$
CREATE TRIGGER `add_food_id_into_stock` AFTER INSERT ON `food` FOR EACH ROW BEGIN
	INSERT INTO stock(food_id) VALUES(NEW.food_id);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `monthly_revenue`
--

CREATE TABLE `monthly_revenue` (
  `years` int(11) NOT NULL,
  `months` int(11) NOT NULL,
  `revenue` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `monthly_revenue`
--

INSERT INTO `monthly_revenue` (`years`, `months`, `revenue`) VALUES
(2024, 9, '1376000.00');

--
-- Triggers `monthly_revenue`
--
DELIMITER $$
CREATE TRIGGER `update_yearly_after_monthly_insert` AFTER INSERT ON `monthly_revenue` FOR EACH ROW BEGIN
	DECLARE total decimal(10,2);
    
    SELECT SUM(revenue) INTO total
    FROM monthly_revenue
    WHERE years = NEW.years;
    
    IF EXISTS (SELECT 1 FROM yearly_revenue WHERE years = NEW.years) THEN
    UPDATE yearly_revenue
    SET revenue_per_year = total
    WHERE years = NEW.years;
    ELSE
    INSERT INTO yearly_revenue(years, revenue_per_year)
    VALUES(NEW.years, NEW.revenue);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_yearly_after_monthly_update` AFTER UPDATE ON `monthly_revenue` FOR EACH ROW BEGIN
	DECLARE total decimal(10,2);
    
    SELECT SUM(revenue) INTO total
    FROM monthly_revenue
    WHERE years = NEW.years;
    
    UPDATE yearly_revenue
    SET revenue_per_year = total
    WHERE years = NEW.years;
   
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `order_food`
--

CREATE TABLE `order_food` (
  `order_food_id` varchar(30) NOT NULL,
  `booking_id` varchar(30) NOT NULL,
  `room_no` varchar(5) NOT NULL,
  `food_id` int(11) NOT NULL,
  `food_quantity` int(11) NOT NULL,
  `food_charges` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `order_food`
--

INSERT INTO `order_food` (`order_food_id`, `booking_id`, `room_no`, `food_id`, `food_quantity`, `food_charges`) VALUES
('10', 'b004', '4', 1, 5, '25000.00'),
('11', 'b004', '4', 2, 10, '50000.00'),
('12', 'b004', '4', 3, 10, '30000.00'),
('13', 'b001', '1', 2, 1, '5000.00'),
('2', 'b001', '1', 3, 40, '120000.00'),
('3', 'b002', '2', 2, 5, '25000.00'),
('4', 'b002', '2', 2, 7, '35000.00'),
('5', 'b004', '5', 1, 5, '25000.00'),
('6', 'b004', '4', 1, 5, '25000.00'),
('7', 'b004', '4', 1, 5, '25000.00'),
('9', 'b004', '4', 1, 5, '25000.00');

--
-- Triggers `order_food`
--
DELIMITER $$
CREATE TRIGGER `calculate_food_charges` BEFORE INSERT ON `order_food` FOR EACH ROW SET NEW.food_charges = NEW.food_quantity * (SELECT food_price FROM food WHERE NEW.food_id = food.food_id)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `calculate_total_food_charges` AFTER INSERT ON `order_food` FOR EACH ROW BEGIN
  DECLARE mycount INT;

  SET mycount = (SELECT COUNT(*) FROM charges_for_food WHERE booking_id = NEW.booking_id);

  IF mycount > 0 THEN
    UPDATE charges_for_food 
    SET food_total_charges = food_total_charges + NEW.food_charges 
    WHERE booking_id = NEW.booking_id;
  ELSE
    INSERT INTO charges_for_food (booking_id, food_total_charges) 
    VALUES (NEW.booking_id, NEW.food_charges);
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `order_service`
--

CREATE TABLE `order_service` (
  `order_service_id` varchar(30) NOT NULL,
  `booking_id` varchar(30) NOT NULL,
  `room_no` varchar(5) NOT NULL,
  `service_id` int(11) NOT NULL,
  `service_times` int(11) NOT NULL,
  `service_charges` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `order_service`
--

INSERT INTO `order_service` (`order_service_id`, `booking_id`, `room_no`, `service_id`, `service_times`, `service_charges`) VALUES
('3', 'b002', '2', 2, 7, '7000.00'),
('4', 'b004', '4', 2, 5, '5000.00');

--
-- Triggers `order_service`
--
DELIMITER $$
CREATE TRIGGER `calculate_service_charges` BEFORE INSERT ON `order_service` FOR EACH ROW SET NEW.service_charges = NEW.service_times * (SELECT service_price FROM service WHERE NEW.service_id = service.service_id)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `calculate_total_service_charges` AFTER INSERT ON `order_service` FOR EACH ROW BEGIN
  DECLARE mycount INT;

  SET mycount = (SELECT COUNT(*) FROM charges_for_service WHERE booking_id = NEW.booking_id);

  IF mycount > 0 THEN
    UPDATE charges_for_service 
    SET service_total_charges = service_total_charges + NEW.service_charges 
    WHERE booking_id = NEW.booking_id;
  ELSE
    INSERT INTO charges_for_service (booking_id, service_total_charges) 
    VALUES (NEW.booking_id, NEW.service_charges);
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `payment_id` int(11) NOT NULL,
  `booking_id` varchar(30) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_date` datetime NOT NULL,
  `payment_method` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`payment_id`, `booking_id`, `amount`, `payment_date`, `payment_method`) VALUES
(10, 'b002', '105000.00', '2024-09-13 02:08:37', 'online'),
(12, 'b004', '150000.00', '2024-09-13 09:18:02', 'online');

--
-- Triggers `payment`
--
DELIMITER $$
CREATE TRIGGER `insert_monthly_after_payment_insert` AFTER INSERT ON `payment` FOR EACH ROW BEGIN
    DECLARE p_years INT;
    DECLARE p_months INT;
    DECLARE p_count INT;
    
    SELECT YEAR(NEW.payment_date) INTO p_years;
    SELECT MONTH(NEW.payment_date) INTO p_months;
    SELECT COUNT(*) FROM monthly_revenue
    WHERE years = p_years AND months = p_months 
    INTO p_count;
    
    IF p_count = 0 THEN
    INSERT INTO monthly_revenue
    VALUES (p_years, p_months, NEW.amount);
    ELSE
    UPDATE monthly_revenue
    SET revenue = revenue + NEW.amount 
    WHERE years = p_years AND months = p_months;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `room`
--

CREATE TABLE `room` (
  `room_no` varchar(5) NOT NULL,
  `room_type_id` varchar(3) NOT NULL,
  `floor` int(11) NOT NULL,
  `room_status` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `room`
--

INSERT INTO `room` (`room_no`, `room_type_id`, `floor`, `room_status`) VALUES
('1', 'r1', 1, 'Available'),
('2', 'r1', 2, 'Available'),
('3', 'r1', 1, 'Available'),
('4', 'r2', 1, 'Unavailable'),
('5', 'r2', 2, 'Available'),
('6', 'r2', 1, 'Available'),
('7', 'r1', 3, 'Unavailable'),
('8', 'r2', 3, 'Out of service');

-- --------------------------------------------------------

--
-- Table structure for table `roomtype`
--

CREATE TABLE `roomtype` (
  `room_type_id` varchar(3) NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `roomtype`
--

INSERT INTO `roomtype` (`room_type_id`, `description`) VALUES
('r1', 'Single'),
('r2', 'Double');

-- --------------------------------------------------------

--
-- Table structure for table `room_charges_table`
--

CREATE TABLE `room_charges_table` (
  `booking_id` varchar(30) NOT NULL,
  `room_no` varchar(5) NOT NULL,
  `room_type_id` varchar(3) NOT NULL,
  `room_charges` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `room_charges_table`
--

INSERT INTO `room_charges_table` (`booking_id`, `room_no`, `room_type_id`, `room_charges`) VALUES
('b001', '1', 'r1', '105000.00'),
('b002', '2', 'r1', '350000.00'),
('b003', '3', 'r1', '0.00'),
('b004', '4', 'r2', '500000.00'),
('b005', '5', 'r2', '1000000.00'),
('b006', '6', 'r2', '300000.01'),
('b006', '7', 'r1', '500000.00');

--
-- Triggers `room_charges_table`
--
DELIMITER $$
CREATE TRIGGER `add_new_booking_charges` BEFORE INSERT ON `room_charges_table` FOR EACH ROW BEGIN
DECLARE mycount INT;

  SET mycount = (SELECT COUNT(*) FROM booking_charges WHERE booking_id = NEW.booking_id);

  IF mycount = 0 THEN
	INSERT INTO booking_charges(booking_id) VALUES(NEW.booking_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `calculate_total_booking_charges_room` AFTER INSERT ON `room_charges_table` FOR EACH ROW BEGIN
	DECLARE p_total_room_charges decimal(10,2);
    SELECT total_room_charges INTO p_total_room_charges 	FROM booking_charges 
    WHERE booking_id = NEW.booking_id;
    
    UPDATE booking_charges
    SET total_room_charges = p_total_room_charges + 		NEW.room_charges 
    WHERE booking_id = NEW.booking_id;
    
    UPDATE booking_charges
    SET total_booking_charges = total_booking_charges - 	p_total_room_charges + total_room_charges 
    WHERE booking_id = NEW.booking_id;

	UPDATE booking_charges
    SET deposite_amount = total_room_charges * (SELECT deposite_rate FROM 	  deposite)
    WHERE booking_id = NEW.booking_id;
    
    UPDATE booking_charges
    SET remaining_amount = total_booking_charges - deposite_amount
    WHERE booking_id = NEW.booking_id;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `room_price_table`
--

CREATE TABLE `room_price_table` (
  `room_type_id` varchar(3) NOT NULL,
  `price_per_night` decimal(10,2) NOT NULL,
  `price_per_hour` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `room_price_table`
--

INSERT INTO `room_price_table` (`room_type_id`, `price_per_night`, `price_per_hour`) VALUES
('r1', '50000.00', '5000.00'),
('r2', '100000.00', '10000.00');

-- --------------------------------------------------------

--
-- Table structure for table `service`
--

CREATE TABLE `service` (
  `service_id` int(11) NOT NULL,
  `service_name` varchar(50) NOT NULL,
  `service_price` decimal(10,2) NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `service`
--

INSERT INTO `service` (`service_id`, `service_name`, `service_price`, `description`) VALUES
(1, 'cleaning', '2000.00', 'clean the whole room'),
(2, 'laundary', '1000.00', 'wash clothes');

-- --------------------------------------------------------

--
-- Table structure for table `stock`
--

CREATE TABLE `stock` (
  `food_id` int(11) NOT NULL,
  `current_stock` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `stock`
--

INSERT INTO `stock` (`food_id`, `current_stock`) VALUES
(1, 0),
(2, 2),
(3, 50),
(4, 30),
(5, 20),
(7, 0),
(8, 11);

--
-- Triggers `stock`
--
DELIMITER $$
CREATE TRIGGER `update_stock_status` AFTER UPDATE ON `stock` FOR EACH ROW BEGIN
    IF (SELECT current_stock FROM stock WHERE food_id = 	NEW.food_id) > 		10 THEN
    UPDATE food
    SET stock_status = 'Available stock' WHERE food_id = 	 NEW.food_id;
    
    ELSEIF (SELECT current_stock FROM stock WHERE food_id = 				NEW.food_id) > 0 AND (SELECT current_stock FROM stock WHERE food_id = 				NEW.food_id) <= 10 THEN
    UPDATE food
    SET stock_status = 'Low stock' WHERE food_id = 	 NEW.food_id;
    
    ELSE
    UPDATE food
    SET stock_status = 'Out of stock' WHERE food_id = 		NEW.food_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` int(11) NOT NULL,
  `user_name` varchar(50) NOT NULL,
  `privilege` varchar(20) NOT NULL,
  `pass_word` varchar(20) NOT NULL,
  `status` varchar(20) NOT NULL,
  `login_time` datetime NOT NULL,
  `logout_time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `user_name`, `privilege`, `pass_word`, `status`, `login_time`, `logout_time`) VALUES
(1, 'Nomi', 'admin', '123456789', '', '0000-00-00 00:00:00', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `yearly_revenue`
--

CREATE TABLE `yearly_revenue` (
  `years` int(11) NOT NULL,
  `revenue_per_year` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `yearly_revenue`
--

INSERT INTO `yearly_revenue` (`years`, `revenue_per_year`) VALUES
(2024, '1376000.00');

-- --------------------------------------------------------

--
-- Structure for view `book_details`
--
DROP TABLE IF EXISTS `book_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `book_details`  AS  select `booking`.`guest_id` AS `guest_id`,`booking`.`room_no` AS `room_no`,`booking`.`check_in` AS `check_in`,`booking`.`check_out` AS `check_out`,`room`.`floor` AS `floor` from (`room` join `booking`) where (`booking`.`room_no` = `room`.`room_no`) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `booking`
--
ALTER TABLE `booking`
  ADD PRIMARY KEY (`booking_id`,`room_no`),
  ADD KEY `FK_room_no` (`room_no`),
  ADD KEY `FK_guest_id` (`guest_id`),
  ADD KEY `room_type_id` (`room_type_id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indexes for table `booking_charges`
--
ALTER TABLE `booking_charges`
  ADD PRIMARY KEY (`booking_id`);

--
-- Indexes for table `charges_for_food`
--
ALTER TABLE `charges_for_food`
  ADD PRIMARY KEY (`booking_id`);

--
-- Indexes for table `charges_for_service`
--
ALTER TABLE `charges_for_service`
  ADD PRIMARY KEY (`booking_id`),
  ADD UNIQUE KEY `booking_id` (`booking_id`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`guest_id`),
  ADD UNIQUE KEY `identity_card` (`identity_card`);

--
-- Indexes for table `deposite`
--
ALTER TABLE `deposite`
  ADD PRIMARY KEY (`deposite_rate`);

--
-- Indexes for table `food`
--
ALTER TABLE `food`
  ADD PRIMARY KEY (`food_id`);

--
-- Indexes for table `monthly_revenue`
--
ALTER TABLE `monthly_revenue`
  ADD PRIMARY KEY (`years`,`months`);

--
-- Indexes for table `order_food`
--
ALTER TABLE `order_food`
  ADD PRIMARY KEY (`order_food_id`),
  ADD KEY `FK_food_id` (`food_id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `room_no` (`room_no`);

--
-- Indexes for table `order_service`
--
ALTER TABLE `order_service`
  ADD PRIMARY KEY (`order_service_id`),
  ADD KEY `room_no` (`room_no`),
  ADD KEY `service_id` (`service_id`),
  ADD KEY `FK_booking_id` (`booking_id`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indexes for table `room`
--
ALTER TABLE `room`
  ADD PRIMARY KEY (`room_no`),
  ADD KEY `FK_room_type` (`room_type_id`);

--
-- Indexes for table `roomtype`
--
ALTER TABLE `roomtype`
  ADD PRIMARY KEY (`room_type_id`);

--
-- Indexes for table `room_charges_table`
--
ALTER TABLE `room_charges_table`
  ADD PRIMARY KEY (`booking_id`,`room_no`),
  ADD KEY `room_no` (`room_no`),
  ADD KEY `room_type_id` (`room_type_id`);

--
-- Indexes for table `room_price_table`
--
ALTER TABLE `room_price_table`
  ADD PRIMARY KEY (`room_type_id`),
  ADD KEY `FK_room_type_id` (`room_type_id`);

--
-- Indexes for table `service`
--
ALTER TABLE `service`
  ADD PRIMARY KEY (`service_id`);

--
-- Indexes for table `stock`
--
ALTER TABLE `stock`
  ADD PRIMARY KEY (`food_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `yearly_revenue`
--
ALTER TABLE `yearly_revenue`
  ADD PRIMARY KEY (`years`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `food`
--
ALTER TABLE `food`
  MODIFY `food_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `service`
--
ALTER TABLE `service`
  MODIFY `service_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `FK_guest_id` FOREIGN KEY (`guest_id`) REFERENCES `customer` (`guest_id`),
  ADD CONSTRAINT `FK_room_no` FOREIGN KEY (`room_no`) REFERENCES `room` (`room_no`);

--
-- Constraints for table `booking_charges`
--
ALTER TABLE `booking_charges`
  ADD CONSTRAINT `booking_charges_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`);

--
-- Constraints for table `charges_for_food`
--
ALTER TABLE `charges_for_food`
  ADD CONSTRAINT `charges_for_food_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`);

--
-- Constraints for table `charges_for_service`
--
ALTER TABLE `charges_for_service`
  ADD CONSTRAINT `booking_id` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`);

--
-- Constraints for table `order_food`
--
ALTER TABLE `order_food`
  ADD CONSTRAINT `FK_food_id` FOREIGN KEY (`food_id`) REFERENCES `food` (`food_id`),
  ADD CONSTRAINT `order_food_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`),
  ADD CONSTRAINT `order_food_ibfk_2` FOREIGN KEY (`room_no`) REFERENCES `room` (`room_no`);

--
-- Constraints for table `order_service`
--
ALTER TABLE `order_service`
  ADD CONSTRAINT `FK_booking_id` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`),
  ADD CONSTRAINT `FK_service_id` FOREIGN KEY (`service_id`) REFERENCES `service` (`service_id`),
  ADD CONSTRAINT `order_service_ibfk_2` FOREIGN KEY (`room_no`) REFERENCES `room` (`room_no`);

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`);

--
-- Constraints for table `room`
--
ALTER TABLE `room`
  ADD CONSTRAINT `FK_room_type` FOREIGN KEY (`room_type_id`) REFERENCES `roomtype` (`room_type_id`);

--
-- Constraints for table `room_charges_table`
--
ALTER TABLE `room_charges_table`
  ADD CONSTRAINT `room_charges_table_ibfk_1` FOREIGN KEY (`room_no`) REFERENCES `room` (`room_no`),
  ADD CONSTRAINT `room_charges_table_ibfk_2` FOREIGN KEY (`room_type_id`) REFERENCES `roomtype` (`room_type_id`);

--
-- Constraints for table `room_price_table`
--
ALTER TABLE `room_price_table`
  ADD CONSTRAINT `FK_room_type_id` FOREIGN KEY (`room_type_id`) REFERENCES `roomtype` (`room_type_id`);

--
-- Constraints for table `stock`
--
ALTER TABLE `stock`
  ADD CONSTRAINT `fk2_food_id` FOREIGN KEY (`food_id`) REFERENCES `food` (`food_id`);

--
-- Constraints for table `yearly_revenue`
--
ALTER TABLE `yearly_revenue`
  ADD CONSTRAINT `FK_years` FOREIGN KEY (`years`) REFERENCES `monthly_revenue` (`years`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
