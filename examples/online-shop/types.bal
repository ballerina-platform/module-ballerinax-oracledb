import ballerina/time;

public type Customer record {
    decimal customer_id;
    string name;
    string address;
    string credit_limit;
    string website;
};

public type Order record {
    decimal order_id;
    decimal customer_id;
    string status;
    decimal salesman_id;
    time:Civil order_date;
};

public type Employee record {
    decimal employee_id;
    string first_name;
    string last_name;
    string email;
    string phone;
    time:Civil hire_date;
    decimal? manager_id;
    string job_title;
};

public type Product record {
    decimal product_id;
    string product_name;
    string description;
    decimal standard_cost;
    decimal list_price;
};

public type OrderItem record {
    decimal order_id;
    decimal item_id;
    decimal product_id;
    decimal quantity;
    decimal unit_price;
};

public type Contact record {
    decimal contact_id;
    string first_name;
    string last_name;
    string email;
    string phone;
    decimal customer_id;
};