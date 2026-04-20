-- V5__Seed_Data.sql
-- Datos de prueba para validar restricciones, triggers y auditoría.

SET search_path TO sigebio, public;

INSERT INTO categorias_investigador (categoria_id, nombre) VALUES
(1, 'Investigador Junior'),
(2, 'Investigador Senior'),
(3, 'Director de Proyecto');

INSERT INTO investigadores (investigador_id, categoria_id, codigo_investigador, nombres, apellidos, correo, telefono) VALUES
('79959963-52d4-41bd-82a5-ec2bfe5e8ef4', 1, 'INV-001', 'Ana', 'López', 'ana.lopez@ues.edu.sv', '7000-0001'),
('054a95d4-f4f6-4a47-84d6-fe4ccb5ad22d', 1, 'INV-002', 'Luis', 'Pérez', 'luis.perez@ues.edu.sv', '7000-0002'),
('69018716-5efb-4d5a-bc10-a08f4dd68f0c', 2, 'INV-003', 'Marta', 'Sánchez', 'marta.sanchez@ues.edu.sv', '7000-0003'),
('48e32ca1-566b-4c1b-a3b9-cf19b34a0bec', 2, 'INV-004', 'Carlos', 'Ramírez', 'carlos.ramirez@ues.edu.sv', '7000-0004'),
('77e0dceb-4605-4d82-93bd-45c410ab1ae0', 3, 'INV-005', 'Elena', 'Morales', 'elena.morales@ues.edu.sv', '7000-0005');

INSERT INTO laboratorios (laboratorio_id, nombre, nivel_bioseguridad, capacidad, ubicacion, activo) VALUES
('d88c3f8e-6973-4b1d-b95f-fc0442a64098', 'Laboratorio Genómica', 2, 12, 'Edificio A - Nivel 2', TRUE),
('06d8bae6-8de7-4561-b87e-f8f68646d61b', 'Laboratorio Cultivos', 3, 10, 'Edificio B - Nivel 3', TRUE),
('8f5a066d-09f2-4816-b26f-5015dbab344c', 'Laboratorio Virología', 4, 8, 'Edificio C - Nivel 4', TRUE),
('2404e19c-88b7-4323-b0c2-1b2dbb9aae89', 'Laboratorio Microscopia', 1, 15, 'Edificio A - Nivel 1', TRUE),
('eae6ee34-31e5-4308-8c0c-23106fa693e0', 'Laboratorio Bioquímica', 2, 11, 'Edificio D - Nivel 2', TRUE);

INSERT INTO equipos (equipo_id, laboratorio_id, codigo_equipo, nombre, descripcion, estado_operativo) VALUES
('68eeae17-c39c-4082-b7e8-755870b959cc', 'd88c3f8e-6973-4b1d-b95f-fc0442a64098', 'EQ-001', 'Centrífuga', 'Centrífuga de alta velocidad', 'OPERATIVO'),
('488feddc-6626-49e7-8f53-600bc798a547', 'd88c3f8e-6973-4b1d-b95f-fc0442a64098', 'EQ-002', 'PCR', 'Termociclador PCR', 'OPERATIVO'),
('5e18bcb3-adaa-4cc4-9d9d-e35c88f49953', '06d8bae6-8de7-4561-b87e-f8f68646d61b', 'EQ-003', 'Incubadora', 'Incubadora controlada', 'OPERATIVO'),
('b7954d31-373f-4b45-a2de-ec142fa034ff', '06d8bae6-8de7-4561-b87e-f8f68646d61b', 'EQ-004', 'Autoclave', 'Autoclave industrial', 'MANTENIMIENTO'),
('30c33d31-7960-45db-9205-69562ce5de75', '8f5a066d-09f2-4816-b26f-5015dbab344c', 'EQ-005', 'Cabina Biosegura', 'Cabina de bioseguridad nivel III', 'OPERATIVO'),
('b26c6fd6-a1a9-4489-8ef0-38f7208a2053', '8f5a066d-09f2-4816-b26f-5015dbab344c', 'EQ-006', 'Congelador -80', 'Congelador ultra bajo', 'OPERATIVO'),
('02fc60ee-c582-4342-a5ef-5f6f5dd5c414', '2404e19c-88b7-4323-b0c2-1b2dbb9aae89', 'EQ-007', 'Microscopio', 'Microscopio de fluorescencia', 'OPERATIVO'),
('07c1b07d-73ff-40b8-8f4b-b27ad63ae02e', 'eae6ee34-31e5-4308-8c0c-23106fa693e0', 'EQ-008', 'Agitador', 'Agitador orbital', 'OPERATIVO'),
('5a1354e1-9b6b-4e13-b637-f96bce4097f5', 'eae6ee34-31e5-4308-8c0c-23106fa693e0', 'EQ-009', 'Balanza', 'Balanza analítica', 'FUERA_DE_SERVICIO'),
('8a6bce48-f96b-4a1a-979f-e84e26a71528', 'd88c3f8e-6973-4b1d-b95f-fc0442a64098', 'EQ-010', 'Espectrofotómetro', 'Espectrofotómetro UV-Vis', 'OPERATIVO');

