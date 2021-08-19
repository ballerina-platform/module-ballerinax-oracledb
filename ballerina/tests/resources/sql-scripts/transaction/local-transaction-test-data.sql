CREATE TABLE LocalTranCustomers(
        id              NUMBER GENERATED ALWAYS AS IDENTITY,
        firstName       VARCHAR2(100),
        lastName        VARCHAR2(100),
        registrationID  NUMBER,
        creditLimit     VARCHAR2(100),
        country         VARCHAR2(100),
        PRIMARY KEY (id)
);
