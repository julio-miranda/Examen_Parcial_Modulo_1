-- V4__Equipment_Maintenance.sql
-- Evolución del esquema para control de mantenimiento.

ALTER TABLE equipos
    ADD COLUMN ultima_revision DATE,
    ADD COLUMN responsable_mantenimiento VARCHAR(150),
    ADD COLUMN observaciones_mantenimiento TEXT;
