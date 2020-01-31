/*
=============================================================================================================================
role: finaluser
=============================================================================================================================
*/

CREATE ROLE finaluser WITH NOINHERIT LOGIN REPLICATION ENCRYPTED PASSWORD 'finaluser';
GRANT SELECT ON TABLE location, station, measurement, finaluser TO finaluser;
GRANT SELECT, UPDATE, DELETE ON TABLE finaluser TO finaluser;