/*
=====================================================================================================================
trigger: locationToUpper()
whatdoes: pasa a mayusculas los atributos country, region, city.
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION locationToUpper() RETURNS TRIGGER AS $funcemp$
BEGIN
	new.country := upper(new.country);
	new.region := upper(new.region);
	new.city := upper(new.city);
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER locationToUpper BEFORE INSERT OR UPDATE ON location FOR EACH ROW EXECUTE PROCEDURE locationToUpper();

/*
=============================================================================================================================
test: locationToUpper()
=============================================================================================================================
*/

-- INSERT INTO INSERT INTO location (latitude, longitude, country, region, city, zip_code) VALUES (-33.0333, -59.0167, 'ARGENTINA', 'ENTRE RIOS', 'LARROQUE', 2854);
-- SELECT location FROM location WHERE location.latitude=-33.0333, location.longitude=-59.0167;
-- DELETE FROM location WHERE  WHERE location.latitude=-33.0333, location.longitude=-59.0167;