/*
==================================================================================================================================================================
functions: location
==================================================================================================================================================================
*/

/**
=====================================================================================================================
@function: registerLocation
@param {double precision} lat: latitude
@param {double precision} lon: latitude
@param {varchar} ctry: country
@param {varchar} reg: region
@param {varchar} citnm: city name
@param {varchar} zipc: zip code
@whatdoes: registra una localizacion en la que se ubicara una estacion.
@return: retorna el identificador de la estacion registrada.
=====================================================================================================================
**/

CREATE OR REPLACE FUNCTION registerLocation(lat double precision, lon double precision, ctry varchar, reg varchar, citnm varchar, zipc varchar)
RETURNS varchar AS $BODY$
DECLARE
	idlocation varchar;
BEGIN
	INSERT INTO location(latitude, longitude, country, region, city_name, zip_code) 
		VALUES(lat, lon, ctry, reg, citnm, zipc);
	idlocation := (SELECT location.id_location FROM location WHERE location.latitude=lat AND location.longitude=lon);
	
	-- RAISE NOTICE 'idlocation: %', idlocation;
		
	RETURN idlocation;
END; $BODY$ LANGUAGE 'plpgsql';

/*
==================================================================================================================================================================
functions: station
==================================================================================================================================================================
*/

/**
=====================================================================================================================
@function: registerStation
@param {varchar} name: name station
@param {double precision} latitude: latitude
@param {double precision} longitude: latitude
@param {varchar} country: country
@param {varchar} region: region
@param {varchar} cityname: city name
@param {varchar} zipcode: zip code
@whatdoes: registra una estacion en la localizacion indicada.
@return: retorna el identificador de la estacion registrada.
=====================================================================================================================
**/

CREATE OR REPLACE FUNCTION registerStation(namestation varchar, latitude double precision, longitude double precision, country varchar, region varchar, cityname varchar, zipcode varchar)
RETURNS varchar AS $BODY$
DECLARE
	idlocation varchar;
	idstation varchar;
BEGIN
	idlocation := (SELECT registerLocation(latitude, longitude, country, region, cityname, zipcode));
	
	INSERT INTO station(name_station, id_location)
		VALUES(namestation, idlocation);
 
	idstation := (SELECT station.id_station FROM station WHERE station.name_station=namestation);
	RAISE NOTICE 'idstation: %', idstation;
				   
	RETURN idstation;
END; $BODY$ LANGUAGE 'plpgsql';

/*
==================================================================================================================================================================
functions: measurement
==================================================================================================================================================================
*/

/**
=====================================================================================================================
@function: registerMeasurement
@param {double precision} temp: temperature
@param {double precision} hum: humidity
@param {double precision} pres: pressure
@param {double precision} uvrad: ultraviolet radiation
@param {double precision} windvel: wind velocity
@param {double precision} winddir: wind direction
@param {double precision} rainmm: rain milimeters
@param {integer} rainintensity: rain intensity
@param {varchar} namestation: name station
@whatdoes: registra una medicion realizada por una estacion.
@return: void
=====================================================================================================================
**/

CREATE OR REPLACE FUNCTION registerMeasurement(temp double precision, hum double precision, pres double precision, uvrad double precision, windvel double precision, winddir double precision, rainmm double precision, rainintensity integer, namestation varchar)
RETURNS void AS $BODY$
DECLARE
	idstation station.id_station%TYPE;
BEGIN
	idstation := (SELECT station.id_station FROM station WHERE station.name_station=namestation);
	RAISE NOTICE 'idstation: %', idstation;
	
	if (idstation is not null) then
		INSERT INTO measurement(temperature, humidity, pressure, uv_radiation, wind_vel, wind_dir, rain_mm, rain_intensity, id_station)
			VALUES(temp, hum, pres, uvrad, windvel, winddir, rainmm, rainintensity, idstation);
	else
		raise exception 'Revise que la estacion "%" exista', namestaion;
	end if;

	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/*
==================================================================================================================================================================
functions: plan
==================================================================================================================================================================
*/


/*
==================================================================================================================================================================
functions: admin
==================================================================================================================================================================
*/

/**
==============================================================================================================================
function: weatherDataPerDay(weather_date date)
params: @param
whatdoes: Consulta los registros de mediciones segun una fecha concreta. Relacionado con el caso de uso "Check per day"
		  que extiende de "Consult weather data".
==============================================================================================================================
**/

