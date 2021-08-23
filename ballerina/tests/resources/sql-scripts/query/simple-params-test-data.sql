CREATE TABLE GeneralQueryTable (
        id              NUMBER,
        col_number      NUMBER,
        col_varchar2    VARCHAR2(4000),
        PRIMARY KEY (id)
);

CREATE TABLE NumericSimpleQueryTable (
        id NUMBER,
        col_number NUMBER,
        col_float FLOAT,
        col_binary_float BINARY_FLOAT,
        col_binary_double BINARY_DOUBLE,
        PRIMARY KEY (id)
);

CREATE TABLE CharSimpleQueryTable (
        id              NUMBER,
        col_varchar2    VARCHAR2(4000),
        col_varchar     VARCHAR(4000),
        col_nvarchar2   NVARCHAR2(2000),
        col_char        CHAR(2000),
        col_nchar       NCHAR(1000),
        PRIMARY KEY(id)
);

CREATE TABLE AnsiSimpleQueryTable (
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

CREATE TABLE SqlDsSimpleQueryTable (
        id                  NUMBER,
        col_character       CHARACTER(255),
        col_long_varchar    LONG VARCHAR,
        PRIMARY KEY(id)
);

CREATE TABLE LobSimpleQueryTable (
        id          NUMBER,
        col_clob    CLOB,
        col_nclob   NCLOB,
        col_blob    BLOB,
        PRIMARY KEY(id)
);

INSERT INTO GeneralQueryTable (id, col_number, col_varchar2)
    VALUES (1, -23.4, 'Hello world');

INSERT INTO NumericSimpleQueryTable (id, col_number, col_float, col_binary_float, col_binary_double)
    VALUES (1, 1, 922.337, 123.34, 123.34);

INSERT INTO CharSimpleQueryTable (id, col_varchar2, col_varchar, col_nvarchar2, col_char, col_nchar)
    VALUES (1, 'Hello world', 'Hello world', 'Hello world', 'Hello world', 'Hello world');

INSERT INTO AnsiSimpleQueryTable(id, col_character, col_character_var, col_national_character,
            col_national_char, col_national_character_var, col_national_char_var, col_nchar_var, col_numeric,
            col_decimal, col_integer, col_int, col_smallint, col_float, col_double_precision, col_real)
    VALUES (1, 'Hello world', 'Hello world', 'Hello world', 'Hello world', 'Hello world', 'Hello world',
            'Hello world', 1234134, 1234134, 1234134, 1234134, 1234134, 1234.134, 1234.134, 1234.134);

INSERT INTO SqlDsSimpleQueryTable(id, col_character, col_long_varchar)
    VALUES (1, 'Hello world', 'Hello world');

INSERT INTO LobSimpleQueryTable(id, col_clob, col_nclob, col_blob)
    VALUES (1, 'Hello world', 'Hello world', 'AB34EFC234');
