/*
=====================================================================================================================
trigger: generateQueryhistory()
whatdoes: genera un apikey por defecto al dar de alta un cliente y se asocia al mismo.
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION generateQueryHistory() RETURNS TRIGGER AS $funcemp$
DECLARE
BEGIN	
	INSERT INTO queryhistory(id_client) VALUES(NEW.id_client);
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER generateQueryhistory AFTER INSERT ON client FOR EACH ROW EXECUTE PROCEDURE generateQueryhistory();

/*
=============================================================================================================================
test: generateQueryhistory()
=============================================================================================================================
*/

-- INSERT INTO finaluser (email, first_name, last_name, birthdate) VALUES('asd@gmail.com', 'asd', 'asd', '06/08/1992');
-- SELECT * FROM queryhistory WHERE queryhistory.id_client=SOME(SELECT c.id_client FROM client c, finaluser f WHERE c.id_finaluser=f.id_finaluser AND f.email='asd@gmail.com');
-- DELETE FROM finaluser WHERE email='asd@gmail.com';