CREATE TABLE CallStringTypes (
        id              NUMBER,
        col_char        CHAR(5),
        col_nchar       NCHAR(5),
        col_varchar2    VARCHAR2(255),
        col_varchar     VARCHAR(255),
        col_nvarchar2   NVARCHAR2(255),
        PRIMARY KEY (id)
);

INSERT INTO CallStringTypes (id, col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2)
        VALUES (1, 'test0', 'test1', 'test2', 'test3', 'test4');

CREATE TABLE CallNumericTypes (
        id                  NUMBER,
        col_number          NUMBER,
        col_float           FLOAT,
        col_binary_float    BINARY_FLOAT,
        col_binary_double   BINARY_DOUBLE,
        PRIMARY KEY (id)
);

INSERT INTO CallNumericTypes (id, col_number, col_float, col_binary_float, col_binary_double)
        VALUES (1, 2147483647, 21474.83647, 21.47483647, 21474836.47);

CREATE TABLE CallComplexTypes (
        id      NUMBER,
        col_xml XMLType,
        PRIMARY KEY (id)
);

INSERT INTO CallComplexTypes (id, col_xml)
        VALUES(1, XMLType('<key>value</key>'));

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH:MI:SS AM';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'DD-MON-YYYY HH:MI:SS AM TZR';

CREATE TABLE CallDateTimeTypes(
        id                          NUMBER,
        col_date                    DATE,
        col_date_only               DATE,
        col_timestamp               TIMESTAMP,
        col_timestamptz             TIMESTAMP WITH TIME ZONE,
        col_interval_year_to_month  INTERVAL YEAR TO MONTH,
        col_interval_day_to_second  INTERVAL DAY TO SECOND,
        PRIMARY KEY(id)
);

INSERT INTO CallDateTimeTypes(ID, COL_DATE, COL_DATE_ONLY, COL_TIMESTAMP, COL_TIMESTAMPTZ, COL_INTERVAL_YEAR_TO_MONTH,
                COL_INTERVAL_DAY_TO_SECOND)
        VALUES (1, '05-JAN-2020 10:35:10 AM','05-JAN-2020','05-JAN-2020 10:35:10 AM',
                    '05-JAN-2020 10:35:10 AM +05:30','15-11', '20 11:21:24.45');

CREATE OR replace PROCEDURE Insertstringdata (
        p_id            IN NUMBER,
        p_col_char      IN CHAR,
        p_col_nchar     IN NCHAR,
        p_col_varchar2  IN VARCHAR2,
        p_col_varchar   IN VARCHAR,
        p_col_nvarchar2 IN NVARCHAR2)
AS
BEGIN
        INSERT INTO callstringtypes (id, col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2)
            VALUES (p_id, p_col_char, p_col_nchar, p_col_varchar2, p_col_varchar, p_col_nvarchar2);
END;
/

CREATE OR REPLACE PROCEDURE SelectStringData (
        p_col_char      OUT CHAR,
        p_col_nchar     OUT NCHAR,
        p_col_varchar2  OUT VARCHAR2,
        p_col_varchar   OUT VARCHAR,
        p_col_nvarchar2 OUT NVARCHAR2)
AS
BEGIN
        SELECT col_char, col_nchar, col_varchar2, col_varchar, col_nvarchar2
        INTO p_col_char, p_col_nchar, p_col_varchar2, p_col_varchar, p_col_nvarchar2
        FROM CallStringTypes where id = 1;
END;
/

CREATE OR REPLACE PROCEDURE InOutStringData (
        p_id            IN OUT NUMBER,
        p_col_varchar2  IN OUT VARCHAR2,
        p_col_varchar   IN OUT VARCHAR,
        p_col_nvarchar2 IN OUT NVARCHAR2)
AS
BEGIN
        INSERT INTO CallStringTypes(id, col_varchar2, col_varchar, col_nvarchar2)
            VALUES (p_id, p_col_varchar2, p_col_varchar, p_col_nvarchar2);
        SELECT col_varchar2, col_varchar, col_nvarchar2 INTO p_col_varchar2, p_col_varchar, p_col_nvarchar2
            FROM CallStringTypes where id = 1;
END;
/

