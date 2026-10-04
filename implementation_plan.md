# Plan de Implementación — Mejoras y Requerimientos AquaControl

Se implementarán las 9 modificaciones solicitadas por el usuario para la plataforma AquaControl, abarcando gestión de zonas, precios diferenciados por cliente, tabla de registros para administrador, selección de cliente por parte del trabajador, impresión de tabla con firmas, simplificación de estados de despachadores con nueva codificación de color, eliminación de la sección "Más", y ajuste de posición/estilo del botón de registro de despachadores.

---

## 1. Zonas: Agregar, Editar y Eliminar (Admin)
- **Modelo (`zone_data.dart`)**:
  - Agregar funciones globales: `addZone(ZoneItem zone)`, `updateZone(String oldName, ZoneItem updatedZone)`, `deleteZone(String zoneName)`.
- **UI en `admin_dashboard_screen.dart` y `supply_points_screen.dart`**:
  - Agregar botón para "+ Nueva Zona" que abre modal/diálogo para ingresar nombre y descripción.
  - En cada tarjeta de zona, añadir menú de opciones (tres puntos) o botones para:
    - **Editar**: Permite modificar el nombre y subtítulo/descripción de la zona.
    - **Eliminar**: Diálogo de confirmación con alerta de despachadores contenidos.
- **UI en `point_detail_screen.dart`**:
  - Opción en la barra superior o menú para editar y eliminar la zona activa.

---

## 2. Precios de Garrafón por Cliente y Visualización en Tabla
- **Modelo (`zone_data.dart`)**:
  - Ampliar `ClientItem` con `final double pricePerBottle` (con valores por defecto realistas, ej. $35.00, $38.00, $32.00 MXN).
  - Añadir función `updateClient(ClientItem client)` para guardar cambios de precio y datos.
  - Ampliar `SupplyRecord` con campos:
    - `String clientName`
    - `double pricePerBottle`
    - `double get totalPrice => bottles * pricePerBottle`
- **Gestión en `clients_screen.dart`**:
  - Mostrar el precio del garrafón en la tarjeta de cada cliente (`$XX.00 / garrafón`).
  - Permitir al administrador configurar y editar el precio por garrafón en el formulario de creación y en un nuevo modal de "Editar Cliente / Precio".
- **Visualización en la Tabla de Registros**:
  - Agregar columnas en la cuadrícula de registros: **Cliente**, **Precio Unit.** y **Total ($)**.

---

## 3. Tabla de Registros en la Sección de Administrador
- **Navegación Admin (`app_shell.dart` y `bottom_nav_bar.dart`)**:
  - Eliminar la pestaña "Más" (punto 8).
  - Integrar la pantalla completa de la tabla de registros (`WorkerHistoryTableScreen` / renombrada/exportada como vista de registros reutilizable `RecordsTableScreen`) en la posición del índice 2 de la barra inferior de navegación de Administrador.
  - En `AdminDashboardScreen`, añadir acceso rápido directo hacia la tabla de registros.

---

## 4. Selección de Cliente por el Trabajador al Abastecer
- **Flujo de Abastecimiento (`dispenser_detail_screen.dart` y `digital_signature_screen.dart`)**:
  - En la pantalla del despachador y de firma digital, incorporar selector desplegable / modal para **"Seleccionar Cliente a Abastecer"**.
  - El selector muestra las empresas clientes disponibles con su respectivo precio por garrafón.
  - Calcula dinámicamente el total: `garrafones × precio por garrafón`.
  - Al confirmar y firmar, el registro `SupplyRecord` se almacena con el cliente seleccionado, su precio unitario y el monto total.

---

## 5. Impresión de la Tabla con todo y Firma
- **Integración con paquetes `pdf` y `printing`**:
  - Crear helper de impresión `lib/utils/table_pdf_printer.dart` que utiliza `Printing.layoutPdf`.
  - Genera un documento PDF estructurado en orientación horizontal con:
    - Encabezado oficial AquaControl con fecha/hora de reporte y totales.
    - Cuadrícula con columnas: Fecha, Hora, Cliente, Zona, Despachador, Garrafones, Precio Unitario, Total, Operación, Recibió y **Firma Digital**.
    - La firma se dibuja en el PDF trazando los puntos capturados en `signaturePoints` en escala adecuada dentro de su celda.
  - En la pantalla de la tabla, añadir un botón visible y estilizado "Imprimir Tabla" (`Icons.print_rounded`) que abre el diálogo nativo de impresión del sistema operativo / guardado como PDF.

---

## 6 & 7. Estados y Colores de las Tarjetas de Despachadores
- **Estados limpios**:
  - Actualizar `DispenserStatus` para soportar:
    - `DispenserStatus.supplied` → `"Abastecido"`
    - `DispenserStatus.resupplied` → `"Reabastecido"`
    - `DispenserStatus.pending` → `"Pendiente de abastecer"`
  - Eliminar el texto "Alerta" y mensajes de advertencia ruidosos.
- **Colores de tarjetas**:
  - **Reabastecido**: Tarjeta con tinte **AZUL** (fondo azul suave, borde azul, icono y badge azul "Reabastecido").
  - **Pendiente de abastecer**: Tarjeta con tinte **ROJO** (fondo rojo suave, borde rojo, icono y badge rojo "Pendiente de abastecer").
  - **Abastecido**: Tarjeta en verde / esmeralda limpio con badge "Abastecido".
  - Aplicar este diseño en `worker_dispensers_screen.dart`, `point_detail_screen.dart` y `dispenser_detail_screen.dart`.

---

## 8. Eliminar la Página "Más" de la Sección de Administrador
- **En `app_shell.dart`**:
  - Eliminar `SettingsScreen` del stack.
  - Dejar las 3 pestañas principales de Administrador: **Inicio**, **Puntos**, **Registros**.
- **En `bottom_nav_bar.dart`**:
  - Ajustar para soportar dinámicamente o configurar los ítems: [Inicio, Puntos, Registros] sin el ítem "Más".

---

## 9. Botón "Registrar Nuevo Despachador" Sutil y Reubicado
- **En `admin_dashboard_screen.dart`**:
  - Cambiar el orden: colocar primero las tarjetas de acceso rápido **Clientes** y **Trabajadores**.
  - Inmediatamente debajo de dichas tarjetas, colocar el botón **"Registrar nuevo despachador"**.
  - Hacerlo más sutil: usar estilo secundario/vidrio satinado con bordes suaves, menor prominencia visual y altura compacta.

---

## Plan de Verificación
1. **Verificación de compilación y linter**:
   - Ejecutar `flutter analyze` para asegurar 0 errores y advertencias.
2. **Verificación de funcionalidad**:
   - Probar creación, edición y eliminación de una zona en Admin.
   - Probar edición de precio por garrafón de un cliente y verificar que se refleje en la tabla de registros.
   - Probar abastecimiento como trabajador seleccionando un cliente y revisando el nuevo registro en la tabla.
   - Probar visualización de tarjetas con colores azul (reabastecido) y rojo (pendiente de abastecer).
   - Probar acción de imprimir tabla con firma.
   - Verificar que no exista la pestaña "Más" y que el botón de registrar despachador sea sutil y esté bajo las tarjetas Clientes/Trabajadores.
