# AquaControl: documentación técnica de avance

**Fecha de inspección:** 6 de octubre de 2026  
**Proyecto inspeccionado:** aplicación Flutter `aqua_control`  
**Estado del proyecto:** en desarrollo.  
**Alcance de esta documentación:** corte de avance elaborado mediante lectura estática del árbol de trabajo en la ruta indicada por el usuario. Registra lo construido hasta este momento, distingue los componentes conectados de los prototipos y enumera las siguientes áreas que aún requieren desarrollo o validación. No representa una entrega final ni afirma que la aplicación esté terminada. No se ejecutó la aplicación ni se verificó una instancia real de Supabase.

> **Criterio de evidencia:** “Implementado” significa que hay código ejecutable que realiza la operación; que exista una pantalla, campo, dependencia o script SQL no demuestra por sí mismo que una función esté conectada o desplegada. Las credenciales y valores de configuración que puedan ser sensibles se omiten o sustituyen por `[REDACTADO]`.

## 1. Resumen ejecutivo del avance

AquaControl es un proyecto de aplicación Flutter en desarrollo, con interfaz en español, cuyo alcance contempla administrar clientes, trabajadores, zonas y despachadores, y registrar operaciones de abastecimiento con nombre de quien recibe y firma. En el avance actual ya hay pantallas para perfiles administrador y trabajador, paneles de indicadores, filtros, historial tabular y gráfico, y generación/impresión PDF.

La etapa actual tiene componentes de interfaz y lógica local funcional en memoria: las colecciones globales de zonas, clientes, trabajadores y movimientos comienzan vacías y las funciones CRUD editan esas colecciones durante la vida del proceso. También se ha preparado la inicialización del SDK de Supabase y un esquema SQL, pero la integración de persistencia remota todavía está pendiente en las pantallas.

El lector QR es una maqueta interactiva: el toque en el marco abre el detalle del despachador `#023`; no se observa acceso a cámara ni decodificación de QR. La pantalla de firma sí captura trazos y valida nombre y firma antes de crear el registro en memoria. El PDF se genera a partir de los registros en memoria.

El repositorio contiene una prueba unitaria para operaciones de abastecimiento/reabastecimiento y alta de cliente/trabajador. La prueba de movimientos espera encontrar el despachador `#024`, pero el catálogo inicial de zonas y despachadores está vacío; por lectura del código hay un pendiente de sincronizar las pruebas con los datos del avance actual. No se ejecutó la prueba.

## 2. Propósito y problema abordado según los artefactos disponibles

El comentario inicial de `implementation_plan.md` plantea mejoras para administrar zonas, clientes, precios por garrafón, personal, despachadores, abastecimientos, firmas, historial imprimible y navegación para administrador y trabajador. El problema operativo implícito es organizar y dar seguimiento a los abastecimientos por punto/despachador, conservar evidencia de entrega y consultar cantidades y movimientos.

El repositorio no incluye en su README una descripción del problema ni del contexto de estadías: `README.md` conserva únicamente el texto genérico “A new Flutter project.” Por ello, la motivación institucional, empresa, alcance del piloto y beneficios reales deben completarse con información del usuario y no se deducen del código.

## 3. Alcance funcional real

### Implementado en la aplicación

- Selección entre los perfiles de administrador y trabajador.
- Acceso de administrador que abre el panel sin validar credenciales.
- Acceso de trabajador comparando identificador y contraseña contra objetos `WorkerItem` locales.
- Selección de empresa/cliente para la sesión del trabajador y opción de cambiar la empresa.
- Altas, ediciones, bajas y cambios de estado locales para clientes, zonas y despachadores; alta y consulta de trabajadores.
- Asignación de despachadores a clientes, con lógica para retirarlos de la asignación de otros clientes.
- Búsqueda y filtros locales en listados de clientes, trabajadores, zonas/puntos y despachadores.
- Flujo de detalle de despachador, selección de abastecimiento/reabastecimiento y cantidad de garrafones.
- Captura de nombre de receptor y firma manuscrita en pantalla; creación de un `SupplyRecord` local y actualización del estado/cantidad del despachador local.
- Tablero con métricas derivadas de las colecciones locales, historial con filtro por cliente, vistas de tabla y gráfica de barras, vista de firma y generación/diálogo de impresión PDF.
- Activación/desactivación de la modalidad QR por cliente en el estado local; en modo desactivado se muestra una vista explicativa al trabajador.
- Autocompletado aproximado de ciudad/estado a partir del código postal, usando un catálogo local y una regla por prefijo.

### Parcialmente implementado o de demostración

- **Supabase:** SDK configurado e inicializado en `main()`, configuración SQL para crear backend disponible, pero las operaciones de negocio de Flutter usan las colecciones globales locales. No hay sincronización ni persistencia remota comprobable.
- **Autenticación/roles:** se muestra un flujo visual por rol; administrador entra directamente y el trabajador se valida localmente. No hay sesión autenticada de Supabase, recuperación de contraseña, control de acceso del servidor ni autorización por rol en base de datos.
- **QR:** pantalla visual y navegación de prueba, sin lector real, cámara ni asociación del contenido escaneado al registro.
- **Firma:** los trazos se conservan como puntos `Offset` en memoria y se presentan en pantalla/tabla/PDF. No se sube imagen ni puntos a Storage desde Flutter.
- **Historial resumido:** `HistoryScreen` tiene elementos de ejemplo constantes independientes del almacén global y no está conectado al shell principal.
- **Datos de catálogo:** los catálogos globales de zonas, clientes, trabajadores y registros se inicializan vacíos; no hay carga de semillas en el código revisado.
- **Campos de trabajador:** alta y consulta existen, pero no se encontró una ruta de edición/baja de trabajador conectada a una operación CRUD completa.

