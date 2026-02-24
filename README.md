# APLICACION MOVIL DE ACADEMIX

Aplicación móvil desarrollada con **Flutter** como parte del proyecto Academix.

---

## Requisitos previos

Antes de instalar y ejecutar el proyecto, asegúrate de tener instalado lo siguiente:

- Git
- Flutter SDK (versión estable)
- Android Studio o VS Code
- Android SDK
- Un dispositivo físico o emulador Android

Para verificar que Flutter está correctamente instalado, ejecuta:
```bash
flutter doctor
```

Asegúrate de que no haya errores críticos.

---

## Instalación del proyecto

**Clona el repositorio:**
```bash
git clone https://github.com/academix10A/academix_movil.git
```

**Entra al directorio del proyecto:**
```bash
cd academix_movil
```

**Obtén las dependencias del proyecto:**
```bash
flutter pub get
```

---

## Estructura importante del proyecto

- `lib/` → Código fuente de la aplicación
- `assets/` → Recursos gráficos
- `fonts/` → Fuentes personalizadas
- `pubspec.yaml` → Configuración del proyecto y dependencias

**No elimines ni ignores las carpetas `assets/` ni `fonts/`**, ya que son necesarias para compilar el proyecto.

---

## Flujo de trabajo con Git (IMPORTANTE)

**Nunca trabajes directamente sobre `main` ni hagas merge a `main`.**  
Todo el trabajo se integra en la rama **`develop`**.

### 1. Crear una nueva rama desde develop

Asegúrate de estar en `develop` y actualizada. Antes de que comiences a trabajar debes de realizar lo siguiente:
```bash
git checkout develop
git pull origin develop
```

Crea tu rama de trabajo:
```bash
git checkout -b feature/nombre-descriptivo
```

**Ejemplo:**
```bash
git checkout -b feature/login-ui
```

### 2. Agregar cambios a la rama

Agrega todos los cambios realizados:
```bash
git add .
```

### 3. Crear el commit

Crea el commit con un mensaje claro:
```bash
git commit -m "Descripción clara del cambio realizado"
```

**Ejemplo:**
```bash
git commit -m "Agrega pantalla de login con validaciones"
```

### 4. Hacer push a tu rama
```bash
git push origin feature/nombre-descriptivo
```

**Ejemplo:**
```bash
git push origin feature/login-ui
```

### 5. Merge de tu rama a develop

**El merge NO se hace a `main`, se hace a `develop`.**

**Opción A: Desde GitHub**

1. Crea un Pull Request (PR) de tu rama hacia `develop`
2. Espera revisión y aprobación
3. Haz merge a `develop`

**Opción B: Desde consola (si el equipo lo permite):**
```bash
git checkout develop
git pull origin develop
git merge feature/nombre-descriptivo
git push origin develop
```

---

## Ejecución del proyecto

Conecta un dispositivo Android o inicia un emulador y ejecuta:
```bash
flutter run
```

Si tienes varios dispositivos:
```bash
flutter devices
flutter run -d 
```

---

## Limpieza del proyecto (si hay errores raros)

Si Flutter muestra errores inesperados:
```bash
flutter clean
flutter pub get
flutter run
```

---

## Buenas prácticas

- No subir archivos generados (`build/`, `.dart_tool/`, etc.)
- No modificar directamente `main`
- Commits pequeños y descriptivos
- Verificar que el proyecto compile antes de hacer push
- Mantener `develop` siempre funcional
- Siempre hacer pull antes de comenzar a trabajar
- Estar atentos cuando se hacen cambios en el repositorio

---

## Tecnologías usadas

- Flutter
- Dart
- Material Design
- Android SDK

---

## ¿Para qué sirve cada archivo?

### `main.dart`

**Responsabilidad:** punto de entrada de la app.

- Inicializa Flutter
- Aplica el tema global
- Define la pantalla inicial (`LoginScreen`)
- No tiene lógica de negocio

**Arquitectura:** Capa de presentación (root)

---

### CORE (código reutilizable, transversal)

#### `core/constants/`

##### `app_spacing.dart`

Constantes de espaciado (`sm`, `md`, `lg`, etc.)

- Evita números mágicos
- Mantiene consistencia visual
- Cambias el diseño desde un solo lugar

#### `core/errors/`

##### `exceptions.dart`

Define errores personalizados:

- `ServerException`
- `UnauthorizedException`
- etc.

- Evita `throw Exception()` genérico
- Permite manejar errores por tipo

**Arquitectura:** Soporte transversal

#### `core/network/`

##### `api_client.dart`

Cliente HTTP base:

- Configura `baseUrl`
- Headers
- Manejo de status codes

- Centraliza el consumo de APIs
- Ninguna feature usa `http` directo

##### `network_info.dart`

Verifica conexión a internet.

- Permite decidir si usar API o cache
- Importante para apps reales

#### `core/themes/`

##### `app_colors.dart`

Colores oficiales de la app.

- Evita colores hardcodeados
- Mantiene identidad visual

##### `app_text_styles.dart`

Estilos de texto centralizados.

- Misma tipografía en toda la app
- Cambios globales fáciles

##### `app_theme.dart`

`ThemeData` completo de Flutter.

- Configura inputs, botones, textos
- Se usa en `MaterialApp`

#### `core/utils/`

##### `env.dart`

Carga variables del archivo `.env`.

- Nunca subes credenciales al repo
- Cambias entornos sin tocar código

#### `core/widgets/`

##### `primary_button.dart`

Botón reutilizable con estilo oficial.

- UI consistente
- Menos código duplicado

---

### FEATURES / Ejemplo con AUTH (login)

#### `auth/data/` — capa de datos

##### `datasources/auth_remote_datasource.dart`

Llama directamente a la API.

- Construye requests
- Parsea respuestas
- Maneja errores HTTP

- Es la única que conoce la API
- No tiene lógica de negocio

##### `models/login_request_model.dart`

Modelo de datos para enviar al backend.

- Convierte Dart ↔ JSON
- No se usa en UI

##### `repositories/auth_repository_impl.dart`

Implementa el contrato del dominio.

- Decide de dónde vienen los datos
- Puede cambiar API por cache sin afectar UI

#### `auth/domain/` — lógica de negocio

##### `entities/user_entity.dart`

Entidad pura del negocio.

- No depende de Flutter
- No depende de API
- Representa conceptos reales

##### `repositories/auth_repository.dart`

Contrato del repositorio.

- El dominio no sabe cómo se obtienen los datos
- Solo define qué se puede hacer

##### `usecases/login_usecase.dart`

Regla de negocio:

- "Qué significa hacer login"
- Orquesta repositorio + validaciones

#### `auth/presentation/` — UI

##### `view/login_screen.dart`

Pantalla visual.

- Solo UI
- No lógica de negocio
- Escucha al ViewModel

##### `viewmodel/login_viewmodel.dart`

Estado y lógica de presentación.

- Valida campos vacíos
- Llama al use case
- Expone `errorMessage`

**Arquitectura:** MVVM + Clean Architecture

---

## Notas finales

- Cualquier cambio importante en dependencias, assets o fonts debe reflejarse correctamente en `pubspec.yaml`.
- Si el proyecto no compila, revisar primero:
  - Rutas de assets y fonts
  - Versión de Flutter
  - Salida de `flutter doctor`
