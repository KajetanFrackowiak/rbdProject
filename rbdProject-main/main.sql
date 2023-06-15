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
SELECT o.id AS order_id, o.order_date, c.pesel, a.city, a.street
FROM data."order" o
         JOIN data.customer c ON o.customer_id = c.id
         LEFT JOIN data.address a ON o.address_id = a.id;

-- Ten widok łączy tabelę "order" z tabelą "order_item" przy użyciu klauzuli JOIN, a następnie złącza tabelę "description" przy użyciu klauzuli INNER JOIN.
-- Wyświetla identyfikator zamówienia, identyfikator pozycji zamówienia, ilość, wartość częściową, nazwę i cenę przedmiotów zamówienia.
-- Umożliwia łatwe uzyskanie szczegółowych informacji o zamówieniach wraz z danymi dotyczącymi poszczególnych przedmiotów zamówienia.
CREATE VIEW data.order_order_item_description_view AS
SELECT o.id AS order_id, oi.id AS order_item_id, oi.quantity, d.name, d.price
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
SELECT o.id, o.order_date, c.pesel, a.city, a.street
FROM data.order o
         JOIN data.customer c ON o.customer_id = c.id
         JOIN data.address a ON o.address_id = a.id;

--To zapytanie wykonuje join między tabelą "order" a tabelą "order_item" na podstawie kolumny "order_id", a następnie joinuje tabelę "description" na podstawie kolumny "id".
-- Wybiera identyfikator zamówienia, identyfikator pozycji zamówienia, ilość, wartość częściową, nazwę i cenę przedmiotów zamówienia.
SELECT o.id, oi.id, oi.quantity, d.name, d.price
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
SELECT o.id AS order_id, o.order_date, c.pesel, a.city, a.street
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

-- Procedura dodająca zamówienie
CREATE OR REPLACE PROCEDURE insert_order(
    p_order_id           INT,
    p_order_date         DATE,
    p_customer_id        INT,
    p_address_id         INT,
    p_service_id         INT,
    p_extra_articles_id  INT,
    p_payment_method_id  INT
)
AS $$
BEGIN
    INSERT INTO data."order" (
        id, order_date, customer_id, address_id, service_id, extra_articles_id, payment_method_id
    )
    VALUES (
        p_order_id, p_order_date, p_customer_id, p_address_id, p_service_id, p_extra_articles_id, p_payment_method_id
    );
END;
$$ LANGUAGE plpgsql;

-- Wywołanie procedury insert_order
CALL insert_order(1, '2023-06-15', 100.00, 1, 1, 1, 1, 1);


-- Funkcja do tworzenia krotek w tabeli "order"
CREATE OR REPLACE FUNCTION create_order_tuple()
  RETURNS TRIGGER AS
$$
BEGIN
  INSERT INTO data."order" (id, order_date, customer_id, address_id, service_id, extra_articles_id, payment_method_id)
  VALUES (NEW.id, NEW.order_date, NEW.customer_id, NEW.address_id, NEW.service_id, NEW.extra_articles_id, NEW.payment_method_id);

  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

SELECT create_order_tuple();


-- Trigger wywołujący funkcję create_order_tuple po wstawieniu nowej krotki do tabeli "order"
CREATE TRIGGER create_order_trigger
AFTER INSERT ON data."order"
FOR EACH ROW
EXECUTE FUNCTION create_order_tuple();


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
    customer_id := 1,-- := przypisanie wartosci do zmiennej
    full_name := 'John Doe',
    email := 'johndoe@example.com',
    phone_number := '123456789'
);
SELECT *
FROM data.customer
JOIN data.personal_data ON data.customer.personal_data_id = data.personal_data.id
WHERE data.customer.id = 1;

