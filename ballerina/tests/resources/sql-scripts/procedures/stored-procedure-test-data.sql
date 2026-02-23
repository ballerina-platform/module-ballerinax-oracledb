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

CREATE OR REPLACE PROCEDURE SelectStringDataWithRefCursor(
      oActiveCursor              OUT SYS_REFCURSOR,
      oUpcomingCursor            OUT SYS_REFCURSOR
    )
AS
BEGIN
       OPEN oActiveCursor FOR
       SELECT * FROM CallStringTypes;

       OPEN oUpcomingCursor FOR
       SELECT col_char FROM CallStringTypes;
END;
/

CREATE OR REPLACE PROCEDURE SelectDataWithRefCursorAndNumber(
      p_id                       IN NUMBER,
      oActiveCursor              OUT SYS_REFCURSOR
    )
AS
BEGIN
       OPEN oActiveCursor FOR
       SELECT * FROM CallStringTypes where id = p_id;

END;
/

CREATE OR REPLACE PROCEDURE ClobOutProc(p_clob_out OUT CLOB)
AS
    v_json_out   json_object_t;
    v_json_array_out json_array_t;
    v_json_inner json_object_t;
BEGIN
    v_json_out := json_object_t();
    v_json_array_out := json_array_t();
    v_json_inner := json_object_t();

    for i in 1..4000
        loop
            v_json_inner.put(key => 'i: ' || i, val =>'random string');
            v_json_array_out.append(val => v_json_inner);
            v_json_inner := json_object_t();
        end loop;
    v_json_out.put(key => 'files', val => v_json_array_out);
    p_clob_out := v_json_out.To_Clob;

END;
/

CREATE OR REPLACE FUNCTION GetStringById(p_id NUMBER)
RETURN VARCHAR2
IS
    v_result VARCHAR2(255);
BEGIN
    SELECT col_varchar2 INTO v_result FROM CallStringTypes WHERE id = p_id;
    RETURN v_result;
END;
/

CREATE OR REPLACE FUNCTION GetNumericById(p_id NUMBER)
RETURN NUMBER
IS
    v_result NUMBER;
BEGIN
    SELECT col_number INTO v_result FROM CallNumericTypes WHERE id = p_id;
    RETURN v_result;
END;
/

CREATE OR REPLACE FUNCTION GetDoubleById(p_id NUMBER)
RETURN BINARY_DOUBLE
IS
    v_result BINARY_DOUBLE;
BEGIN
    SELECT col_binary_double INTO v_result FROM CallNumericTypes WHERE id = p_id;
    RETURN v_result;
END;
/

CREATE OR REPLACE FUNCTION GetStringByIdAndType(p_id NUMBER, p_type VARCHAR2)
RETURN VARCHAR2
IS
    v_result VARCHAR2(255);
BEGIN
    IF p_type = 'varchar2' THEN
        SELECT col_varchar2 INTO v_result FROM CallStringTypes WHERE id = p_id;
    ELSIF p_type = 'char' THEN
        SELECT col_char INTO v_result FROM CallStringTypes WHERE id = p_id;
    ELSE
        v_result := NULL;
    END IF;
    RETURN v_result;
END;
/

CREATE OR REPLACE FUNCTION GetNullableStringById(p_id NUMBER)
RETURN VARCHAR2
IS
    v_result VARCHAR2(255);
BEGIN
    SELECT col_varchar2 INTO v_result FROM CallStringTypes WHERE id = p_id;
    RETURN v_result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

CREATE OR REPLACE TYPE CallResultObjectType AS OBJECT (
    STRING_ATTR VARCHAR2(255),
    INT_ATTR NUMBER,
    FLOAT_ATTR FLOAT,
    DECIMAL_ATTR NUMBER
);
/

CREATE OR REPLACE FUNCTION GetObjectById(p_id NUMBER)
RETURN CallResultObjectType
IS
    v_result CallResultObjectType;
    v_string VARCHAR2(255);
    v_number NUMBER;
    v_float FLOAT;
    v_double NUMBER;
