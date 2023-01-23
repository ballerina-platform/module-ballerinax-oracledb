CREATE USER METADATAEMPTYDB IDENTIFIED BY password;
GRANT CONNECT, RESOURCE TO METADATAEMPTYDB;

CREATE USER METADATADB IDENTIFIED BY password;
GRANT CONNECT, RESOURCE TO METADATADB;

ALTER SESSION SET CURRENT_SCHEMA = METADATADB;

CREATE TABLE METADATADB.OFFICES (
    OFFICECODE VARCHAR2(10) NOT NULL,
    CONSTRAINT PK_OFFICES PRIMARY KEY (OFFICECODE)
);

CREATE TABLE METADATADB.EMPLOYEES (
    EMPLOYEENUMBER NUMBER(11) NOT NULL,
    LASTNAME VARCHAR2(50) NOT NULL,
    FIRSTNAME VARCHAR2(50) NOT NULL,
    EXTENSION VARCHAR2(10) NOT NULL,
    EMAIL VARCHAR2(100) NOT NULL,
    OFFICECODE VARCHAR2(10) NOT NULL,
    REPORTSTO NUMBER(11) DEFAULT NULL,
    JOBTITLE VARCHAR2(50) NOT NULL,
    CONSTRAINT PK_EMPLOYEES PRIMARY KEY (EMPLOYEENUMBER),
    CONSTRAINT CHK_EmpNums CHECK (EMPLOYEENUMBER > 0 AND REPORTSTO > 0),
    CONSTRAINT FK_EMPLOYEES_MANAGER FOREIGN KEY (REPORTSTO) REFERENCES EMPLOYEES(EMPLOYEENUMBER),
    CONSTRAINT FK_EMPLOYEES_OFFICE FOREIGN KEY (OFFICECODE) REFERENCES OFFICES(OFFICECODE)
);

CREATE OR REPLACE PROCEDURE METADATADB.GETEMPSNAME(EMPNUMBER IN NUMBER, FNAME OUT VARCHAR2) AS
BEGIN
    SELECT FIRSTNAME INTO FNAME
    FROM METADATADB.EMPLOYEES
    WHERE EMPLOYEENUMBER = EMPNUMBER;
END;

CREATE OR REPLACE PROCEDURE METADATADB.GETEMPSEMAIL(EMPNUMBER IN NUMBER, EMPEMAIL OUT VARCHAR2) AS
BEGIN
    SELECT EMAIL INTO EMPEMAIL
    FROM METADATADB.EMPLOYEES
    WHERE EMPLOYEENUMBER = EMPNUMBER;
END;