# Estructura Completa de lib/ - Academix App

```
lib/
├── main.dart
│   # Punto de entrada. Configura MaterialApp, tema dark, .env, Dio.init(), rutas (splash/login/main), imports todas las screens.
├── core/                    # Utilidades compartidas
│   ├── constants/           # Design tokens
│   │   ├── app_radius.dart  # Radios UI: sm=8, md=12...
│   │   └── app_spacing.dart # Espaciados: xs=4 ... xxxl=64
│   ├── errors/              # Manejo errores (vacía)
│   ├── network/
│   │   └── dio_client.dart  # Dio singleton API, token interceptor
│   ├── preferences/
│   │   └── app_preferences.dart # SharedPrefs (vacía)
│   ├── routes/
│   │   └── app_routes.dart  # Rutas constantes + AppNavigator
│   ├── storage/
│   │   └── session_manager.dart # FlutterSecureStorage(token, isLoggedIn)
│   ├── themes/              # Design system
│   │   ├── app_colors.dart  # Paleta: primary oro #D4AF37, bg azul #0F2340
│   │   ├── app_text_styles.dart # Tipos: display ArchivoBlack, h1 RedHat...
│   │   └── app_theme.dart   # ThemeData.dark
│   ├── utils/
│   │   └── env.dart         # dotenv safe (API_URL, API_KEY)
│   └── widgets/             # UI reutilizables
│       ├── app_button_navigation.dart # BottomNav (5 tabs)
│       └── primary_button.dart        # Botón primary (vacía)
└── features/                # Módulos Clean Arch (data/domain/presentation)
    ├── ai/
    │   └── domain/
    │       └── entities/
    │           └── ai_message_entity.dart
    │   └── presentation/
    │       └── view/
    │           └── ai_chat_screen.dart
    │       └── viewmodel/
    │           └── ai_viewmodel.dart
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── auth_remote_datasource.dart
    │   │   ├── models/
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart
    │   │   └── usecases/
    │   │       └── login_usecase.dart
    │   └── presentation/
    │       ├── view/
    │       │   ├── forgot_password_screen.dart
    │       │   ├── login_screen.dart      # Form email/pass
    │       │   ├── register_screen.dart
    │       │   └── splash_screen.dart     # Logo anim, auth check
    │       ├── viewmodel/
    │       │   ├── forgot_password_viewmodel.dart
    │       │   ├── login_viewmodel.dart
    │       │   └── register_viewmodel.dart
    │       └── widgets/
    ├── exam/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── exam_remote_datasource.dart
    │   │   ├── models/
    │   │   └── repositories/
    │   │       └── exam_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── exam_entity.dart
    │   │   └── repositories/
    │   │       └── exam_repository.dart
    │   │   └── usecases/
    │   └── presentation/
    │       ├── view/
    │       │   ├── exam_history_screen.dart
    │       │   ├── exam_result_screen.dart
    │       │   ├── exam_take_screen.dart
    │       │   └── exams_screen.dart
    │       ├── viewmodel/
    │       │   ├── exam_history_viewmodel.dart
    │       │   └── exams_viewmodel.dart
    │       └── widgets/
    │           ├── exam_completed_card.dart
    │           └── exam_recommended_card.dart
    ├── home/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── home_remote_datasource.dart
    │   │   ├── models/
    │   │   └── repositories/
    │   │       └── home_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── home_entity.dart
    │   │   ├── repositories/
    │   │   │   └── home_repository.dart
    │   │   └── usecases/
    │   │       └── get_home_data_usecase.dart
    │   └── presentation/
    │       ├── view/
    │       │   ├── home_screen.dart
    │       │   ├── main_screen.dart
    │       │   └── offline_content_screen.dart
    │       ├── viewmodel/
    │       │   ├── home_viewmodel.dart
    │       │   └── offline_viewmodel.dart
    │       └── widgets/
    │           ├── course_progress_card.dart
    │           └── recent_item_card.dart
    ├── library/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── library_remote_datasource.dart
    │   │   ├── models/
    │   │   └── repositories/
    │   │       └── library_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── library_entity.dart
    │   │   ├── repositories/
    │   │   │   └── library_repository.dart
    │   │   └── usecases/
    │   └── presentation/
    │       ├── view/
    │       │   ├── book_detail_screen.dart
    │       │   ├── favorites_screen.dart
    │       │   └── library_screen.dart
    │       ├── viewmodel/
    │       │   ├── book_detail_viewmodel.dart
    │       │   ├── favorites_viewmodel.dart
    │       │   └── library_viewmodel.dart
    │       └── widgets/
    │           └── library_resource_card.dart
    ├── note/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── note_remote_datasource.dart
    │   │   ├── models/
    │   │   └── repositories/
    │   │       └── note_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── note_entity.dart
    │   │   ├── repositories/
    │   │   │   └── note_repository.dart
    │   │   └── usecases/
    │   └── presentation/
    │       ├── view/
    │       │   ├── create_note_screen.dart
    │       │   ├── edit_note_screen.dart
    │       │   ├── note_detail_screen.dart
    │       │   └── notes_screen.dart
    │       ├── viewmodel/
    │       │   ├── create_note_viewmodel.dart
    │       │   └── notes_viewmodel.dart
    │       └── widgets/
    │           └── note_card.dart
    ├── profile/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── profile_remote_datasource.dart
    │   │   ├── models/
    │   │   └── repositories/
    │   │       └── profile_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── membresia_entity.dart
    │   │   │   └── profile_entity.dart
    │   │   ├── repositories/
    │   │   │   └── profile_repository.dart
    │   │   └── usecases/
    │   └── presentation/
    │       ├── view/
    │       │   ├── premium_screen.dart
    │       │   ├── profile_screen.dart
    │       │   └── settings_screen.dart
    │       ├── viewmodel/
    │       │   ├── membresia_viewmodel.dart
    │       │   └── profile_viewmodel.dart
    │       └── widgets/
    │           └── plan_card.dart
    ├── search/
    │   ├── data/
    │   └── presentation/
    │       ├── view/
    │       │   └── search_screen.dart
    │       └── viewmodel/
    │           └── search_viewmodel.dart
    └── tema/
        ├── domain/
        │   ├── entities/
        │   │   ├── subtema_entity.dart
        │   │   └── tema_entity.dart
        │   └── usecases/
        │       └── get_subtemas_usecase.dart
        └── presentation/
            ├── view/
            │   ├── subtema_screen.dart
            │   └── temas_screen.dart
            └── viewmodel/
                ├── subtema_viewmodel.dart
                └── temas_viewmodel.dart
```

