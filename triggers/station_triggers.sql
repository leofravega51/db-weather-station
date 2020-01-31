/*
=====================================================================================================================
trigger: stationToUpper()
whatdoes: pasa a mayusculas el atributo name_station
=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION stationToUpper() RETURNS TRIGGER AS $funcemp$
BEGIN
	new.name_station := upper(new.name_station);
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER stationToUpper BEFORE INSERT OR UPDATE ON station FOR EACH ROW EXECUTE PROCEDURE stationToUpper();

/*
=============================================================================================================================
test: stationToUpper()
=============================================================================================================================
*/

-- SELECT testStationToUpper();
-- DELETE FROM location WHERE location.latitude=-33.0333 AND location.longitude=-59.0167;
-- DROP FUNCTION testStationToUpper;

/*
=====================================================================================================================
trigger: stationStatusControl()
whatdoes: controla el estado fail de la estacion. Si una variable de medicion es nula o vacia se asume una falla.

=====================================================================================================================
*/

CREATE OR REPLACE FUNCTION stationStatusControl() RETURNS TRIGGER AS $funcemp$
DECLARE
	fail bool;
BEGIN
	fail := (SELECT station.fail FROM station WHERE station.id_station = NEW.id_station);
	
	if ((new.temperature is null) or (new.humidity is null) or (new.pressure is null)
			or (new.uv_radiation is null) or (new.wind_vel is null) or (new.wind_dir is null)
			or (new.rain_mm is null) or (new.rain_intensity is null)) then
		UPDATE station SET fail=true WHERE station.id_station = new.id_station;
	else
		UPDATE station SET fail=false WHERE station.id_station = NEW.id_station;
	end if;
    
	RETURN NEW;
END; $funcemp$ LANGUAGE plpgsql;

CREATE TRIGGER stationStatusControl BEFORE INSERT OR UPDATE ON measurement FOR EACH ROW EXECUTE PROCEDURE stationStatusControl();

/*
=============================================================================================================================
test: stationStatusControl()
=============================================================================================================================
*/

/**
CREATE OR REPLACE FUNCTION testStationStatusControl() RETURNS void AS $BODY$
DECLARE
	id_location varchar;
	id_station varchar;
	stationwithfail boolean;
BEGIN
	INSERT INTO location (latitude, longitude, country, region, city, zip_code) VALUES (-33.0333, -59.0167, 'ARGENTINA', 'ENTRE RIOS', 'LARROQUE', 2854);
	id_location := (SELECT location.id_location FROM location WHERE location.latitude=-33.0333 AND location.longitude=-59.0167);
	
	INSERT INTO station(name_station, id_location) VALUES('BASE TEST', id_location);
	id_station := (SELECT station.id_station FROM station WHERE station.name_station = 'BASE TEST');

	INSERT INTO measurement(temperature, pressure, uv_radiation, humidity, wind_vel, wind_dir, rain_mm, rain_intensity, id_station)
		VALUES (21.22, 67.96, 32.59, 38.88, 87.93, 89.63, 10.96, null, id_station);
	
	stationwithfail := (SELECT station.fail FROM station WHERE station.name_station='BASE TEST');
	raise notice '¿Station with fail?: %', stationwithfail;
	
	INSERT INTO measurement(temperature, pressure, uv_radiation, humidity, wind_vel, wind_dir, rain_mm, rain_intensity, id_station)
		VALUES (21.22, 67.96, 32.59, 38.88, 87.93, 89.63, 10.96, 10.1, id_station);
	
	stationwithfail := (SELECT station.fail FROM station WHERE station.name_station='BASE TEST');
	raise notice '¿Station with fail?: %', stationwithfail;

	RETURN;
END; $BODY$ LANGUAGE plpgsql;
*/

-- SELECT testStationStatusControl();
-- DELETE FROM location WHERE location.latitude=-33.0333 AND location.longitude=-59.0167;
-- DROP FUNCTION testStationStatusControl;