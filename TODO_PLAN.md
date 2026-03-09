# Backend Personalization Plan

## Objective
Create personalized endpoints that return data specific to each user (by their ID from authentication) instead of returning general data.

## Backend Endpoints Added

### 1. Vistas (Views) - Personal ✅
- GET /vistas/usuario/recursos - Get all resources viewed by current user
- GET /vistas/usuario/publicaciones - Get all publications viewed by current user
- GET /vistas/usuario/recientes - Get recently viewed content (limit 10)

### 2. Progreso (Progress) - Personal ✅
- GET /progreso/usuario/recursos - Get all resource reading progress for current user
- GET /progreso/usuario/publicaciones - Get all publication reading progress for current user
- GET /progreso/usuario/recurso/{id} - Get progress for specific resource
- GET /progreso/usuario/publicacion/{id} - Get progress for specific publication

### 3. Notas - Personal ✅
- GET /notas/usuario - Get notes created by current user (private + shared)
- GET /notas/usuario/privadas - Get only private notes
- GET /notas/usuario/compartidas - Get only shared notes

### 4. Intentos (Attempts) - Personal ✅
- GET /intento/usuario - Get all exam attempts by current user
- GET /intento/usuario/examen/{id_examen} - Get user's attempt for specific exam

### 5. Home - New Endpoints ✅
- GET /home/usuario/progreso-examenes - Get user's exam progress (exams taken, average score)
- GET /home/usuario/recientes - Get recently viewed resources/publications
- GET /home/usuario/recursos-leidos - Get resources read by user with progress

## Flutter Updates ✅
- Updated home_remote_datasource.dart
- Updated home_repository.dart
- Updated home_repository_impl.dart
- Updated get_home_data_usecase.dart
- Updated home_viewmodel.dart
- Updated home_screen.dart

## Progress
- [x] Add vistas personal endpoints
- [x] Add progreso personal endpoints
- [x] Add auth to notas endpoints
- [x] Add auth to intentos endpoints
- [x] Create home endpoints
- [x] Update Flutter datasources

