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

/*
=============================================================================================================================
test: weatherDataPerDay(weather_date timestamp without time zone)
=============================================================================================================================

SELECT * FROM weatherDataPerDay('2018-11-26') -> No esta en los registros.
SELECT * FROM weatherDataPerDay('2019-11-26') -> Esta en los registros.

SELECT current_timestamp;
SELECT current_timestamp::date;

*/

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

/*
=============================================================================================================================
test: usersSuscribedAtPlan(planname varchar)
=============================================================================================================================

SELECT * FROM usersSuscribedAtPlan('basic') -> Registro existente.
SELECT * FROM usersSuscribedAtPlan('Normal') -> Registro inexistente.


*/


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
=============================================================================================================================
test: amountUserConsults(iduser varchar)
=============================================================================================================================

DROP FUNCTION amountUserConsults(iduser varchar)
SELECT * FROM amountUserConsults('ab03eece80f9')

*/