### Previsto en artefactos, no implementado o no conectado

- Persistencia de clientes, zonas, trabajadores, despachadores y registros en Supabase.
- Inicio de sesión contra Supabase Auth, almacenamiento seguro de credenciales y autorización en servidor.
- Escaneo/lectura real de QR, generación/impresión de códigos QR y permiso de cámara.
- Uso del esquema de Supabase y de sus vistas, triggers, Storage o canal Realtime desde Flutter.
- Sincronización offline/online, cola de cambios, detección de conectividad y resolución de conflictos.
- `SettingsScreen` como sección integrada de la navegación de producción y `HistoryScreen` como fuente real de datos.
- Despliegue, firma de publicación y distribución en tiendas configurados de manera verificable.

## 4. Arquitectura general y flujo de datos

La estructura es una aplicación monolítica Flutter organizada por pantallas, modelos, servicios, tema, utilidades y widgets. `lib/main.dart` inicializa Flutter, ejecuta `SupabaseService.initialize()`, fija orientación vertical y carga `AquaControlApp`. `MaterialApp` usa el tema Aqua y `RoleSelectionScreen` como página inicial.

Flujo principal de administrador: `RoleSelectionScreen` → `LoginScreen(initialRole: admin)` → `AppShell` → `AdminDashboardScreen`, `ClientsScreen` o `WorkerHistoryTableScreen`. El login administrador no consulta ni compara usuario/contraseña antes de abrir `AppShell`.

Flujo principal de trabajador: `RoleSelectionScreen` → `LoginScreen(initialRole: worker)` → comprobación local en `kDefaultWorkers` → selección de cliente si corresponde → `WorkerSession` estática → `WorkerShell`. El shell ofrece escaneo visual, lista de despachadores y tabla de historial. La selección de cliente y trabajador permanece en memoria.

Los listados, tarjetas, KPIs y formularios leen y mutan directamente `kDefaultZones`, `kDefaultClients`, `kDefaultWorkers` y `kSupplyRecords`, definidas en `lib/models/zone_data.dart`. No se encontró una capa repositorio ni DTO/serialización JSON para estas entidades. El único servicio es `SupabaseService`, que contiene valores de inicialización y un getter del cliente de Supabase.

### Flujo de abastecimiento que sí ejecuta el código

1. En `WorkerShell`, si el cliente activo tiene QR habilitado, se muestra `QrScannerScreen`; si está deshabilitado, se muestra una pantalla informativa.
2. Al tocar el marco del escáner, `_onDetectQr()` navega a `DispenserDetailScreen` con el ID fijo `#023`. No hay detección de cámara ni lectura de contenido.
3. El detalle permite cambiar entre abastecimiento y reabastecimiento y ajustar la cantidad de garrafones. Toma el cliente activo local o el primer cliente existente.
4. La pantalla de detalle abre `DigitalSignatureScreen` con ID, zona, operación, trabajador, cliente y precio.
5. `_onConfirm()` requiere nombre de receptor y puntos de firma. Llama a `markDispenserSupplied()` o `resupplyDispenser()` del modelo, que actualizan el dispensador y agregan un registro a `kSupplyRecords`.
6. Se abre `SuccessScreen` con resumen y vista de la firma. El registro es volátil y no se envía al servidor.

## 5. Tecnologías y versiones detectables

| Tecnología | Evidencia/versión declarada |
|---|---|
| Flutter / Dart | `pubspec.yaml`: SDK Dart `^3.11.5`; `pubspec.lock`: Dart `>=3.12.0 <4.0.0` y Flutter `>=3.44.0`. El lockfile refleja el entorno que lo generó, no una garantía de versión instalada en otra máquina. |
| Supabase Flutter | `supabase_flutter ^2.18.0`; lockfile `2.18.0`. |
| Google Fonts | `google_fonts ^8.2.1`; lockfile `8.2.1`. |
| PDF e impresión | `pdf ^3.13.0` y `printing ^5.15.0`, fijadas también en el lockfile. |
| Pruebas/análisis | `flutter_test` SDK, `flutter_lints ^6.0.0` (lock `6.0.0`). |
| Iconos de launcher | `flutter_launcher_icons ^0.14.4`; configuración en `pubspec.yaml`. |
| Android | Gradle wrapper `9.0.0`; Kotlin/JVM y compatibilidad Java 17 en `android/app/build.gradle.kts`; compile/target/min SDK delegados a Flutter. |
| Base de datos propuesta | PostgreSQL administrado por Supabase, descrito por `supabase_schema.sql`. No se verificó su despliegue. |

La plataforma Flutter declara carpetas generadas para Android, iOS, web, Windows, macOS y Linux. La existencia de scaffolding no acredita compilación, pruebas ni publicación en todas ellas.

## 6. Estructura del proyecto

