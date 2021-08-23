CREATE TABLE DataTable (
        id NUMBER           GENERATED ALWAYS AS IDENTITY,
        col_number          NUMBER UNIQUE,
        col_float           FLOAT,
        col_binary_float    BINARY_FLOAT,
        col_binary_double   BINARY_DOUBLE,
        PRIMARY KEY (id)
);

INSERT INTO DataTable (col_number, col_float, col_binary_float, col_binary_double)
        VALUES(1, 922.337, 123.34, 123.34);

INSERT INTO DataTable (col_number, col_float, col_binary_float, col_binary_double)
        VALUES(2, 922.337, 123.34, 123.34);
