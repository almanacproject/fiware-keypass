CREATE DATABASE keypass;

CREATE OR REPLACE USER 'AMpap'@'172.%' IDENTIFIED BY '$${psst.database_pap_pw}',
                       'AMpdp'@'172.%' IDENTIFIED BY '$${psst.database_pdp_pw}';

GRANT ALL ON *.* TO 'AMpap'@'172.%';
GRANT SELECT ON keypass.* TO 'AMpdp'@'172.%';
COMMIT;
