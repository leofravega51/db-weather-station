/*
=============================================================================================================================
role: client
=============================================================================================================================
*/

CREATE ROLE client WITH NOINHERIT LOGIN REPLICATION ENCRYPTED PASSWORD 'client';
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE finaluser, client TO client;
GRANT SELECT, INSERT, UPDATE ON TABLE apikey, queryhistory TO client;
GRANT SELECT ON TABLE plan TO client;