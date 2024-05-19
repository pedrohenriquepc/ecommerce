-- Criar o banco de dados
CREATE DATABASE ecommerce;

-- Criar a tabela Customer
CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender CHAR(1),
    address TEXT,
    birth_date DATE,
    phone VARCHAR(20)
);

-- Criar a tabela Category
CREATE TABLE Category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    category_path TEXT NOT NULL
);

-- Criar a tabela Item
CREATE TABLE Item (
    item_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    cancellation_date DATE,
    category_id INT REFERENCES Category(category_id)
);

-- Criar a tabela Order
CREATE TABLE "Order" (
    order_id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT REFERENCES Customer(customer_id),
    item_id INT REFERENCES Item(item_id),
    quantity INT NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL
);