```text
AquaControl/
├── lib/
│   ├── main.dart
│   ├── models/zone_data.dart
│   ├── screens/                 # interfaces y flujos de usuario
│   ├── services/supabase_service.dart
│   ├── theme/                   # paleta y tema Material
│   ├── utils/                   # CP y PDF
│   └── widgets/                 # componentes visuales reutilizables
├── assets/icon/, assets/images/ # iconos/logos declarados en pubspec
├── supabase_schema.sql          # esquema SQL propuesto
├── test/unit_test.dart          # pruebas unitarias presentes
├── android/, ios/, web/         # configuración y recursos por plataforma
├── windows/, macos/, linux/     # scaffolding de escritorio
├── pubspec.yaml, pubspec.lock   # dependencias y versiones resueltas
├── analysis_options.yaml        # reglas de análisis Dart/Flutter
├── implementation_plan.md      # plan/comentarios de funcionalidades
├── README.md                    # README genérico de Flutter
└── .agents/, .vscode/, .dart_tool/, build/ # instrucciones/herramientas y artefactos locales
```

Archivos fuente relevantes:

- `lib/models/zone_data.dart`: modelos de dominio, datos globales, operaciones CRUD, métricas, sesión local y creación de movimientos.
- `lib/screens/`: pantallas descritas en la sección 10.
- `lib/services/supabase_service.dart`: inicialización SDK; no implementa repositorios ni llamadas CRUD.
- `lib/utils/table_pdf_printer.dart`: composición de PDF horizontal y diálogo de impresión.
- `lib/utils/postal_code_helper.dart`: catálogo exacto parcial y aproximación geográfica por prefijo postal.
- `lib/widgets/signature_pad.dart`: captura/pintado/previa de trazos de firma.
- `lib/widgets/aqua_background.dart`, `glass_card.dart`, `aqua_button.dart`, `aqua_badge.dart`, `bottom_nav_bar.dart`, `zoom_container.dart`, `water_dispenser_art.dart`, `aqua_logo.dart`, `aqua_star.dart`: elementos visuales reutilizables.
- `lib/theme/aqua_colors.dart`, `aqua_theme.dart`: paleta y configuración visual.
- `supabase_schema.sql`: definición propuesta de tablas, políticas, funciones, vistas y Storage.
- `implementation_plan.md`: lista de requerimientos y plan de verificación, no evidencia de que cada punto esté terminado.

## 7. Modelo de datos en Flutter

Las entidades son clases Dart simples; no implementan `toJson`/`fromJson` ni mapeo con PostgREST en el código observado.

| Clase | Campos principales y tipos | Uso |
|---|---|---|
| `DispenserItem` | `id`, `brand`, `model`, `serialNumber`, `lastSupplyInfo`, `alertMessage` (`String`); `status` (`DispenserStatus`); `bottleCount` (`int`); `isActive` (`bool`) | Equipo instalado y estado operativo. `copyWith` produce copias. |
| `ZoneItem` | `name`, `subtitle` (`String`); `dispensers` (`List<DispenserItem>`) | Contenedor de despachadores y agregados calculados: total, abastecidos, pendientes, reabastecidos, botellas y estado completo. |
| `SupplyRecord` | `id`, `dispenserId`, `zoneName`, `workerName`, `recipientName`, `clientName` (`String`); `bottles` (`int`); `timestamp` (`DateTime`); `isResupply` (`bool`); `signaturePoints` (`List<Offset>?`); `pricePerBottle` (`double`) | Movimiento y recibo; calcula precio efectivo y total. |
| `ClientItem` | `id`, `companyName`, `razonSocial`, `rfc`, contacto, teléfonos/correo, dirección desglosada, `pais`, `address`, `status`, `notes`, frecuencia (`String`); `activeDispensers`, `initialBottles`, `racksCount`, `rackCapacity` (`int`); `assignedDispenserIds` (`List<String>`); precio (`double`); `hasQrScanning` (`bool`) | Cliente y configuración de abastecimiento. Incluye dirección completa calculada, conteo asignado y capacidad total. |
| `WorkerItem` | `id`, `name`, `employeeNumber`, `phone`, `email`, `assignedZone`, `shift`, `status`, `password` (`String`); `assignedClients` (`List<String>`) | Trabajador y asignaciones locales. La contraseña se mantiene como texto en el objeto. |
| `WorkerSession` | `activeClientName` (`String?`), `activePricePerBottle` (`double`), `currentWorker` (`WorkerItem?`) estáticos | Estado temporal de sesión del trabajador; `clear()` lo borra. |
| `ZoneDispenserEntry` | `zoneName` (`String`), `dispenser` (`DispenserItem`) | Vista auxiliar que combina equipo y zona. |
| `ClientKpiMetrics` | contadores de equipos, abastecidos, pendientes y botellas (`int`) | KPIs calculados en memoria. |

Los almacenes globales `kDefaultZones`, `kDefaultClients`, `kDefaultWorkers` y `kSupplyRecords` se inicializan como listas vacías al final del archivo y no se encontraron semillas automáticas. Altas y movimientos solo persisten mientras permanece el proceso.

### Estructura SQL propuesta para Supabase

El SQL define tipos `dispenser_status` (`supplied`, `resupplied`, `pending`) y `record_type` (`supply`, `resupply`); el segundo tipo no aparece usado por ninguna columna definida. Los UUID usan `gen_random_uuid()`; hay campos temporales `TIMESTAMPTZ`, texto, enteros, booleanos, arreglos `TEXT[]`, JSONB y números decimales.

