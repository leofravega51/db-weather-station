/**
=====================================================================================================================
@function: getWeatherdataBetweenDates
@param {double precision} lat: latitude
@param {double precision} lon: longitude
@param {varchar} startdate: start date (YYYY-MM-DD HH:MM:SS.mm)
@param {varchar} enddate: end date (YYYY-MM-DD HH:MM:SS.mm)
@whatdoes: devuelve todas las mediciones registradas entre fecha de inicio y de fin en una determinada geolocalizacion.
@return: record
=====================================================================================================================
**/

CREATE OR REPLACE FUNCTION getWeatherdataBetweenDates(lat double precision, lon double precision, startdate varchar, enddate varchar)
RETURNS SETOF measurement AS $BODY$
DECLARE
	weatherdata measurement%ROWTYPE;
	stationlocated station.id_station%TYPE;
	idlocationreq location.id_location%TYPE;
BEGIN
	idlocationreq := (SELECT location.id_location FROM location WHERE location.latitude=lat AND location.longitude=lon);
	-- raise notice 'idlocationreq: %', idlocationreq;
	
	if (idlocationreq is null) then
		raise exception 'No poseemos datos de mediciones en la latitude: % y longitude: %', lat, lon;
	else
		stationlocated := (SELECT station.id_station FROM station WHERE station.id_location=idlocationreq);
		-- raise notice 'stationlocated: %', stationlocated;
		
		for weatherdata in (SELECT * FROM measurement 
					  	WHERE measurement.id_station=stationlocated 
					  	AND measurement.date_measurement 
					  	BETWEEN TO_TIMESTAMP(startdate, 'YYYY-MM-DD HH24:MI:SS') 
					  	AND  TO_TIMESTAMP(enddate, 'YYYY-MM-DD HH24:MI:SS'))
		loop
			return next weatherdata;
		end loop;
	end if;
	
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/**
=============================================================================================================================
test: getWeatherdataBetweenDates
=============================================================================================================================
**/

-- SELECT registerStation('BASE UADER', -32.479361, -58.2347473, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '2854');
-- SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE UADER');
-- SELECT * FROM getWeatherdataBetweenDates(-32.479361, -58.2347473, '2019-11-27 14:00.00', '2019-11-27 21:00.00');
-- DELETE FROM location WHERE location.latitude=-32.479361 AND location.longitude=-58.2347473;

/**
=====================================================================================================================
@function: getWeatherdataByStationId
@param {varchar} idstation: id station
@whatdoes: devuelve la ultima medicion registrada por una determinada estacion.
@return: record
=====================================================================================================================
**/

CREATE OR REPLACE FUNCTION getWeatherdataByStationId(idstation varchar)
RETURNS SETOF measurement AS $BODY$
DECLARE
	weatherdata measurement%ROWTYPE;
	stationlocated station.id_station%TYPE;
BEGIN
	stationlocated := (SELECT station.id_location FROM station WHERE station.id_station=idstation);
	-- raise notice 'stationlocated: %', stationlocated;
	if (stationlocated is null) then
		raise exception 'No poseemos datos de mediciones para este id: % de estacion', idstation;
	else
		for weatherdata in (SELECT * FROM measurement 
						WHERE measurement.id_station=idstation 
						ORDER BY measurement.date_measurement 
						DESC LIMIT 1)
		loop
			return next weatherdata;
		end loop;
	end if;
					
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/**
=============================================================================================================================
test: getWeatherdataByStationId
=============================================================================================================================
**/

-- SELECT registerStation('BASE UADER', -32.479361, -58.2347473, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '2854');
-- SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE UADER');
-- SELECT * FROM getWeatherdataByStationId('f610f7884416');
-- DELETE FROM location WHERE location.latitude=-32.479361 AND location.longitude=-58.2347473;

/**
=====================================================================================================================
@function: getWeatherdataByPlace
@param {varchar} regionname: region
@param {varchar} cityname: city name
@whatdoes: devuelve la ultima medicion realizada en una region y ciudad.
@return: record
=====================================================================================================================
**/

CREATE OR REPLACE FUNCTION getWeatherdataByPlace(regionname varchar, cityname varchar)
RETURNS SETOF measurement AS $BODY$
DECLARE
	weatherdata measurement%ROWTYPE;
	stationlocated station.id_station%TYPE;
	idlocationreq location.id_location%TYPE;
