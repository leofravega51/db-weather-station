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
=============================================================================================================================
test: planToUpper()
=============================================================================================================================
*/

-- INSERT INTO plan(description, price, amount_consults) VALUES('full', 150.55, 100000000);
-- SELECT * FROM plan WHERE plan.description='FULL';
-- DELETE FROM plan WHERE plan.description='FULL';
