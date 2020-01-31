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
=============================================================================================================================
test: generateDefaultApikey()
=============================================================================================================================
*/

-- INSERT INTO finaluser (email, first_name, last_name, birthdate) VALUES('asd@gmail.com', 'asd', 'asd', '06/08/1992');
-- SELECT * FROM apikey WHERE apikey.id_client=SOME(SELECT c.id_client FROM client c, finaluser f WHERE c.id_finaluser=f.id_finaluser AND f.email='asd@gmail.com');
-- DELETE FROM finaluser WHERE email='asd@gmail.com';

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
=============================================================================================================================
test: apikeyToUpper()
=============================================================================================================================
*/

-- INSERT INTO finaluser (email, first_name, last_name, birthdate) VALUES('asd@gmail.com', 'asd', 'asd', '06/08/1992');
-- UPDATE apikey SET name_apikey = 'weatherstation-app' WHERE apikey.id_client=SOME(SELECT c.id_client FROM client c, finaluser f WHERE c.id_finaluser=f.id_finaluser AND f.email='asd@gmail.com');
-- SELECT * FROM apikey WHERE apikey.id_client=SOME(SELECT c.id_client FROM client c, finaluser f WHERE c.id_finaluser=f.id_finaluser AND f.email='asd@gmail.com');
-- DELETE FROM finaluser WHERE email='asd@gmail.com';
