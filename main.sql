CREATE SCHEMA data;

CREATE TABLE data.address
(
    id               int         NOT NULL,
    street           varchar(30) NOT NULL,
    postcode         char(6)     NOT NULL,
    city             varchar(30) NOT NULL,
    region           varchar(30) NOT NULL,
    building_number  int         NOT NULL,
    apartment_number int         NOT NULL,
    CONSTRAINT address_pk PRIMARY KEY (id)
);

CREATE TABLE data.category
(
    id            int         NOT NULL,
    category_name varchar(30) NOT NULL,
    CONSTRAINT category_pk PRIMARY KEY (id)
);

CREATE TABLE data.customer
(
    id               int      NOT NULL,
    pesel            char(11) NOT NULL,
    personal_data_id int      NOT NULL,
    CONSTRAINT customer_pk PRIMARY KEY (id)
);

CREATE TABLE data.description
(
    id       int            NOT NULL,
    price    decimal(12, 2) NOT NULL,
    name     varchar(255)   NOT NULL,
    image    bytea          NOT NULL,
    material varchar(30)    NOT NULL,
    width    varchar(30)    NOT NULL,
    weight   varchar(30)    NOT NULL,
    height   varchar(30)    NOT NULL,
    CONSTRAINT description_pk PRIMARY KEY (id)
);

CREATE TABLE data.extra_article
(
    id             int NOT NULL,
    description_id int NOT NULL,
    CONSTRAINT extra_article_pk PRIMARY KEY (id)
);

CREATE TABLE data.monument
(
    id             int NOT NULL,
    supplier_id    int NOT NULL,
    category_id    int NOT NULL,
    description_id int NOT NULL,
    CONSTRAINT monument_pk PRIMARY KEY (id)
);

CREATE TABLE data."order"
(
    id                int  NOT NULL,
    order_date        date NOT NULL,
    total_amount      int  NOT NULL,
    customer_id       int  NOT NULL,
    address_id        int  NOT NULL,
    service_id        int  NOT NULL,
    extra_articles_id int  NOT NULL,
    payment_method_id int  NOT NULL,
    CONSTRAINT order_pk PRIMARY KEY (id)
);

CREATE TABLE data.order_item
(
    id          int         NOT NULL,
    quantity    int         NOT NULL,
    subtotal    varchar(30) NOT NULL,
    unit_price  money       NOT NULL,
    order_id    int         NOT NULL,
    monument_id int         NOT NULL,
    CONSTRAINT order_item_pk PRIMARY KEY (id)
);

CREATE TABLE data.payment_method
(
    id   int         NOT NULL,
    name varchar(30) NOT NULL,
    CONSTRAINT payment_method_pk PRIMARY KEY (id)
);

CREATE TABLE data.personal_data
(
    id           int          NOT NULL,
    full_name    varchar(255) NOT NULL,
    email        varchar(255) NOT NULL,
    phone_number varchar(30)  NOT NULL,
    CONSTRAINT personal_data_pk PRIMARY KEY (id)
);

CREATE TABLE data.service
(
    id          int          NOT NULL,
    name        varchar(40)  NOT NULL,
    description varchar(255) NOT NULL,
    CONSTRAINT service_pk PRIMARY KEY (id)
);

CREATE TABLE data.supplier
(
    id               int         NOT NULL,
    contact_person   varchar(40) NOT NULL,
    personal_data_id int         NOT NULL,
    CONSTRAINT supplier_pk PRIMARY KEY (id)
);