BEGIN
	idlocationreq := (SELECT location.id_location FROM location 
					  	WHERE location.region=regionname AND location.city=cityname
					  	ORDER BY location.id_location ASC LIMIT 1);
	-- raise notice 'idlocation: %', idlocationreq;
	
	if (idlocationreq is null) then
		raise exception 'No poseemos datos de mediciones en la region "%" y ciudad "%".', regionname, cityname;
	else
		stationlocated := (SELECT station.id_station FROM station WHERE station.id_location=idlocationreq);
		-- raise notice 'stationlocated: %', stationlocated;
		
		for weatherdata in (SELECT * FROM measurement 
					WHERE measurement.id_station=stationlocated 
					ORDER BY measurement.date_measurement 
					DESC LIMIT 1)
		loop
			return next weatherdata;
		end loop;
	end if;
	
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/**
=============================================================================================================================
test: getWeatherdataByPlace
=============================================================================================================================
**/

-- SELECT registerStation('BASE UADER', -32.479361, -58.2347473, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '2854');
-- SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE UADER');
-- SELECT * FROM getWeatherdataByPlace('ENTRE RIOS', 'GUALEGUAYCHU');
-- DELETE FROM location WHERE location.latitude=-32.479361 AND location.longitude=-58.2347473;

/*
=====================================================================================================================
@function: getWeatherdataByGeolocation
@param {double precision} lat: latitude
@param {double precision} lon: longitude
@whatdoes: devuelve la ultima medicion registradas en una determinada geolocalizacion.
@return: record
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION getWeatherdataByGeolocation(lat double precision, lon double precision)
RETURNS SETOF measurement AS $BODY$
DECLARE
	weatherdata measurement%ROWTYPE;
	stationlocated station.id_station%TYPE;
	idlocationreq location.id_location%TYPE;
BEGIN
	idlocationreq := (SELECT location.id_location FROM location 
					  	WHERE location.latitude=lat AND location.longitude=lon);
	-- raise notice 'idlocationreq: %', idlocationreq;
	
	if (idlocationreq is null) then
		raise exception 'No poseemos datos de mediciones en la latitude: % y longitude: %', lat, lon;
	else
		stationlocated := (SELECT station.id_station FROM station WHERE station.id_location=idlocationreq);
		-- raise notice 'stationlocated: %', stationlocated;
		
		for weatherdata in (SELECT * FROM measurement 
					WHERE measurement.id_station=stationlocated 
					ORDER BY measurement.date_measurement 
					DESC LIMIT 1)
		loop
			return next weatherdata;
		end loop;
	end if;
	
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=============================================================================================================================
test: getWeatherdataByGeolocation
=============================================================================================================================
*/

-- SELECT registerStation('BASE UADER', -32.479361, -58.2347473, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '2854');
-- SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE UADER');
-- SELECT * FROM getWeatherdataByGeolocation(-32.479361, -58.2347473);
-- DELETE FROM location WHERE location.latitude=-32.479361 AND location.longitude=-58.2347473;

/*
=====================================================================================================================
@function: getWeatherdataByZipCode
@param {varchar} zipcode: zip code
@whatdoes: devuelve la ultima medicion realizada en una region segun su codigo de area.
@return: record
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION getWeatherdataByZipCode(zipcode varchar)
RETURNS SETOF measurement AS $BODY$
DECLARE
	weatherdata measurement%ROWTYPE;
	stationlocated station.id_station%TYPE;
	idlocationreq location.id_location%TYPE;
BEGIN
	idlocationreq := (SELECT location.id_location FROM location 
					  	WHERE location.zip_code=zipcode
					  	ORDER BY location.id_location ASC LIMIT 1);
	-- raise notice 'idlocationreq: %', idlocationreq;
	
	if (idlocationreq is null) then
		raise exception 'No poseemos datos de mediciones en la ciudad con el zipcode: %.', zipcode;
	else
		stationlocated := (SELECT station.id_station FROM station WHERE station.id_location=idlocationreq);
		-- raise notice 'stationlocated: %', stationlocated;
		
		for weatherdata in (SELECT * FROM measurement 
					WHERE measurement.id_station=stationlocated 
					ORDER BY measurement.date_measurement 
					DESC LIMIT 1)
		loop
			return next weatherdata;
		end loop;
	end if;
	
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=============================================================================================================================
test: getWeatherdataByZipCode
=============================================================================================================================
*/