| Tabla | Campos y restricciones destacables |
|---|---|
| `zones` | `id UUID PK`, `name TEXT NOT NULL UNIQUE`, `subtitle TEXT DEFAULT ''`, `created_at`, `updated_at` (`TIMESTAMPTZ`, `NOW()`). |
| `clients` | `id UUID PK`; `code TEXT UNIQUE`; `company_name TEXT NOT NULL`; `razon_social`, `rfc`, `contact_person`, `phone`, `email`, `domicilio`, `calle`, `numero`, `cp`, `colonia`, `ciudad`, `pais`, `address`, `delivery_frequency`, `status`, `notes` (`TEXT`); `active_dispensers`, `initial_bottles`, `racks_count`, `rack_capacity` (`INTEGER`); `price_per_bottle NUMERIC(10,2)`; `has_qr_scanning BOOLEAN`; `created_at`, `updated_at` (`TIMESTAMPTZ`). Estados permitidos en `status`: Activo/Inactivo. |
| `dispensers` | `id TEXT PK`; `zone_id UUID FK → zones(id) ON DELETE SET NULL`; `zone_name TEXT NOT NULL`; `client_id UUID FK → clients(id) ON DELETE SET NULL`; `brand`, `model`, `serial_number`, `last_supply_info`, `alert_message` (`TEXT`); `status dispenser_status`; `bottle_count INTEGER`; `is_active BOOLEAN`; `created_at`, `updated_at` (`TIMESTAMPTZ`). |
| `workers` | `id UUID PK`; `employee_number TEXT UNIQUE NOT NULL`; `name TEXT NOT NULL`; `phone`, `email`, `assigned_zone`, `shift`, `status`, `password` (`TEXT`); `assigned_clients TEXT[]`; `created_at`, `updated_at` (`TIMESTAMPTZ`). `password` aparece como texto sin mecanismo de hash documentado por el script. |
| `supply_records` | `id UUID PK`; `dispenser_id TEXT NOT NULL FK → dispensers(id) ON DELETE CASCADE`; `zone_name`, `client_name`, `worker_name`, `recipient_name` (`TEXT`); `client_id UUID FK → clients(id) ON DELETE SET NULL`; `worker_id UUID FK → workers(id) ON DELETE SET NULL`; `bottles INTEGER`; `is_resupply BOOLEAN`; `price_per_bottle NUMERIC(10,2)`; `total_price NUMERIC(10,2) GENERATED ALWAYS AS (bottles * price_per_bottle) STORED`; `signature_points JSONB`; `signature_image_url TEXT`; `timestamp`, `created_at` (`TIMESTAMPTZ`). |

Relaciones: una zona puede tener varios despachadores; un cliente puede relacionarse con despachadores y movimientos; un trabajador puede relacionarse con movimientos. La asignación cliente-trabajador en SQL es una lista de nombres `TEXT[]`, no una tabla de unión. Las claves foráneas de zona/cliente/trabajador permiten borrar la entidad y poner la referencia a `NULL`; borrar un despachador elimina sus movimientos relacionados.

El script también crea índices en nombres/estados/relaciones/fechas, trigger `handle_updated_at`, trigger de inserción de abastecimiento que modifica estado/cantidad de botellas del equipo, y vistas `v_client_metrics` y `v_zone_metrics`. Activa RLS y define políticas CRUD abiertas `USING (true)` / `WITH CHECK (true)` para roles `anon` y `authenticated` en las cinco tablas. Añade tablas a publicación Realtime y crea bucket público `signatures`, con políticas de lectura pública e inserción para `anon` y `authenticated`. Son definiciones presentes en el archivo SQL: no se confirmó que se hayan ejecutado en un proyecto Supabase.

## 8. APIs, servicios y comunicación

- No se encontraron llamadas Flutter a `SupabaseService.client`, `supabase.from(...)`, `auth`, `storage`, `rpc`, `channel` ni métodos de consulta/escritura. Tampoco endpoints HTTP propios.
- `SupabaseService.initialize()` invoca `Supabase.initialize(url, anonKey)` desde el arranque. Los valores concretos se excluyen de este documento como `[REDACTADO]`.
- El getter de cliente existe, pero no se encontró consumo de este desde las pantallas/modelos.
- La comunicación entre UI y lógica se hace mediante imports directos y funciones globales del archivo `zone_data.dart`; navegación con `Navigator`/`MaterialPageRoute`, shells `IndexedStack` y callbacks.
- `printing` invoca el mecanismo de impresión del dispositivo para el PDF; no es una API de backend.
- `lookupMexicanPostalCode()` funciona sin red usando datos incrustados y reglas de prefijo. Es aproximación, no consulta oficial en vivo.

## 9. Roles y flujo de usuario

### Administrador

1. Elige perfil Administrador.
2. La pantalla Login precarga campos de muestra; el botón de acceso lleva directamente a `AppShell` sin validar el usuario ni la contraseña.
3. La navegación visible ofrece Inicio, Clientes y Registros.
4. Inicio presenta KPIs calculados de las listas actuales y acciones para gestión de trabajadores y despachadores. El selector de cliente filtra los indicadores.
5. Clientes permite consultar, buscar, filtrar, dar de alta/editar/borrar clientes y asignar despachadores; hay restricciones locales para no borrar clientes con movimientos.
6. Registros muestra tabla/gráfica de `kSupplyRecords`, permite filtrar por cliente, consultar firmas e imprimir PDF con importes.

La pantalla `SupplyPointsScreen` ofrece alta/edición/baja de zonas y detalle de puntos, pero no se encuentra conectada a `AppShell` ni a otra ruta del flujo activo. El callback `onNavigateToPoints` del dashboard selecciona el índice 1 del shell, que en realidad muestra `ClientsScreen`.

### Trabajador

