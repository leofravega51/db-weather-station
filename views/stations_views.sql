/*
==============================================================================================================================
view: stationsThatFailed
whatdoes: Devuelve todas las estaciones que fallaron al menos una vez.
==============================================================================================================================
*/

CREATE OR REPLACE VIEW stationsThatFailed AS
(
 SELECT DISTINCT m.id_station
   FROM measurement m
  WHERE m.temperature is null OR m.humidity is null OR m.pressure is null OR m.uv_radiation is null OR m.wind_vel is null 
	OR m.wind_dir is null OR m.rain_mm is null OR m.rain_intensity is null
)

/*
=============================================================================================================================
test: stationThatFailed
=============================================================================================================================

SELECT * FROM stationThatFailed
*/

/*
==============================================================================================================================
view: stationFailuredDate
whatdoes: Devuelve todas las estaciones que fallaron al menos una vez y la fecha correspondiente.
==============================================================================================================================
*/

CREATE OR REPLACE VIEW stationFailuredDate AS
(
 SELECT m.id_station, m.date_measurement::date
   FROM measurement m
  WHERE m.temperature is null OR m.humidity is null OR m.pressure is null OR m.uv_radiation is null OR m.wind_vel is null 
	OR m.wind_dir is null OR m.rain_mm is null OR m.rain_intensity is null
)

/*
=============================================================================================================================
test: stationFailuredDate
=============================================================================================================================

SELECT * FROM stationFailuredDate;

*/
