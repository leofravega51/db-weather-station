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

/*
=============================================================================================================================
test: saveInQueryHistory()
=============================================================================================================================
*/

-- INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('andywarol@gmail.com', 'ANDY', 'WAROL', '06/08/1928'); -- Realizar insercion como rol "client"
-- SELECT client.id_client FROM client WHERE client.id_finaluser=SOME(SELECT finaluser.id_finaluser FROM finaluser WHERE finaluser.email='andywarol@gmail.com');
-- SELECT * FROM queryhistory WHERE queryhistory.id_client='b5e8f478b67c'; -- Reemplazar el id_client por el correspondiente obtenido en la query anterior
-- SELECT saveInQueryHistory('b5e8f478b67c');
-- SELECT * FROM queryhistory WHERE queryhistory.id_client='b5e8f478b67c'; -- Reemplazar el id_client por el correspondiente obtenido en la query anterior
-- DELETE FROM finaluser WHERE finaluser.email='andywarol@gmail.com';