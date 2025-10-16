-- ===============================================
-- CREACIÓN DE BASE DE DATOS
-- ===============================================
CREATE DATABASE Viveros;
USE Viveros;


-- ===============================================
-- TABLA VIVERO
-- ===============================================
CREATE TABLE Vivero (
    ID_vivero INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    latitud FLOAT,
    longitud FLOAT
);

-- ===============================================
-- TABLA ZONA
-- ===============================================
CREATE TABLE Zona (
    ID_zona INT PRIMARY KEY,
    ID_vivero INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    latitud FLOAT,
    longitud FLOAT,
    FOREIGN KEY (ID_vivero) REFERENCES Vivero(ID_vivero)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ===============================================
-- TABLA CLIENTE
-- ===============================================
CREATE TABLE Cliente (
    ID_cliente INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(150),
    CONSTRAINT chk_nombre_cliente CHECK (LENGTH(nombre) > 0)
);

-- ===============================================
-- TABLA EMAIL
-- ===============================================
CREATE TABLE Email (
    ID_email INT PRIMARY KEY,
    ID_cliente INT NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    FOREIGN KEY (ID_cliente) REFERENCES Cliente(ID_cliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_email_formato CHECK (email LIKE '%@%.%')
);

-- ===============================================
-- TABLA TELEFONO
-- ===============================================
CREATE TABLE Telefono (
    ID_telefono INT PRIMARY KEY,
    ID_cliente INT NOT NULL,
    telefono VARCHAR(15) NOT NULL UNIQUE,
    FOREIGN KEY (ID_cliente) REFERENCES Cliente(ID_cliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_telefono CHECK (telefono ~ '^[0-9]{9,15}$')
);

-- ===============================================
-- TABLA PLUS
-- ===============================================
CREATE TABLE Plus (
    ID_plus INT PRIMARY KEY,
    ID_cliente INT NOT NULL,
    bonificacion DECIMAL(5,2) DEFAULT 0 CHECK (bonificacion >= 0),
    fecha_ingreso DATE NOT NULL,
    FOREIGN KEY (ID_cliente) REFERENCES Cliente(ID_cliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ===============================================
-- TABLA EMPLEADO
-- ===============================================
CREATE TABLE Empleado (
    ID_empleado INT PRIMARY KEY,
    DNI VARCHAR(15) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    latitud FLOAT,
    longitud FLOAT,
    puesto VARCHAR(50),
    CONSTRAINT chk_dni CHECK (LENGTH(DNI) >= 8)
);

-- ===============================================
-- TABLA PEDIDO
-- ===============================================
CREATE TABLE Pedido (
    ID_pedido INT PRIMARY KEY,
    ID_plus INT NOT NULL,
    ID_empleado INT NOT NULL,
    fecha DATE NOT NULL,
    coste_final DECIMAL(10,2) DEFAULT 0 CHECK (coste_final >= 0),
    FOREIGN KEY (ID_plus) REFERENCES Plus(ID_plus)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (ID_empleado) REFERENCES Empleado(ID_empleado)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ===============================================
-- TABLA PRODUCTO
-- ===============================================
CREATE TABLE Producto (
    ID_producto INT PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    stock INT DEFAULT 0 CHECK (stock >= 0),
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0)
);

-- ===============================================
-- TABLA PEDIDO_PRODUCTO (N:M)
-- ===============================================
CREATE TABLE Pedido_Producto (
    ID_pedido_producto INT PRIMARY KEY,
    ID_pedido INT NOT NULL,
    ID_producto INT NOT NULL,
    unidades INT NOT NULL CHECK (unidades > 0),
    FOREIGN KEY (ID_pedido) REFERENCES Pedido(ID_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ID_producto) REFERENCES Producto(ID_producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- ===============================================
-- TABLA ZONA_PRODUCTO (N:M)
-- ===============================================
CREATE TABLE Zona_Producto (
    ID_zona_producto INT PRIMARY KEY,
    ID_zona INT NOT NULL,
    ID_producto INT NOT NULL,
    FOREIGN KEY (ID_zona) REFERENCES Zona(ID_zona)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ID_producto) REFERENCES Producto(ID_producto)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ===============================================
-- TABLA ZONA_EMPLEADO (N:M)
-- ===============================================
CREATE TABLE Zona_Empleado (
    ID_zona_empleado INT PRIMARY KEY,
    ID_zona INT NOT NULL,
    ID_empleado INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    FOREIGN KEY (ID_zona) REFERENCES Zona(ID_zona)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ID_empleado) REFERENCES Empleado(ID_empleado)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

-- ===============================================
-- VISTA DE ATRIBUTO DERIVADO
-- ===============================================
CREATE VIEW v_coste_pedido AS
SELECT 
    p.ID_pedido,
    SUM(pp.unidades * pr.precio) AS total_calculado
FROM Pedido p
JOIN Pedido_Producto pp ON p.ID_pedido = pp.ID_pedido
JOIN Producto pr ON pr.ID_producto = pp.ID_producto
GROUP BY p.ID_pedido;






INSERT INTO Vivero (ID_vivero, nombre, latitud, longitud) VALUES
(1, 'Vivero Norte', 28.480, -16.320),
(2, 'Vivero Sur', 28.050, -16.720),
(3, 'Vivero Este', 28.480, -16.220),
(4, 'Vivero Oeste', 28.500, -16.350),
(5, 'Vivero Central', 28.470, -16.280);


INSERT INTO Zona (ID_zona, ID_vivero, nombre, latitud, longitud) VALUES
(1, 1, 'Zona A', 28.481, -16.321),
(2, 1, 'Zona B', 28.482, -16.319),
(3, 2, 'Zona C', 28.051, -16.721),
(4, 3, 'Zona D', 28.481, -16.221),
(5, 4, 'Zona E', 28.501, -16.349),
(6, 5, 'Zona F', 28.471, -16.281);



INSERT INTO Cliente (ID_cliente, nombre, direccion) VALUES
(1, 'Ana Gómez', 'Calle Los Almendros 12, Santa Cruz'),
(2, 'Luis Pérez', 'Av. El Cardón 45, La Laguna'),
(3, 'Marta Díaz', 'Camino del Pino 7, Arona'),
(4, 'Carlos Ruiz', 'Calle Las Rosas 10, Adeje'),
(5, 'Lucía Hernández', 'Calle La Paz 21, Icod de los Vinos'),
(6, 'Pedro Morales', 'Av. El Hierro 99, La Orotava'),
(7, 'Nerea Martín', 'Calle Los Tiles 6, Tacoronte');


INSERT INTO Email (ID_email, ID_cliente, email) VALUES
(1, 1, 'ana.gomez@email.com'),
(2, 2, 'luisperez@email.com'),
(3, 3, 'marta.diaz@email.com'),
(4, 4, 'carlos.ruiz@email.com'),
(5, 5, 'lucia.hernandez@email.com'),
(6, 6, 'pedro.morales@email.com'),
(7, 7, 'nerea.martin@email.com');



INSERT INTO Telefono (ID_telefono, ID_cliente, telefono) VALUES
(1, 1, '689123456'),
(2, 2, '678987654'),
(3, 3, '627345678'),
(4, 4, '654111222'),
(5, 5, '612333444'),
(6, 6, '699555666'),
(7, 7, '611777888');



INSERT INTO Plus (ID_plus, ID_cliente, bonificacion, fecha_ingreso) VALUES
(1, 1, 5.00, '2023-05-10'),
(2, 2, 3.50, '2024-01-15'),
(3, 3, 7.25, '2022-12-01'),
(4, 4, 4.00, '2023-08-22'),
(5, 5, 2.75, '2024-06-05'),
(6, 6, 6.00, '2022-11-30'),
(7, 7, 5.50, '2023-09-10');





INSERT INTO Empleado (ID_empleado, DNI, nombre, latitud, longitud, puesto) VALUES
(1, '12345678A', 'Laura Ramos', 28.463, -16.251, 'Vendedor'),
(2, '23456789B', 'Juan Torres', 28.469, -16.290, 'Encargado'),
(3, '34567890C', 'Sofía López', 28.455, -16.300, 'Repartidor'),
(4, '45678901D', 'Andrés Navarro', 28.470, -16.265, 'Jardinero'),
(5, '56789012E', 'Elena Pérez', 28.460, -16.280, 'Administrativo'),
(6, '67890123F', 'David Molina', 28.458, -16.250, 'Vendedor');



INSERT INTO Producto (ID_producto, tipo, nombre, stock, precio) VALUES
(1, 'Planta', 'Rosa Mini', 50, 5.50),
(2, 'Planta', 'Helecho Boston', 30, 8.20),
(3, 'Decoración', 'Maceta Terracota', 100, 4.00),
(4, 'Jardinería', 'Tierra Universal 20L', 40, 6.75),
(5, 'Planta', 'Cactus Mexicano', 25, 9.90),
(6, 'Decoración', 'Farol Solar', 15, 14.50),
(7, 'Jardinería', 'Regadera Metálica', 20, 12.00);



INSERT INTO Zona_Producto (ID_zona_producto, ID_zona, ID_producto) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 2, 3),
(4, 3, 4),
(5, 4, 5),
(6, 5, 6),
(7, 6, 7);




INSERT INTO Zona_Empleado (ID_zona_empleado, ID_zona, ID_empleado, fecha_inicio, fecha_fin) VALUES
(1, 1, 1, '2024-01-10', NULL),
(2, 2, 2, '2024-02-15', NULL),
(3, 3, 3, '2024-03-05', NULL),
(4, 4, 4, '2024-04-20', NULL),
(5, 5, 5, '2024-05-25', NULL),
(6, 6, 6, '2024-06-10', NULL);




INSERT INTO Pedido (ID_pedido, ID_plus, ID_empleado, fecha, coste_final) VALUES
(1, 1, 1, '2024-10-01', 27.50),
(2, 2, 2, '2024-10-03', 54.00),
(3, 3, 3, '2024-10-04', 18.40),
(4, 4, 4, '2024-10-06', 36.75),
(5, 5, 5, '2024-10-07', 22.00),
(6, 6, 6, '2024-10-08', 45.60);




INSERT INTO Pedido_Producto (ID_pedido_producto, ID_pedido, ID_producto, unidades) VALUES
(1, 1, 1, 5),
(2, 1, 3, 2),
(3, 2, 4, 3),
(4, 3, 5, 1),
(5, 4, 2, 4),
(6, 5, 6, 1),
(7, 6, 7, 2);






SELECT * FROM Cliente;

SELECT * FROM Telefono;

SELECT * FROM Vivero;

SELECT * FROM Zona;

SELECT * FROM Empleado;

SELECT * FROM Producto;

SELECT * FROM Pedido;