1. Elige perfil Trabajador.
2. Introduce correo, número de empleado o nombre; el código busca la coincidencia en `kDefaultWorkers` y compara la contraseña local.
3. Si hay una empresa asignada única se selecciona automáticamente; de otro modo se presenta el selector filtrable de empresas.
4. Se establece `WorkerSession` y abre `WorkerShell`.
5. Puede cambiar la empresa, consultar pendientes/abastecidos/reabastecidos en Despachadores y ver la tabla sin importes financieros (`showFinancials: false`).
6. Si el cliente habilita QR se ve la interfaz de escaneo demostrativa; si no, la pestaña queda como “Sin QR”.

## 10. Inventario de pantallas

| Archivo / clase | Función comprobable y estado de conexión |
|---|---|
| `role_selection_screen.dart` / `RoleSelectionScreen` | Tarjetas de selección Administrador y Trabajador; pantalla inicial. |
| `login_screen.dart` / `LoginScreen` | Formulario para dos perfiles; trabajador se valida localmente, administrador pasa sin autenticación. Incluye `ClientSelectionScreen`, buscador por empresa/dirección/teléfono y selección restringida a clientes asignados cuando hay lista. |
| `app_shell.dart` / `AppShell` | Shell principal administrador con tres índices: dashboard, clientes y tabla de registros. Usa `IndexedStack`. No incluye puntos/zonas ni Settings. |
| `worker_shell.dart` / `WorkerShell` | Encabezado de trabajador/cliente, cambio de empresa, cierre de sesión y pestañas Escanear QR, Despachadores, Tabla. Maneja modalidad sin QR. |
| `admin_dashboard_screen.dart` / `AdminDashboardScreen` | Selector de cliente, KPIs (equipos, abastecidos, pendientes, botellas), acciones para trabajadores y despachadores, cierre de sesión. Métricas desde objetos en memoria. |
| `clients_screen.dart` / `ClientsScreen` | Lista, búsqueda por nombre/razón social/RFC/contacto/dirección/ubicación/ID equipo, filtro de estado, formularios fiscales y dirección, datos de equipo, precio y ajuste QR, asignaciones, historial asociado, validación local y baja restringida si hay movimientos. |
| `workers_management_screen.dart` / `WorkersManagementScreen` | Búsqueda y alta de trabajadores, empleado, teléfono, correo, contraseña, turno/zona y clientes asignados; muestra ficha/credenciales. El alta valida nombre, contraseña mínima y selección de cliente; no usa servicio remoto. No se identificó edición/baja completa conectada. |
| `dispensers_management_screen.dart` / `DispensersManagementScreen` | Listado filtrable por ID, marca, modelo, zona, serie y cliente; edición de equipo, zona, cliente, activación/desactivación y baja con confirmación; acceso a alta. Opera sobre listas locales. |
| `register_dispenser_screen.dart` / `RegisterDispenserScreen` | Alta local de despachador indicando zona, número/ID, marca y modelo. Valida campos obligatorios y llama `addDispenser`. |
| `supply_points_screen.dart` / `SupplyPointsScreen` | Listado por zona, indicadores, búsqueda y filtro (todos/abastecidos/pendientes), alta/edición/baja de zonas y acceso a detalle. Disponible en código, sin conexión al shell principal encontrado. |
| `point_detail_screen.dart` / `PointDetailScreen` | Detalle de zona, filtros, historial, consulta/edición/baja de despachadores y cambios de zona/estado; abre detalle de equipo. En código, pero la ruta habitual depende de `SupplyPointsScreen`/`HistoryScreen`, ambas no conectadas al shell activo. |
| `qr_scanner_screen.dart` / `QrScannerScreen` | Visor gráfico animado; tocar marco abre ID fijo `#023`; botón de linterna solo cambia estado visual. No escanea. |
| `worker_dispensers_screen.dart` / `WorkerDispensersScreen` | Lista de equipos del cliente y filtro por pendiente, abastecido, reabastecido o todos; abre detalle. |
| `dispenser_detail_screen.dart` / `DispenserDetailScreen` | Detalles del equipo, modo abastecimiento/reabastecimiento, control de cantidad y paso a firma. Usa el cliente activo o, en su defecto, el primer cliente. |
| `digital_signature_screen.dart` / `DigitalSignatureScreen` | Resumen de movimiento, receptor y firma. Exige ambos campos antes de registrar en memoria. |
| `success_screen.dart` / `SuccessScreen` | Confirmación con despachador, punto, trabajador, cantidad, receptor, hora y previsualización de firma; regreso al flujo. |
| `worker_history_table_screen.dart` / `WorkerHistoryTableScreen` | Tabla y gráfica de barras, filtro por cliente, consulta de firma, cantidades/importes según `showFinancials`, y acción de impresión PDF. La fuente es `kSupplyRecords`. |
| `history_screen.dart` / `HistoryScreen` | Resumen con selector de fecha y seis registros constantes de ejemplo; no utiliza `kSupplyRecords` y no está enrutada desde el shell actual. |
| `settings_screen.dart` / `SettingsScreen` | Página de estilo/colores y navegación a pantallas de demostración, con botón de salir; no se encontró construcción desde el flujo principal actual. |

No se identificó un sistema central de rutas nombradas; las transiciones usan `MaterialPageRoute` desde callbacks y botones.

## 11. Reglas de negocio y validaciones observadas

