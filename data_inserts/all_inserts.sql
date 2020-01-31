/*
=============================================================================================================================
insert on: station/location
=============================================================================================================================
*/

SELECT registerStation('BASE LARROQUE', -33.0333, -59.0167, 'ARGENTINA', 'ENTRE RIOS', 'LARROQUE', '2854');
SELECT registerStation('BASE CONCEPCION DEL URUGUAY', -32.4833, -58.2283, 'ARGENTINA', 'ENTRE RIOS', 'CONCEPCION DEL URUGUAY', '3260');
SELECT registerStation('BASE GUALEGUAYCHU', -33.0103, -58.6436, 'ARGENTINA', 'ENTRE RIOS', 'GUALEGUAYCHU', '2820');
SELECT registerStation('BASE CONCORDIA', -31.4, -58.0333, 'ARGENTINA', 'ENTRE RIOS', 'CONCORDIA', '3200');
SELECT registerStation('BASE CORRIENTES', -27.4667, -58.8333, 'ARGENTINA', 'CORRIENTES', 'CORRIENTES', '3400');
SELECT registerStation('BASE BARRIO ALTO PALERMO', -31.3667, -64.2167, 'ARGENTINA', 'BUENOS AIRES', 'BARRIO ALTO PALERMO', '5009');
SELECT registerStation('BASE VILLAGUAY', -58.4666, -31.3500, 'ARGENTINA', 'ENTRE RIOS', 'VILLAGUAY', '3240');
SELECT registerStation('BASE BASAVILBASO', -32.3667, -58.8833, 'ARGENTINA', 'ENTRE RIOS', 'BASAVILBASO', '3170');
SELECT registerStation('BASE SANTA FE', -31.6333, -60.7, 'ARGENTINA', 'ENTRE RIOS', 'SANTA FE', '3000');
SELECT registerStation('BASE PARANA', -31.7333, -60.5333, 'ARGENTINA', 'ENTRE RIOS', 'PARANA', '3100');

/*
=============================================================================================================================
insert on: measurement
=============================================================================================================================
*/

SELECT registerMeasurement(21.22, 67.96, 32.59, 38.88, 87.93, 89.63, 10.0, 9, 'BASE LARROQUE');
SELECT registerMeasurement(11.01, 29.53, 77.91, 79.99, 50.65, 39.71, 4.0, 67, 'BASE CONCEPCION DEL URUGUAY');
SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE GUALEGUAYCHU');
SELECT registerMeasurement(14.45, 7.88, 61.73, 56.51, 89.79, 53.53, 24.0, 15, 'BASE CONCORDIA');
SELECT registerMeasurement(47.58, 16.73, 21.56, 41.36, 34.68, 20.97, 40.0, 69, 'BASE CORRIENTES');
SELECT registerMeasurement(49.99, 63.26, 67.07, 61.40, 91.12, 16.97, 4.0, 14, 'BASE BARRIO ALTO PALERMO');
SELECT registerMeasurement(24.72, 90.18, 32.17, 76.49, 97.23, 51.46, 65.0, 19, 'BASE VILLAGUAY');
SELECT registerMeasurement(-14.46, 98.95, 24.22, 72.12, 53.10, 59.44, 95.0, 35, 'BASE BASAVILBASO');
SELECT registerMeasurement(2.75, 36.84, 42.81, 37.00, 16.13, 90.18, 77.0, 41, 'BASE SANTA FE');
SELECT registerMeasurement(-3.83, 70.17, 21.39, 13.41, 3.19, 62.78, 11.0, 74, 'BASE PARANA');

SELECT registerMeasurement(21.22, 67.96, 32.59, null, 87.93, 89.63, 10.0, 9, 'BASE LARROQUE');
SELECT registerMeasurement(11.01, 29.53, 77.91, 79.99, 50.65, null, 4.0, 67, 'BASE CONCEPCION DEL URUGUAY');
SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, null, 60, 'BASE GUALEGUAYCHU');
SELECT registerMeasurement(14.45, 7.88, null, null, 89.79, 53.53, 24.0, 15, 'BASE CONCORDIA');
SELECT registerMeasurement(47.58, 16.73, 21.56, 41.36, 34.68, 20.97, 40.0, null, 'BASE CORRIENTES');
SELECT registerMeasurement(null, 63.26, 67.07, 61.40, 91.12, 16.97, 4.0, 14, 'BASE BARRIO ALTO PALERMO');
SELECT registerMeasurement(24.72, null, 32.17, 76.49, 97.23, 51.46, 65.0, 19, 'BASE VILLAGUAY');
SELECT registerMeasurement(-14.46, 98.95, 24.22, 72.12, 53.10, 59.44, 95.0, null, 'BASE BASAVILBASO');
SELECT registerMeasurement(2.75, null, 42.81, null, 16.13, 90.18, 77.0, 41, 'BASE SANTA FE');
SELECT registerMeasurement(-3.83, 70.17, 21.39, 13.41, 3.19, null, 11.0, 74, 'BASE PARANA');

