CREATE SCHEMA data;

CREATE TABLE data.category
(
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(30)
);

CREATE TABLE data.payment_method
(
    payment_method_id SERIAL PRIMARY KEY,
    name              VARCHAR(30)
);

CREATE TABLE data.personal_data
(
    personal_data_id SERIAL PRIMARY KEY,
    full_name        VARCHAR(255),
    email            VARCHAR(255),
    phone_number     VARCHAR(30)
);

CREATE TABLE data.address
(
    address_id       SERIAL PRIMARY KEY,
    street           VARCHAR(30),
    postcode         CHAR(6),
    city             VARCHAR(30),
    region           VARCHAR(30),
    building_number  INT,
    apartment_number INT
);

CREATE TABLE data.customer
(
    customer_id SERIAL PRIMARY KEY,
    pesel       CHAR(11)
);

CREATE TABLE data.service
(
    service_id  SERIAL PRIMARY KEY,
    name        VARCHAR(40),
    description VARCHAR(255)
);

CREATE TABLE data.description
(
    description_id SERIAL PRIMARY KEY,
    price          DECIMAL(12, 2),
    name           VARCHAR(255),
    image          BYTEA,
    material       VARCHAR(30),
    width          VARCHAR(30),
    height         VARCHAR(30)
);

CREATE TABLE data.supplier
(
    supplier_id    SERIAL PRIMARY KEY,
    contact_person VARCHAR(40)
);

CREATE TABLE data.order
(
    order_id     SERIAL PRIMARY KEY,
    order_date   DATE,
    total_amount INT
);

CREATE TABLE data.extra_article
(
    extra_article_id SERIAL PRIMARY KEY
);

CREATE TABLE data.monument
(
    monument_id SERIAL PRIMARY KEY
);

CREATE TABLE data.order_item
(
    order_item_id SERIAL PRIMARY KEY,
    quantity      INT,
    subtotal      VARCHAR(30),
    unit_price    MONEY
);

ALTER TABLE data.monument
    ADD COLUMN supplier_id INT,
ADD CONSTRAINT fk_monument_supplier
FOREIGN KEY (supplier_id) REFERENCES data.supplier (supplier_id);

ALTER TABLE data.monument
    ADD COLUMN category_id INT,
ADD CONSTRAINT fk_monument_category
FOREIGN KEY (category_id) REFERENCES data.category (category_id);

ALTER TABLE data.monument
    ADD COLUMN description_id INT UNIQUE,
ADD CONSTRAINT fk_monument_description
FOREIGN KEY (description_id) REFERENCES data.description (description_id);

ALTER TABLE data.customer
    ADD COLUMN personal_data_id INT,
ADD CONSTRAINT fk_customer_personal_data
FOREIGN KEY (personal_data_id) REFERENCES data.personal_data (personal_data_id);

ALTER TABLE data.supplier
    ADD COLUMN personal_data_id INT,
ADD CONSTRAINT fk_supplier_personal_data
FOREIGN KEY (personal_data_id) REFERENCES data.personal_data (personal_data_id);

ALTER TABLE data.extra_article
    ADD COLUMN description_id INT,
ADD CONSTRAINT fk_extra_article_description
FOREIGN KEY (description_id) REFERENCES data.extra_article (extra_article_id);

ALTER TABLE data.order
    ADD COLUMN customer_id INT,
ADD CONSTRAINT fk_ordering_customer
FOREIGN KEY (customer_id) REFERENCES data.customer (customer_id);

ALTER TABLE data.order
    ADD COLUMN address_id INT,
ADD CONSTRAINT fk_order_address
FOREIGN KEY (address_id) REFERENCES data.address (address_id);

ALTER TABLE data.order
    ADD COLUMN service_id INT,
ADD CONSTRAINT fk_order_service
FOREIGN KEY (service_id) REFERENCES data.service (service_id);

ALTER TABLE data.order
    ADD COLUMN extra_articles_id INT,
ADD CONSTRAINT fk_extra_order_articles
FOREIGN KEY (extra_articles_id) REFERENCES data.extra_articles (extra_articles_id);

ALTER TABLE data.order
    ADD COLUMN payment_method_id INT,
ADD CONSTRAINT fk_payment_method_for_ordering
FOREIGN KEY (payment_method_id) REFERENCES data.payment_method (payment_method_id);

-- Nowa tabela by osiągnąć relacje wiele do wielu:
CREATE TABLE data.order_order_item
(
    order_order_item_id SERIAL PRIMARY KEY,
    order_id INT,
    order_item_id INT,
    CONSTRAINT fk_order_order_item_order -- order_id from order_order_item to data.order order_id
        FOREIGN KEY (order_id) REFERENCES data.order (order_id),
    CONSTRAINT fk_order_order_item_order_item -- order_item_id from order_order_item to data.order_item order_item_id
        FOREIGN KEY (order_item_id) REFERENCES data.order_item(order_item_id)
);