- Estados de equipo: `pending`, `supplied`, `resupplied`. El helper `isSupplied` considera abastecido tanto `supplied` como `resupplied`.
- `markDispenserSupplied(id, cantidad, ...)` reemplaza la cantidad actual por la entregada, marca estado abastecido y agrega un registro.
- `resupplyDispenser(id, cantidad, ...)` suma la cantidad al conteo actual, marca reabastecido y registra solo las unidades añadidas.
- Si no se encuentra el ID del equipo, ambas funciones devuelven `false`; la pantalla de firma no comprueba este resultado antes de mostrar éxito.
- El importe total de `SupplyRecord` es cantidad × precio unitario; el precio puede resolverse por el nombre del cliente si el registro no incluye precio positivo.
- Una zona se identifica por nombre en varios CRUD; las comparaciones de zona ignoran mayúsculas/minúsculas en edición/baja.
- Las asignaciones a cliente se basan en IDs de despachador como texto; al reasignar, la función quita esos IDs de otros clientes.
- La eliminación de cliente se bloquea localmente si hay registros cuyo nombre coincide con nombre comercial o razón social.
- Alta de cliente requiere nombre, razón social, RFC, domicilio, calle, número, CP, colonia y ciudad; los validadores están en `clients_screen.dart`. No se encontró garantía de validación fiscal/formato RFC en backend.
- Alta de trabajador comprueba nombre, contraseña con longitud mínima de 4 y al menos un cliente seleccionado; no implementa hash ni servicio de identidad.
- Firma requiere nombre de receptor no vacío y al menos un punto de trazo.
- Código postal debe contener cinco dígitos después de limpiar caracteres no numéricos para consultar; si no hay coincidencia exacta, genera una ciudad/estado aproximados según prefijo.
- La lista y métricas de estado se recalculan en memoria; no hay validación de concurrencia ni transacciones distribuidas.

## 12. Seguridad y permisos

- `SupabaseService` contiene URL de proyecto y clave de cliente incrustadas en código. En este documento se tratan como `[REDACTADO]`; deben gestionarse como configuración y la clave publicable/anon nunca debe confundirse con una clave de servicio.
- El flujo de administrador no autentica credenciales; el flujo de trabajador compara una contraseña guardada como propiedad de `WorkerItem`. Se encuentran valores de muestra y contraseñas predeterminadas/fallback en el código, pero se omiten aquí por seguridad.
- El script SQL modela `workers.password` como texto. No define flujo de hash ni política de contraseñas.
- Las políticas RLS SQL permiten todas las operaciones a `anon` y `authenticated` con condición verdadera. Aplicadas literalmente, no aíslan datos por usuario/rol.
- Bucket `signatures` es público para lectura y permite inserción para `anon`/`authenticated` en el script. No se observó mecanismo de validación/autorización por trabajador.
- Android `src/main/AndroidManifest.xml` no declara permiso CAMERA ni INTERNET; solo los manifiestos debug/profile declaran INTERNET. No aparece permiso de cámara. iOS `Info.plist` no contiene descripción de acceso a cámara.
- No se encontró almacenamiento local seguro, manejo de token de sesión, rol autenticado del backend ni encriptación explícita de credenciales.
- `SystemChrome` fija interfaz vertical en `main.dart`; no es un control de seguridad.

## 13. Errores, estados y casos límite

- Formularios muestran validaciones y mensajes mediante `SnackBar`/diálogos, según pantalla.
- El código no muestra un manejo general de errores de Supabase/red porque no hace operaciones remotas; la inicialización de Supabase en arranque no está envuelta por manejo explícito de excepciones.
- No hay estados de carga/error/vacío ligados a consultas remotas. Los estados de vacío se derivan de listas locales vacías.
- `DigitalSignatureScreen` puede seguir a confirmación aunque `markDispenserSupplied`/`resupplyDispenser` devuelva `false`; no verifica que el equipo realmente exista.
- Puede haber incoherencia en datos de cliente por uso de nombres además de IDs para asociaciones e historial.
- Los datos y la sesión desaparecen al cerrar/reiniciar la aplicación; no hay sincronización/offline.
- En un entorno multiusuario, no hay bloqueo ni prevención de movimientos duplicados.
- El scanner no tiene casos de QR inválido, cámara denegada, falta de iluminación ni dispositivo sin cámara porque no hay lector implementado.
- La eliminación local de zona no expresa relación en cascada con despachadores; el script SQL, en cambio, mantiene referencias nulas para equipos con `zone_id`.

## 14. Dependencias relevantes

Dependencias directas declaradas en `pubspec.yaml`:

- `google_fonts`: tipografías en la interfaz.
- `pdf`: estructura y generación del documento PDF.
- `printing`: abrir el flujo de impresión/guardado del PDF.
- `supabase_flutter`: inicialización del cliente Supabase.
- SDK Flutter Material; paquetes de pruebas/análisis y generación de iconos como dependencias de desarrollo.

El lockfile contiene también paquetes transitivos del SDK Supabase y otros plugins Flutter. No hay dependencia directa declarada para lector QR/cámara. La presencia de paquetes transitivos cuyo nombre incluya QR no equivale a integración de escaneo.

## 15. Configuración y variables

- Configuración de paquete: `pubspec.yaml` (`aqua_control`, versión `0.1.0+1`, SDK y dependencias).
- Configuración Supabase: constantes estáticas en `lib/services/supabase_service.dart`. Valores sensibles: `[REDACTADO]`; no aparecen variables `.env` en la estructura revisada.
- Tablas, políticas, Storage y Realtime propuestos: `supabase_schema.sql`.
- Android: `applicationId`/namespace `com.example.aqua_control`, Java/JVM 17; signing de release actualmente apunta a la configuración debug según `android/app/build.gradle.kts`.
- Iconos e imágenes: `assets/icon/`, `assets/images/` declarados en pubspec; existen recursos nativos para plataformas.
- No se detectó configuración de entorno por flavors, secretos de CI, archivo de configuración separado para producción ni pipeline de publicación.