ALTER TABLE data.customer
    ADD CONSTRAINT customer_personal_data
        FOREIGN KEY (personal_data_id)
            REFERENCES data.personal_data (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE data.extra_article
    ADD CONSTRAINT extra_articles_description
        FOREIGN KEY (description_id)
            REFERENCES data.description (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE data.monument
    ADD CONSTRAINT monument_category
        FOREIGN KEY (category_id)
            REFERENCES data.category (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE data.monument
    ADD CONSTRAINT monument_description
        FOREIGN KEY (description_id)
            REFERENCES data.description (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE data.monument
    ADD CONSTRAINT monument_supplier
        FOREIGN KEY (supplier_id)
            REFERENCES data.supplier (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE data."order"
    ADD CONSTRAINT order_address
        FOREIGN KEY (address_id)
            REFERENCES data.address (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE data."order"
    ADD CONSTRAINT order_customer
        FOREIGN KEY (customer_id)
            REFERENCES data.customer (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE data."order"
    ADD CONSTRAINT order_extra_articles
        FOREIGN KEY (extra_articles_id)
            REFERENCES data.extra_article (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE data.order_item
    ADD CONSTRAINT order_item_monument
        FOREIGN KEY (monument_id)
            REFERENCES data.monument (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE data.order_item
    ADD CONSTRAINT order_item_order
        FOREIGN KEY (order_id)
            REFERENCES data."order" (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE data."order"
    ADD CONSTRAINT order_payment_method
        FOREIGN KEY (payment_method_id)
            REFERENCES data.payment_method (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE data."order"
    ADD CONSTRAINT order_service
        FOREIGN KEY (service_id)
            REFERENCES data.service (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE data.supplier
    ADD CONSTRAINT supplier_personal_data
        FOREIGN KEY (personal_data_id)
            REFERENCES data.personal_data (id)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;



------------------------------------------------------------------------------------------------------------------------
-- Dodane widoki (view) wykorzystujące różne klauzule i komendy

-- Widok złączający tabelę 'customer' i 'personal_data' przy użyciu klauzuli INNER JOIN
CREATE VIEW data.customer_personal_data_view AS
SELECT c.id AS customer_id, c.pesel, pd.full_name, pd.email
FROM data.customer c
INNER JOIN data.personal_data pd ON c.personal_data_id = pd.id;

-- Widok złączający tabelę 'order', 'customer' i zagnieżdżone złączenie z tabelą 'address' przy użyciu klauzuli LEFT JOIN
CREATE VIEW data.order_customer_address_view AS
SELECT o.id AS order_id, o.order_date, o.total_amount, c.pesel, a.city, a.street
FROM data."order" o
JOIN data.customer c ON o.customer_id = c.id
LEFT JOIN data.address a ON o.address_id = a.id;

-- Widok złączający tabelę 'order', 'order_item' i zagnieżdżone złączenie z tabelą 'description' przy użyciu klauzuli INNER JOIN
CREATE VIEW data.order_order_item_description_view AS
SELECT o.id AS order_id, oi.id AS order_item_id, oi.quantity, oi.subtotal, d.name, d.price
FROM data."order" o
INNER JOIN data.order_item oi ON o.id = oi.order_id
INNER JOIN data.description d ON oi.description_id = d.id;

--zapytanie z joinem miedzy tabelami 'customer' i 'personal_data'--------
SELECT c.customer_id, c.pesel, pd.full_name, pd.email
FROM data.customer c
         JOIN data.personal_data pd ON c.personal_data_id = pd.personal_data_id;

--zapytanie z joinem miedzy tabelami 'order' i 'customer', oraz zagniezdzonym joinem do tabeli 'address'
SELECT o.order_id, o.order_date, o.total_amount, c.pesel, a.city, a.street
FROM data.order o
         JOIN data.customer c ON o.customer_id = c.customer_id
         JOIN data.address a ON o.address_id = a.address_id;

--zapytanie z joinem miedzy tabelami 'order' i 'order_item', oraz zagniezdzonym joinem do tabeli 'description'
SELECT o.order_id, oi.order_item_id, oi.quantity, oi.subtotal, d.name, d.price
FROM data.order o
         JOIN data.order_item oi ON o.order_id = oi.order_id
         JOIN data.description d ON oi.description_id = d.description_id;

--zapytanie z joinem miedzy tabelami 'monument','supplier',category' i 'description'-----
SELECT m.monument_id,
       m.supplier_id,
       data.contact_person,
       m.category_id,
       c.category_name,
       m.description_id,
       d.name,
       d.price
FROM data.monument m
         JOIN data.supplier s ON m.supplier_id = data.supplier_id
         JOIN data.category c ON m.category_id = c.category_id
         JOIN data.description d ON m.description_id = d.description_id;

---- Widok złączający tabelę 'customer' i 'personal_data' przy użyciu klauzuli RIGHT JOIN
CREATE VIEW data.customer_personal_data_view AS
SELECT c.id AS customer_id, c.pesel, pd.full_name, pd.email
FROM data.customer c
RIGHT JOIN data.personal_data pd ON c.personal_data_id = pd.id;

-- Widok złączający tabelę 'order', 'customer' i zagnieżdżone złączenie z tabelą 'address' przy użyciu klauzuli FULL JOIN
CREATE VIEW data.order_customer_address_view AS
SELECT o.id AS order_id, o.order_date, o.total_amount, c.pesel, a.city, a.street
FROM data."order" o
FULL JOIN data.customer c ON o.customer_id = c.id
FULL JOIN data.address a ON o.address_id = a.id;

-- Przykład złączenia typu LEFT JOIN z klauzulą HAVING i podzapytaniem:
SELECT c.category_id, c.category_name, COUNT(p.product_id) AS product_count
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
HAVING COUNT(p.product_id) > (SELECT AVG(product_count) FROM (SELECT category_id, COUNT(product_id) AS product_count FROM products GROUP BY category_id) AS subquery);


--Przykład złączenia typu FULL JOIN z klauzulą OFFSET i LIMIT:
SELECT c.customer_id, c.customer_name, o.order_id, o.order_date
FROM customers c
FULL JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id
OFFSET 10 LIMIT 5;


-- Zwraca pełne nazwy, adresy e-mail i numery telefonów osób, które są zarówno klientami, jak i dostawcami
SELECT full_name, email, phone_number
FROM data.personal_data
         JOIN (SELECT customer_id, personal_data_id
               FROM data.customer
               UNION
               SELECT supplier_id, personal_data_id
               FROM data.supplier) AS merged_table ON merged_table.personal_data_id = data.personal_data.id;

-- Zwraca pełne nazwy, adresów email i numery telefonów osób, które są zarówno klientami, jak i dostawcami (tylko te, które występują w obu grupach).
SELECT full_name, email, phone_number
FROM data.personal_data
         JOIN (SELECT customer_id, personal_data_id
               FROM data.customer
               INTERSECT
               SELECT supplier_id, personal_data_id
               FROM data.supplier) AS merged_table ON merged_table.personal_data_id = data.personal_data.id;

-- Zwraca pełne nazwy, adresy e-mail i numery telefonów osób, które sa klientami, ale nie są jednocześnie dostawcami.
SELECT full_name, email, phone_number
FROM data.personal_data
         JOIN (SELECT customer_id, personal_data_id
               FROM data.customer
               EXCEPT
               SELECT supplier_id, personal_data_id
               FROM data.supplier) AS merged_table ON merged_table.personal_data_id = data.personal_data.id;


--procedura dodajaca nowego klienta wraz z danymi osobowymi-------------
CREATE
OR REPLACE PROCEDURE data.create_customer(
    customer_name VARCHAR(255),
    customer_email VARCHAR(255),
    customer_phone VARCHAR(30),
    customer_pesel CHAR(11),
    customer_street VARCHAR(30),
    customer_postcode CHAR(6),
    customer_city VARCHAR(30),
    customer_region VARCHAR(30),
    customer_building_number INT,
    customer_apartment_number INT
)
AS $$
DECLARE
personal_data_id INT;
    address_id
INT;
    customer_id
INT;
BEGIN
INSERT INTO data.personal_data (full_name, email, phone_number)
VALUES (customer_name, customer_email, customer_phone) RETURNING personal_data_id
INTO personal_data_id;

INSERT INTO data.address (street, postcode, city, region, building_number, apartment_number)
VALUES (customer_street, customer_postcode, customer_city, customer_region, customer_building_number,
        customer_apartment_number) RETURNING address_id
INTO address_id;

INSERT INTO data.customer (pesel, personal_data_id)
VALUES (customer_pesel, personal_data_id) RETURNING customer_id
INTO customer_id;

UPDATE data.customer
SET address_id = address_id
WHERE customer_id = customer_id;

COMMIT;
END;
$$
LANGUAGE plpgsql;

--procedura dodajaca nowy pomnik wraz z informacjami o dostawcy i opisie------------
CREATE
OR REPLACE PROCEDURE data.create_monument(
    monument_name VARCHAR(255),
    monument_price DECIMAL(12,2),
    monument_supplier VARCHAR(40),
    monument_category VARCHAR(30),
    monument_image BYTEA,
    monument_material VARCHAR(30),
    monument_width VARCHAR(30),
    monument_height VARCHAR(30)
)
AS $$
DECLARE
supplier_id INT;
    category_id
INT;
    description_id
INT;
    monument_id
INT;
BEGIN
INSERT INTO data.supplier (contact_person)
VALUES (monument_supplier) RETURNING supplier_id
INTO supplier_id;

INSERT INTO data.category (category_name)
VALUES (monument_category) RETURNING category_id
INTO category_id;

INSERT INTO data.description (price, name, image, material, width, height)
VALUES (monument_price, monument_name, monument_image, monument_material, monument_width,
        monument_height) RETURNING description_id
INTO description_id;

INSERT INTO data.monument (supplier_id, category_id, description_id)
VALUES (supplier_id, category_id, description_id) RETURNING monument_id
INTO monument_id;

COMMIT;
END;
$$
LANGUAGE plpgsql;

--trigger sprawdzajacy poprawnosc danych osobowych przy dodawaniu klienta---
CREATE
OR REPLACE FUNCTION data.validate_personal_data()
    RETURNS TRIGGER AS $$
BEGIN
    IF
CHAR_LENGTH(NEW.pesel) <> 11 THEN
        RAISE EXCEPTION 'PESEL must be 11 characters long.';
END IF;

RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER validate_personal_data_trigger
    BEFORE INSERT
    ON data.personal_data
    FOR EACH ROW
    EXECUTE FUNCTION data.validate_personal_data();



----------------------------------------

-- Nadaje użytkownikowi (o nazwie użytkownika) uprawnienia SELECT, INSERT, UPDATE i DELETE dla wszystkich tabel w schemacie "data"
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA data TO username;

-- Nadaje użytkownikowi (o nazwie użytkownika) uprawnienia EXECUTE dla wszystkich funkcji w schemacie "data"
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA data TO username;

-----------------------------------------
-- Funkcje z tranzakcjami

CREATE OR REPLACE FUNCTION add_customer_address(
    customer_id INT,
    street VARCHAR(30),
    postcode CHAR(6),
    city VARCHAR(30),
    region VARCHAR(30),
    building_number INT,
    apartment_number INT
) RETURNS VOID AS $$
BEGIN
    -- Rozpoczęcie transakcji
    BEGIN;

    -- Dodanie adresu
    INSERT INTO data.address (id, street, postcode, city, region, building_number, apartment_number)
    VALUES (customer_id, street, postcode, city, region, building_number, apartment_number);

    -- Powiązanie adresu z klientem
    UPDATE data.customer
    SET address_id = customer_id
    WHERE id = customer_id;

    -- Zatwierdzenie transakcji
    COMMIT;
END;
$$ LANGUAGE plpgsql;

-- Funkcja do aktualizacji danych osobowych klienta i powiązanych z nimi informacji:
    CREATE OR REPLACE FUNCTION place_order(
    order_id INT,
    order_date DATE,
    total_amount INT,
    customer_id INT,
    address_id INT,
    service_id INT,
    payment_method_id INT,
    order_items data.order_item[]
) RETURNS VOID AS $$
DECLARE
    item data.order_item;
BEGIN
    -- Rozpoczęcie transakcji
    BEGIN;

    -- Dodanie zamówienia
    INSERT INTO data."order" (id, order_date, total_amount, customer_id, address_id, service_id, payment_method_id)
    VALUES (order_id, order_date, total_amount, customer_id, address_id, service_id, payment_method_id);

    -- Dodanie pozycji zamówienia
    FOREACH item IN ARRAY order_items
    LOOP
        INSERT INTO data.order_item (id, quantity, subtotal, unit_price, order_id, monument_id)
        VALUES (item.id, item.quantity, item.subtotal, item.unit_price, order_id, item.monument_id);
    END LOOP;

    -- Zatwierdzenie transakcji
    COMMIT;
END;
$$ LANGUAGE plpgsql;


-- Funkcja do aktualizacji danych osobowych klienta i powiązanych z nimi informacji:
    CREATE OR REPLACE FUNCTION update_customer_personal_data(
    customer_id INT,
    full_name VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(30)
) RETURNS VOID AS $$
BEGIN
    -- Rozpoczęcie transakcji
    BEGIN;

    -- Aktualizacja danych osobowych klienta
    UPDATE data.personal_data
    SET full_name = full_name, email = email, phone_number = phone_number
    WHERE id = (SELECT personal_data_id FROM data.customer WHERE id = customer_id);

    -- Zatwierdzenie transakcji
    COMMIT;
END;
$$ LANGUAGE plpgsql;

