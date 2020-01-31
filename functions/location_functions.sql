/**
=====================================================================================================================
@function: registerLocation
@param {double precision} lat: latitude
@param {double precision} lon: latitude
@param {varchar} ctry: country
@param {varchar} reg: region
@param {varchar} citnm: city name
@param {varchar} zipc: zip code
@whatdoes: registra una localizacion en la que se ubicara una estacion.
@return: retorna el identificador de la estacion registrada.
=====================================================================================================================
**/

CREATE OR REPLACE FUNCTION registerLocation(lat double precision, lon double precision, ctry varchar, reg varchar, citnm varchar, zipc varchar)
RETURNS varchar AS $BODY$
DECLARE
	idlocation varchar;
BEGIN
	INSERT INTO location(latitude, longitude, country, region, city, zip_code) 
		VALUES(lat, lon, ctry, reg, citnm, zipc);
	idlocation := (SELECT location.id_location FROM location WHERE location.latitude=lat AND location.longitude=lon);
	
	-- RAISE NOTICE 'idlocation: %', idlocation;
		
	RETURN idlocation;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=============================================================================================================================
test: registerLocation()
=============================================================================================================================
*/

-- SELECT registerLocation(-33.0333, -59.0167, 'ARGENTINA', 'ENTRE RIOS', 'LARROQUE', '2854');
-- DELETE FROM location WHERE location.latitude=-33.0333 AND location.longitude=-59.0167;
