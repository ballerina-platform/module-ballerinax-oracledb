CREATE TABLE Customers(
    customerId NUMBER,
    name  VARCHAR(300),
    creditLimit DOUBLE PRECISION,
    country  VARCHAR(300)
);

CREATE TABLE CustomersTrx(
    customerId INTEGER,
    name  VARCHAR(300),
    creditLimit DOUBLE PRECISION,
    country  VARCHAR(300),
    PRIMARY KEY (customerId)
);

INSERT INTO CustomersTrx VALUES (30, 'Oliver', 200000, 'UK');