## 16. Pruebas existentes

`test/unit_test.dart` incluye dos pruebas:

1. Comprueba abastecimiento y reabastecimiento del ID `#024`: espera éxito, aumento de lista, tipo de movimiento, receptor y actualización del total de garrafones.
2. Comprueba alta de cliente y trabajador en listas globales y que se almacenen dos clientes asignados.

No se localizaron pruebas de widgets, integración, backend, cámara/QR, PDF, seguridad, sincronización o interacción de despliegue. La primera prueba depende de `#024`; en el archivo de modelo revisado `kDefaultZones` comienza vacío y no se encontró fixture que agregue ese equipo antes de la prueba. Esto hace que la expectativa de éxito parezca incompatible con el estado actual del test, pero no se ejecutó para confirmarlo.

## 17. Instalación, ejecución y despliegue

El README no contiene instrucciones de instalación. A partir de la estructura y `pubspec.yaml`, el procedimiento Flutter convencional sería:

1. Instalar Flutter/Dart compatibles con las restricciones indicadas.
2. Abrir la carpeta raíz del proyecto y obtener dependencias del paquete (`flutter pub get`).
3. Configurar Supabase si se pretende inicializar el SDK; la configuración actual está embebida en `supabase_service.dart`.
4. Ejecutar en un emulador/dispositivo o destino desktop/web soportado usando Flutter (`flutter run`).

Los pasos anteriores son inferidos de la estructura estándar; no se verificó en este trabajo que el proyecto compile o corra. El script SQL contiene instrucciones para ejecutarlo manualmente en el editor SQL de Supabase, pero no evidencia de que haya sido aplicado. La publicación de Android no está lista para producción según el Gradle: el build release usa firma debug. No se identifican perfiles de distribución configurados.

## 18. Estado actual y limitaciones

- Código Flutter con interfaz amplia de administración y flujo de operación, aún dependiente de listas locales vacías.
- Sin persistencia ni comunicación de negocio con Supabase; reiniciar la app pierde cambios.
- QR, cuentas de administrador, autenticación real y sincronización son simulados/no implementados.
- El esquema SQL es más completo que su integración en Flutter y contiene políticas de acceso ampliamente abiertas.
- La navegación productiva del administrador no integra el listado de zonas/puntos ni Settings; algunas pantallas existen pero quedan desconectadas del shell.
- `README.md` y `implementation_plan.md` no bastan para afirmar que el sistema fue desplegado o probado en campo.
- Git presenta cambios locales previos en varios archivos de Flutter, dependencias y configuración, además de archivos sin seguimiento como el servicio Supabase y el esquema SQL. La documentación describe ese árbol de trabajo tal como fue inspeccionado; no se modificó deliberadamente el código fuente.

## 19. Funcionalidades mencionadas en comentarios/plan y contraste con el código

`implementation_plan.md` se titula “Plan de Implementación — Mejoras y Requerimientos AquaControl” y usa formulaciones futuras (“se implementarán”). Debe leerse como plan, no como acta de validación. Contraste de puntos relevantes:

| Punto del plan | Evidencia actual |
|---|---|
| CRUD de zonas | Funciones y UI existen en `zone_data.dart`/`supply_points_screen.dart`; esta pantalla no está enlazada al shell principal. Parcialmente conectado al producto. |
| Precio por cliente y columnas financieras | Modelo, formularios, cálculo, tabla/PDF existen en código y están conectados a listas locales. No hay persistencia remota. |
| Tabla de registros del administrador | `AppShell` usa `WorkerHistoryTableScreen` como pestaña Registros. Implementado localmente. |
| Selección de cliente por trabajador | Sesión y selector implementados localmente; el detalle consume sesión/lista. |
| PDF con firma | Existe tabla PDF y reproducción de trazos; el origen de datos es temporal local. |
| Estados visuales abastecido/pendiente/reabastecido | Enumeración, badges/colores y filtros aparecen en modelo y pantallas. |
| Quitar pestaña “Más” | El shell actual presenta tres pestañas Inicio/Clientes/Registros. |
| Lector QR | El plan/copy describe escanear, pero el código solo anima el marco y navega con ID fijo. No implementado. |
| Autenticación y acceso seguro | No están descritos como entregados por el plan; código no implementa backend Auth. |
| Verificación por compilación y escenarios | El plan enumera pruebas manuales y `flutter analyze`; no hay evidencia de que se hayan ejecutado. |

## 20. Inventario de evidencias

Las rutas son relativas a la raíz del repositorio. Las líneas ayudan a localizar la implementación; su numeración puede cambiar con ediciones posteriores.

