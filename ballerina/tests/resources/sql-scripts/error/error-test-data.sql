CREATE TABLE ErrorTable(
    row_id       NUMBER,
    string_type  VARCHAR(50),
    PRIMARY KEY (row_id)
);

INSERT INTO ErrorTable (row_id, string_type)
    VALUES(1, 'Hello');
