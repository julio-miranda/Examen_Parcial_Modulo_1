-- V3__Auditing_Logic.sql
-- Lógica avanzada: auditoría y validaciones por rango / estado.

CREATE TABLE IF NOT EXISTS log_auditoria (
    audit_id         BIGSERIAL PRIMARY KEY,
    tabla_afectada   VARCHAR(80) NOT NULL,
    operacion        VARCHAR(10) NOT NULL,
    usuario_db       VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,
    usuario_app      VARCHAR(100),
    fecha_hora       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    registro_id      UUID,
    datos_anteriores JSONB,
    datos_nuevos     JSONB
);

CREATE OR REPLACE FUNCTION fn_validar_reserva_investigador_bsl4()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_nivel SMALLINT;
    v_categoria VARCHAR(40);
BEGIN
    SELECT l.nivel_bioseguridad
      INTO v_nivel
      FROM laboratorios l
     WHERE l.laboratorio_id = NEW.laboratorio_id;

    IF v_nivel IS NULL THEN
        RAISE EXCEPTION 'El laboratorio % no existe.', NEW.laboratorio_id;
    END IF;

    SELECT c.nombre
      INTO v_categoria
      FROM investigadores i
      JOIN categorias_investigador c ON c.categoria_id = i.categoria_id
     WHERE i.investigador_id = NEW.investigador_id;

    IF v_nivel = 4 AND v_categoria IS DISTINCT FROM 'Director de Proyecto' THEN
        RAISE EXCEPTION
            'Solo un investigador con rango Director de Proyecto puede reservar laboratorios de bioseguridad 4.';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_reserva_bsl4
BEFORE INSERT OR UPDATE OF investigador_id, laboratorio_id
ON reservas
FOR EACH ROW
EXECUTE FUNCTION fn_validar_reserva_investigador_bsl4();

CREATE OR REPLACE FUNCTION fn_validar_equipo_reservable()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_estado VARCHAR(30);
    v_lab_reserva UUID;
    v_lab_equipo UUID;
    v_inicio TIMESTAMPTZ;
    v_fin TIMESTAMPTZ;
    v_conflicto UUID;
    v_self_id UUID;
BEGIN
    IF TG_OP = 'UPDATE' THEN
        v_self_id := OLD.reserva_equipo_id;
    END IF;

    SELECT e.estado_operativo, e.laboratorio_id
      INTO v_estado, v_lab_equipo
      FROM equipos e
     WHERE e.equipo_id = NEW.equipo_id;

    IF v_estado IS NULL THEN
        RAISE EXCEPTION 'El equipo % no existe.', NEW.equipo_id;
    END IF;

    IF v_estado <> 'OPERATIVO' THEN
        RAISE EXCEPTION 'El equipo % no puede reservarse porque su estado es %.', NEW.equipo_id, v_estado;
    END IF;

    SELECT r.laboratorio_id, r.fecha_inicio, r.fecha_fin
      INTO v_lab_reserva, v_inicio, v_fin
      FROM reservas r
     WHERE r.reserva_id = NEW.reserva_id;

    IF v_lab_reserva IS NULL THEN
        RAISE EXCEPTION 'La reserva % no existe.', NEW.reserva_id;
    END IF;

    IF v_lab_equipo <> v_lab_reserva THEN
        RAISE EXCEPTION 'El equipo % no pertenece al laboratorio de la reserva.', NEW.equipo_id;
    END IF;

    SELECT re.reserva_equipo_id
      INTO v_conflicto
      FROM reserva_equipos re
      JOIN reservas r2 ON r2.reserva_id = re.reserva_id
     WHERE re.equipo_id = NEW.equipo_id
       AND r2.estado <> 'CANCELADA'
       AND tstzrange(r2.fecha_inicio, r2.fecha_fin, '[)') && tstzrange(v_inicio, v_fin, '[)')
       AND (v_self_id IS NULL OR re.reserva_equipo_id <> v_self_id)
     LIMIT 1;

    IF v_conflicto IS NOT NULL THEN
        RAISE EXCEPTION 'El equipo % ya está reservado en ese intervalo de tiempo.', NEW.equipo_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_equipo_reservable
BEFORE INSERT OR UPDATE OF reserva_id, equipo_id
ON reserva_equipos
FOR EACH ROW
EXECUTE FUNCTION fn_validar_equipo_reservable();

CREATE OR REPLACE FUNCTION fn_auditar_evento()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_usuario_app TEXT := current_setting('app.user', true);
    v_registro_id UUID;
BEGIN
    IF TG_TABLE_NAME = 'reservas' THEN
        IF TG_OP = 'DELETE' THEN
            v_registro_id := OLD.reserva_id;
        ELSE
            v_registro_id := NEW.reserva_id;
        END IF;
    ELSIF TG_TABLE_NAME = 'reserva_equipos' THEN
        IF TG_OP = 'DELETE' THEN
            v_registro_id := OLD.reserva_equipo_id;
        ELSE
            v_registro_id := NEW.reserva_equipo_id;
        END IF;
    ELSIF TG_TABLE_NAME = 'equipos' THEN
        IF TG_OP = 'DELETE' THEN
            v_registro_id := OLD.equipo_id;
        ELSE
            v_registro_id := NEW.equipo_id;
        END IF;
    END IF;

    IF TG_OP = 'DELETE' THEN
        INSERT INTO log_auditoria(tabla_afectada, operacion, usuario_db, usuario_app, registro_id, datos_anteriores, datos_nuevos)
        VALUES (
            TG_TABLE_NAME,
            TG_OP,
            CURRENT_USER,
            NULLIF(v_usuario_app, ''),
            v_registro_id,
            to_jsonb(OLD),
            NULL
        );
        RETURN OLD;
    ELSE
        INSERT INTO log_auditoria(tabla_afectada, operacion, usuario_db, usuario_app, registro_id, datos_anteriores, datos_nuevos)
        VALUES (
            TG_TABLE_NAME,
            TG_OP,
            CURRENT_USER,
            NULLIF(v_usuario_app, ''),
            v_registro_id,
            CASE WHEN TG_OP = 'UPDATE' THEN to_jsonb(OLD) ELSE NULL END,
            to_jsonb(NEW)
        );
        RETURN NEW;
    END IF;
END;
$$;

CREATE TRIGGER trg_auditar_reservas
AFTER INSERT OR UPDATE OR DELETE
ON reservas
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_evento();

CREATE TRIGGER trg_auditar_reserva_equipos
AFTER INSERT OR UPDATE OR DELETE
ON reserva_equipos
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_evento();

CREATE TRIGGER trg_auditar_equipos
AFTER INSERT OR UPDATE OR DELETE
ON equipos
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_evento();
