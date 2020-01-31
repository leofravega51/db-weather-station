/*
=============================================================================================================================
role: developper
=============================================================================================================================
*/

CREATE ROLE developper WITH SUPERUSER CREATEDB CREATEROLE LOGIN REPLICATION ENCRYPTED PASSWORD 'developper';
GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO developper;

/*
=============================================================================================================================
role: finaluser
=============================================================================================================================
*/

CREATE ROLE finaluser WITH NOINHERIT LOGIN REPLICATION ENCRYPTED PASSWORD 'finaluser';
GRANT SELECT ON TABLE location, station, measurement, finaluser TO finaluser;
GRANT SELECT, UPDATE, DELETE ON TABLE finaluser TO finaluser;

/*
=============================================================================================================================
role: admin
=============================================================================================================================
*/

CREATE ROLE admin WITH SUPERUSER NOINHERIT LOGIN REPLICATION ENCRYPTED PASSWORD 'admin';
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE location, station, measurement, finaluser, plan, apikey, client, queryhistory TO admin;
GRANT SELECT ON TABLE administrator to admin;

/*
=============================================================================================================================
role: client
=============================================================================================================================
*/

CREATE ROLE client WITH NOINHERIT LOGIN REPLICATION ENCRYPTED PASSWORD 'client';
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE finaluser, client TO client;
GRANT SELECT, INSERT, UPDATE ON TABLE apikey, queryhistory TO client;
GRANT SELECT ON TABLE plan TO client;