CREATE OR REPLACE FUNCTION weatherDataPerDay(weather_date timestamp without time zone)
RETURNS SETOF measurement AS $measurements$
DECLARE measurementregister measurement%ROWTYPE;
BEGIN
	SELECT * FROM measurement WHERE measurement.date_measurement::date = weather_date::date INTO measurementregister;
	IF(measurementregister is null) THEN
		RAISE EXCEPTION 'No se encuentran registros de mediciones en la fecha %', weather_date::date;
	ELSE
		FOR measurementregister IN (SELECT * FROM measurement WHERE measurement.date_measurement::date = weather_date::date)
		LOOP
			RETURN next measurementregister;
		END LOOP;
	END IF;
END;
$measurements$ LANGUAGE plpgsql;


/**
==============================================================================================================================
function: usersSuscribedAtPlan(planname varchar)
params: @param
whatdoes: Consulta por todos los usuarios de un determinado plan. Relacionado con el caso de uso "User suscribed at plan"
==============================================================================================================================
**/

CREATE OR REPLACE FUNCTION usersSuscribedAtPlan(planname varchar)
RETURNS SETOF client AS $userdata$
DECLARE users client%ROWTYPE;
BEGIN
	FOR users IN (SELECT * FROM client WHERE client.suscribed_to_plan = upper(planname))
	LOOP
		RETURN NEXT users;
	END LOOP;
	
	SELECT * FROM client WHERE client.suscribed_to_plan = upper(planname) INTO users;
	
	IF(users is null) THEN
		RAISE EXCEPTION 'No existen usuarios con dicho plan!';
	END IF;
END;
$userdata$ LANGUAGE plpgsql;



/**
===================================================================================================================================================
function: amountUserConsults(iduser varchar)
params: @param
whatdoes: Devuelve la cantidad de consultas disponibles de un usuario (cliente) . Relacionado con el caso de uso "User suscribed at plan"
===================================================================================================================================================
**/

CREATE OR REPLACE FUNCTION amountUserConsults(iduser varchar)
RETURNS int AS $clientdata$
DECLARE clientamount int;
BEGIN
	SELECT client.available_consults FROM client WHERE client.id_client = iduser INTO clientamount;
	
	IF(clientamount is null) THEN
		RAISE EXCEPTION 'No existen usuarios con dicho plan!';
	END IF;
	
	RETURN clientamount;
END;
$clientdata$ LANGUAGE plpgsql;


/*
==================================================================================================================================================================
functions: finaluser
==================================================================================================================================================================
*/


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
					  	WHERE location.region=regionname AND location.city_name=cityname
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
=====================================================================================================================
@function: getStationdataBetweenDates
@param {varchar} startdate: start date (YYYY-MM-DD HH:MM:SS.mm)
@param {varchar} enddate: end date (YYYY-MM-DD HH:MM:SS.mm)
@param {integer} amount: amount rows
@whatdoes: devuelve todas las estaciones creadas en un intervalo de fechas [startdate; enddate].
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city_name varchar, zip_code varchar)
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
						location.city_name, location.zip_code
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
=====================================================================================================================
@function: getStationdataById
@param {varchar} idstation: id station
@whatdoes: devuelve la estacion con el id especificado.
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city_name varchar, zip_code varchar)
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
						location.city_name, location.zip_code
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
=====================================================================================================================
@function: getStationdataByCity
@param {varchar} cityname: city name
@param {integer} amount: amount rows
@whatdoes: devuelve todas las estaciones localizadas en la ciudad especificada.
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city_name varchar, zip_code varchar)
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
						location.city_name, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.city_name=cityname
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
=====================================================================================================================
@function: getStationdataByRegion
@param {varchar} regionname: region name
@param {integer} amount: amount rows
@whatdoes: devuelve todas las estaciones localizadas en la region especificada.
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city_name varchar, zip_code varchar)
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
						location.city_name, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.region=reg
						ORDER BY station.created_at ASC
						LIMIT amount)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones ubicadas en la region "%".', reg;
	end if;
	
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=====================================================================================================================
@function: getStationdataByPlace
@param {varchar} regionname: region name
@param {varchar} cityname: city name
@param {integer} amount: amount rows
@whatdoes: devuelve todas las estaciones localizadas en la region y ciudad especificada.
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city_name varchar, zip_code varchar)
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
						location.city_name, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.region=regionname
					AND location.city_name=cityname
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
=====================================================================================================================
@function: getStationdataByGeolocation
@param {double precision} lat: latitude
@param {double precision} lon: longitude
@whatdoes: devuelve la estacion localizazda en la geolocalizacion especificada.
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city_name varchar, zip_code varchar)
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
						location.city_name, location.zip_code
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
=====================================================================================================================
@function: getStationdataByZipcode
@param {varchar} zipcode: zip code
@param {integer} amount: amount rows
@whatdoes: devuelve todas las estaciones localizadas en la region con el codigo de area especificado.
@return: stationdata(id_station varchar, name_station varchar, fail bool, created_at timestamp, latitude double precision, 
		longitude double precision, country varchar, region varchar, city_name varchar, zip_code varchar)
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
						location.city_name, location.zip_code
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
==================================================================================================================================================================
functions: admin
==================================================================================================================================================================
*/

