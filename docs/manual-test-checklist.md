# Lista de pruebas manuales — to Audit

Referencia: spec §11. Marcar con `[x]` y anotar fecha, dispositivo y resultado.
Estado inicial: ninguna prueba ejecutada todavía (no hay emulador ni dispositivo en el entorno de desarrollo). Pendiente de ejecutar en un móvil Android real.

## Seguridad y datos
- [ ] Modo avión: con red desactivada, la app arranca y todas las funciones operan igual (RNF-07).
- [ ] Cierre forzado durante un borrador: rellenar un cierre de día, matar la app, reabrir y comprobar que el borrador se conserva.
- [ ] Bloqueo tras 5 min: dejar la app en segundo plano más de 5 min y comprobar que pide PIN al volver.
- [ ] Huella / Face ID: desbloqueo biométrico correcto, y caída al PIN si falla o se cancela.
- [ ] Prueba de integración del cifrado en dispositivo: `flutter test integration_test -d <dispositivo>` (PASS). NO ejecutada: no hay emulador/dispositivo disponible.

## Uso y rendimiento
- [ ] Primer arranque completo: onboarding, creación de PIN, catálogos iniciales y primer cierre.
- [ ] Registrar un día completo en menos de 3 min (cronometrado): ______ s.
- [ ] Arranque en frío < 2 s en gama media: ______ s.
- [ ] Lista mensual < 1 s en gama media: ______ s.
- [ ] Cambio de idioma a chino: todas las pantallas se muestran traducidas, sin desbordes.
- [ ] Ajustes, Meses, Historial y Catálogos (sin tests de widget): abrir cada pantalla y probar crear/editar/archivar.

## Informes, justificantes y copias
- [ ] Compartir PDF, Excel y ZIP; guardar PDF en el dispositivo.
- [ ] Justificantes: adjuntar con cámara, galería y PDF; verlos después.
- [ ] Crear copia de seguridad y restaurarla en otro móvil (contraseña correcta e incorrecta).
- [ ] Restaurar desde la pantalla de error de arranque (base de datos ilegible).

## Plataformas
- [ ] Android → iOS: migrar una copia a iOS. Pendiente de disponer de un Mac (no se puede compilar iOS en Windows).
