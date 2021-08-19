CREATE TABLE NumericTypesTable (
        id                  NUMBER,
        col_number          NUMBER,
        col_float           FLOAT,
        col_binary_float    BINARY_FLOAT,
        col_binary_double   BINARY_DOUBLE,
        PRIMARY KEY (id)
);

INSERT INTO NumericTypesTable (id, col_number, col_float, col_binary_float, col_binary_double)
        VALUES(1, 1, 922.337, 123.34, 123.34);

INSERT INTO NumericTypesTable (id, col_number, col_float, col_binary_float, col_binary_double)
        VALUES(2, 2, 922.337, 123.34, 123.34);

CREATE TABLE CharTypesTable(
        id              NUMBER,
        col_varchar2    VARCHAR2(4000),
        col_varchar     VARCHAR2(4000),
        col_nvarchar2   NVARCHAR2(2000),
        col_char        CHAR(2000),
        col_nchar       NCHAR(1000),
        PRIMARY KEY(id)
);

CREATE TABLE AnsiTypesTable(
        id                          NUMBER,
        col_character               CHARACTER(256),
        col_character_var           CHARACTER VARYING(256),
        col_national_character      NATIONAL CHARACTER(256),
        col_national_char           NATIONAL CHAR(256),
        col_national_character_var  NATIONAL CHARACTER VARYING(256),
        col_national_char_var       NATIONAL CHAR VARYING(256),
        col_nchar_var               NCHAR VARYING(256),
        col_numeric                 NUMERIC,
        col_decimal                 DECIMAL,
        col_integer                 INTEGER,
        col_int                     INT,
        col_smallint                SMALLINT,
        col_float                   FLOAT,
        col_double_precision        DOUBLE PRECISION,
        col_real                    REAL,
        PRIMARY KEY(id)
);

CREATE TABLE SqlDsTypesTable(
        id                  NUMBER,
        col_character       CHARACTER(255),
        col_long_varchar    LONG VARCHAR,
        PRIMARY KEY(id)
);

CREATE TABLE LobTypesTable(
        id          NUMBER,
        col_clob    CLOB,
        col_nclob   NCLOB,
        col_blob    BLOB,
        PRIMARY KEY(id)
);
