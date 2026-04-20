-- V2__Constraints_And_Indexes.sql
-- Restricciones referenciales, de dominio, índices y reglas de concurrencia.
-- Requiere btree_gist para la exclusión por rango.

CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE investigadores
    ADD CONSTRAINT fk_investigadores_categoria
    FOREIGN KEY (categoria_id)
    REFERENCES categorias_investigador (categoria_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

ALTER TABLE laboratorios
    ADD CONSTRAINT chk_laboratorios_bioseguridad
    CHECK (nivel_bioseguridad BETWEEN 1 AND 4);

ALTER TABLE laboratorios
    ADD CONSTRAINT chk_laboratorios_capacidad
    CHECK (capacidad > 0);

ALTER TABLE equipos
    ADD CONSTRAINT fk_equipos_laboratorio
    FOREIGN KEY (laboratorio_id)
    REFERENCES laboratorios (laboratorio_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE;

ALTER TABLE investigadores
    ADD CONSTRAINT uq_investigadores_codigo
    UNIQUE (codigo_investigador);

ALTER TABLE investigadores
    ADD CONSTRAINT uq_investigadores_correo
    UNIQUE (correo);

ALTER TABLE laboratorios
    ADD CONSTRAINT uq_laboratorios_nombre
    UNIQUE (nombre);

ALTER TABLE equipos
    ADD CONSTRAINT uq_equipos_codigo
    UNIQUE (codigo_equipo);

ALTER TABLE equipos
    ADD CONSTRAINT chk_equipos_estado
    CHECK (estado_operativo IN ('OPERATIVO', 'MANTENIMIENTO', 'FUERA_DE_SERVICIO'));

ALTER TABLE reservas
    ADD CONSTRAINT fk_reservas_investigador
    FOREIGN KEY (investigador_id)
    REFERENCES investigadores (investigador_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

ALTER TABLE reservas
    ADD CONSTRAINT fk_reservas_laboratorio
    FOREIGN KEY (laboratorio_id)
    REFERENCES laboratorios (laboratorio_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

ALTER TABLE reservas
    ADD CONSTRAINT chk_reservas_rango
    CHECK (fecha_fin > fecha_inicio);

ALTER TABLE reservas
    ADD CONSTRAINT chk_reservas_estado
    CHECK (estado IN ('PENDIENTE', 'APROBADA', 'CANCELADA', 'FINALIZADA'));

ALTER TABLE reserva_equipos
    ADD CONSTRAINT fk_reserva_equipos_reserva
    FOREIGN KEY (reserva_id)
    REFERENCES reservas (reserva_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE;

ALTER TABLE reserva_equipos
    ADD CONSTRAINT fk_reserva_equipos_equipo
    FOREIGN KEY (equipo_id)
    REFERENCES equipos (equipo_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

ALTER TABLE reserva_equipos
    ADD CONSTRAINT uq_reserva_equipo
    UNIQUE (reserva_id, equipo_id);

-- Un investigador no puede tener dos reservas que se traslapen.
ALTER TABLE reservas
    ADD CONSTRAINT ex_reservas_investigador_no_solape
    EXCLUDE USING gist (
        investigador_id WITH =,
        tstzrange(fecha_inicio, fecha_fin, '[)') WITH &&
    )
    WHERE (estado <> 'CANCELADA');

-- Un laboratorio no puede ser reservado por dos personas en el mismo intervalo.
ALTER TABLE reservas
    ADD CONSTRAINT ex_reservas_laboratorio_no_solape
    EXCLUDE USING gist (
        laboratorio_id WITH =,
        tstzrange(fecha_inicio, fecha_fin, '[)') WITH &&
    )
    WHERE (estado <> 'CANCELADA');

CREATE INDEX idx_reservas_fecha_inicio ON reservas (fecha_inicio);
CREATE INDEX idx_reservas_fecha_fin ON reservas (fecha_fin);
CREATE INDEX idx_reservas_investigador_fecha ON reservas (investigador_id, fecha_inicio DESC);
CREATE INDEX idx_reservas_laboratorio_fecha ON reservas (laboratorio_id, fecha_inicio DESC);
CREATE INDEX idx_equipos_laboratorio_estado ON equipos (laboratorio_id, estado_operativo);
CREATE INDEX idx_reserva_equipos_equipo ON reserva_equipos (equipo_id);
