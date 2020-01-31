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
=============================================================================================================================
test: signUpAsAdmin()
=============================================================================================================================
*/

-- INSERT INTO finaluser (email, first_name, last_name, birthdate) VALUES('asd@gmail.com', 'asd', 'asd', '06/08/1992');
-- SELECT * FROM administrator a, finaluser f WHERE a.id_finaluser=f.id_finaluser AND f.email='asd@gmail.com';
-- DELETE FROM finaluser WHERE email='asd@gmail.com';