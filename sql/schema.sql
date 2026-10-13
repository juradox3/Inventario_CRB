-- =========================================================
-- Sistema de Inventario de Bienes - Colegio Cristo Rey Bogota
-- Script de creacion de tablas (coincide con el Anexo del documento
-- Sistema_Inventario_CRB.docx)
-- =========================================================

-- =========================================================
-- Catalogos base
-- =========================================================

CREATE TABLE ubicaciones (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(120) NOT NULL UNIQUE  -- ej. "Oficina de Sistemas", "Biblioteca Primaria"
);

CREATE TABLE categorias (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(120) NOT NULL UNIQUE  -- ej. "Portatiles", "Impresoras", "Herramientas"
);

CREATE TABLE roles (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(60) NOT NULL UNIQUE   -- ej. "Administrador", "Auxiliar", "Consulta"
);

-- =========================================================
-- Personas y usuarios
-- =========================================================

-- Cualquier persona relacionada con el inventario (responsables, solicitantes,
-- firmantes), tenga o no una cuenta para entrar al sistema.
CREATE TABLE personas (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(150) NOT NULL,
    cargo       VARCHAR(120)                  -- cargo actual de la persona
);

-- Solo quienes necesitan iniciar sesion en el sistema tienen un usuario.
CREATE TABLE usuarios (
    id          SERIAL PRIMARY KEY,
    persona_id  INTEGER NOT NULL REFERENCES personas(id),
    correo      VARCHAR(150) NOT NULL UNIQUE,
    rol_id      INTEGER NOT NULL REFERENCES roles(id),
    creado_en   TIMESTAMP NOT NULL DEFAULT now()
);

-- =========================================================
-- Bienes
-- =========================================================

CREATE TABLE bienes (
    id              SERIAL PRIMARY KEY,
    placa_serial    VARCHAR(80),               -- opcional: placa o numero de serie
    descripcion     VARCHAR(255) NOT NULL,
    categoria_id    INTEGER NOT NULL REFERENCES categorias(id),
    ubicacion_id    INTEGER NOT NULL REFERENCES ubicaciones(id),
    cantidad        INTEGER NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    estado          VARCHAR(20) NOT NULL DEFAULT 'disponible'
                        CHECK (estado IN ('disponible','prestado','mantenimiento','danado','baja')),
    acta_compra     VARCHAR(60),               -- acta/comprobante de compra (ej. "CI - DAF - 09/2025")
    foto_url        TEXT,
    observaciones   TEXT,
    creado_en       TIMESTAMP NOT NULL DEFAULT now()
);

-- =========================================================
-- Movimientos (traslados, bajas, ajustes)
-- =========================================================

CREATE TABLE movimientos (
    id                      SERIAL PRIMARY KEY,
    bien_id                 INTEGER NOT NULL REFERENCES bienes(id),
    tipo                    VARCHAR(20) NOT NULL
                                CHECK (tipo IN ('traslado','baja','ajuste','mantenimiento')),
    usuario_id              INTEGER NOT NULL REFERENCES usuarios(id),
    fecha_hora              TIMESTAMP NOT NULL DEFAULT now(),
    ubicacion_origen_id     INTEGER REFERENCES ubicaciones(id),
    ubicacion_destino_id    INTEGER REFERENCES ubicaciones(id),
    observacion             TEXT
);

-- =========================================================
-- Prestamos (solo bienes individuales, cantidad = 1)
-- =========================================================

CREATE TABLE prestamos (
    id                          SERIAL PRIMARY KEY,
    bien_id                     INTEGER NOT NULL REFERENCES bienes(id),
    solicitante_id              INTEGER NOT NULL REFERENCES personas(id),
    cargo_solicitante           VARCHAR(120),   -- cargo de la persona al momento del prestamo
    autorizado_por_id           INTEGER NOT NULL REFERENCES usuarios(id),
    ubicacion_destino_id        INTEGER REFERENCES ubicaciones(id),
    fecha_hora_salida           TIMESTAMP NOT NULL DEFAULT now(),
    fecha_hora_devolucion_esp   TIMESTAMP,
    fecha_hora_devolucion_real  TIMESTAMP,
    estado                      VARCHAR(20) NOT NULL DEFAULT 'prestado'
                                    CHECK (estado IN ('prestado','devuelto','vencido','perdido')),
    condicion_salida            VARCHAR(255),
    condicion_entrada           VARCHAR(255),
    observaciones               TEXT
);

-- =========================================================
-- Levantamientos de inventario (conteo fisico por ubicacion)
-- =========================================================

CREATE TABLE levantamientos_inventario (
    id                      SERIAL PRIMARY KEY,
    ubicacion_id            INTEGER NOT NULL REFERENCES ubicaciones(id),
    fecha_hora              TIMESTAMP NOT NULL DEFAULT now(),
    responsable_id          INTEGER NOT NULL REFERENCES personas(id),
    cargo_responsable       VARCHAR(120),
    registrado_por_id       INTEGER REFERENCES personas(id),
    revisado_por_id         INTEGER REFERENCES personas(id),
    verificado_por_id       INTEGER REFERENCES personas(id),
    estado                  VARCHAR(20) NOT NULL DEFAULT 'borrador'
                                CHECK (estado IN ('borrador','verificado'))
);

-- =========================================================
-- Datos iniciales de catalogos (roles base)
-- =========================================================

INSERT INTO roles (nombre) VALUES
    ('Administrador'),
    ('Auxiliar de inventario'),
    ('Directivo'),
    ('Consulta');
