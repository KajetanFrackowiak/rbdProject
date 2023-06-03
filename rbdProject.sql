CREATE SCHEMA data;

CREATE TABLE data.category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(30)
);

CREATE TABLE data.payment_method (
    payment_method_id SERIAL PRIMARY KEY,
    name VARCHAR(30)
);

CREATE TABLE data.personal_data (
    personal_data_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(30)
);

CREATE TABLE data.address (
    address_id SERIAL PRIMARY KEY,
    street VARCHAR(30),
    postcode CHAR(6),
    city VARCHAR(30),
    region VARCHAR(30),
    building_number INT,
    apartment_number INT
);

CREATE TABLE data.customer (
    customer_id SERIAL PRIMARY KEY,
    pesel CHAR(11),
    personal_data_id INT
);

CREATE TABLE data.service (
    service_id SERIAL PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(255)
);

CREATE TABLE data.description (
    description_id SERIAL PRIMARY KEY,
    price DECIMAL(12,2),
    name VARCHAR(255),
    image BYTEA,
    material VARCHAR(30),
    width VARCHAR(30),
    height VARCHAR(30)
);

CREATE TABLE data.supplier (
    supplier_id SERIAL PRIMARY KEY,
    contact_person VARCHAR(40),
    personal_data_id INT
);

CREATE TABLE data.order (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    total_amount INT,
    customer_id INT,
    address_id INT,
    service_id INT,
    extra_articles_id INT,
    payment_method_id INT
);

CREATE TABLE data.extra_article (
    extra_article_id SERIAL PRIMARY KEY,
    description_id INT
);

CREATE TABLE data.monument (
    monument_id SERIAL PRIMARY KEY,
    supplier_id INT,
    category_id INT,
    description_id INT
);

CREATE TABLE data.order_item (
    order_item_id SERIAL PRIMARY KEY,
    quantity INT,
    subtotal VARCHAR(30),
    unit_price MONEY,
    order_id INT,
    monument_id INT
);

