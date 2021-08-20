CREATE TABLE ComplexQueryTable (
        id      NUMBER,
        col_xml XMLType,
        PRIMARY KEY (id)
);

CREATE TABLE ComplexDataTable (
        row_id      NUMBER,
        int_type    NUMBER,
        double_type BINARY_DOUBLE,
        string_type VARCHAR2(50),
        PRIMARY KEY (row_id)
);

INSERT INTO ComplexDataTable (row_id, int_type, double_type, string_type)
    VALUES (1, 1, 2139095039.23, 'Hello');
