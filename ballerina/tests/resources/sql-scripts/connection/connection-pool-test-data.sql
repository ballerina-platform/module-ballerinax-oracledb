CREATE TABLE PoolCustomers (
        customerId      NUMBER GENERATED ALWAYS AS IDENTITY,
        firstName       VARCHAR2(300),
        lastName        VARCHAR2(300),
        registrationID  NUMBER,
        creditLimit     FLOAT,
        country         VARCHAR2(300),
        PRIMARY KEY (customerId)
);

INSERT INTO PoolCustomers (firstName, lastName, registrationID, creditLimit, country)
        VALUES ('Peter', 'Stuart', 1, 5000.75, 'USA');

INSERT INTO PoolCustomers (firstName, lastName, registrationID, creditLimit, country)
        VALUES ('Dan', 'Brown', 2, 10000, 'UK');
