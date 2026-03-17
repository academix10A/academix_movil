# TODO: Implementación Pantallas Academix Mobile (UI-Only) - Progreso

## Completado ✓
- [x] **Paso 1: Auth Completo** 
  - [x] RegisterScreen + vm (mock register)
  - [x] ForgotPasswordScreen + vm (mock email)
  - [x] Login links integrados
  - [x] Routes + main.dart updated
  - [x] Test: flutter run → nav OK

- [x] **Paso 2: Notes Create/Edit** 
  - [x] CreateNoteScreen + vm (title, content, tags, public toggle, mock save)
  - [x] EditNoteScreen (reuse vm, load args)
  - [x] FAB integration (needs screen edit for context)
  - [x] Routes added
  - Test: Notes FAB → create

## Pendientes
- [ ] **Paso 3: Temas**
  - [ ] TemasScreen + drill subtemas
  - [ ] Button in Home
  - [ ] Filter library/notes/exams by tema

- [ ] **Paso 4: Profile Edit**
  - [ ] EditProfileScreen + vm

- [ ] **Paso 5: IA Modal + Favorites + Offline**
  - [ ] AI modal (premium)
  - [ ] FavoritesScreen
  - [ ] OfflineSyncScreen

## Test Command
flutter pub get && flutter run

## Próximo backend connect