BEGIN
    SELECT col_varchar2 INTO v_string FROM CallStringTypes WHERE id = p_id;
    SELECT col_number, col_float, col_binary_double INTO v_number, v_float, v_double
        FROM CallNumericTypes WHERE id = p_id;
    v_result := CallResultObjectType(v_string, v_number, v_float, v_double);
    RETURN v_result;
END;
/

CREATE OR REPLACE TYPE CallNullableObjectType AS OBJECT (
    ID_ATTR NUMBER,
    STRING_ATTR VARCHAR2(255),
    STATUS VARCHAR2(20)
);
/

CREATE OR REPLACE FUNCTION GetNullableObjectById(p_id NUMBER)
RETURN CallNullableObjectType
IS
    v_result CallNullableObjectType;
BEGIN
    BEGIN
        SELECT CallNullableObjectType(id, col_varchar2, NULL)
        INTO v_result
        FROM CallStringTypes WHERE id = p_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_result := NULL;
    END;
    RETURN v_result;
END;
/

CREATE TABLE CallMobileUsers (
    user_id         NUMBER,
    first_name      VARCHAR2(100),
    last_name       VARCHAR2(100),
    email           VARCHAR2(255),
    mobile_number   VARCHAR2(20),
    is_verified     VARCHAR2(5) DEFAULT 'N',
    PRIMARY KEY (user_id)
);

INSERT INTO CallMobileUsers (user_id, first_name, last_name, email, mobile_number, is_verified)
VALUES (1, 'John', 'Doe', 'john.doe@example.com', '0771234567', 'Y');

CREATE OR REPLACE TYPE MobileResultType AS OBJECT (
    USER_ID NUMBER,
    FIRST_NAME VARCHAR2(100),
    LAST_NAME VARCHAR2(100),
    EMAIL VARCHAR2(255),
    MOBILE_NUMBER VARCHAR2(20),
    STATUS VARCHAR2(20),
    IS_VERIFIED VARCHAR2(5),
    MESSAGE VARCHAR2(255)
);
/

CREATE OR REPLACE FUNCTION verify_mobile(p_mobile_number VARCHAR2)
RETURN MobileResultType
IS
    v_result MobileResultType;
    v_user_id NUMBER;
    v_first_name VARCHAR2(100);
    v_last_name VARCHAR2(100);
    v_email VARCHAR2(255);
    v_mobile_number VARCHAR2(20);
    v_is_verified VARCHAR2(5);
BEGIN
    SELECT user_id, first_name, last_name, email, mobile_number, is_verified
    INTO v_user_id, v_first_name, v_last_name, v_email, v_mobile_number, v_is_verified
    FROM CallMobileUsers
    WHERE mobile_number = p_mobile_number;

    v_result := MobileResultType(v_user_id, v_first_name, v_last_name, v_email, v_mobile_number, 'ACTIVE', v_is_verified, 'Mobile number verified successfully');
    RETURN v_result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        v_result := MobileResultType(NULL, NULL, NULL, NULL, p_mobile_number, 'NOT_FOUND', 'N', 'Mobile number not registered');
        RETURN v_result;
END;
/

CREATE OR REPLACE TYPE CallAddressType AS OBJECT (
    STREET VARCHAR2(255),
    CITY VARCHAR2(100)
);
/

CREATE OR REPLACE TYPE CallPersonType AS OBJECT (
    NAME VARCHAR2(100),
    AGE NUMBER,
    ADDRESS CallAddressType
);
/

CREATE OR REPLACE FUNCTION GetNestedObject
RETURN CallPersonType
IS
BEGIN
    RETURN CallPersonType('John Doe', 30, CallAddressType('123 Main St', 'Colombo'));
END;
/

CREATE OR REPLACE FUNCTION GetNestedObjectWithNullField
RETURN CallPersonType
IS
BEGIN
    RETURN CallPersonType('Jane Doe', 25, NULL);
END;
/
