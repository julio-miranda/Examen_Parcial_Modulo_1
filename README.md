# SIGEBIO+

Repositorio base para el examen práctico de PostgreSQL + Flyway + Git/GitHub.

## Estructura sugerida

- `sql/V1__Initial_Schema.sql`
- `sql/V2__Constraints_And_Indexes.sql`
- `sql/V3__Auditing_Logic.sql`
- `sql/V4__Equipment_Maintenance.sql`
- `sql/V5__Seed_Data.sql`
- `docs/ERD.png`
- `flyway.toml.example`

## Modelo lógico resumido

- `categorias_investigador(1) ---- (N) investigadores`
- `investigadores(1) ---- (N) reservas`
- `laboratorios(1) ---- (N) equipos`
- `laboratorios(1) ---- (N) reservas`
- `reservas(1) ---- (N) reserva_equipos`
- `equipos(1) ---- (N) reserva_equipos`
- `reservas / reserva_equipos / equipos ---- log_auditoria` mediante triggers

## Reglas de negocio implementadas

1. Un investigador no puede tener dos reservas traslapadas.
2. Un laboratorio no puede estar reservado por dos personas al mismo tiempo.
3. Los laboratorios nivel 4 solo pueden ser reservados por `Director de Proyecto`.
4. Un equipo no puede asignarse si está en `MANTENIMIENTO` o `FUERA_DE_SERVICIO`.
5. La tabla de auditoría registra `usuario_db`, `usuario_app`, fecha y operación.

## Flyway

Ejemplo de secuencia:
1. `V1__Initial_Schema.sql`
2. `V2__Constraints_And_Indexes.sql`
3. `V3__Auditing_Logic.sql`
4. `V4__Equipment_Maintenance.sql`
5. `V5__Seed_Data.sql`

Validación:
```bash
flyway info
flyway validate
```

## Git recomendado

- `feature/schema-base`
- `feature/constraints`
- `feature/triggers`
- `feature/maintenance`
- `feature/seed-data`

Commits sugeridos:
- `chore: create initial schema`
- `feat: add constraints and indexes`
- `feat: add validation and auditing triggers`
- `feat: add equipment maintenance fields`
- `test: add seed data for validation`

## Nota

Para que la auditoría registre un usuario de aplicación diferente al usuario DB, la app puede ejecutar:

```sql
SET app.user = 'nombre_usuario';
```
