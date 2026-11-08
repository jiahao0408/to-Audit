# to Audit — Diseño del MVP (fase 1)

- **Fecha:** 2026-11-08
- **Fuente de requisitos:** [Requisitos — to Audit](https://claude.ai/artifact/JHjKQdke5CcWn4y9Cm7X9E) (rev. 41). Los códigos RF-/RNF- citados aquí son los de ese documento.
- **Alcance de este diseño:** solo los requisitos marcados **MVP**. Las fases F2 y F3 tendrán su propio diseño y plan.

## 1. Propósito y criterios de éxito

to Audit es una app móvil sin conexión para el dueño de un restaurante buffet (un único usuario, un único móvil). Registra ventas, gastos y movimientos de caja, cuadra cada día contra el TPV (ifiume) y el datáfono CaixaBank, y muestra el beneficio real por día y por mes, con rastro de auditoría.

El MVP es correcto cuando:

1. Se puede registrar un día completo (ventas, propinas, retiradas, gastos en efectivo, recuento y cierre) en menos de 3 minutos (RNF-12).
2. Cualquier descuadre, aunque sea de 1 céntimo, obliga a un comentario y queda visible en el calendario y en las alertas.
3. La cuenta de resultados mensual cuadra con la suma de ventas, compras, personal y fijos registrados.
4. Ningún cambio se pierde ni se borra: todo queda en el historial y los períodos cerrados no se pueden modificar sin reabrirlos con PIN o biometría.
5. Una copia hecha en un móvil se restaura en otro (Android ↔ iOS) y no se puede leer sin la contraseña.
6. Toda la app funciona en modo avión.

## 2. Decisiones tomadas

| Tema | Decisión |
| --- | --- |
| Tecnología | Flutter (Dart), una base de código para Android 9+ e iOS 15+ (RNF-01) |
| Base de datos | Drift sobre SQLite cifrado con SQLCipher (`sqlcipher_flutter_libs`) (RNF-03/04) |
| Estado | Riverpod |
| Alcance | Solo requisitos MVP |
| Plataforma de pruebas | Android (emulador o móvil). iOS se compila y prueba cuando haya un Mac disponible |
| Día sin actividad | Nuevo estado de día, no presente en el documento de requisitos (ver 5.1) |
| Beneficio | Gastos por fecha de factura; gastos fijos solo los confirmados (ver 8.2) |
| PDF en chino | Se incluye la fuente Noto Sans SC en la app (~8 MB) |

## 3. Requisitos incluidos

- **Ventas:** RF-VEN-01, 02, 03, 06
- **Caja:** RF-CAJ-01 a 08
- **Gastos:** RF-GAS-01 a 05, 07
- **Fijos:** RF-FIJ-01, 02
- **Nóminas:** RF-NOM-01, 02, 04
- **Retiradas:** RF-RET-01, 03
- **Importación:** RF-IMP-01 (formulario en el orden de ifiume)
- **Informes:** RF-INF-01, 02, 06, 07, 08, 09
- **Auditoría:** RF-AUD-01 a 05
- **Copia:** RF-SEG-01 a 04
- **Configuración:** RF-CFG-01 a 04
- **No funcionales:** RNF-01 a 10, 12 a 19 (RNF-11 es de OCR, fase 2)

Quedan fuera (F2/F3): RF-VEN-04, 05, 07; RF-GAS-06; RF-FIJ-03; RF-NOM-03; RF-RET-02; RF-IMP-02 a 05; RF-INF-03 a 05; RF-AUD-06, 07.

## 4. Arquitectura

Tres capas con dependencias en un solo sentido: `features` → `data` → `domain`. `domain` no depende de Flutter ni de la base de datos.

```
lib/
  main.dart, app.dart            arranque, tema claro/oscuro, rutas, bloqueo
  domain/                        lógica pura, probada al 80 %+ (RNF-17)
    money.dart                   tipo Money en céntimos (int), suma, IVA, formato
    cash_calc.dart               efectivo esperado, descuadres, recuento por billetes
    pnl_calc.dart                cuenta de resultados, ticket medio, % personal
    period.dart                  rangos: hoy, semana, mes, desde–hasta
    alerts_calc.dart             reglas de alertas a partir de datos ya leídos
  data/
    db/                          tablas Drift, DAOs, migraciones versionadas (RNF-16)
    repositories/                days, sales, expenses, suppliers, fixed_costs,
                                 payroll, withdrawals, periods, audit, settings
    audit/                       AuditWriter: compara y escribe HistorialCambio
    files/                       justificantes: compresión y rutas privadas
    backup/                      exportar y restaurar .toaudit
    security/                    clave de BD, hash del PIN, biometría
    export/                      PDF, XLSX, ZIP para el gestor
  features/
    lock/  onboarding/  home/  calendar/  day_close/  expenses/  suppliers/
    fixed_costs/  payroll/  withdrawals/  reports/  alerts/  settings/  backup/
  l10n/                          app_es.arb, app_zh.arb
assets/fonts/                    NotoSansSC para los PDF
test/                            espejo de lib/
```

**Regla central:** las pantallas nunca escriben directamente en la base de datos. Toda escritura pasa por un repositorio, que en una sola transacción:

1. comprueba que el día o el mes no esté cerrado, y si lo está rechaza la escritura (`PeriodLockedException`);
2. aplica el cambio;
3. escribe en `HistorialCambio` una fila por cada campo cambiado;
4. actualiza `updated_at` y `author` del registro.

### Dependencias principales

drift, sqlcipher_flutter_libs, flutter_riverpod, flutter_secure_storage, local_auth, pdf, printing, excel, csv, archive, cryptography (AES-GCM y PBKDF2), share_plus, image_picker, file_picker, flutter_image_compress, path_provider, intl, uuid.

## 5. Modelo de datos

Basado en la sección 5 de los requisitos. Todas las tablas llevan `id` (UUID texto), `created_at`, `updated_at` y `author` (RNF-19). Los importes son `int` en céntimos (RNF-08).

| Tabla | Campos (además de los comunes) |
| --- | --- |
| `dia_caja` | fecha (única), estado, fondo_inicial, efectivo_contado, recuento_billetes (JSON, opcional), total_datafono, propinas_efectivo, propinas_tarjeta, descuadre_efectivo, descuadre_tarjeta, comentario, cerrado_en |
| `venta` | dia_id, turno (comida/cena), forma_pago_id, importe |
| `comensales` | dia_id, turno, numero |
| `forma_pago` | nombre, tipo (efectivo/tarjeta/otro), orden, activa |
| `proveedor` | nombre, nif, telefono, categoria_id |
| `categoria_gasto` | nombre, tipo (compra/otro), activa |
| `gasto` | fecha, proveedor_id, categoria_id, num_factura, base, iva_pct, iva, total, forma_pago_id, pagado_en_efectivo_dia_id, estado_pago, vencimiento, origen (manual/fijo), gasto_fijo_id, estado_fijo (previsto/confirmado), anulado, motivo_anulacion |
| `justificante` | gasto_id, ruta_archivo, tipo (foto/pdf), tamano |
| `gasto_fijo` | concepto, categoria_id, importe_previsto, iva_pct, periodicidad (mensual/bimestral/trimestral/anual), dia_cargo, inicio (AAAA-MM, primer mes de cargo), activo |
| `empleado` | nombre, puesto, alta, baja |
| `pago_nomina` | empleado_id, mes (AAAA-MM), bruto, neto, ss_empresa, forma_pago_id, anulado, motivo_anulacion |
| `retirada` | dia_id, importe, tipo_retirada_id, nota, anulado, motivo_anulacion |
| `tipo_retirada` | nombre, activa |
| `periodo` | mes (AAAA-MM, único), estado, cerrado_en |
| `historial_cambio` | fecha_hora, entidad, registro_id, campo, valor_anterior, valor_nuevo, motivo, author, hash_anterior (vacío en MVP) |
| `ajustes` | clave, valor (restaurante, idioma, umbral, días de recordatorio, última copia…) |

Notas:

- **Ventas por turno:** cada forma de pago se puede introducir por turno (comida/cena). Si el dueño solo tiene el total del día, lo introduce en "comida" y deja "cena" a cero. El ticket medio usa la suma de ambos turnos.
- **Gasto pagado en efectivo:** `pagado_en_efectivo_dia_id` lo vincula al día de caja, y entonces cuenta en el efectivo esperado de ese día.
- **Catálogos** (`forma_pago`, `categoria_gasto`, `tipo_retirada`): llevan además `code`. Las filas creadas por defecto tienen un código (`cash`, `card`, `meat`…) y la app muestra su nombre traducido; las que crea el usuario tienen `code` vacío y se muestran con su nombre. Nunca se borran, solo se desactivan.
- **No hay `MovimientoBanco` ni `Alerta` persistida en el MVP.** Las alertas se calculan al vuelo (6.4); la conciliación bancaria es F3.

### 5.1 Estados de un día

```
sin registrar ──(abrir)──► abierto ──(cerrar)──► cerrado
      │                       ▲                     │
      └──(sin actividad)──►   └──(reabrir: PIN + motivo)
```

- **Sin registrar:** no existe fila en `dia_caja`.
- **Abierto:** borrador, se guarda en cada cambio de campo.
- **Cerrado:** bloqueado. En el calendario se distingue "cuadrado" (ambos descuadres = 0) y "con descuadre".
- **Sin actividad:** el restaurante no abrió. Cuenta como cerrado y su fondo final es igual a su fondo inicial.

## 6. Flujos

### 6.1 Primer arranque

1. Elegir idioma.
2. Datos del restaurante (RF-CFG-01).
3. Crear PIN de 6 dígitos (dos veces) y activar biometría si el móvil la tiene.
4. Fondo de caja inicial del primer día.
5. Se crean las formas de pago (efectivo, tarjeta CaixaBank, Bizum, vales, Glovo, Just Eat, Uber Eats), las categorías de gasto y los tipos de retirada por defecto.

### 6.2 Registrar y cerrar un día (RF-CAJ, RF-VEN, RF-IMP-01)

Una pantalla con secciones, en el orden de la pantalla de resumen de ifiume:

1. **Ventas:** importe por forma de pago y turno; comensales por turno.
2. **Propinas:** efectivo y tarjeta (no cuentan como venta).
3. **Efectivo que sale:** retiradas del día y gastos pagados en efectivo, con alta rápida.
4. **Recuento:** fondo inicial (del día anterior, editable con aviso), efectivo contado como total o por billetes y monedas (conmutador), total del ticket de cierre del datáfono.
5. **Resultado en vivo:**
   - efectivo esperado = fondo inicial + ventas en efectivo + propinas en efectivo − gastos en efectivo − retiradas
   - descuadre de efectivo = contado − esperado
   - descuadre de tarjeta = total datáfono − (ventas con tarjeta + propinas con tarjeta)
   - se muestran en euros con signo y texto "sobra" / "falta".
6. **Cerrar día:** si |descuadre| > umbral (0,00 € por defecto) en efectivo o tarjeta, el comentario es obligatorio. Al cerrar:
   - el estado pasa a cerrado;
   - el fondo final (= efectivo contado) pasa a ser el fondo inicial del siguiente día si está sin registrar o abierto;
   - la app abre el siguiente día pendiente (RF-CAJ-08).

Las propinas con tarjeta se cobran en el datáfono, así que su ticket de cierre las incluye: por eso se suman a las ventas con tarjeta en el cuadre. Las propinas nunca cuentan como venta en los informes.

### 6.3 Reabrir y cerrar períodos (RF-AUD-03/04)

- **Reabrir día:** pide PIN o biometría y un motivo; queda en el historial. Si el mes está cerrado, primero hay que reabrir el mes.
- **Al volver a cerrar un día reabierto** con un fondo final distinto, si el día siguiente está abierto se actualiza su fondo inicial. Si está cerrado, no se toca y se crea una alerta de "fondo inicial no coincide".
- **Cerrar mes:** solo si todos los días del mes hasta hoy están cerrados o sin actividad. Bloquea días, gastos (por fecha), nóminas y retiradas del mes.
- **Reabrir mes:** PIN o biometría y un motivo.

### 6.4 Alertas (RF-AUD-05)

Se calculan al abrir la app, al volver a ella y tras cada guardado, sin notificaciones push:

| Alerta | Regla |
| --- | --- |
| Descuadre | Día cerrado con descuadre ≠ 0 en el mes en curso o en un mes sin cerrar |
| Día sin registrar | Días entre el primer día registrado y ayer sin fila en `dia_caja` |
| Día abierto | Días anteriores a hoy en estado abierto |
| Sin justificante | Gasto no anulado sin ningún justificante |
| Factura vencida | Gasto pendiente con vencimiento < hoy |
| Fondo no coincide | Fondo inicial de un día ≠ fondo final del día anterior |
| Copia antigua | Última copia hace más de 14 días (aviso al abrir, RNF-15) |

Cada alerta lleva a la pantalla del registro afectado. Una alerta desaparece cuando deja de cumplirse su regla.

### 6.5 Gastos, fijos, nóminas y retiradas

- **Gasto (RF-GAS-02 a 05):**
  - Al elegir proveedor se rellena su categoría.
  - Al teclear la base y elegir el IVA (4/10/21 %) se calcula el total; al teclear el total se calcula la base.
  - Los justificantes vienen de la cámara, la galería o un PDF. Las fotos se comprimen a ~300 KB (lado largo 1600 px, JPEG calidad 75).
  - Lista de pendientes ordenada por vencimiento.
- **Fijos (RF-FIJ-01/02):** al abrir la app se generan los gastos previstos de los períodos vencidos hasta el mes en curso. Confirmarlos pide el importe real.
- **Nóminas (RF-NOM-01/02/04):** pantalla por mes con los empleados activos; se introducen bruto, neto, SS de la empresa y forma de pago. Coste de personal = bruto + SS de la empresa.
- **Retiradas (RF-RET-01/03):** se dan de alta desde el día de caja; listado con totales por tipo y período.
- **Anular** (cualquier registro): pide un motivo; el registro sale de los totales y se ve tachado.

### 6.6 Inicio (RF-INF-09)

- Ventas del mes en curso.
- Beneficio acumulado hasta el último día cerrado.
- Botón "Registrar siguiente día pendiente".
- Contador de alertas.
- Accesos a gastos, informes y ajustes.

## 7. Seguridad y copia de seguridad

### 7.1 Bloqueo y cifrado (RF-CFG-04, RNF-04/05/07)

- **Clave de BD:** 32 bytes aleatorios, generada en el primer arranque y guardada en `flutter_secure_storage` (Keystore/Keychain). No se deriva del PIN.
- **PIN:** se guarda solo su hash PBKDF2-SHA256 con sal (100 000 iteraciones). Tras 5 intentos fallidos hay que esperar 30 s, que se duplican en cada fallo siguiente.
- **Bloqueo:** al abrir la app y tras 5 minutos en segundo plano.
- **PIN olvidado:** se puede entrar con biometría y crear uno nuevo. Sin biometría, la única vía es reinstalar y restaurar una copia; se avisa al crear el PIN.
- **Privacidad:** la versión de producción para Android no declara el permiso de Internet (compartir usa el menú del sistema, que no lo necesita) y la app no incluye analítica.

### 7.2 Archivo de copia `.toaudit` (RF-SEG-01 a 04, RNF-06/18)

```
cabecera:  "TOAUDIT1" | versión formato | sal (16 B) | iteraciones PBKDF2
cuerpo:    bloques de 1 MB, cada uno AES-256-GCM con nonce = prefijo aleatorio + nº de bloque
contenido: ZIP con  db.sqlite (instantánea sin cifrar, con sqlcipher_export), justificantes/…, manifest.json
```

- La clave sale de la contraseña con PBKDF2-SHA256 (600 000 iteraciones). La contraseña tiene un mínimo de 8 caracteres.
- `manifest.json` lleva la versión del esquema, la fecha, el número de registros y el hash SHA-256 de cada archivo.
- **Exportar:** se genera en una carpeta temporal privada, se comparte con `share_plus` y se borra el temporal. Se guarda la fecha de la última copia.
- **Restaurar:**
  1. elegir el archivo;
  2. contraseña;
  3. descifrar y verificar los hashes;
  4. mostrar el resumen (fecha, nº de días y gastos) y pedir confirmación;
  5. sustituir la BD y los justificantes, volver a cifrar con la clave de este móvil y aplicar migraciones si la copia es de un esquema anterior.

  Si algo falla, la BD actual no se toca.
- **Recordatorio:** banner en la app cuando han pasado N días (7 por defecto, configurable) desde la última copia; aviso al abrir a partir de 14 días.

## 8. Informes y exportación

### 8.1 Períodos

Hoy, esta semana (lunes a domingo), este mes, o desde–hasta.

### 8.2 Cálculos (RF-INF-01/02, RF-VEN-03, RF-NOM-04)

- **Ventas:** suma de `venta` de días cerrados del período (las propinas no son ventas).
- **Compras:** gastos no anulados de origen manual con categoría de tipo "compra", por fecha de factura.
- **Fijos:** gastos de origen "fijo" y confirmados, por fecha, sea cual sea su categoría. Los previstos sin confirmar se muestran aparte como "pendientes de confirmar" y no restan.
- **Otros gastos:** el resto de gastos no anulados.
- **Personal:** bruto + SS de la empresa de los pagos del mes. En períodos de menos de un mes se prorratea por días.
- **Beneficio** = ventas − compras − fijos − otros gastos − personal. Los importes de gastos se toman con IVA incluido (total), igual que se pagan; el IVA soportado se muestra como dato informativo.
- **Ticket medio** = ventas / comensales.
- **% personal** = personal / ventas.

### 8.3 Formatos

- **PDF (RF-INF-06/08):** nombre y NIF del restaurante, período, fecha de generación, totales de ventas, gastos, nóminas, retiradas, descuadres y beneficio, y tabla diaria. Se usa Noto Sans SC para los textos en chino. Se comparte o se guarda.
- **Excel (RF-INF-07):** `.xlsx` con hojas Resumen, Días, Ventas, Gastos, Nóminas, Retiradas.
- **CSV:** los mismos datos, un CSV por hoja, dentro de un ZIP.
- **ZIP para el gestor:** `gastos.csv` y los justificantes con nombre `AAAA-MM-DD_proveedor_nºfactura_n.ext`.

## 9. Idiomas, accesibilidad y usabilidad (RNF-12/13/14)

- Todos los textos en `app_es.arb` y `app_zh.arb`. Un test falla si hay claves sin traducir.
- Moneda y fechas con `intl` según el idioma.
- Tema claro y oscuro con contraste AA; se respeta el tamaño de letra del sistema.
- Botones de al menos 48 dp y teclado numérico para importes.

## 10. Errores y casos límite

| Caso | Comportamiento |
| --- | --- |
| Escritura en período cerrado | Se rechaza con un mensaje que ofrece reabrir |
| Cierre forzado de la app | El borrador del día ya está guardado; cada guardado es una transacción (RNF-09) |
| Importe negativo o no numérico | El teclado solo admite números; los campos no aceptan negativos salvo los descuadres calculados |
| Base de datos no se puede abrir (clave perdida) | Pantalla de error que ofrece restaurar una copia; nunca se crea una BD nueva encima |
| Copia con contraseña errónea o archivo dañado | Mensaje claro y la BD actual sin tocar |
| Copia de una versión más nueva de la app | Se rechaza y se pide actualizar la app |
| Almacenamiento lleno | Se avisa al guardar un justificante o exportar; nada queda a medias |
| Día anterior al primer día registrado | No genera alertas de "sin registrar" |

## 11. Pruebas (RNF-17)

- **Unitarias (`domain/`):** Money y redondeo, efectivo esperado, descuadres, recuento por billetes, IVA, cuenta de resultados, prorrateo de personal, períodos y alertas. Objetivo de cobertura ≥ 80 % en cálculos de caja, impuestos e informes.
- **Repositorios** con BD en memoria: el historial se escribe en la misma transacción, los períodos cerrados rechazan escrituras, las anulaciones salen de los totales, el cierre propaga el fondo, la generación de fijos no duplica.
- **Copia:** ida y vuelta (exportar → restaurar → comparar), contraseña errónea, archivo truncado.
- **Widget:** flujo de cierre de día con y sin descuadre; pantalla de bloqueo.
- **Traducciones:** todas las claves existen en ES y ZH.
- **Manuales:** modo avión (RNF-02), cierre forzado, bloqueo tras 5 min, rendimiento en gama media (RNF-10), restauración Android → iOS cuando haya un Mac (RNF-18).

## 12. Entorno de desarrollo

- Instalar Flutter SDK (canal stable) y JDK 17. El Android SDK ya está en `%LOCALAPPDATA%\Android\Sdk`.
- Probar en emulador Android o móvil conectado por USB.
- iOS: el código no usa nada exclusivo de Android, pero compilar y probar requiere un Mac con Xcode.

## 13. Supuestos y preguntas para más adelante

- El ticket de cierre del datáfono incluye las propinas cobradas con tarjeta (6.2).
- La semana empieza en lunes.
- Las ventas solo cuentan en días cerrados; un día abierto no suma en informes ni en el inicio.
- Los gastos fijos tienen cuatro periodicidades: mensual, bimestral, trimestral y anual.
