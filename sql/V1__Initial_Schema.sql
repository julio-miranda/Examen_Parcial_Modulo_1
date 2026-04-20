-- V1__Initial_Schema.sql
-- SIGEBIO+ | Esquema inicial
-- Contiene solo el esquema base y las tablas principales con sus PK.

CREATE SCHEMA IF NOT EXISTS sigebio;
SET search_path TO sigebio, public;

CREATE TABLE categorias_investigador (
    categoria_id SMALLINT PRIMARY KEY,
    nombre       VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE investigadores (
    investigador_id   UUID PRIMARY KEY,
    categoria_id       SMALLINT NOT NULL,
    codigo_investigador VARCHAR(20) NOT NULL,
    nombres            VARCHAR(120) NOT NULL,
    apellidos          VARCHAR(120) NOT NULL,
    correo             VARCHAR(150) NOT NULL,
    telefono           VARCHAR(30)
);

CREATE TABLE laboratorios (
    laboratorio_id      UUID PRIMARY KEY,
    nombre              VARCHAR(120) NOT NULL,
    nivel_bioseguridad  SMALLINT NOT NULL,
    capacidad           INTEGER NOT NULL,
    ubicacion           VARCHAR(150),
    activo              BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE equipos (
    equipo_id      UUID PRIMARY KEY,
    laboratorio_id  UUID NOT NULL,
    codigo_equipo   VARCHAR(30) NOT NULL,
    nombre          VARCHAR(120) NOT NULL,
    descripcion     TEXT,
    estado_operativo VARCHAR(30) NOT NULL DEFAULT 'OPERATIVO'
);

CREATE TABLE reservas (
    reserva_id       UUID PRIMARY KEY,
    investigador_id   UUID NOT NULL,
    laboratorio_id    UUID NOT NULL,
    fecha_inicio      TIMESTAMPTZ NOT NULL,
    fecha_fin         TIMESTAMPTZ NOT NULL,
    motivo            TEXT NOT NULL,
    estado            VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    creado_en         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE reserva_equipos (
    reserva_equipo_id UUID PRIMARY KEY,
    reserva_id        UUID NOT NULL,
    equipo_id         UUID NOT NULL
);
