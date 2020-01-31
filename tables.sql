/*
=================================================================================================
extensions
=================================================================================================
*/
CREATE EXTENSION IF NOT EXISTS pgcrypto;

/*
=================================================================================================
location Table
=================================================================================================
*/

CREATE TABLE public.location
(
    id_location varchar UNIQUE DEFAULT 
		REPLACE(substring(cast(gen_random_uuid() as text) from 0 for 15), '-', ''),
    latitude double precision UNIQUE NOT NULL,
    longitude double precision UNIQUE NOT NULL,
    country varchar NOT NULL,
	region varchar NOT NULL,
    city varchar NOT NULL,
    zip_code varchar(4) NOT NULL,
    CONSTRAINT PK_location PRIMARY KEY (id_location)
);

/*
=================================================================================================
station Table
=================================================================================================
*/

CREATE TABLE public.station
(
    id_station varchar UNIQUE DEFAULT 
		REPLACE(substring(cast(gen_random_uuid() as text) from 0 for 15), '-', ''),
    name_station varchar UNIQUE NOT NULL,
    fail boolean DEFAULT false,
    created_at timestamp (0) WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    id_location varchar NOT NULL,
    CONSTRAINT PK_station PRIMARY KEY (id_station),
    CONSTRAINT FK_location FOREIGN KEY (id_location)
        REFERENCES public.location (id_location)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

/*
=================================================================================================
measurement Table
=================================================================================================
*/

CREATE TABLE public.measurement
(
    id_measurement varchar UNIQUE DEFAULT 
		REPLACE(substring(cast(gen_random_uuid() as text) from 0 for 15), '-', ''),
    date_measurement timestamp (0) WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    temperature double precision,
    humidity double precision,
    pressure double precision,
    uv_radiation double precision,
    wind_vel double precision,
    wind_dir double precision,
    rain_mm double precision,
    rain_intensity integer,
    id_station varchar NOT NULL,
    CONSTRAINT PK_measurement PRIMARY KEY (id_measurement),
    CONSTRAINT FK_station FOREIGN KEY (id_station)
        REFERENCES public.station (id_station)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

/*
=================================================================================================
plan Table
=================================================================================================
*/

CREATE TABLE public.plan(
    description varchar UNIQUE NOT NULL DEFAULT 'BASIC',
    price double precision NOT NULL,
    amount_consults integer NOT NULL,
	CONSTRAINT PK_plan PRIMARY KEY (description)
);

/*
=================================================================================================
finaluser Table
=================================================================================================
*/

CREATE TABLE public.finaluser(
    id_finaluser varchar UNIQUE DEFAULT
		REPLACE(substring(cast(gen_random_uuid() as text) from 0 for 15), '-', ''),
    email varchar UNIQUE NOT NULL CHECK(email LIKE('%@%.%')),
    first_name varchar NOT NULL,
    last_name varchar NOT NULL,
    profile_picture varchar,
    birthdate date NOT NULL CHECK((date_part('year', age(birthdate)) >= 18) AND (date_part('year', age(birthdate)) <= 122)),
    CONSTRAINT PK_user PRIMARY KEY (id_finaluser)
);

/*
=================================================================================================
administrator Table
=================================================================================================
*/

CREATE TABLE public.administrator(
    id_administrator varchar UNIQUE DEFAULT 
		REPLACE(substring(cast(gen_random_uuid() as text) from 0 for 15), '-', ''),
    id_finaluser varchar NOT NULL,
    CONSTRAINT PK_administrator PRIMARY KEY (id_administrator),
    CONSTRAINT FK_user FOREIGN KEY (id_finaluser) REFERENCES public.finaluser(id_finaluser)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

/*
=================================================================================================
client Table
=================================================================================================
*/

CREATE TABLE public.client(
    id_client varchar UNIQUE DEFAULT 
		REPLACE(substring(cast(gen_random_uuid() as text) from 0 for 15), '-', ''),
    available_consults smallint NOT NULL,
    suscribed_to_plan varchar NOT NULL,
    id_finaluser varchar NOT NULL,
    CONSTRAINT PK_client PRIMARY KEY (id_client),
    CONSTRAINT FK_plan FOREIGN KEY (suscribed_to_plan) REFERENCES public.plan(description),
    CONSTRAINT FK_finaluser FOREIGN KEY (id_finaluser) REFERENCES public.finaluser(id_finaluser)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

/*
=================================================================================================
apikey Table
=================================================================================================
*/

CREATE TABLE public.apikey(
    id_apikey varchar UNIQUE DEFAULT gen_random_uuid(),
    name_apikey varchar DEFAULT ('DEFAULT'),
	id_client varchar NOT NULL,
    CONSTRAINT PK_apikey PRIMARY KEY (id_apikey),
	CONSTRAINT FK_client FOREIGN KEY (id_client) REFERENCES public.client(id_client)
	ON UPDATE CASCADE
    ON DELETE CASCADE
);

/*
=================================================================================================
queryhistory Table
=================================================================================================
*/

CREATE TABLE public.queryhistory(
    id_qh varchar UNIQUE DEFAULT 
		REPLACE(substring(cast(gen_random_uuid() as text) from 0 for 15), '-', ''),
    amount_consults int DEFAULT 0,
    date_query timestamp (0) WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    id_client varchar NOT NULL,
    CONSTRAINT PK_queryhistory PRIMARY KEY (id_qh),
    CONSTRAINT FK_client FOREIGN KEY (id_client) REFERENCES public.client(id_client)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

/**
DROP TABLE location CASCADE;
DROP TABLE station CASCADE;
DROP TABLE measurement CASCADE;
DROP TABLE administrator CASCADE;
DROP TABLE apikey CASCADE;
DROP TABLE client CASCADE;
DROP TABLE plan CASCADE;
DROP TABLE queryhistory CASCADE;
DROP TABLE finaluser CASCADE;
DROP EXTENSION pgcrypto;
*/
