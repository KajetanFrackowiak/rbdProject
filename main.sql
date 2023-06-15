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
    weigth   varchar(30)    NOT NULL,
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
    id                int            NOT NULL,
    order_date        date           NOT NULL,
    total_amount      DECIMAL(12, 2) NOT NULL,
    customer_id       int            NOT NULL,
    address_id        int            NOT NULL,
    service_id        int            NOT NULL,
    extra_articles_id int            NOT NULL,
    payment_method_id int            NOT NULL,
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

-- Ten widok łączy tabelę "customer" z tabelą "personal_data" przy użyciu klauzuli INNER JOIN. Wyświetla identyfikator klienta, PESEL,
-- pełne imię i adres e-mail klienta. Umożliwia łatwe pobranie danych osobowych klienta wraz z informacjami z tabeli "personal_data".
CREATE VIEW data.customer_personal_data_view AS
SELECT c.id AS customer_id, c.pesel, pd.full_name, pd.email
FROM data.customer c
         INNER JOIN data.personal_data pd ON c.personal_data_id = pd.id;

-- Ten widok łączy tabelę "order" z tabelą "customer" przy użyciu klauzuli JOIN, a następnie złącza tabelę "address" przy użyciu klauzuli LEFT JOIN.
-- Wyświetla identyfikator zamówienia, datę zamówienia, łączną kwotę zamówienia, PESEL klienta, miasto i ulicę związane z adresem dostawy zamówienia.
-- Umożliwia łatwe uzyskanie danych o zamówieniach wraz z informacjami o kliencie i adresem dostawy.
CREATE VIEW data.order_customer_address_view AS
SELECT o.id AS order_id, o.order_date, o.total_amount, c.pesel, a.city, a.street
FROM data."order" o
         JOIN data.customer c ON o.customer_id = c.id
         LEFT JOIN data.address a ON o.address_id = a.id;

-- Ten widok łączy tabelę "order" z tabelą "order_item" przy użyciu klauzuli JOIN, a następnie złącza tabelę "description" przy użyciu klauzuli INNER JOIN.
-- Wyświetla identyfikator zamówienia, identyfikator pozycji zamówienia, ilość, wartość częściową, nazwę i cenę przedmiotów zamówienia.
-- Umożliwia łatwe uzyskanie szczegółowych informacji o zamówieniach wraz z danymi dotyczącymi poszczególnych przedmiotów zamówienia.
CREATE VIEW data.order_order_item_description_view AS
SELECT o.id AS order_id, oi.id AS order_item_id, oi.quantity, oi.subtotal, d.name, d.price
FROM data."order" o
         INNER JOIN data.order_item oi ON o.id = oi.order_id
         INNER JOIN data.description d ON oi.id = d.id;

--To zapytanie wykonuje prosty join między tabelą "customer" a tabelą "personal_data".
-- Wybiera identyfikator klienta, PESEL, pełne imię i adres e-mail klienta.
-- Pozwala na pobranie danych osobowych klienta, które są przechowywane w tabeli "personal_data".
SELECT c.id, c.pesel, pd.full_name, pd.email
FROM data.customer c
         JOIN data.personal_data pd ON c.personal_data_id = pd.id;

--To zapytanie wykonuje join między tabelą "order" a tabelą "customer" na podstawie kolumny "customer_id", a następnie joinuje tabelę "address" na podstawie kolumny "address_id".
-- Wybiera identyfikator zamówienia, datę zamówienia, łączną kwotę zamówienia, PESEL klienta, miasto i ulicę związane z adresem dostawy zamówienia.
SELECT o.id, o.order_date, o.total_amount, c.pesel, a.city, a.street
FROM data.order o
         JOIN data.customer c ON o.customer_id = c.id
         JOIN data.address a ON o.address_id = a.id;

--To zapytanie wykonuje join między tabelą "order" a tabelą "order_item" na podstawie kolumny "order_id", a następnie joinuje tabelę "description" na podstawie kolumny "id".
-- Wybiera identyfikator zamówienia, identyfikator pozycji zamówienia, ilość, wartość częściową, nazwę i cenę przedmiotów zamówienia.
SELECT o.id, oi.id, oi.quantity, oi.subtotal, d.name, d.price
FROM data.order o
         JOIN data.order_item oi ON o.id = oi.order_id
         JOIN data.description d ON oi.id = d.id;

