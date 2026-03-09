# TODO - Actualizar endpoints a Access Token

## Flutter - Changes

### 1. Modificar DioClient para incluir access_token
- [x] Leer dio_client.dart actual
- [x] Actualizar para incluir interceptor que añade el token ✅ (YA ESTABA IMPLEMENTADO)

### 2. Actualizar ExamRemoteDataSource
- [x] Leer archivo actual
- [x] Cambiar `getCompletedExams()` de `/intento/` a `/intento/usuario` ✅ (YA ESTABA IMPLEMENTADO)
- [x] Actualizar `submitExam()` para usar current_user ✅ (El backend ahora extrae del token)

### 3. Actualizar NoteRemoteDataSource
- [x] Leer archivo actual
- [x] Cambiar `getNotes()` de `/notas/` a `/notas/usuario` ✅ (YA ESTABA IMPLEMENTADO)
- [x] Actualizar `createNote()` para usar current_user ✅ (El backend ahora extrae del token)
- [x] Actualizar `updateNote()` y `deleteNote()` para verificar propiedad ✅ (IMPLEMENTADO)

## Backend - Changes

### 1. Verificar/actualizar endpoints de intento
- [x] Verificar que `/intento/usuario` funciona correctamente ✅
- [x] Actualizar `create_intento` para usar `current_user` ✅

### 2. Verificar/actualizar endpoints de notas
- [x] Verificar que `/notas/usuario` funciona correctamente ✅
- [x] Agregar verificación de propiedad para update/delete ✅
- [x] Actualizar `create_nota` para usar `current_user` ✅

## Endpoints verificados que ya usan current_user:
- `/usuarios/me` ✅
- `/usuarios/{id}` ✅ (verifica propiedad)
- `/home/usuario/progreso-examenes` ✅
- `/home/usuario/recientes` ✅
- `/home/usuario/recursos-leidos` ✅
- `/intento/usuario` ✅
- `/notas/usuario` ✅

