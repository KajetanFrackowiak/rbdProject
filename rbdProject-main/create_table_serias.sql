CREATE TABLE data.address
(
    id               SERIAL      NOT NULL,
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
    id            SERIAL      NOT NULL,
    category_name varchar(30) NOT NULL,
    CONSTRAINT category_pk PRIMARY KEY (id)
);

CREATE TABLE data.customer
(
    id               SERIAL      NOT NULL,
    pesel            char(11)    NOT NULL,
    personal_data_id int         NOT NULL,
    CONSTRAINT customer_pk PRIMARY KEY (id)
);

CREATE TABLE data.description
(
    id       SERIAL          NOT NULL,
    price    decimal(12, 2)  NOT NULL,
    name     varchar(255)    NOT NULL,
    image    bytea           NOT NULL,
    material varchar(30)     NOT NULL,
    width    varchar(30)     NOT NULL,
    weight   varchar(30)     NOT NULL,
    height   varchar(30)     NOT NULL,
    CONSTRAINT description_pk PRIMARY KEY (id)
);

CREATE TABLE data.extra_article
(
    id             SERIAL      NOT NULL,
    description_id int         NOT NULL,
    CONSTRAINT extra_article_pk PRIMARY KEY (id)
);

CREATE TABLE data.monument
(
    id             SERIAL      NOT NULL,
    supplier_id    int         NOT NULL,
    category_id    int         NOT NULL,
    description_id int         NOT NULL,
    CONSTRAINT monument_pk PRIMARY KEY (id)
);

CREATE TABLE data."order"
(
    id                SERIAL          NOT NULL,
    order_date        date            NOT NULL,
    customer_id       int             NOT NULL,
    address_id        int             NOT NULL,
    service_id        int             NOT NULL,
    extra_articles_id int             NOT NULL,
    payment_method_id int             NOT NULL,
    CONSTRAINT order_pk PRIMARY KEY (id)
);

CREATE TABLE data.order_item
(
    id          SERIAL      NOT NULL,
    quantity    int          NOT NULL,
    order_id    int          NOT NULL,
    monument_id int          NOT NULL,
    CONSTRAINT order_item_pk PRIMARY KEY (id)
);

CREATE TABLE data.payment_method
(
    id   SERIAL      NOT NULL,
    name varchar(30) NOT NULL,
    CONSTRAINT payment_method_pk PRIMARY KEY (id)
);

CREATE TABLE data.personal_data
(
    id           SERIAL       NOT NULL,
    full_name    varchar(255) NOT NULL,
    email        varchar(255) NOT NULL,
    phone_number varchar(30)  NOT NULL,
    CONSTRAINT personal_data_pk PRIMARY KEY (id)
);

CREATE TABLE data.service
(
    id          SERIAL       NOT NULL,
    name        varchar(40)  NOT NULL,
    description varchar(255) NOT NULL,
    CONSTRAINT service_pk PRIMARY KEY (id)
);

CREATE TABLE data.supplier
(
    id               SERIAL       NOT NULL,
    contact_person   varchar(40)  NOT NULL,
    personal_data_id int          NOT NULL,
    CONSTRAINT supplier_pk PRIMARY KEY (id)
);
