BEGIN
EXECUTE IMMEDIATE 'DROP TABLE ' || 'CallStringTypes';
EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
        RAISE;
    END IF;
END;

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE ' || 'CallNumericTypes';
EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
        RAISE;
    END IF;
END;

CREATE TABLE CallStringTypes (
       id NUMBER,
       col_char CHAR(5),
       col_nchar NCHAR(5),
       col_varchar2  VARCHAR2(255),
       col_varchar  VARCHAR(255),
       col_nvarchar2 NVARCHAR2(255),
       PRIMARY KEY (id)
);

INSERT INTO CallStringTypes(id, col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2)
       VALUES (1, 'test0', 'test1', 'test2', 'test3', 'test4');

CREATE TABLE CallNumericTypes (
       id NUMBER,
       col_number  NUMBER,
       col_float  FLOAT,
       col_binary_float BINARY_FLOAT,
       col_binary_double BINARY_DOUBLE,
       PRIMARY KEY (id)
);

INSERT INTO CallNumericTypes(
       id, col_number, col_float, col_binary_float, col_binary_double)
       VALUES (1, 2147483647, 21474.83647, 21.47483647, 21474836.47)
);

CREATE OR REPLACE PROCEDURE InsertStringData(p_id IN NUMBER,
       p_col_char IN CHAR, p_col_nchar IN NCHAR,
       p_col_varchar2 IN VARCHAR2, p_col_varchar IN VARCHAR,
       p_col_nvarchar2 IN NVARCHAR2)
       AS BEGIN
       INSERT INTO CallStringTypes(id, col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2)
       VALUES (p_id, p_col_char, p_col_nchar, p_col_varchar2, p_col_varchar, p_col_nvarchar2);
END;

CREATE OR REPLACE PROCEDURE SelectStringData(p_col_char OUT CHAR, p_col_nchar OUT NCHAR,
       p_col_varchar2 OUT VARCHAR2, p_col_varchar OUT VARCHAR, p_col_nvarchar2 OUT NVARCHAR2)
       AS BEGIN
       SELECT col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2 INTO
       p_col_char, p_col_nchar, p_col_varchar2, p_col_varchar, p_col_nvarchar2
       FROM CallStringTypes where id = 1;
END;

CREATE OR REPLACE PROCEDURE InOutStringData(p_id IN OUT NUMBER, 
       p_col_varchar2 IN OUT VARCHAR2, p_col_varchar IN OUT VARCHAR, 
       p_col_nvarchar2 IN OUT NVARCHAR2) 
       AS BEGIN 
       INSERT INTO CallStringTypes(id, col_varchar2, col_varchar, col_nvarchar2) 
       VALUES (p_id, p_col_varchar2, p_col_varchar, p_col_nvarchar2); 
       SELECT col_varchar2, col_varchar, col_nvarchar2 INTO 
       p_col_varchar2, p_col_varchar, p_col_nvarchar2 
       FROM CallStringTypes where id = 1; 
END;

CREATE OR REPLACE PROCEDURE SelectNumericDataWithOutParams(
       p_id IN NUMBER, p_col_number OUT NUMBER, p_col_float OUT FLOAT, p_col_binary_float OUT BINARY_FLOAT,
       p_col_binary_double OUT BINARY_DOUBLE)
       AS BEGIN
       SELECT col_number, col_float, col_binary_float, col_binary_double INTO
       p_col_number, p_col_float, p_col_binary_float, p_col_binary_double
       FROM CallNumericTypes where id = p_id;
END;
