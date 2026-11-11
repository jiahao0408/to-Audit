# to Audit

Aplicación Flutter de contabilidad diaria para un restaurante: cierre de caja, gastos, nóminas, costes fijos, informes y alertas. Funciona 100 % sin conexión (la build de release no declara el permiso `INTERNET`) y guarda los datos cifrados con SQLCipher.

- Spec: [docs/superpowers/specs/2026-11-08-to-audit-mvp-design.md](docs/superpowers/specs/2026-11-08-to-audit-mvp-design.md)
- Plan: [docs/superpowers/plans/2026-11-08-to-audit-mvp.md](docs/superpowers/plans/2026-11-08-to-audit-mvp.md)
- Pruebas manuales: [docs/manual-test-checklist.md](docs/manual-test-checklist.md)

## Requisitos

- Flutter 3.47.9 (stable)
- JDK 17 (`JAVA_HOME` apuntando a él)
- Android SDK con build-tools (la build de iOS requiere un Mac)
- En Windows, `PUB_CACHE` debe estar en la misma unidad que el SDK de Flutter (por ejemplo `D:\dev\pub-cache` con Flutter en `D:\dev\flutter`).

## Puesta en marcha

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # código de drift
flutter gen-l10n                                           # localizaciones (lib/l10n, ya versionadas)
```

## Tests

```
flutter analyze
flutter test --coverage
dart run tool/coverage_check.dart coverage/lcov.info lib/domain 80
```

El último comando es la puerta de cobertura: cada archivo de `lib/domain` debe tener al menos un 80 % de líneas cubiertas; si no, imprime los porcentajes y termina con código 1.

Prueba de integración del cifrado (requiere emulador o dispositivo):

```
flutter test integration_test -d <dispositivo>
```

## Builds

```
flutter build apk --release      # build/app/outputs/flutter-apk/app-release.apk
```

La release se firma con la clave de debug (suficiente para este MVP; antes de publicar hay que configurar un keystore propio). Para comprobar los permisos (no debe aparecer `android.permission.INTERNET`):

```
%LOCALAPPDATA%\Android\Sdk\build-tools\36.0.0\aapt2.exe dump permissions build\app\outputs\flutter-apk\app-release.apk
```

## Cifrado

SQLCipher se enlaza mediante el build hook de `sqlite3` (configurado en `pubspec.yaml`), no con un paquete nativo adicional. La clave de la base de datos se guarda en el almacén seguro del sistema y el PIN protege el acceso a la app.

## iOS

Aviso: la plataforma iOS está configurada pero NO se ha compilado ni probado, porque requiere un Mac. La migración Android → iOS con una copia de seguridad queda pendiente.

## Estructura

```
lib/
  domain/      cálculo puro (dinero, caja, P&L, alertas, fechas)
  data/        drift (base de datos), repositorios, seguridad, copias, exportación, informes, auditoría
  features/    pantallas por funcionalidad (calendario, cierre de día, gastos, nóminas, ajustes...)
  l10n/        ARB y código generado (es / zh)
test/          tests unitarios y de widgets
integration_test/  prueba de cifrado en dispositivo
tool/          coverage_check.dart
docs/          spec, plan y lista de pruebas manuales
```
