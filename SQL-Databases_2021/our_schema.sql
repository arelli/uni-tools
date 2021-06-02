--
-- PostgreSQL database dump
--
-- Class of databases TUC, 2021
-- Implemented on PgAdmin4

-- This file includes only functions and views implemented by me and my collegaue
-- Some of the code that we wrote is not here
-- This is not a full recovery file, to recover the actual functional database
-- You'll have to download the actual backup file.

-- Dumped from database version 11.11
-- Dumped by pg_dump version 11.11

-- Started on 2021-06-02 16:58:42


CREATE FUNCTION public.check_room6_2(idhotel integer, idroom integer, at_date date) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
doc_client CHARACTER VARYING;
BEGIN
	IF EXISTS
	(SELECT * FROM room
	JOIN roombooking ON room."idRoom" = roombooking."roomID" 
	JOIN hotel ON room."idHotel" = hotel."idHotel" AND hotel."idHotel"= idhotel
	JOIN roomrate ON hotel."idHotel" = roomrate."idHotel" AND room.roomtype = roomrate.roomtype
	WHERE roombooking.checkin < at_date AND roombooking.checkout > at_date
	AND room."idRoom" = idroom) THEN 
		-- return the documentclient
		SELECT client.documentclient INTO doc_client FROM room
		JOIN roombooking ON room."idRoom" = roombooking."roomID" 
		JOIN hotel ON room."idHotel" = hotel."idHotel" AND hotel."idHotel"= idhotel
		JOIN hotelbooking ON hotelbooking.idhotelbooking = roombooking."hotelbookingID"
		JOIN client ON hotelbooking."bookedbyclientID" = client."idClient";
		RETURN doc_client;  -- prepei na einai o sostos typas
	ELSE
		RETURN '0';
	END IF;
END;
$$;


ALTER FUNCTION public.check_room6_2(idhotel integer, idroom integer, at_date date) OWNER TO postgres;