CREATE OR REPLACE PROCEDURE SelectNumericDataWithOutParams (
        p_id                IN NUMBER,
        p_col_number        OUT NUMBER,
        p_col_float         OUT FLOAT,
        p_col_binary_float  OUT BINARY_FLOAT,
        p_col_binary_double OUT BINARY_DOUBLE)
AS
BEGIN
        SELECT col_number, col_float, col_binary_float, col_binary_double INTO
        p_col_number, p_col_float, p_col_binary_float, p_col_binary_double
        FROM CallNumericTypes where id = p_id;
END;
/

CREATE OR REPLACE PROCEDURE SelectComplexDataWithOutParams (
        p_id        IN NUMBER,
        p_col_xml   OUT XMLType)
AS
BEGIN
        SELECT col_xml INTO p_col_xml FROM CallComplexTypes where id = p_id;
END;
/

CREATE OR REPLACE PROCEDURE SelectDateTimesWithOutParams(
        p_id                            IN NUMBER,
        p_col_date                      OUT DATE,
        p_col_date_only                 OUT DATE,
        p_col_timestamp                 OUT TIMESTAMP,
        p_col_timestamptz               OUT TIMESTAMP WITH TIME ZONE,
        p_col_interval_year_to_month    OUT INTERVAL YEAR TO MONTH,
        p_col_interval_day_to_second    OUT INTERVAL DAY TO SECOND)
AS
BEGIN
        SELECT col_date INTO p_col_date FROM CallDateTimeTypes where id = p_id;
        SELECT col_date_only INTO p_col_date_only FROM CallDateTimeTypes where id = p_id;
        SELECT col_timestamp INTO p_col_timestamp FROM CallDateTimeTypes where id = p_id;
        SELECT col_timestamptz INTO p_col_timestamptz FROM CallDateTimeTypes where id = p_id;
        SELECT col_interval_year_to_month INTO p_col_interval_year_to_month FROM CallDateTimeTypes where id = p_id;
        SELECT col_interval_day_to_second INTO p_col_interval_day_to_second FROM CallDateTimeTypes where id = p_id;
END;
/

CREATE OR REPLACE PACKAGE SelectStringDataWithRefCursor
AS
   PROCEDURE GET_STRING_DATA(
      oActiveCursor              OUT SYS_REFCURSOR
    );
END SelectStringDataWithRefCursor;

/

CREATE OR REPLACE PACKAGE BODY SelectStringDataWithRefCursor
AS
    PROCEDURE GET_STRING_DATA(
      oActiveCursor              OUT SYS_REFCURSOR
    )
    IS
    BEGIN
       OPEN oActiveCursor FOR
       SELECT * FROM CallStringTypes;

    END GET_STRING_DATA;
END SelectStringDataWithRefCursor;
/

CREATE OR REPLACE PACKAGE SelectSingleStringDataWithRefCursor
AS
   PROCEDURE GET_STRING_DATA_COLUMN(
      oActiveCursor              OUT SYS_REFCURSOR
    );
END SelectSingleStringDataWithRefCursor;

/

CREATE OR REPLACE PACKAGE BODY SelectSingleStringDataWithRefCursor
AS
    PROCEDURE GET_STRING_DATA_COLUMN(
      oActiveCursor              OUT SYS_REFCURSOR
    )
    IS
    BEGIN
       OPEN oActiveCursor FOR
       SELECT col_char FROM CallStringTypes;

    END GET_STRING_DATA_COLUMN;
END SelectSingleStringDataWithRefCursor;
/

CREATE OR REPLACE PACKAGE SelectStringDataWithRefCursorAndInputParam
AS
   PROCEDURE GET_STRING_DATA_WITH_INPUT(
      p_id                       IN NUMBER,
      oActiveCursor              OUT SYS_REFCURSOR
    );
END SelectStringDataWithRefCursorAndInputParam;

/

CREATE OR REPLACE PACKAGE BODY SelectStringDataWithRefCursorAndInputParam
AS
    PROCEDURE GET_STRING_DATA_WITH_INPUT(
      p_id                       IN NUMBER,
      oActiveCursor              OUT SYS_REFCURSOR
    )
    IS
    BEGIN
       OPEN oActiveCursor FOR
       SELECT * FROM CallStringTypes where id = p_id;

    END GET_STRING_DATA_WITH_INPUT;
END SelectStringDataWithRefCursorAndInputParam;
