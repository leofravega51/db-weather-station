/*
==================================================================================================================================================================
trigers: location
==================================================================================================================================================================
*/

/*
=====================================================================================================================
trigger: locationToUpper()
whatdoes: pasa a mayusculas los atributos country, region, city.
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION locationToUpper() RETURNS TRIGGER AS $funcemp$
BEGIN
	new.country := upper(new.country);
	new.region := upper(new.region);
	new.city := upper(new.city);
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER locationToUpper BEFORE INSERT OR UPDATE ON location FOR EACH ROW EXECUTE PROCEDURE locationToUpper();

/*
==================================================================================================================================================================
trigers: station
==================================================================================================================================================================
*/

/*
=====================================================================================================================
trigger: stationToUpper()
whatdoes: pasa a mayusculas el atributo name_station
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION stationToUpper() RETURNS TRIGGER AS $funcemp$
BEGIN
	new.name_station := upper(new.name_station);
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER stationToUpper BEFORE INSERT OR UPDATE ON station FOR EACH ROW EXECUTE PROCEDURE stationToUpper();

/*
=====================================================================================================================
trigger: stationStatusControl()
whatdoes: controla el estado fail de la estacion. Si una variable de medicion es nula o vacia se asume una falla.

=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION stationStatusControl() RETURNS TRIGGER AS $funcemp$
DECLARE
	fail bool;
BEGIN
	fail := (SELECT station.fail FROM station WHERE station.id_station = NEW.id_station);
	
	if ((new.temperature is null) or (new.humidity is null) or (new.pressure is null)
			or (new.uv_radiation is null) or (new.wind_vel is null) or (new.wind_dir is null)
			or (new.rain_mm is null) or (new.rain_intensity is null)) then
		UPDATE station SET fail=true WHERE station.id_station = new.id_station;
	else
		UPDATE station SET fail=false WHERE station.id_station = NEW.id_station;
	end if;
    
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER stationStatusControl BEFORE INSERT OR UPDATE ON measurement FOR EACH ROW EXECUTE PROCEDURE stationStatusControl();

/*
==================================================================================================================================================================
trigers: plan
==================================================================================================================================================================
*/

/*
=====================================================================================================================
trigger: planToUpper()
whatdoes: pasa a mayusculas el atributo description
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION planToUpper() RETURNS TRIGGER AS $funcemp$
BEGIN
	new.description := upper(new.description);
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER planToUpper BEFORE INSERT OR UPDATE ON plan FOR EACH ROW EXECUTE PROCEDURE planToUpper();

/*
==================================================================================================================================================================
trigers: finaluser
==================================================================================================================================================================
*/

/*
=====================================================================================================================
trigger: finaluserToUpper()
whatdoes: pasa a mayusculas los atributos firstname, lastname.
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION finaluserToUpper() RETURNS TRIGGER AS $funcemp$
BEGIN
	new.email := lower(new.email);
	new.first_name := upper(new.first_name);
	new.last_name := upper(new.last_name);
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER finaluserToUpper BEFORE INSERT OR UPDATE ON finaluser FOR EACH ROW EXECUTE PROCEDURE finaluserToUpper();

/*
==================================================================================================================================================================
trigers: admin
==================================================================================================================================================================
*/

/*
=====================================================================================================================
trigger: signUpAsAdmin()
whatdoes: registra un admin al dar de alta un usuario.
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION signUpAsAdmin() RETURNS TRIGGER AS $funcemp$
DECLARE
	currentuser varchar;
BEGIN
	currentuser := (SELECT current_user);
	if (currentuser = 'developper') then
		INSERT INTO administrator(id_finaluser)
			VALUES(NEW.id_finaluser);
	end if;
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER signUpAsAdmin AFTER INSERT ON finaluser FOR EACH ROW EXECUTE PROCEDURE signUpAsAdmin();

/*
==================================================================================================================================================================
trigers: client
==================================================================================================================================================================
*/

/*
=====================================================================================================================
trigger: signUpAsClient()
whatdoes: registra un cliente al dar de alta un usuario.
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION signUpAsClient() RETURNS TRIGGER AS $funcemp$
DECLARE
	planbasic plan% ROWTYPE;
	currentuser varchar;
BEGIN
	currentuser := (SELECT current_user);
	if (currentuser = 'client') then
		planbasic := (SELECT plan FROM plan WHERE plan.description='BASIC');

		INSERT INTO client(available_consults, suscribed_to_plan, id_finaluser)
			VALUES(planbasic.amount_consults, planbasic.description, NEW.id_finaluser);
	end if;
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER signUpAsClient AFTER INSERT ON finaluser FOR EACH ROW EXECUTE PROCEDURE signUpAsClient();

/*
=====================================================================================================================
trigger: availableConsultsControl()
whatdoes: controla las consultas disponibles del cliente.
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION availableConsultsControl() RETURNS TRIGGER AS $funcemp$
DECLARE
	amountcurrentplanqueries plan.amount_consults%TYPE;
	amountqueriesmade queryhistory.amount_consults%TYPE;
	availableconsults client.available_consults%TYPE;
BEGIN
	amountcurrentplanqueries := (SELECT plan.amount_consults FROM plan, client 
								 	WHERE client.id_client=new.id_client AND client.suscribed_to_plan=plan.description);
	-- raise notice 'amountcurrentplanqueries: %', amountcurrentplanqueries;
	amountqueriesmade := new.amount_consults;
	-- raise notice 'amountqueriesmade: %', amountqueriesmade;
	
	availableconsults := (SELECT client.available_consults FROM client WHERE client.id_client=new.id_client);
	-- raise notice 'availableconsults: %', availableconsults;
	
	if (availableconsults = 0) then
		raise exception 'Ha llegado a su limite de consultas.';
	else
		UPDATE client SET available_consults = amountcurrentplanqueries-amountqueriesmade
			WHERE client.id_client=new.id_client;
	end if;
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER availableConsultsControl AFTER UPDATE ON queryhistory FOR EACH ROW EXECUTE PROCEDURE availableConsultsControl();

/*
==================================================================================================================================================================
trigers: apikey
==================================================================================================================================================================
*/

/*
=====================================================================================================================
trigger: apikeyToUpper()
whatdoes: pasa a mayusculas el atributo name_apikey
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION apikeyToUpper() RETURNS TRIGGER AS $funcemp$
BEGIN
	new.name_apikey := upper(new.name_apikey);
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER apikeyToUpper BEFORE INSERT OR UPDATE ON apikey FOR EACH ROW EXECUTE PROCEDURE apikeyToUpper();

/*
=====================================================================================================================
trigger: generateDefaultApikey()
whatdoes: genera un apikey por defecto al dar de alta un cliente y se asocia al mismo.
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION generateDefaultApikey() RETURNS TRIGGER AS $funcemp$
DECLARE
BEGIN	
	INSERT INTO apikey(id_client) VALUES(NEW.id_client);
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER generateDefaultApikey AFTER INSERT ON client FOR EACH ROW EXECUTE PROCEDURE generateDefaultApikey();

/*
==================================================================================================================================================================
trigers: queryhistory
==================================================================================================================================================================
*/

/*
=====================================================================================================================
trigger: generateQueryhistory()
whatdoes: genera un registro en queryhistory por defecto y se le asocia un cliente.
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION generateQueryHistory() RETURNS TRIGGER AS $funcemp$
DECLARE
BEGIN	
	INSERT INTO queryhistory(id_client) VALUES(NEW.id_client);
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER generateQueryhistory AFTER INSERT ON client FOR EACH ROW EXECUTE PROCEDURE generateQueryhistory();


