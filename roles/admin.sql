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
role: developper
=============================================================================================================================
*/

CREATE ROLE developper WITH SUPERUSER CREATEDB CREATEROLE LOGIN REPLICATION ENCRYPTED PASSWORD 'developper';
GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO developper;