**Leyenda**:
- **Vacías**: folders sin archivos listados.
- Basado en exploración completa recursiva.
- Descripciones breves de contenido/propósito (de lectura directa).

# Estructura Completa de `lib/` – Explicación Detallada

---

## `main.dart`

**Propósito:** Punto de entrada de toda la aplicación.

**Responsabilidades:**
- Inicializa variables de entorno (`.env`)
- Configura el cliente HTTP (Dio)
- Define el `MaterialApp`
- Aplica el tema global (`ThemeData.dark`)
- Configura las rutas iniciales (`splash`, `login`, `main`)

---

## `core/` – Infraestructura Compartida

Contiene todo lo reutilizable en toda la app. No depende de ninguna feature.

### `constants/` – Design Tokens

Centraliza valores de diseño para mantener consistencia.

#### `app_radius.dart`
- Define radios de bordes reutilizables: `sm`, `md`, `lg`, `xl`, `full`
- Evita usar valores hardcodeados en UI

#### `app_spacing.dart`
- Define espaciados estándar: `xs`, `sm`, `md`, `lg`, `xl`, etc.
- Permite mantener layouts consistentes

---

### `errors/`

> Estado actual: vacío

**Propósito futuro:** Definir clases como `Failure`, `ServerFailure`, `NetworkFailure`. Clave para Clean Architecture (manejo de errores desacoplado).

---

### `network/`

#### `dio_client.dart`
**Propósito:** Cliente HTTP centralizado usando Dio.

**Responsabilidades:**
- Configurar `baseUrl`
- Definir timeouts
- Agregar interceptor de token automáticamente
- Manejar requests/responses globalmente

> Es el punto único de comunicación con la API.

---

### `preferences/`

#### `app_preferences.dart`
> Estado actual: vacío

**Propósito futuro:** Manejar almacenamiento local con `SharedPreferences` (configuraciones, flags como modo offline, onboarding visto).

---

### `routes/`

#### `app_routes.dart`
**Propósito:** Sistema de navegación centralizado.

**Contiene:**
- Constantes de rutas (`/login`, `/main`, etc.)
- Clase `AppNavigator`

**Responsabilidades:**
- Navegación controlada
- Evitar duplicación de pantallas
- Métodos como `pushReplacement`, navegación única

---

### `storage/`

#### `session_manager.dart`
**Propósito:** Manejo de sesión segura.

**Responsabilidades:**
- Guardar token en `FlutterSecureStorage`
- Obtener token
- Validar si el usuario está logueado (`isLoggedIn`)

> Base de autenticación persistente.

---

### `themes/` – Design System

#### `app_colors.dart`
Define la paleta global: `primary` (oro), `background` (azul oscuro), `accent`.

#### `app_text_styles.dart`
Define estilos tipográficos: `display`, `h1`, `h2`, `body`, etc.

> Evita repetir estilos en widgets.

#### `app_theme.dart`
**Propósito:** Configuración global del tema.

**Responsabilidades:**
- Define `ThemeData.dark`
- Aplica colores y tipografías
- Configura estilos globales de widgets

---

### `utils/`

#### `env.dart`
**Propósito:** Manejo seguro de variables de entorno.

**Responsabilidades:**
- Leer `.env`
- Exponer `API_BASE_URL` y `API_KEY`

> Evita hardcodear datos sensibles.

---

### `widgets/`

Componentes reutilizables en toda la app.

#### `app_button_navigation.dart`
**Propósito:** Barra de navegación inferior con 5 tabs: Home, Library, Notes, Exams, Profile.

> Controla navegación principal de la app.

#### `primary_button.dart`
> Estado: vacío

