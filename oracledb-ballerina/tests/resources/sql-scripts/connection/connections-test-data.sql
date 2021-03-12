-- CREATE DATABASE IF NOT EXISTS CONNECT_DB;

-- USE CONNECT_DB;

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE ' || 'Customers';
EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
        RAISE;
    END IF;
END;

CREATE TABLE Customers(
          customerId NUMBER GENERATED ALWAYS AS IDENTITY,
          firstName  VARCHAR2(300),
          lastName  VARCHAR2(300),
          registrationID NUMBER,
          creditLimit FLOAT,
          country  VARCHAR2(300),
          PRIMARY KEY (customerId)
);

INSERT INTO Customers (firstName,lastName,registrationID,creditLimit,country)
                VALUES ('Peter', 'Stuart', 1, 5000.75, 'USA');
