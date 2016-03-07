CREATE DATABASE keypass;

CREATE OR REPLACE USER 'AMpap'@'172.17.0.%' IDENTIFIED BY 'AMpap',
                       'AMpdp'@'172.17.0.%' IDENTIFIED BY 'AMpdp';

GRANT ALL ON *.* TO 'AMpap'@'172.17.0.%';
GRANT SELECT ON keypass.* TO 'AMpdp'@'172.17.0.%';
COMMIT;
