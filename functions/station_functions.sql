/**
=====================================================================================================================
@function: registerStation
@param {varchar} name: name station
@param {double precision} latitude: latitude
@param {double precision} longitude: latitude
@param {varchar} country: country
@param {varchar} region: region
@param {varchar} cityname: city name
@param {varchar} zipcode: zip code
@whatdoes: registra una estacion en la localizacion indicada.
@return: retorna el identificador de la estacion registrada.
=====================================================================================================================
**/

CREATE OR REPLACE FUNCTION registerStation(namestation varchar, latitude double precision, longitude double precision, country varchar, region varchar, cityname varchar, zipcode varchar)
RETURNS varchar AS $BODY$
DECLARE
	idlocation varchar;
	idstation varchar;
BEGIN
	idlocation := (SELECT registerLocation(latitude, longitude, country, region, cityname, zipcode));
	
	INSERT INTO station(name_station, id_location)
		VALUES(namestation, idlocation);
 
	idstation := (SELECT station.id_station FROM station WHERE station.name_station=namestation);
	RAISE NOTICE 'idstation: %', idstation;
				   
	RETURN idstation;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=============================================================================================================================
test: registerStation()
=============================================================================================================================
*/

-- SELECT registerStation('base gualeguaychu', -33.0333, -59.0167, 'ARGENTINA', 'ENTRE RIOS', 'LARROQUE', '2854');
-- DELETE FROM location WHERE location.latitude=-33.0333 AND location.longitude=-59.0167;
-- DELETE FROM station WHERE station.name_station='BASE GUALEGUAYCHU';