--To zapytanie wykonuje join między tabelami "monument", "supplier", "category" i "description" na podstawie odpowiednich kolumn identyfikatorów.
-- Wybiera identyfikator pomnika, identyfikator dostawcy, osobę kontaktową dostawcy, identyfikator kategorii, nazwę kategorii, identyfikator opisu i nazwę opisu, oraz cenę.
-- Pozwala na uzyskanie informacji o pomnikach wraz z danymi o dostawcach, kategoriach i opisach.
SELECT m.id,
       m.supplier_id,
       s.contact_person,
       m.category_id,
       c.category_name,
       m.description_id,
       d.name,
       d.price
FROM data.monument m
         JOIN data.supplier s ON m.supplier_id = s.id
         JOIN data.category c ON m.category_id = c.id
         JOIN data.description d ON m.description_id = d.id;

----Ten widok łączy tabelę "customer" z tabelą "personal_data" przy użyciu klauzuli RIGHT JOIN.
-- Wyświetla identyfikator klienta, PESEL, pełne imię i adres e-mail klienta.
-- Umożliwia łatwe pobranie danych osobowych klienta wraz z informacjami z tabeli "personal_data".
CREATE VIEW data.customer_personal_data_view AS
SELECT c.id AS customer_id, c.pesel, pd.full_name, pd.email
FROM data.customer c
         RIGHT JOIN data.personal_data pd ON c.personal_data_id = pd.id;

-- Ten widok łączy tabelę "order" z tabelą "customer" przy użyciu klauzuli FULL JOIN, a następnie złącza tabelę "address" przy użyciu klauzuli FULL JOIN.
-- Wyświetla identyfikator zamówienia, datę zamówienia, łączną kwotę zamówienia, PESEL klienta, miasto i ulicę związane z adresem dostawy zamówienia.
-- Umożliwia łatwe uzyskanie danych o zamówieniach wraz z informacjami o kliencie i adresem dostawy.
CREATE VIEW data.order_customer_address_view AS
SELECT o.id AS order_id, o.order_date, o.total_amount, c.pesel, a.city, a.street
FROM data."order" o
         FULL JOIN data.customer c ON o.customer_id = c.id
         FULL JOIN data.address a ON o.address_id = a.id;
--


-- To zapytanie wykonuje złączenie typu LEFT JOIN między tabelami "category" i "monument". Wybiera identyfikator kategorii, nazwę kategorii oraz liczbę pomników w każdej kategorii.
-- Klauzula HAVING ogranicza wyniki do kategorii, które mają liczbę pomników większą niż średnia liczba pomników we wszystkich kategoriach.
SELECT c.id, c.category_name, COUNT(m.id) AS product_count
FROM data.category c
         LEFT JOIN data.monument m ON c.id = m.id
GROUP BY c.id, c.category_name, c.id
HAVING COUNT(m.id) > (SELECT AVG(product_count)
                      FROM (SELECT id, COUNT(id) AS product_count FROM data.monument GROUP BY id, id) AS subquery);


--To zapytanie wykonuje złączenie typu FULL JOIN między tabelami "customer" i "order".
-- Wybiera identyfikator klienta, PESEL klienta, identyfikator zamówienia i datę zamówienia.
-- Klauzula OFFSET pomija pierwsze 10 wyników, a klauzula LIMIT ogranicza wyniki do 5. Pozwala na paginację wyników złączenia.
SELECT c.id, c.pesel, o.id, o.order_date
FROM data.customer c
         FULL JOIN data."order" o ON c.id = o.customer_id
ORDER BY c.id
OFFSET 10 LIMIT 5;


-- Zwraca pełne nazwy, adresy e-mail i numery telefonów osób, które są zarówno klientami, jak i dostawcami
SELECT full_name, email, phone_number
FROM data.personal_data
         JOIN (SELECT id, personal_data_id
               FROM data.customer
               UNION
               SELECT id, personal_data_id
               FROM data.supplier) AS merged_table ON merged_table.personal_data_id = data.personal_data.id;