CREATE FUNCTION public.days_apart2_2(date1 date, date2 date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE 
days_apart INT;
BEGIN
	SELECT (date2::date-date1::date)::varchar(255)
	INTO days_apart;
	RETURN days_apart;
END;
$$;


ALTER FUNCTION public.days_apart2_2(date1 date, date2 date) OWNER TO postgres;


CREATE FUNCTION public.find_clients_of_hotel4_1(hotelid integer) RETURNS TABLE(client_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	WITH all_clients AS
	(WITH testtable AS(
		SELECT "idClient","idEmployee" FROM client
		LEFT JOIN employee on "idClient" = "idEmployee"
		ORDER BY "idClient")

		SELECT "idClient" FROM testtable
		EXCEPT
		SELECT "idEmployee" FROM testtable
		ORDER BY "idClient")  -- the pure of purest clients
		
	SELECT DISTINCT "bookedbyclientID" FROM hotelbooking
	JOIN all_clients ON all_clients."idClient" = hotelbooking."bookedbyclientID"  -- all the reservations from pure clients
	JOIN roombooking ON "hotelbookingID"= idhotelbooking
	JOIN room ON roombooking."roomID"=room."idRoom" WHERE room."idHotel" = hotelid;
END;
$$;


ALTER FUNCTION public.find_clients_of_hotel4_1(hotelid integer) OWNER TO postgres;


CREATE FUNCTION public.func2_1(action character varying, document_client character varying, fname_arg character varying, lname_arg character varying, sex_arg character, dateofbirth_arg date, address_arg character varying, city_arg character varying, country_arg character varying, cardtype_arg character varying, number_arg character varying, holder_arg character varying, expiration_arg date) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
client_key INTEGER;
person_amka INTEGER;
BEGIN
	SELECT "idClient" INTO client_key FROM client WHERE client.documentclient = document_client;

	--write the function code here
	IF (action = 'insert') THEN
		INSERT INTO person ("idPerson",fname, lname, sex, dateofbirth, address, city, country)
		VALUES (default,fname_arg, lname_arg, sex_arg, dateofbirth_arg, address_arg, city_arg, country_arg)
		RETURNING "idPerson" INTO person_amka;  -- to get the "default" amka(idPerson) of person
		
		INSERT INTO client("idClient",documentclient)
		VALUES (person_amka, document_client);
		
		INSERT INTO creditcard (cardtype, number, expiration, holder,"clientID")
		VALUES (cardtype_arg, number_arg, expiration_arg, holder_arg, person_amka);
		--the above inserts the data we got as arguments, in the creditcard(s) table
		--the above inserts the data we got as arguments, in the person(s) table		
		
	ELSIF (action = 'update') THEN
		UPDATE person
		SET fname = fname_arg, lname= lname_arg, sex = sex_arg, dateofbirth = dateofbirth_arg,
				address = address_arg, city = city_arg, country = country_arg
		WHERE person."idPerson" = client_key;  
		
		UPDATE creditcard
		SET cardtype = cardtype_arg, number = number_arg, expiration = expiration_arg, holder = holder_arg 
		WHERE creditcard."clientID" = client_key;  -- we choose by number because it is a key!
		
	ELSIF action = 'delete' THEN
		DELETE FROM person WHERE person."idPerson" = client_key;  
	END IF;
	
END;
$$;


ALTER FUNCTION public.func2_1(action character varying, document_client character varying, fname_arg character varying, lname_arg character varying, sex_arg character, dateofbirth_arg date, address_arg character varying, city_arg character varying, country_arg character varying, cardtype_arg character varying, number_arg character varying, holder_arg character varying, expiration_arg date) OWNER TO postgres;


CREATE FUNCTION public.func2_2(number_of_records integer, start_date date, end_date date, hotelid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare 
  i INT;
  j INT;
  country_of_origin CHAR VARYING;  -- the country of the person making the reservation and the people that inhabit the rooms
  id_of_person INT;
  number_of_rooms INT;  -- how many rooms to book(random number from 1 to 5)
  hotelbooking_id INT;
  rand_checkin_interval INT;
  rand_checkin_date DATE;
  rand_checkout_interval INT;
  rand_checkout_date DATE;
  room_id INT;
BEGIN
	-- create a hotelbooking-compatible table:
	SELECT random_between(1,5)::int INTO number_of_rooms;  -- get a random amount of roombookings to add
	
	IF has_n_free_rooms2_2(hotelid,number_of_rooms,start_date,end_date)  THEN
		for i in 1..number_of_records loop
			--RAISE NOTICE 'External loop iteration no. (%)', i;
			-- get a random person, and also store their country(due to the constraint mentioned in the excersise)
			SELECT idperson,country INTO id_of_person, country_of_origin FROM  get_random_person2_2();
			-- insert data into the hotelbooking table once
			--RAISE NOTICE 'Id of person to insert at the bookedbyclientID field :%', id_of_person;
			Insert into hotelbooking(reservationdate,cancellationdate,totalamount,"bookedbyclientID",payed,paymethod,status)
			values(start_date-'20 days'::interval, start_date-'10 days'::interval,NULL,id_of_person,false,NULL,NULL)
			RETURNING idhotelbooking INTO hotelbooking_id;  -- get the id of the row we just added(for use in the roombookings)
			
			-- update hotelbooking total amount based on days_apart1_1() and rate of the type of room
			
			for j in 1..number_of_rooms loop  -- insert 1 to 5 room bookings into the above hotelbooking
				--RAISE NOTICE 'Internal loop iteration no. (%)', j;
				SELECT random_between(1,(days_apart2_2(start_date,end_date)-1)) INTO rand_checkin_interval;  -- get the random checkin interval
				SELECT random_between((rand_checkin_interval+1),(days_apart2_2(start_date,end_date))) INTO rand_checkout_interval;  -- get the checkout interval, based on the checkin

				SELECT start_date + (rand_checkin_interval::varchar(255)||' days')::interval INTO rand_checkin_date;  -- create the checkin date
				SELECT start_date + (rand_checkout_interval::varchar(255)||' days')::interval INTO rand_checkout_date;  -- and the checkout date
				
				SELECT get_a_room2_2 INTO room_id FROM get_a_room2_2(hotelid,start_date, end_date);
				IF room_id IS NULL THEN 
					RAISE NOTICE 'NOT ENOUGH FREE ROOMS';
					RETURN False;
				END IF;
				--RAISE NOTICE 'filled the checkin-checkout dates, inserting(into roombooking)...';
				INSERT INTO roombooking("hotelbookingID", "roomID", "bookedforpersonID",checkin,checkout,rate)
				VALUES (hotelbooking_id,room_id,get_random_person_from_country2_2(country_of_origin),
					   rand_checkin_date, rand_checkout_date, NULL );
					   -- get_a_room2_2() returns a non-reserved room at the given period of time.
			end loop;
		end loop;
		RETURN True;
	ELSE  
		RAISE NOTICE 'There are not enough free rooms the period you requested';
		RETURN False;
	end if;
	-- DROP TABLE pure_clients;
END;
$$;


ALTER FUNCTION public.func2_2(number_of_records integer, start_date date, end_date date, hotelid integer) OWNER TO postgres;


CREATE FUNCTION public.func3_1() RETURNS TABLE(city character varying, country character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN -- return all cities/countries with discounts above 30%
	RETURN QUERY
	SELECT DISTINCT hotel.city, hotel.country 
	FROM roomrate
	INNER JOIN hotel ON ((hotel."idHotel" = roomrate."idHotel") AND (roomrate.discount >= 30));
END;
$$;


ALTER FUNCTION public.func3_1() OWNER TO postgres;


COMMENT ON FUNCTION public.func3_1() IS 'check ok
';




CREATE FUNCTION public.func3_2(stars_args character varying, letters_args character varying) RETURNS TABLE(id_of_hotel integer, name_of_hotel character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN  -- this function uses 2 other functions to return the result of the search. Could be done by relational algebra operations(join etc).
	RETURN QUERY
	SELECT hotel."idHotel",hotel.name FROM hotel 
	WHERE hotel.stars = stars_args AND hotel.name LIKE letters_args||'%' AND has_restaurant(hotel."idHotel")
		AND has_breakfast(hotel."idHotel") AND has_studio_less_than_80(hotel."idHotel") ;
END;
$$;


ALTER FUNCTION public.func3_2(stars_args character varying, letters_args character varying) OWNER TO postgres;

CREATE FUNCTION public.func3_3() RETURNS TABLE(name character varying, roomtype character varying, max_discount real)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	--TRIPLE JOIN!
	SELECT DISTINCT    hotel.name,room.roomtype,MAX(roomrate.discount)
	FROM room  -- join the room table
	INNER JOIN hotel  -- with the hotel one
	ON (hotel."idHotel" = room."idHotel")  -- based on the idHotel
	INNER JOIN roomrate --join the roomrate table
	ON (hotel."idHotel" = roomrate."idHotel")  
	GROUP BY hotel.name,room.roomtype 
	ORDER BY room.roomtype;
END;
$$;


ALTER FUNCTION public.func3_3() OWNER TO postgres;


COMMENT ON FUNCTION public.func3_3() IS 'check ok';



CREATE FUNCTION public.func3_4(hotel_id integer) RETURNS TABLE(idhotelbooking integer, fname character varying, lname character varying, reservationdate date, property character)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	WITH temp_table AS(
	SELECT hotelbooking.idhotelbooking, person.fname, person.lname,hotelbooking.reservationdate, 
         room."idHotel", person."idPerson" as general_amka, employee."idEmployee" as employee_amka,
        hotelbooking."bookedbyclientID" as client_amka,'not_defined'::character(11) as property
    FROM room
    JOIN roombooking ON room."idRoom"=roombooking."roomID" 
    JOIN hotelbooking ON roombooking."hotelbookingID" = hotelbooking.idhotelbooking  
	LEFT JOIN employee ON employee."idEmployee" = roombooking."hotelbookingID"
    JOIN person ON person."idPerson" = roombooking."bookedforpersonID" 
    ORDER BY "idHotel" ASC)
	
	
	SELECT temp_table.idhotelbooking, temp_table.fname, temp_table.lname,
			temp_table.reservationdate, 'employee'::character(11) as "bookedBy"
	FROM temp_table WHERE temp_table.client_amka IS NULL and temp_table."idHotel" = hotel_id
	UNION  
	SELECT temp_table.idhotelbooking, temp_table.fname, temp_table.lname,
			temp_table.reservationdate, 'client'::character(11) as "bookedBy"
	FROM temp_table WHERE  temp_table.employee_amka IS NULL and temp_table."idHotel" = hotel_id;

	
END;
$$;


ALTER FUNCTION public.func3_4(hotel_id integer) OWNER TO postgres;


CREATE FUNCTION public.func3_5(hotelid integer) RETURNS TABLE(weekday integer, starttime integer, endtime integer, idhotel integer)
    LANGUAGE plpgsql
    AS $$
DECLARE 
count_of_participants INTEGER;
BEGIN 
	RETURN QUERY
	SELECT activity.weekday, activity.starttime, activity.endtime, activity.idhotel FROM activity 
	WHERE no_of_participants_3_5(activity.weekday,activity.endtime, activity.starttime, activity.idhotel) = 0;
	-- the function returns how many participations there are in each activity(excluding responsible employees)
	-- if the number is 0, the activity is returned from the function func3_5().
END;
$$;


ALTER FUNCTION public.func3_5(hotelid integer) OWNER TO postgres;


CREATE FUNCTION public.func3_6(facility_type character varying) RETURNS TABLE(city character varying, country character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN 
	RETURN QUERY
	With recursive facility_subtree("nameFacility")as(
	select "nameFacility"  from facility where "nameFacility" = facility_type  
	union
	select facility."nameFacility" from facility_subtree ,facility   -- refering here to the outside tree: recursion
		where facility_subtree."nameFacility"=facility."subtypeOf" -- AND type = 'hotel'(error: question is ambiguous)
	)
	Select facility_subtree."nameFacility","subtypeOf" from facility_subtree 
	Join facility ON facility."nameFacility" = facility_subtree."nameFacility"
	WHERE "subtypeOf" IS NOT NULL;  -- to not display the master facility
END;
$$;


ALTER FUNCTION public.func3_6(facility_type character varying) OWNER TO postgres;

CREATE FUNCTION public.func3_8() RETURNS TABLE(hotelid integer, hotelname character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT hotel."idHotel",hotel.name FROM hotel WHERE has_free_from_each_type3_8(hotel."idHotel")
	ORDER BY hotel."idHotel";
END;
$$;


ALTER FUNCTION public.func3_8() OWNER TO postgres;


CREATE FUNCTION public.func4_1(hotelid integer) RETURNS TABLE(client_amka integer, how_many_participations bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN 
	RETURN QUERY
	WITH part_amka AS(
	SELECT * FROM find_clients_of_hotel4_1(hotelid))
	
	SELECT "client_id", COUNT(participates.amka) FROM part_amka
	LEFT JOIN participates ON participates.amka = part_amka."client_id" 
	GROUP BY "client_id";
	
END;
$$;


ALTER FUNCTION public.func4_1(hotelid integer) OWNER TO postgres;

CREATE FUNCTION public.func4_2(type_of_room character varying) RETURNS TABLE(average interval)
    LANGUAGE plpgsql
    AS $$
BEGIN 
	RETURN QUERY
	With persons_birthdays as(
	select person.dateofbirth as birthday
    from person,roombooking,room -- join the three tables 
    where person."idPerson" = roombooking."bookedforpersonID" and
    room."idRoom"=roombooking."roomID" and roomtype = type_of_room
    group by person."idPerson")
	select avg(age(current_date,birthday)) from persons_birthdays;
END;
$$;


ALTER FUNCTION public.func4_2(type_of_room character varying) OWNER TO postgres;

CREATE FUNCTION public.func4_3(in_country character varying) RETURNS TABLE(roomtype character varying, city character varying, min_real_rate double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN 
	RETURN QUERY
	WITH prices AS(
	SELECT roomrate.roomtype, hotel."idHotel", (rate - rate*discount/100) AS real_rate, hotel.city, hotel.country
	FROM roomtype 
	JOIN roomrate ON roomrate.roomtype = roomtype.typename
	JOIN hotel ON roomrate."idHotel" = hotel."idHotel" WHERE country = in_country)  -- ADD WHERE COUNTRY 

	SELECT prices.roomtype, prices.city, MIN(real_rate) FROM prices
	GROUP BY prices.roomtype, prices.city
	ORDER BY prices.roomtype;
END;
$$;


ALTER FUNCTION public.func4_3(in_country character varying) OWNER TO postgres;


CREATE FUNCTION public.func4_4() RETURNS TABLE(hotel_id integer, hotel_name character varying, total_income real, city character varying, average_of_city integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	With hotelamount AS(
		select distinct hotel."idHotel",hotel.name,COALESCE(hotelbooking.totalamount,0) as total,hotel.city,COALESCE(get_average_income_of_city4_4(hotel.city),0) as average
		from hotelbooking,roombooking,room,hotel
		where hotelbooking.idhotelbooking=roombooking."hotelbookingID" and
		roombooking."roomID" = room."idRoom" AND
		room."idHotel" = hotel."idHotel"  AND hotelbooking.totalamount > get_average_income_of_city4_4(hotel.city) 
		AND hotelbooking.payed is true

	)
	SELECT * FROM hotelamount;
END;
$$;


ALTER FUNCTION public.func4_4() OWNER TO postgres;

CREATE FUNCTION public.func4_5(hotelid integer, year double precision) RETURNS TABLE(month double precision, percentage bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE 
total_rooms BIGINT;
BEGIN 
	SELECT COUNT(*) INTO total_rooms FROM room WHERE "idHotel" = hotelid; -- save as declared variable
	
	RETURN QUERY
	WITH temp_table AS(
	SELECT DISTINCT "idRoom", "idHotel","idRoom",date_part('MONTH', reservationdate) as time_month,
	date_part('year', reservationdate) as time_year FROM roombooking 
	JOIN room ON "idRoom" = "roomID"
	JOIN hotelbooking ON roombooking."hotelbookingID" = idhotelbooking  WHERE "idHotel" = hotelid
	and date_part('year', reservationdate)=year) 

	SELECT time_month, count(time_month)*100/total_rooms FROM temp_table  -- generate % of rooms that are reserved by month
	GROUP BY time_month
	ORDER BY time_month;
	-- IMPORTANT NOTICE: we implemented the above function to take into consideration the number of rooms a hotel has, divided by
	-- the number of rooms that are reserved by month, as the hotel occupancy. Some rooms are reserved more than 1 time per month,
	-- so we added DISTINCT "idRoom" to delete duplicate room reservations per month.
END;
$$;


ALTER FUNCTION public.func4_5(hotelid integer, year double precision) OWNER TO postgres;


CREATE FUNCTION public.func6_1(idhotel_arg integer) RETURNS TABLE(idhotel integer, roomtype character varying, free_untill date)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT * FROM view6_1 WHERE "idHotel" = idhotel_arg;
END;
$$;


ALTER FUNCTION public.func6_1(idhotel_arg integer) OWNER TO postgres;


CREATE FUNCTION public.get_a_room2_2(id_of_hotel integer, start_date date, end_date date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE 
id_of_room INT;
BEGIN
	SELECT room."idRoom" INTO id_of_room FROM roombooking
	JOIN room ON roombooking."roomID" = room."idRoom"
	WHERE is_free2_2(room."idRoom", start_date, end_date)
	AND room."idHotel" = id_of_hotel
	ORDER BY RANDOM()
	LIMIT 1;
	RETURN id_of_room;
END;
$$;


ALTER FUNCTION public.get_a_room2_2(id_of_hotel integer, start_date date, end_date date) OWNER TO postgres;


CREATE FUNCTION public.get_average_income_of_city4_4(city_arg character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE 
average_of_city INT;
BEGIN
	With hotelamount AS(
    SELECT AVG(hotelbooking.totalamount) as average, hotel.city
    FROM hotelbooking,roombooking,room,hotel
    WHERE hotelbooking.idhotelbooking=roombooking."hotelbookingID" and
    roombooking."roomID" = room."idRoom" AND
    room."idHotel" = hotel."idHotel"  and hotelbooking.payed is true
    GROUP BY hotel.city
    ORDER BY average
	)
	SELECT average INTO average_of_city FROM hotelamount 
	WHERE hotelamount.city = city_arg;
	IF average_of_city IS null THEN
		average_of_city = 0;
	END IF;
	RETURN average_of_city;

END;
$$;


ALTER FUNCTION public.get_average_income_of_city4_4(city_arg character varying) OWNER TO postgres;

CREATE FUNCTION public.get_pure_clients2_2() RETURNS TABLE(id_of_client integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	WITH testtable AS(
	SELECT "idClient","idEmployee" FROM client
	LEFT JOIN employee on "idClient" = "idEmployee"
	ORDER BY "idClient")

	SELECT "idClient" FROM testtable
	EXCEPT
	SELECT "idEmployee" FROM testtable
	ORDER BY "idClient";
END;
$$;


ALTER FUNCTION public.get_pure_clients2_2() OWNER TO postgres;


CREATE FUNCTION public.get_random_person2_2() RETURNS TABLE(idperson integer, country character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT person."idPerson", person.country FROM person  -- 10.000 persons in the db
	WHERE is_pure_client2_2(person."idPerson")  -- ULTRA laggy but needed to verify someone is indeed a client
	ORDER BY RANDOM()
	LIMIT 1;
END;
$$;


ALTER FUNCTION public.get_random_person2_2() OWNER TO postgres;


CREATE FUNCTION public.get_random_person_from_country2_2(country_arg character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
id_of_person INT;
BEGIN
	SELECT person."idPerson" INTO id_of_person FROM person  -- 10.000 persons in the db
	WHERE person.country = country_arg 
	AND is_pure_client2_2(person."idPerson")  -- check that the person is truly a client
	ORDER BY RANDOM()
	LIMIT 1;
	RETURN id_of_person;
END;
$$;


ALTER FUNCTION public.get_random_person_from_country2_2(country_arg character varying) OWNER TO postgres;


CREATE FUNCTION public.has_breakfast(idhotel integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
	PERFORM "nameFacility" FROM hotelfacilities WHERE "nameFacility" = 'Breakfast' and hotelfacilities."idHotel" = "idHotel" ;
	RETURN FOUND;  -- is true or false according to the perform resultD
END;
$$;


ALTER FUNCTION public.has_breakfast(idhotel integer) OWNER TO postgres;

COMMENT ON FUNCTION public.has_breakfast(idhotel integer) IS 'made for 3.2';

CREATE FUNCTION public.has_free_from_each_type3_8(hotelid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
	PERFORM * FROM(
	(SELECT DISTINCT room.roomtype FROM hotel
	JOIN room ON room."idHotel" = hotel."idHotel" 
	WHERE hotel."idHotel" = hotelid-- get all the types of rooms(reserved or not) in a single hotel
	ORDER BY room.roomtype)
	EXCEPT(
	SELECT DISTINCT room.roomtype FROM room    -- get all the types of free rooms
	JOIN roombooking ON roombooking."roomID" = room."idRoom"
	WHERE room."idHotel" = hotelid AND now() not BETWEEN roombooking.checkin AND roombooking.checkout
	ORDER BY room.roomtype)) AS if_empty_then_true;
	RETURN NOT FOUND;
END;
$$;


ALTER FUNCTION public.has_free_from_each_type3_8(hotelid integer) OWNER TO postgres;


CREATE FUNCTION public.has_n_free_rooms2_2(hotel_id integer, number_of_rooms integer, start_date date, end_date date) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
	PERFORM id_of_hotel FROM who_has_n_free_rooms2_2(number_of_rooms, start_date, end_date)
	WHERE id_of_hotel = hotel_id;
	RETURN FOUND; -- FOUND=True--> there are at least n free rooms the selected period
END;
$$;


ALTER FUNCTION public.has_n_free_rooms2_2(hotel_id integer, number_of_rooms integer, start_date date, end_date date) OWNER TO postgres;


CREATE FUNCTION public.has_restaurant(idhotel integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
	PERFORM "nameFacility" FROM hotelfacilities WHERE "nameFacility" = 'Restaurant' and hotelfacilities."idHotel" = "idHotel" ;
	RETURN FOUND;  -- is true or false according to the perform resultD
END;
$$;


ALTER FUNCTION public.has_restaurant(idhotel integer) OWNER TO postgres;


COMMENT ON FUNCTION public.has_restaurant(idhotel integer) IS 'made for 3.2';



CREATE FUNCTION public.has_studio_less_than_80(idhotel_arg integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN  
	PERFORM room.roomtype,(roomrate.rate-roomrate.rate*(roomrate.discount/100)) as true_price FROM room
	JOIN roomrate ON roomrate."idHotel"=room."idHotel" AND room.roomtype = 'Studio' AND true_price<80;
	RETURN FOUND;
END;
$$;


ALTER FUNCTION public.has_studio_less_than_80(idhotel_arg integer) OWNER TO postgres;


COMMENT ON FUNCTION public.has_studio_less_than_80(idhotel_arg integer) IS 'for question 3.2';



CREATE FUNCTION public.is_client(amka integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
	PERFORM "idClient" FROM client WHERE "idClient" = amka;
	RETURN FOUND;  -- is true or false according to the perform resultD
END;
$$;


ALTER FUNCTION public.is_client(amka integer) OWNER TO postgres;


CREATE FUNCTION public.is_free2_2(id_of_room integer, start_date date, end_date date) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
	PERFORM * FROM roombooking
	JOIN room ON roombooking."roomID" = room."idRoom" AND "idRoom" = id_of_room
	WHERE (roombooking.checkin BETWEEN start_date AND end_date)
	OR (roombooking.checkout  BETWEEN start_date AND end_date);
	RETURN NOT FOUND;
END;
$$;


ALTER FUNCTION public.is_free2_2(id_of_room integer, start_date date, end_date date) OWNER TO postgres;

CREATE FUNCTION public.is_pure_client2_2(id_of_person integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- needs the get_pure_clients2_2() to run inside the func2_2()!!
    PERFORM id_of_client FROM pure_clients
    WHERE id_of_client = id_of_person;
    RETURN FOUND;  -- found means the id_of_person is in the pure clients --> he is a client for sure
END;
$$;


ALTER FUNCTION public.is_pure_client2_2(id_of_person integer) OWNER TO postgres;


CREATE FUNCTION public.new_client() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- when a new client is added, we check if he is an amployee or not. If he is not, he is
	-- added in the pure_clients table
    IF NOT EXISTS(SELECT * FROM employee WHERE new."idClient"=employee."idEmployee") THEN
		INSERT INTO pure_clients(id_of_client)
		VALUES (new."idClient");  -- if its refering a pure client, insert the AMKA in the pure clients table
	END IF;
    return new;

end;
$$;


ALTER FUNCTION public.new_client() OWNER TO postgres;

CREATE FUNCTION public.new_employee() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF EXISTS(SELECT * FROM pure_clients WHERE new."idEmployee"=pure_clients.id_of_client) THEN
		DELETE FROM pure_clients WHERE pure_clients.id_of_client=new."idEmployee";  -- if the new employee is in the pure clients, its time to e r a s e him
	END IF;
	return new;
end;
$$;


ALTER FUNCTION public.new_employee() OWNER TO postgres;


CREATE FUNCTION public.new_transaction() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	RAISE NOTICE 'INSIDE THE new_transaction() trigger function...';
	IF (TG_OP ='UPDATE' and new.payed = True ) THEN  -- only add transaction if the customer payed.
		insert into transactions(amount,action,idhotelbooking,date) -- na eisagoume ston pinaka student_audit thn plhroforia 
		select old.totalamount,'UPDATE',old.idhotelbooking,now();  -- hotelbookingid and amount are from hotelbooking
		RAISE NOTICE 'update logged in transactions.';
		return new;
		
	ELSEIF (TG_OP = 'INSERT' and new.payed = True) THEN -- will there be an old payment if it was just created???
		insert into transactions(amount,action,idhotelbooking,date)
		select new.totalamount,'INSERT',new.idhotelbooking,now(); 
		RAISE NOTICE 'insert logged in transactions.';
		return new;
	
	ELSE
		raise notice 'Heavent paint';
		return null;
	END IF;
END;
$$;


ALTER FUNCTION public.new_transaction() OWNER TO postgres;


CREATE FUNCTION public.no_of_participants_3_5(weekday_arg integer, endtime_arg integer, starttime_arg integer, idhotel_arg integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE 
count_of_participants INTEGER;
BEGIN  -- returns the number of participants in a activity
	SELECT 
		COUNT(*) INTO count_of_participants FROM participates
	WHERE
		participates.weekday = weekday_arg AND participates.endtime = endtime_arg AND participates.starttime = starttime_arg 
		AND participates.role = 'participant' AND participates.idhotel = idhotel_arg;  -- from a certain hotel, and only if the row is a participant.
	RETURN count_of_participants;  -- returns how many participants a certain activity has
END;
$$;


ALTER FUNCTION public.no_of_participants_3_5(weekday_arg integer, endtime_arg integer, starttime_arg integer, idhotel_arg integer) OWNER TO postgres;


COMMENT ON FUNCTION public.no_of_participants_3_5(weekday_arg integer, endtime_arg integer, starttime_arg integer, idhotel_arg integer) IS 'CHECK ok';



CREATE FUNCTION public.random_between(low integer, high integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
   RETURN floor(random()* (high-low + 1) + low);
END;
$$;


ALTER FUNCTION public.random_between(low integer, high integer) OWNER TO postgres;


CREATE FUNCTION public.roombooking_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE   -- to store the discount 
discount_rate INT;
cancellation_date DATE;
has_payed BOOLEAN;
BEGIN
	RAISE NOTICE 'Inside the roombooking_insert() trigger function...';
	--get the discount for that room, and the cancellation date drom the hotelbooking table
	SELECT roomrate.discount,hotelbooking.cancellationdate,hotelbooking.payed INTO discount_rate, cancellation_date,has_payed  FROM roombooking
	JOIN room ON roombooking."roomID" = room."idRoom" AND roombooking."hotelbookingID"=new."hotelbookingID" AND roombooking."roomID"=new."roomID"   -- only for these specific PK's
	JOIN hotelbooking ON hotelbooking.idhotelbooking=roombooking."hotelbookingID"
	JOIN hotel ON hotel."idHotel" = room."idHotel"
	JOIN roomrate ON room."idHotel" = roomrate."idHotel";

	-- on updation/deletion or insertion update the totalamount on hotelbooking.
	IF (TG_OP='UPDATE' OR TG_OP='INSERT') THEN
		UPDATE hotelbooking
		SET totalamount=totalamount + (NEW.rate - new.rate*discount_rate)  -- take into account the discount
		WHERE new."hotelbookingID"=hotelbooking.idhotelbooking;
		RETURN NEW;
	ELSEIF (TG_OP='DELETE') THEN
		UPDATE hotelbooking
		SET totalamount=totalamount - (old.rate - old.rate*discount_rate)
		WHERE new."hotelbookingID"=idhotelbooking;
		
		IF (TG_OP='DELETE' AND now()>cancellation_date AND has_payed = true) THEN
			RAISE NOTICE 'you cannot delete the booking after the cancellation date ';
			RETURN OLD;  -- dont allow the deletion
		ELSEIF (TG_OP='DELETE' AND now()<cancellation_date AND has_payed = true) THEN
			-- log the return of money into the transactions
			insert into transactions(amount,action,idhotelbooking,date)
			select transactions.amount-(NEW.rate - NEW.rate*discount_rate/100),'DELETE',new."hotelbookingID",now();
			RAISE NOTICE ' the return of money was logged in the transactions table';
		
		ELSEIF (TG_OP='INSERT' AND now()>cancellation_date AND has_payed = true) THEN
			insert into transactions(amount,action,idhotelbooking,date)
			select (NEW.rate - NEW.rate*discount_rate/100),'INSERT',new."hotelbookingID",now(); 
			RAISE NOTICE 'the  transactions table was updated with the insertion data';
		
		END IF;
		
		RETURN NEW;
	END IF;

END;
$$;


ALTER FUNCTION public.roombooking_insert() OWNER TO postgres;



CREATE FUNCTION public.update_hotelbooking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	RAISE NOTICE 'Inside the update_hotelbooking() trigger function...';
	DROP TABLE IF EXISTS temp_table1;
	CREATE TEMP TABLE temp_table1(manager_role emp_role);  -- this table will contain 1 column and 1 row with the
	INSERT INTO temp_table1(manager_role)                  -- role of the manager(employee,manager,etc)
	SELECT employee.role FROM employee
	JOIN manages ON manages.amka = employee."idEmployee"
	JOIN hotelbooking ON manages.idhotelbooking = hotelbooking.idhotelbooking AND hotelbooking.idhotelbooking = new.idhotelbooking;
	-- At that point, the temp_table1 must contain the role of the employee that manages the hotelbooking
	-- that way, we will be able to know if it is being managed by the director(manager) or someone 
	-- other that does not have privileges.
	
	IF EXISTS (SELECT * FROM temp_table1) THEN  -- if the manager is an employee
		-- IF (TG_OP=UPDATE) THEN  -- if triggered upon an update(probably not needed, specified it on the trigger code)
		IF (old.cancellationdate<>new.cancellationdate AND EXISTS (SELECT * FROM temp_table1 WHERE temp_table1.role='manager')) THEN  -- if the manager tried to change the cancellation date...
		INSERT INTO hotelbooking(cancellationdate)  -- ...let him do that.
		VALUES (new.cancellationdate);                                                                                              -- let him do that.
		ELSE  -- ...dont let him change it.
			new.cancellationdate=old.cancellationdate;  -- dot let anyone but the hotel manager to change the cancellation date
			RAISE NOTICE 'cant allow you to do that, because you are not the manager';
		END IF;
		
		IF (old.status ='confirmed' OR old.status = 'pending' and new.status = 'canceled' AND now()<cancelationdate) THEN  -- if someone tries to cancel it after the cancelation deadline
			new.status = old.status;
			RAISE NOTICE 'cant cancel the booking because the cancellation deadline is in the past.';
		ELSEIF (old.status ='confirmed' OR old.status = 'pending' and new.status = 'canceled' AND now()>cancelationdate) THEN
			RAISE NOTICE ' cancellation accepted because it happened earlier than the cancellation deadline';
		END IF;
		RETURN NEW;
		
	ELSE 
		RAISE NOTICE 'not managed by an employee, cant update.';
		RETURN NULL;  -- this SHOULD not let the changes to pass through to our data. Check it(TODO).
	END IF;
END;
$$;


ALTER FUNCTION public.update_hotelbooking() OWNER TO postgres;


CREATE FUNCTION public.update_roombooking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
cancel_date DATE;
BEGIN
	RAISE NOTICE 'Inside the roombooking_insert() trigger function...';
	-- get cancellationdate from hotelboking(for the roombooking that invoked the trigger)
	SELECT hotelbooking.cancellationdate INTO cancel_date FROM hotelbooking
	JOIN roombooking ON old."hotelbookingID"=hotelbooking.idhotelbooking;

	-- on delete of roombooking... dont let it happen after cancellation date
	IF (TG_OP='DELETE' AND now()>cancel_date) THEN
		RETURN OLD ;  -- return the non-deleted row, and thus avoid deletion.
	END IF;
	
	-- detect reduction in stay time... dont let it happen after cancellation date
	IF (TG_OP='UPDATE' AND (old.checkout-old.checkin)>=(new.checkout-new.checkin) AND now()>cancel_date) THEN
		new.checkout = old.checkout;
		new.checkin = old.checkin;  -- disallow reduction of stay time
		new."bookedforpersonID" = old.rate;
		new.rate = old.rate;
	ELSEIF (TG_OP='UPDATE' AND (old.checkout-old.checkin)<(new.checkout-new.checkin) AND now()>cancel_date) THEN  -- allow elongation of the stay time
		new."bookedforpersonID" = old."bookedforpersonID";
		new.rate = old.rate;  -- Dont allow changes in other fileds except checkin and checkout date.
		
		
	ELSEIF ( TG_OP='UPDATE' AND old.checkout<new.checkout) THEN -- check if vacant when expanding stay(question 5.3!!)
		-- Check if any other reservation exists for that room between old.checkout and new.checkout
		-- this roomID
		IF EXISTS(SELECT * FROM roombooking WHERE roombooking."roomID"=new."roomID" AND
					roombooking.checkin BETWEEN old.checkout AND new.checkout ) THEN
			new.checkout = old.checkout;  -- dont allow the new checkout date
			RAISE NOTICE 'cant make reservation, already reserved.';
		ELSE 
			RAISE NOTICE 'reservation successfull.';
		END IF;
	RETURN NEW;
						
	END IF;
	
	IF (TG_OP='INSERT'  AND now()<cancel_date) THEN 
		RETURN NEW;
	END IF;
	RETURN NEW;
		
END;
$$;


ALTER FUNCTION public.update_roombooking() OWNER TO postgres;

CREATE FUNCTION public.view6_2_update_discount() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE roomrate 
  SET discount=NEW.discount
  WHERE discount=OLD.discount AND "idHotel"=new."idHotel" AND roomtype = new.roomtype ;
END
$$;


ALTER FUNCTION public.view6_2_update_discount() OWNER TO postgres;


CREATE FUNCTION public.view6_2_update_rate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
BEGIN
  UPDATE roomrate 
  SET rate=new.rate
  WHERE rate=old.rate AND "idHotel"=new."idHotel" AND roomtype = new.roomtype;
END
$$;


ALTER FUNCTION public.view6_2_update_rate() OWNER TO postgres;


CREATE FUNCTION public.who_has_n_free_rooms2_2(number_of_rooms integer, start_date date, end_date date) RETURNS TABLE(no_of_rooms bigint, id_of_hotel integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	WITH free_rooms As (
	SELECT room."idHotel", room."idRoom",roombooking.checkin, roombooking.checkout FROM roombooking
	JOIN room ON roombooking."roomID" = room."idRoom"
	WHERE is_free2_2(room."idRoom", start_date, end_date)  -- all the free rooms between these dates
		)
	SELECT COUNT("idHotel") as no_of_rooms, "idHotel"  FROM free_rooms
	GROUP BY "idHotel"
	HAVING COUNT("idHotel")>number_of_rooms  -- satisfy the argument condition of at least n rooms
	ORDER BY RANDOM();  -- order the rows randomly
END;
$$;


ALTER FUNCTION public.who_has_n_free_rooms2_2(number_of_rooms integer, start_date date, end_date date) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;


CREATE TABLE public.activity (
    idhotel integer NOT NULL,
    amka integer NOT NULL,
    "activityType" public.activities,
    weekday integer NOT NULL,
    endtime integer NOT NULL,
    starttime integer NOT NULL,
    CONSTRAINT normalday CHECK ((weekday < 7)),
    CONSTRAINT "start<end" CHECK ((starttime < endtime))
);


ALTER TABLE public.activity OWNER TO postgres;


COMMENT ON COLUMN public.activity.idhotel IS 'TakesPlace from the ER diagram.';


CREATE VIEW public.view6_1 AS
 SELECT room."idHotel",
    room.roomtype,
    roombooking.checkin AS free_till_date
   FROM (public.room
     JOIN public.roombooking ON ((room."idRoom" = roombooking."roomID")))
  WHERE ((NOT ((now() >= roombooking.checkin) AND (now() <= roombooking.checkout))) AND (roombooking.checkin > now()));


ALTER TABLE public.view6_1 OWNER TO postgres;


CREATE VIEW public.view6_2 AS
 SELECT DISTINCT room."idHotel",
    room."idRoom",
    room.roomtype,
    roombooking.checkin,
    roomrate.rate,
    roomrate.discount,
    public.check_room6_2(hotel."idHotel", room."idRoom", ((now() + ((((((7)::double precision - date_part('ISODOW'::text, now())))::character varying)::text || ' days'::text))::interval))::date) AS sunday,
    public.check_room6_2(hotel."idHotel", room."idRoom", ((now() + ((((((8)::double precision - date_part('ISODOW'::text, now())))::character varying)::text || ' days'::text))::interval))::date) AS monday,
    public.check_room6_2(hotel."idHotel", room."idRoom", ((now() + ((((((9)::double precision - date_part('ISODOW'::text, now())))::character varying)::text || ' days'::text))::interval))::date) AS tuesday,
    public.check_room6_2(hotel."idHotel", room."idRoom", ((now() + ((((((10)::double precision - date_part('ISODOW'::text, now())))::character varying)::text || ' days'::text))::interval))::date) AS wednesday,
    public.check_room6_2(hotel."idHotel", room."idRoom", ((now() + ((((((11)::double precision - date_part('ISODOW'::text, now())))::character varying)::text || ' days'::text))::interval))::date) AS thursday,
    public.check_room6_2(hotel."idHotel", room."idRoom", ((now() + ((((((12)::double precision - date_part('ISODOW'::text, now())))::character varying)::text || ' days'::text))::interval))::date) AS friday,
    public.check_room6_2(hotel."idHotel", room."idRoom", ((now() + ((((((13)::double precision - date_part('ISODOW'::text, now())))::character varying)::text || ' days'::text))::interval))::date) AS saturday
   FROM (((public.room
     JOIN public.roombooking ON ((room."idRoom" = roombooking."roomID")))
     JOIN public.hotel ON ((room."idHotel" = hotel."idHotel")))
     JOIN public.roomrate ON (((hotel."idHotel" = roomrate."idHotel") AND ((room.roomtype)::text = (roomrate.roomtype)::text))))
  WHERE ((roombooking.checkin >= (now() + ((((((7)::double precision - date_part('ISODOW'::text, now())))::character varying)::text || ' days'::text))::interval)) AND (roombooking.checkin <= (now() + ((((((14)::double precision - date_part('ISODOW'::text, now())))::character varying)::text || ' days'::text))::interval)))
  ORDER BY roombooking.checkin;



-- Completed on 2021-06-02 16:58:42

--
-- PostgreSQL database dump complete
--