**Propósito esperado:** Botón reutilizable con estilo consistente y manejo de estados (`loading`, `disabled`).

---

## `features/` – Módulos por Funcionalidad

Cada feature sigue **Clean Architecture**:
- `data` → acceso a datos
- `domain` → lógica de negocio
- `presentation` → UI + estado

---

### `ai/`

#### `domain/entities/ai_message_entity.dart`
Define la estructura de un mensaje: texto, remitente (usuario / IA), timestamp.

#### `presentation/view/ai_chat_screen.dart`
Pantalla del chat: input de usuario, lista de mensajes.

#### `presentation/viewmodel/ai_viewmodel.dart`
Maneja: estado del chat, envío de mensajes, interacción con backend/IA.

---

### `auth/`

#### `data/`
- `auth_remote_datasource.dart` – Llamadas API: login, register, forgot password
- `auth_repository_impl.dart` – Implementa el contrato del dominio

#### `domain/`
- `auth_repository.dart` – Define métodos: `login()`, `register()`
- `login_usecase.dart` – Encapsula la lógica de login: valida y ejecuta repositorio

#### `presentation/`
**Views:**
- `login_screen.dart` → formulario email/password
- `register_screen.dart` → registro
- `forgot_password_screen.dart` → recuperación
- `splash_screen.dart` → verifica sesión

**ViewModels:**
- `login_viewmodel.dart`
- `register_viewmodel.dart`
- `forgot_password_viewmodel.dart`

---

### `exam/`

#### `data/`
- `exam_remote_datasource.dart` – Obtiene exámenes desde API
- `exam_repository_impl.dart` – Conecta data con dominio

#### `domain/`
- `exam_entity.dart` – Representa examen, preguntas y resultados
- `exam_repository.dart` – Contrato del repositorio

#### `presentation/`
**Views:**
- `exams_screen.dart` → lista
- `exam_take_screen.dart` → resolver examen
- `exam_result_screen.dart` → resultados
- `exam_history_screen.dart` → historial

**ViewModels:**
- `exams_viewmodel.dart`
- `exam_history_viewmodel.dart`

**Widgets:**
- `exam_completed_card.dart`
- `exam_recommended_card.dart`

---

### `home/`

#### `data/`
- `home_remote_datasource.dart` – Obtiene datos del dashboard
- `home_repository_impl.dart`

#### `domain/`
- `home_entity.dart` – Estructura: progreso, recientes, estadísticas
- `home_repository.dart`
- `get_home_data_usecase.dart`

#### `presentation/`
**Views:**
- `main_screen.dart` → contenedor principal
- `home_screen.dart` → dashboard
- `offline_content_screen.dart` → contenido offline

**ViewModels:**
- `home_viewmodel.dart`
- `offline_viewmodel.dart`

**Widgets:**
- `course_progress_card.dart`
- `recent_item_card.dart`

---

### `library/`

#### `data/`
- `library_remote_datasource.dart`
- `library_repository_impl.dart`

#### `domain/`
- `library_entity.dart` – Representa recurso educativo
- `library_repository.dart`

#### `presentation/`
**Views:**
- `library_screen.dart`
- `book_detail_screen.dart`
- `favorites_screen.dart`

**ViewModels:**
- `library_viewmodel.dart`
- `book_detail_viewmodel.dart`
- `favorites_viewmodel.dart`

**Widgets:**
- `library_resource_card.dart`

---

### `note/`

#### `data/`
- `note_remote_datasource.dart`
- `note_repository_impl.dart`

#### `domain/`
- `note_entity.dart` – Representa una nota
- `note_repository.dart`

#### `presentation/`
**Views:**
- `notes_screen.dart`
- `note_detail_screen.dart`
- `create_note_screen.dart`
- `edit_note_screen.dart`

**ViewModels:**
- `notes_viewmodel.dart`
- `create_note_viewmodel.dart`

**Widgets:**
- `note_card.dart`

---

### `profile/`

#### `data/`
- `profile_remote_datasource.dart`
- `profile_repository_impl.dart`

#### `domain/`
- `profile_entity.dart` – Datos del usuario
- `membresia_entity.dart` – Planes/premium
- `profile_repository.dart`

#### `presentation/`
**Views:**
- `profile_screen.dart`
- `settings_screen.dart`
- `premium_screen.dart`

**ViewModels:**
- `profile_viewmodel.dart`
- `membresia_viewmodel.dart`

**Widgets:**
- `plan_card.dart`

---

### `search/`

#### `presentation/`
- `search_screen.dart` – Pantalla de búsqueda global
- `search_viewmodel.dart` – Maneja queries y resultados

#### `data/`
> Actualmente vacío (pendiente implementación API)

---

### `tema/`

#### `domain/`
- `tema_entity.dart` – Representa tema
- `subtema_entity.dart` – Representa subtema
- `get_subtemas_usecase.dart` – Obtiene subtemas

#### `presentation/`
**Views:**
- `temas_screen.dart`
- `subtema_screen.dart`

**ViewModels:**
- `temas_viewmodel.dart`
- `subtema_viewmodel.dart`