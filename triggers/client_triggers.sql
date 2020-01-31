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
=============================================================================================================================
test: signUpAsClient()
=============================================================================================================================
*/

-- INSERT INTO finaluser (email, first_name, last_name, birthdate) VALUES('asd@gmail.com', 'asd', 'asd', '06/08/1992');
-- SELECT c FROM client c, finaluser f WHERE c.id_finaluser=f.id_finaluser AND f.email='asd@gmail.com';
-- DELETE FROM finaluser WHERE email='asd@gmail.com';

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
=============================================================================================================================
test: signUpAsClient()
=============================================================================================================================
*/

-- INSERT INTO finaluser (email, first_name, last_name, birthdate) VALUES('asd@gmail.com', 'asd', 'asd', '06/08/1992');
-- SELECT c FROM client c, finaluser f WHERE c.id_finaluser=f.id_finaluser AND f.email='asd@gmail.com';
-- SELECT saveInQueryHistory('idclient');
-- SELECT * FROM queryhistory WHERE queryhistory.id_client='idclient';
-- DELETE FROM finaluser WHERE email='asd@gmail.com';