-- SELECT registerStation('BASE UADER', -32.479361, -58.2347473, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '2854');
-- SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE UADER');
-- SELECT * FROM getWeatherdataByZipCode('2854');
-- DELETE FROM location WHERE location.latitude=-32.479361 AND location.longitude=-58.2347473;

/*
=====================================================================================================================
@function: getStationdataBetweenDates
@param {varchar} startdate: start date (YYYY-MM-DD HH:MM:SS.mm)
@param {varchar} enddate: end date (YYYY-MM-DD HH:MM:SS.mm)
@param {integer} amount: amount rows
@whatdoes: devuelve todas las estaciones creadas en un intervalo de fechas [startdate; enddate].
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city varchar, zip_code varchar)
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION getStationdataBetweenDates(startdate varchar, enddate varchar, amount integer default 10)
RETURNS SETOF record AS $BODY$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND station.created_at 
						BETWEEN TO_TIMESTAMP(startdate, 'YYYY-MM-DD HH24:MI:SS') 
							AND  TO_TIMESTAMP(enddate, 'YYYY-MM-DD HH24:MI:SS') 
						ORDER BY station.created_at ASC
						LIMIT amount)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones creadas en el intervalo de fechas [%; %].', startdate, enddate;
	end if;
	
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=============================================================================================================================
test: getStationdataBetweenDates
=============================================================================================================================
*/

-- SELECT registerStation('BASE UADER', -32.479361, -58.2347473, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '2854');
-- SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE UADER');
/*
SELECT * FROM getStationdataBetweenDates('2019-11-29 14:00.00', '2019-11-30 21:00.00', 5)
	AS stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
	longitude double precision, country varchar, region varchar, city varchar, zip_code varchar);
*/
-- DELETE FROM location WHERE location.latitude=-32.479361 AND location.longitude=-58.2347473;

/*
=====================================================================================================================
@function: getStationdataById
@param {varchar} idstation: id station
@whatdoes: devuelve la estacion con el id especificado.
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city varchar, zip_code varchar)
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION getStationdataById(idstation varchar)
RETURNS SETOF record AS $BODY$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_station=idstation 
					AND station.id_location=location.id_location)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones con el id: % especificado.', idstation;
	end if;
	
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=============================================================================================================================
test: getStationdataById
=============================================================================================================================
*/

-- SELECT registerStation('BASE UADER', -32.479361, -58.2347473, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '2854');
-- SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE UADER');
/*
SELECT * FROM getStationdataById('d3dc4137fbac')
	AS stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
	longitude double precision, country varchar, region varchar, city varchar, zip_code varchar);
*/
-- DELETE FROM location WHERE location.latitude=-32.479361 AND location.longitude=-58.2347473;

/*
=====================================================================================================================
@function: getStationdataByRegion
@param {varchar} regionname: region name
@param {integer} amount: amount rows
@whatdoes: devuelve todas las estaciones localizadas en la region especificada.
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city varchar, zip_code varchar)
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION getStationdataByRegion(regionname varchar, amount integer default 10)
RETURNS SETOF record AS $BODY$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.region=regionname
						ORDER BY station.created_at ASC
						LIMIT amount)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones ubicadas en la region "%".', regionname;
	end if;
	
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=============================================================================================================================
test: getStationdataByRegion
=============================================================================================================================
*/

-- SELECT registerStation('BASE UADER', -32.479361, -58.2347473, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '2854');
-- SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE UADER');
/*
SELECT * FROM getStationdataByRegion('ENTRE RIOS', 5)
	AS stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
	longitude double precision, country varchar, region varchar, city varchar, zip_code varchar);
*/
-- DELETE FROM location WHERE location.latitude=-32.479361 AND location.longitude=-58.2347473;