| Afirmación | Evidencia revisada |
|---|---|
| Arranque, orientación vertical, página inicial y tema | `lib/main.dart:9-45`. |
| Inicialización de Supabase y cliente expuesto | `lib/services/supabase_service.dart:3-19`; sin exponer valores configurados. |
| Listas globales vacías y entidades | `lib/models/zone_data.dart:3-196`, `305-306`, `471-529`, `740-758`. |
| CRUD/métricas y asignaciones | `lib/models/zone_data.dart:308-429`, `531-637`, `724-758`. |
| Abastecimiento y reabastecimiento locales | `lib/models/zone_data.dart:636-722`. |
| Login administrador y validación local de trabajador | `lib/screens/login_screen.dart:11-134`. No se reproducen en este documento los valores precargados/fallback. |
| Shell y navegación administrador | `lib/screens/app_shell.dart:9-65`; `lib/widgets/bottom_nav_bar.dart:6-116`. |
| Dashboard y accesos principales | `lib/screens/admin_dashboard_screen.dart:114-750`. |
| Modalidad QR por cliente y búsqueda/asignación | `lib/models/zone_data.dart:131-164`; `lib/screens/clients_screen.dart:22-75`, formulario aprox. `469-1450`; sección QR aprox. `889-944`. |
| Escáner fijo de demostración | `lib/screens/qr_scanner_screen.dart:14-44`, especialmente `_onDetectQr`; manifiesto Android sin CAMERA: `android/app/src/main/AndroidManifest.xml`. |
| Modo de trabajador y pestañas | `lib/screens/worker_shell.dart:25-65`, `189-432`. |
| Detalle y navegación a firma | `lib/screens/dispenser_detail_screen.dart:11-70`. |
| Validaciones/registro de firma | `lib/screens/digital_signature_screen.dart:35-108`. |
| Widgets de captura/representación de firma | `lib/widgets/signature_pad.dart:16-46`, `133-321`. |
| Listado de trabajadores, búsqueda y validaciones de alta | `lib/screens/workers_management_screen.dart:16-40`, `31-360`, búsqueda en `927-1065`. |
| Listado/gestión de despachadores | `lib/screens/dispensers_management_screen.dart:18-58`, `58-570`, filtros y lista aprox. `906-1255`. |
| CRUD de zonas/puntos y filtros | `lib/screens/supply_points_screen.dart:21-66`, `371-705`; no se referencia desde shell activo. |
| Detalle de punto y filtros | `lib/screens/point_detail_screen.dart:12-60`, gestión en `568-1819`; rutas solo desde otras pantallas no integradas al shell. |
| Tabla, filtro, gráfica, firma e impresión | `lib/screens/worker_history_table_screen.dart:9-37`, `216-667`, `667-1511`; PDF en `lib/utils/table_pdf_printer.dart:7-46`, renderizado de firma aprox. `301-381`. |
| Historial de muestra y selector fecha | `lib/screens/history_screen.dart:7-66`; la clase mantiene registros constantes. |
| Helper postal offline | `lib/utils/postal_code_helper.dart:5-20`, `289-349`. |
| Dependencias y versión de aplicación/SDK | `pubspec.yaml`; versiones resueltas y constraints finales en `pubspec.lock:857-858`. |
| Tablas, relaciones e índices SQL | `supabase_schema.sql:46-189`. |
| Funciones, trigger y vistas SQL | `supabase_schema.sql:35-43`, `191-276`. |
| Políticas RLS, Realtime y bucket de firmas | `supabase_schema.sql:279-355`. |
| Android: ID de aplicación, Java 17 y firma de release debug | `android/app/build.gradle.kts:1-42`; Gradle wrapper en `android/gradle/wrapper/gradle-wrapper.properties`. |
| Sin permiso de cámara y permisos de red por variante | `android/app/src/main/AndroidManifest.xml`, `android/app/src/debug/AndroidManifest.xml`, `android/app/src/profile/AndroidManifest.xml`; iOS `ios/Runner/Info.plist`. |
| Pruebas disponibles | `test/unit_test.dart:1-64`. |
| Plan de trabajo y verificación todavía redactado como plan | `implementation_plan.md:1-74`. |
| README genérico | `README.md`. |

## Información necesaria para completar el reporte

El código por sí solo no permite determinar los siguientes datos. Conviene recabarlos con el responsable del proyecto, la empresa y las evidencias de pruebas:

1. ¿Cuál fue el problema operativo observado antes de desarrollar AquaControl y cómo se registraban los abastecimientos entonces? el problema era olvidar despachar algunos despachadores, se registraban manualmente en hoja y con pluma
2. ¿Cuál es el nombre legal y giro de la empresa receptora, ubicación del proyecto, área/departamento y puesto del asesor empresarial?
3. ¿Cuáles fueron las fechas reales de estadía, duración, horario y etapas de análisis, desarrollo, pruebas y entrega?
4. ¿La base de Supabase descrita en el SQL fue creada? ¿Se ejecutó el script completo y qué versión de esquema quedó desplegada?
5. ¿Cuáles funciones se probaron en un teléfono real? ¿Qué modelos de dispositivos, versiones de Android/iOS, conectividad y resultados se documentaron?
6. ¿Existe un lector QR real o una versión posterior distinta de la carpeta inspeccionada? ¿Se generaron etiquetas QR y cuántos despachadores/puntos se etiquetaron?
7. ¿Cuántos clientes, zonas, despachadores, trabajadores y abastecimientos se manejan en operación real?
8. ¿Qué perfiles y permisos acordó la empresa? ¿El administrador y los trabajadores usan credenciales reales y dónde se administran?
9. ¿Qué métricas antes/después se midieron: tiempo de registro/recorrido, omisiones, errores de captura, disponibilidad de historial, consumo de garrafones o costos?
10. ¿Cuáles fueron resultados de pruebas de usuario/campo, defectos encontrados, correcciones y aceptación del sistema?
11. ¿Se distribuyó la aplicación (APK, Play Store, MDM u otro medio)? ¿Quién la utiliza y desde qué fecha?
12. ¿Qué funcionalidades quedaron fuera del alcance o previstas para una siguiente etapa?
13. ¿Cuál es el nombre definitivo del proyecto de estadías y qué lineamientos de formato/capítulos solicita la universidad?
