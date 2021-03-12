-- CREATE DATABASE IF NOT EXISTS BATCH_EXECUTE_DB;

-- USE BATCH_EXECUTE_DB;

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE ' || 'Customers';
EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
        RAISE;
    END IF;
END;

CREATE TABLE DataTable(
  id NUMBER GENERATED ALWAYS AS IDENTITY,
  col_number NUMBER UNIQUE,
  col_float FLOAT,
  col_binary_float BINARY_FLOAT,
  col_binary_double BINARY_DOUBLE,
  PRIMARY KEY (id)
);

INSERT INTO DataTable (col_number, col_float, col_binary_float, col_binary_double)
  VALUES(1, 9223372036854774807, 123.34, 123.34, 123.34);


INSERT INTO DataTable (col_number, col_float, col_binary_float, col_binary_double)
  VALUES(2, 9372036854774807, 123.34, 123.34, 123.34);