SELECT registerMeasurement(21.22, 67.96, 32.59, 38.88, 87.93, 89.63, 10.0, 9, 'BASE LARROQUE');
SELECT registerMeasurement(11.01, 29.53, 77.91, 79.99, 50.65, 39.71, 4.0, 67, 'BASE CONCEPCION DEL URUGUAY');
SELECT registerMeasurement(1.89, 62.32, 43.99, 55.32, 34.80, 73.28, 96.0, 60, 'BASE GUALEGUAYCHU');
SELECT registerMeasurement(14.45, 7.88, 61.73, 56.51, 89.79, 53.53, 24.0, 15, 'BASE CONCORDIA');
SELECT registerMeasurement(47.58, 16.73, 21.56, 41.36, 34.68, 20.97, 40.0, 69, 'BASE CORRIENTES');
SELECT registerMeasurement(49.99, 63.26, 67.07, 61.40, 91.12, 16.97, 4.0, 14, 'BASE BARRIO ALTO PALERMO');
SELECT registerMeasurement(24.72, 90.18, 32.17, 76.49, 97.23, 51.46, 65.0, 19, 'BASE VILLAGUAY');
SELECT registerMeasurement(-14.46, 98.95, 24.22, 72.12, 53.10, 59.44, 95.0, 35, 'BASE BASAVILBASO');
SELECT registerMeasurement(2.75, 36.84, 42.81, 37.00, 16.13, 90.18, 77.0, 41, 'BASE SANTA FE');
SELECT registerMeasurement(-3.83, 70.17, 21.39, 13.41, 3.19, 62.78, 11.0, 74, 'BASE PARANA');

/*
=============================================================================================================================
insert on: plan
=============================================================================================================================
*/

INSERT INTO plan(description, price, amount_consults) VALUES('BASIC', 0, 50);
INSERT INTO plan(description, price, amount_consults) VALUES('INTERMEDIATE', 5.00, 300);
INSERT INTO plan(description, price, amount_consults) VALUES('PREMIUM', 15.00, 2147483647);

/*
=============================================================================================================================
insert on: finaluser (insertar con rol client)
=============================================================================================================================
*/

INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('andywarol@gmail.com', 'ANDY', 'WAROL', '06/08/1928');
INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('brianjones@gmail.com', 'BRIAN', 'JONES', '28/02/1942');
INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('cristianoronaldo@gmail.com', 'CRISTIANO', 'RONALDO', '05/02/1985');
INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('davidcopperfield@gmail.com', 'DAVID', 'COPPERFIELD', '16/09/1956');
INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('eugeniasilva@gmail.com', 'EUGENIA', 'SILVA', '13/01/1976');
INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('francocafferata@gmail.com', 'FRANCO', 'CAFFERATA', '13/08/1926');
INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('gloriastefan@gmail.com', 'GLORIA', 'ESTEFAN', '01/09/1957');
INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('hugosanchez@gmail.com', 'HUGO', 'SANCHEZ', '11/07/1958');
INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('isabellarossellini@gmail.com', 'ISABELLA', 'RESSELLINI', '18/06/1952');
INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('jenniferhweitt@gmail.com', 'JENNIFER', 'HEWITT', '21/02/1979');

/*
=============================================================================================================================
insert on: admin (insertar con rol developper)
=============================================================================================================================
*/

INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('belwalterv@gmail.com', 'WALTER', 'BEL', '21/02/1979');
INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('fravegaleandro@gmail.com', 'LEANDRO', 'FRAVEGA', '21/02/1979');
INSERT INTO finaluser (email, first_name, last_name, birthdate)	VALUES('leandrojaviercepeda@gmail.com', 'LEANDRO', 'CEPEDA', '21/02/1979');