/*
=====================================================================================================================
@function: getStationdataByCity
@param {varchar} cityname: city name
@param {integer} amount: amount rows
@whatdoes: devuelve todas las estaciones localizadas en la ciudad especificada.
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city varchar, zip_code varchar)
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION getStationdataByCity(cityname varchar, amount integer default 10)
RETURNS SETOF record AS $BODY$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.city=cityname
						ORDER BY station.created_at ASC
						LIMIT amount)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones ubicadas en la ciudad "%".', cityname;
	end if;
	
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=============================================================================================================================
test: getStationdataByCity
=============================================================================================================================
*/

-- SELECT registerStation('BASE UADER', -32.479361, -58.2347473, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '2854');
-- SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE UADER');
/*
SELECT * FROM getStationdataByCity('GUALEGUAYCHU', 5)
	AS stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
	longitude double precision, country varchar, region varchar, city varchar, zip_code varchar);
*/
-- DELETE FROM location WHERE location.latitude=-32.479361 AND location.longitude=-58.2347473;

/*
=====================================================================================================================
@function: getStationdataByPlace
@param {varchar} regionname: region name
@param {varchar} cityname: city name
@param {integer} amount: amount rows
@whatdoes: devuelve todas las estaciones localizadas en la region y ciudad especificada.
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city varchar, zip_code varchar)
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION getStationdataByPlace(regionname varchar, cityname varchar, amount integer default 10)
RETURNS SETOF record AS $BODY$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.region=regionname
					AND location.city=cityname
						ORDER BY station.created_at ASC
						LIMIT amount)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones ubicadas en la region "%" y ciudad "%".', regionname, cityname;
	end if;
	
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=============================================================================================================================
test: getStationdataByPlace
=============================================================================================================================
*/

-- SELECT registerStation('BASE UADER', -32.479361, -58.2347473, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '2854');
-- SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE UADER');
/*
SELECT * FROM getStationdataByPlace('ENTRE RIOS', 'PARANA', 5)
	AS stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
	longitude double precision, country varchar, region varchar, city varchar, zip_code varchar);
*/
-- DELETE FROM location WHERE location.latitude=-32.479361 AND location.longitude=-58.2347473;

/*
=====================================================================================================================
@function: getStationdataByGeolocation
@param {double precision} lat: latitude
@param {double precision} lon: longitude
@whatdoes: devuelve la estacion localizazda en la geolocalizacion especificada.
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city varchar, zip_code varchar)
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION getStationdataByGeolocation(lat double precision, lon double precision)
RETURNS SETOF record AS $BODY$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.latitude=lat
					AND location.longitude=lon)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos ninguna estacion ubicada en las coordenadas latitude: "%" ; longitude:"%".', lat, lon;
	end if;
	
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=============================================================================================================================
test: getStationdataByGeolocation
=============================================================================================================================
*/

-- SELECT registerStation('BASE UADER', -32.479361, -58.2347473, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '2854');
-- SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE UADER');
/*
SELECT * FROM getStationdataByGeolocation(-32.4833, -58.2283)
	AS stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
	longitude double precision, country varchar, region varchar, city varchar, zip_code varchar);
*/
-- DELETE FROM location WHERE location.latitude=-32.479361 AND location.longitude=-58.2347473;


/*
=====================================================================================================================
@function: getStationdataByZipcode
@param {varchar} zipcode: zip code
@param {integer} amount: amount rows
@whatdoes: devuelve todas las estaciones localizadas en la region con el codigo de area especificado.
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city varchar, zip_code varchar)
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION getStationdataByZipcode(zipcode varchar, amount integer default 10)
RETURNS SETOF record AS $BODY$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.zip_code=zipcode
						ORDER BY station.created_at ASC
						LIMIT amount)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones ubicadas la region con el zipcode "%".', zipcode;
	end if;
	
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=============================================================================================================================
test: getStationdataByZipcode
=============================================================================================================================
*/

-- SELECT registerStation('BASE UADER', -32.479361, -58.2347473, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '2854');
-- SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE UADER');
/*
SELECT * FROM getStationdataByZipcode('2820', 5)
	AS stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
	longitude double precision, country varchar, region varchar, city varchar, zip_code varchar);
*/
-- DELETE FROM location WHERE location.latitude=-32.479361 AND location.longitude=-58.2347473;