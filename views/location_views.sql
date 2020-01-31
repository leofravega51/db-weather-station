/*
==============================================================================================================================
view: locationsMoreThanOneStation
whatdoes: devuelve las localidades que tienen mas de una estación.
==============================================================================================================================
*/

CREATE OR REPLACE VIEW locationsMoreThanOneStation  AS
(
 SELECT DISTINCT l.country, l.region, l.city FROM location l, location lcopy, station s
	WHERE l.id_location=s.id_location AND l.id_location!=lcopy.id_location AND l.latitude!=lcopy.latitude AND l.longitude!=lcopy.longitude
		AND l.country=lcopy.country AND l.region=lcopy.region AND l.city=lcopy.city
)

/*
=============================================================================================================================
test: 
=============================================================================================================================

SELECT * FROM locationsMoreThanOneStation

*/
