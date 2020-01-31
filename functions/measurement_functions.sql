/**
=====================================================================================================================
@function: registerMeasurement
@param {double precision} temp: temperature
@param {double precision} hum: humidity
@param {double precision} pres: pressure
@param {double precision} uvrad: ultraviolet radiation
@param {double precision} windvel: wind velocity
@param {double precision} winddir: wind direction
@param {double precision} rainmm: rain milimeters
@param {integer} rainintensity: rain intensity
@param {varchar} namestation: name station
@whatdoes: registra una medicion realizada por una estacion.
@return: void
=====================================================================================================================
**/

CREATE OR REPLACE FUNCTION registerMeasurement(temp double precision, hum double precision, pres double precision, uvrad double precision, windvel double precision, winddir double precision, rainmm double precision, rainintensity integer, namestation varchar)
RETURNS void AS $BODY$
DECLARE
	idstation station.id_station%TYPE;
BEGIN
	idstation := (SELECT station.id_station FROM station WHERE station.name_station=namestation);
	RAISE NOTICE 'idstation: %', idstation;
	
	if (idstation is not null) then
		INSERT INTO measurement(temperature, humidity, pressure, uv_radiation, wind_vel, wind_dir, rain_mm, rain_intensity, id_station)
			VALUES(temp, hum, pres, uvrad, windvel, winddir, rainmm, rainintensity, idstation);
	else
		raise exception 'Revise que la estacion "%" exista', namestation;
	end if;

	RETURN;
END; $BODY$ LANGUAGE 'plpgsql';

/*
=============================================================================================================================
test: registerMeasurement()
=============================================================================================================================
*/

-- SELECT registerStation('base gualeguaychu', -33.0333, -59.0167, 'ARGENTINA', 'ENTRE RIOS', 'LARROQUE', '2854');
-- SELECT * FROM station WHERE station.name_station='base gualeguaychu';
-- SELECT registerMeasurement(21.22, 67.96, 67.96, 38.88, 87.93, 89.63, 10.96, 9, 'base gualeguaychu');
-- SELECT * FROM measurement;
-- DELETE FROM station WHERE station.name_station='base gualeguaychu';
-- DELETE FROM location WHERE location.latitude=-33.0333 AND location.longitude=-59.0167;

