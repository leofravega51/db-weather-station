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
=============================================================================================================================
test: upgradePlan()
=============================================================================================================================
*/

-- INSERT INTO finaluser (email, first_name, last_name, birthdate) VALUES('asd@gmail.com', 'asd', 'asd', '06/08/1992');
-- SELECT * FROM finaluser WHERE finaluser.email='asd@gmail.com';
-- SELECT client FROM client, finaluser WHERE client.id_finaluser=finaluser.id_finaluser AND finaluser.email='asd@gmail.com';
-- SELECT upgradePlan('asd@gmail.com', 'INTERMEDIATE');
-- SELECT client FROM client, finaluser WHERE client.id_finaluser=finaluser.id_finaluser AND finaluser.email='asd@gmail.com';
-- DELETE FROM finaluser WHERE finaluser.email='asd@gmail.com';