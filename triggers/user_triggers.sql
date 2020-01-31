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
=============================================================================================================================
test: finaluserToUpper()
=============================================================================================================================
*/

-- INSERT INTO finaluser(email, first_name, last_name, birthdate) VALUES('asd@gmail.com', 'asd', 'asd', '06/08/1992');
-- SELECT fu finaluser FROM finaluser fu WHERE fu.email=SOME(SELECT fu.email FROM finaluser fu WHERE fu.email='asd@gmail.com');
-- DELETE FROM finaluser WHERE email='asd@gmail.com';