/*
==============================================================================================================================
view: customersConsultLastWeek
whatdoes: Devuelve todos los clientes que hicieron consultas la ultima semana.
==============================================================================================================================
*/

CREATE OR REPLACE VIEW customersConsultLastWeek AS
(
 SELECT qh.id_client
 FROM client c, queryhistory qh
 WHERE c.id_client = qh.id_client 
	AND qh.date_query::date > (current_date::date - integer '7') AND qh.date_query::date < (current_date::date)
)

/*
=============================================================================================================================
test: customersConsultLastWeek
=============================================================================================================================

SELECT * FROM customersConsultLastWeek

*/