-- Las reservas deben cumplir:
-- 1) No traslaparse por investigador.
-- 2) No traslaparse por laboratorio.
-- 3) Bioseguridad 4 solo para Director de Proyecto.
INSERT INTO reservas (reserva_id, investigador_id, laboratorio_id, fecha_inicio, fecha_fin, motivo, estado) VALUES
('7aa650ab-bc7b-45b3-8f98-1b94b161b9b1', '79959963-52d4-41bd-82a5-ec2bfe5e8ef4', 'd88c3f8e-6973-4b1d-b95f-fc0442a64098', '2026-04-21 08:00:00+00', '2026-04-21 10:00:00+00', 'Secuenciación inicial', 'APROBADA'),
('4c17a43b-c95d-4004-bc2c-73d6c06b0864', '69018716-5efb-4d5a-bc10-a08f4dd68f0c', '06d8bae6-8de7-4561-b87e-f8f68646d61b', '2026-04-21 10:30:00+00', '2026-04-21 12:00:00+00', 'Cultivo de muestras', 'APROBADA'),
('1a9cb375-d656-4658-986f-e86a9dad6dcc', '77e0dceb-4605-4d82-93bd-45c410ab1ae0', '8f5a066d-09f2-4816-b26f-5015dbab344c', '2026-04-22 08:00:00+00', '2026-04-22 11:00:00+00', 'Análisis virológico', 'APROBADA'),
('514a5fae-7594-418b-811f-c288e645118f', '054a95d4-f4f6-4a47-84d6-fe4ccb5ad22d', '2404e19c-88b7-4323-b0c2-1b2dbb9aae89', '2026-04-22 13:00:00+00', '2026-04-22 15:00:00+00', 'Observación de muestras', 'PENDIENTE'),
('6d14b75b-4378-4a13-b6ec-2d284ec79d0f', '48e32ca1-566b-4c1b-a3b9-cf19b34a0bec', 'eae6ee34-31e5-4308-8c0c-23106fa693e0', '2026-04-23 09:00:00+00', '2026-04-23 11:30:00+00', 'Preparación de reactivos', 'APROBADA');

INSERT INTO reserva_equipos (reserva_equipo_id, reserva_id, equipo_id) VALUES
('d323d4ad-4d39-453b-a89d-ccf816391fe7', '7aa650ab-bc7b-45b3-8f98-1b94b161b9b1', '68eeae17-c39c-4082-b7e8-755870b959cc'),
('b3e54651-97d0-43b9-b49f-411118c77a0c', '7aa650ab-bc7b-45b3-8f98-1b94b161b9b1', '488feddc-6626-49e7-8f53-600bc798a547'),
('f5fa302e-e1db-4f10-bc6f-5ca3e3b46c7c', '4c17a43b-c95d-4004-bc2c-73d6c06b0864', '5e18bcb3-adaa-4cc4-9d9d-e35c88f49953'),
('36d3e3c9-8d19-4dbf-b0f3-8d02a809f519', '1a9cb375-d656-4658-986f-e86a9dad6dcc', '30c33d31-7960-45db-9205-69562ce5de75'),
('3b432239-6ab1-43bb-ad17-cc486ac6f977', '1a9cb375-d656-4658-986f-e86a9dad6dcc', 'b26c6fd6-a1a9-4489-8ef0-38f7208a2053'),
('3f1b7326-46b6-498d-ab39-637a30ec6511', '514a5fae-7594-418b-811f-c288e645118f', '02fc60ee-c582-4342-a5ef-5f6f5dd5c414'),
('0e7d39fc-45ae-47b3-8dc1-779503e0e2b4', '6d14b75b-4378-4a13-b6ec-2d284ec79d0f', '07c1b07d-73ff-40b8-8f4b-b27ad63ae02e'); 
-- Quité la línea del equipo 8a6b... porque pertenece a otro laboratorio.

-- Ejemplos de pruebas negativas (deben fallar si se ejecutan manualmente):
-- 1) Investigador no director intentando reservar un laboratorio nivel 4.
-- 2) Intentar reservar un equipo en mantenimiento o fuera de servicio.
-- 3) Crear una reserva traslapada del mismo investigador.
-- 4) Reservar un equipo que pertenece a otro laboratorio.


UPDATE equipos
   SET ultima_revision = '2026-04-20',
       responsable_mantenimiento = 'Técnico Luis Herrera',
       observaciones_mantenimiento = 'Revisión preventiva completada'
 WHERE codigo_equipo IN ('EQ-001', 'EQ-004', 'EQ-005');