/*
==================================================================================================================================================================
functions: client
==================================================================================================================================================================
*/

/**
=====================================================================================================================
@function: upgradePlan
@param {varchar} emailadress: email adress
@param {varchar} plantosuscribe: plan to suscribe
@whatdoes: actualiza el plan actual al que esta suscripto el cliente. Incluye: actualizar suscribe_to_plan, acualizar available_consults.
@return: void
=====================================================================================================================
**/

CREATE OR REPLACE FUNCTION upgradePlan(emailadress varchar, plantosuscribe varchar) RETURNS void AS $BODY$
DECLARE
	planselected plan%ROWTYPE;
	iduser finaluser.id_finaluser%TYPE;
	currentplan varchar;
BEGIN	
	emailadress := lower(emailadress);
	plantosuscribe := upper(plantosuscribe);
	planselected := (SELECT plan FROM plan WHERE plan.description=plantosuscribe);
	if (planselected is null) then
		raise exception 'El plan "%" no esta disponible.', plantosuscribe;
	end if;
	
	iduser := (SELECT finaluser.id_finaluser FROM finaluser WHERE finaluser.email=emailadress);
	if (iduser is null) then
		raise exception 'Corrobore que el email "%" sea correcto.', emailadress;
	end if;
	
	currentplan := (SELECT client.suscribed_to_plan FROM client WHERE client.id_finaluser=iduser);
	if(currentplan=plantosuscribe) then
		raise exception 'Usted ya posee el plan "%".', plantosuscribe;
	end if;
	
	if (planselected is not null AND iduser is not null) then
		UPDATE client SET 
			suscribed_to_plan=planselected.description,
			available_consults=planselected.amount_consults
				WHERE client.id_finaluser=iduser;
	end if;

	RETURN;
END; $BODY$ LANGUAGE plpgsql;

/*
==================================================================================================================================================================
functions: apikey
==================================================================================================================================================================
*/

/*
==================================================================================================================================================================
functions: queryhistory
==================================================================================================================================================================
*/

/**
=====================================================================================================================
@function: saveInQueryHistory
@param {varchar} idcurrentuser: email
@whatdoes: añade un registro en el historial de consultas.
@return: void
=====================================================================================================================
**/

CREATE OR REPLACE FUNCTION saveInQueryHistory(idcurrentclient varchar)
RETURNS void AS $BODY$
DECLARE
	lastqueryhistory queryhistory%ROWTYPE;
	datelastquery date;
	currentdate date;
BEGIN
	lastqueryhistory := (SELECT queryhistory
		FROM queryhistory WHERE queryhistory.id_client=idcurrentclient);
	-- raise notice 'lastqueryhistory: %', lastqueryhistory; 
	
	if (lastqueryhistory is null) then
		raise exception 'Corrobore que el idcurrentclient: "%" sea el correcto.', idcurrentclient;
	end if;
	
	datelastquery := lastqueryhistory.date_query::date;
	-- raise notice 'datelastquery: %', datelastquery;
	
	currentdate := (SELECT current_timestamp::date);
	-- raise notice 'currentdate: %', currentdate;

	if (datelastquery = currentdate) then
		UPDATE queryhistory SET amount_consults=amount_consults+1
			WHERE queryhistory.id_qh=lastqueryhistory.id_qh;
	end if;
	
	if (datelastquery != currentdate) then
		INSERT INTO queryhistory(amount_consults, id_client) VALUES(1, idcurrentclient);
	end if;
	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';
