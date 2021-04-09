BEGIN
EXECUTE IMMEDIATE 'DROP TABLE ' || 'TestExecuteTable';
EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
        RAISE;
    END IF;
END;

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


CREATE TABLE TestExecuteTable(field NUMBER, field2 VARCHAR2(255));
    
CREATE TABLE TestCharacterTable(
    id NUMBER,
    col_char CHAR(4),
    col_nchar NCHAR(4),
    col_varchar2  VARCHAR2(4000),
    col_varchar  VARCHAR2(4000),
    col_nvarchar2 NVARCHAR2(2000),
    PRIMARY KEY(id)
);

CREATE TABLE TestNumericTable(
    id NUMBER GENERATED ALWAYS AS IDENTITY,
    col_number  NUMBER,
    col_float  FLOAT,
    col_binary_float BINARY_FLOAT, 
    col_binary_double BINARY_DOUBLE,
    PRIMARY KEY(id)
);