-- Zwraca pełne nazwy, adresów email i numery telefonów osób, które są zarówno klientami, jak i dostawcami (tylko te, które występują w obu grupach).
SELECT full_name, email, phone_number
FROM data.personal_data
         JOIN (SELECT id, personal_data_id
               FROM data.customer
               INTERSECT
               SELECT id, personal_data_id
               FROM data.supplier) AS merged_table ON merged_table.personal_data_id = data.personal_data.id;

-- Zwraca pełne nazwy, adresy e-mail i numery telefonów osób, które sa klientami, ale nie są jednocześnie dostawcami.
SELECT full_name, email, phone_number
FROM data.personal_data
         JOIN (SELECT id, personal_data_id
               FROM data.customer
               EXCEPT
               SELECT id, personal_data_id
               FROM data.supplier) AS merged_table ON merged_table.personal_data_id = data.personal_data.id;


--procedura dodajaca nowego klienta wraz z danymi osobowymi
CREATE OR REPLACE PROCEDURE data.create_customer(
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
AS
$$
DECLARE
    personal_data_id INT;
    address_id INT;
    customer_id INT;
BEGIN
    -- Wstawianie danych osobowych
    INSERT INTO data.personal_data (full_name, email, phone_number)
    VALUES (customer_name, customer_email, customer_phone)
    RETURNING id INTO personal_data_id;

    -- Wstawianie adresu
    INSERT INTO data.address (street, postcode, city, region, building_number, apartment_number)
    VALUES (customer_street, customer_postcode, customer_city, customer_region, customer_building_number,
            customer_apartment_number)
    RETURNING id INTO address_id;

    -- Wstawianie klienta
    INSERT INTO data.customer (pesel, personal_data_id, address_id)
    VALUES (customer_pesel, personal_data_id, address_id)
    RETURNING id INTO customer_id;

    -- Aktualizacja adresu klienta
    UPDATE data.customer
    SET address_id = address_id
    WHERE id = customer_id;

    COMMIT;
END;
$$
LANGUAGE plpgsql;


--procedura dodajaca nowy pomnik wraz z informacjami o dostawcy i opisie------------
--procedura dodajaca nowy pomnik wraz z informacjami o dostawcy i opisie------------
CREATE OR REPLACE PROCEDURE data.create_monument(
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
    category_id INT;
    description_id INT;
    monument_id INT;
BEGIN
    -- Sprawdź, czy dostawca już istnieje
    SELECT id INTO supplier_id
    FROM data.supplier
    WHERE contact_person = monument_supplier;

    -- Jeśli dostawca nie istnieje, dodaj go
    IF supplier_id IS NULL THEN
        INSERT INTO data.supplier (contact_person)
        VALUES (monument_supplier)
        RETURNING id INTO supplier_id;
    END IF;

    -- Dodaj kategorię
    INSERT INTO data.category (category_name)
    VALUES (monument_category)
    RETURNING id INTO category_id;

    -- Dodaj opis
    INSERT INTO data.description (price, name, image, material, width, height)
    VALUES (monument_price, monument_name, monument_image, monument_material, monument_width, monument_height)
    RETURNING id INTO description_id;

    -- Dodaj pomnik
    INSERT INTO data.monument (supplier_id, category_id, description_id)
    VALUES (supplier_id, category_id, description_id)
    RETURNING id INTO monument_id;

    COMMIT;
END;
$$
LANGUAGE plpgsql;



--trigger sprawdzajacy poprawnosc danych osobowych przy dodawaniu klienta---
CREATE OR REPLACE FUNCTION data.validate_customer_personal_data()
    RETURNS TRIGGER AS
$$
BEGIN
    IF CHAR_LENGTH(NEW.pesel) <> 11 THEN
        RAISE EXCEPTION 'PESEL must be 11 characters long.';
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER validate_customer_personal_data_trigger
    BEFORE INSERT
    ON data.customer
    FOR EACH ROW
EXECUTE FUNCTION data.validate_customer_personal_data();


------------------------------------------------------------------------------------------------------------------------
CREATE ROLE username
    LOGIN
    PASSWORD '';

-- Nadaje użytkownikowi (o nazwie użytkownika) uprawnienia SELECT, INSERT, UPDATE i DELETE dla wszystkich tabel w schemacie "data"
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA data TO username;

-- Nadaje użytkownikowi (o nazwie użytkownika) uprawnienia EXECUTE dla wszystkich funkcji w schemacie "data"
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA data TO username;

-----------------------------------------
-- Funkcje z tranzakcjami
------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_customer_address(
    customer_id INT,
    street VARCHAR(30),
    postcode CHAR(6),
    city VARCHAR(30),
    region VARCHAR(30),
    building_number INT,
    apartment_number INT
) RETURNS VOID AS
$$
BEGIN
    -- Rozpoczęcie transakcji
    BEGIN
        -- Dodanie kolumny "address_id" do tabeli "data.customer" (jeśli jeszcze nie istnieje)
        IF NOT EXISTS (SELECT 1
                       FROM information_schema.columns
                       WHERE table_name = 'customer'
                         AND column_name = 'address_id')
        THEN
            ALTER TABLE data.customer
                ADD COLUMN address_id INT;
        END IF;

        -- Sprawdzenie istnienia ograniczenia i utworzenie go, jeśli nie istnieje
        IF NOT EXISTS (SELECT 1
                       FROM pg_constraint
                       WHERE conname = 'customer_address')
        THEN
            ALTER TABLE data.customer
                ADD CONSTRAINT customer_address
                    FOREIGN KEY (address_id)
                        REFERENCES data.address (id)
                        NOT DEFERRABLE
                            INITIALLY IMMEDIATE;
        END IF;

        -- Dodanie adresu
        INSERT INTO data.address (street, postcode, city, region, building_number, apartment_number)
        VALUES (street, postcode, city, region, building_number, apartment_number)
        RETURNING id INTO customer_id;

        -- Powiązanie adresu z klientem
        UPDATE data.customer
        SET address_id = customer_id
        WHERE id = customer_id;

        -- Zatwierdzenie transakcji
        COMMIT;
    END;
END;
$$ LANGUAGE plpgsql;



------------------------------------------------------------------------------------------------------------------------
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
) RETURNS VOID AS
$$
DECLARE
    item data.order_item;
BEGIN
    -- Rozpoczęcie transakcji
    BEGIN

        -- Dodanie zamówienia
        INSERT INTO data."order" (id, order_date, total_amount, customer_id, address_id, service_id, payment_method_id)
        VALUES (order_id, order_date, total_amount, customer_id, address_id, service_id, payment_method_id);

        -- Dodanie pozycji zamówienia
        FOREACH item IN ARRAY order_items
            LOOP
                INSERT INTO data.order_item (quantity, subtotal, unit_price, order_id, monument_id)
                VALUES (item.quantity, item.subtotal, item.unit_price, order_id, item.monument_id);
            END LOOP;

        -- Zatwierdzenie transakcji
        COMMIT;
    END;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------------------------------------------------------------------
-- ☑
CREATE OR REPLACE FUNCTION update_customer_personal_data(
    customer_id INT,
    full_name VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(30)
) RETURNS VOID AS
$$
BEGIN
    -- Aktualizacja danych osobowych klienta
    UPDATE data.personal_data
    SET full_name = update_customer_personal_data.full_name,
        email = update_customer_personal_data.email,
        phone_number = update_customer_personal_data.phone_number
    FROM data.customer
    WHERE data.personal_data.id = data.customer.personal_data_id
        AND data.customer.id = update_customer_personal_data.customer_id;
END;
$$ LANGUAGE plpgsql;


-- Aktualizacja danych osobowych klienta o ID 1
SELECT update_customer_personal_data(
    customer_id := 1,
    full_name := 'John Doe',
    email := 'johndoe@example.com',
    phone_number := '123456789'
);
SELECT *
FROM data.customer
JOIN data.personal_data ON data.customer.personal_data_id = data.personal_data.id
WHERE data.customer.id = 1;

