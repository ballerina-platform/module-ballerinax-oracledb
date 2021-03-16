BEGIN
EXECUTE IMMEDIATE 'DROP TABLE ' || 'TestCharacterTable';
EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
        RAISE;
    END IF;
END;

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE ' || 'TestNumericTable';
EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
        RAISE;
    END IF;
END;


CREATE TABLE TestCharacterTable(
   id NUMBER,
   col_varchar2  VARCHAR2(4000),
   col_varchar  VARCHAR2(4000),
   col_nvarchar2 NVARCHAR2(2000),
   col_char CHAR(2000),
   col_nchar NCHAR(1000),
   PRIMARY KEY(id)
);

CREATE TABLE TestNumericTable (
   id NUMBER GENERATED ALWAYS AS IDENTITY,
   col_number  NUMBER,
   col_float  FLOAT,
   col_binary_float BINARY_FLOAT,
   col_binary_double BINARY_DOUBLE,
   PRIMARY KEY(id)
);

INSERT INTO TestNumericTable (col_number) VALUES (10);

