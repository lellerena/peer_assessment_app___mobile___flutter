# 🎓 Peer Assessment App

![Peer Review](https://cdn-icons-png.flaticon.com/512/3135/3135715.png)

## Descripción

Peer Assessment App es una plataforma móvil desarrollada en Flutter que permite a los estudiantes evaluar el desempeño y compromiso de sus compañeros en actividades colaborativas de cursos. El objetivo es fomentar la autoevaluación, el aprendizaje entre pares y la mejora continua dentro de grupos académicos.

---

## 🚀 Características principales

### 🔐 **Autenticación y Gestión de Usuarios**
- **Login/Registro**: Sistema de autenticación seguro con validación de credenciales
- **Gestión de perfiles**: Los usuarios pueden ver y editar su información personal
- **Roles de usuario**: Diferenciación entre profesores y estudiantes con permisos específicos
- **Integración con Roble API**: Autenticación centralizada con el sistema universitario

### 📚 **Gestión de Cursos**
- **CRUD completo de cursos**: Crear, editar, eliminar y visualizar cursos
- **Inscripción de estudiantes**: Los profesores pueden inscribir estudiantes en sus cursos
- **Visualización de participantes**: Lista detallada de todos los usuarios inscritos en cada curso
- **Dashboard de cursos**: Vista general de todos los cursos disponibles

### 🗂️ **Sistema de Categorías y Grupos**
- **CRUD de categorías**: Los profesores pueden crear categorías de evaluación (Responsabilidad, Trabajo en equipo, etc.)
- **Métodos de agrupación**:
  - **Manual**: El profesor asigna estudiantes a grupos específicos
  - **Self-assigned**: Los estudiantes se auto-inscriben en grupos
  - **Automático**: El sistema distribuye estudiantes automáticamente
- **Gestión de grupos**: Crear, editar y eliminar grupos dentro de cada categoría
- **Asignación de estudiantes**: Mover estudiantes entre grupos según el método de agrupación

### 📝 **Sistema de Actividades**
- **CRUD de actividades**: Crear actividades específicas para cada categoría
- **Tipos de actividades**: Diferentes formatos de actividades colaborativas
- **Asignación por categoría**: Cada actividad está vinculada a una categoría específica
- **Gestión de fechas**: Establecer fechas de inicio y fin para las actividades

### 🎯 **Módulo de Evaluaciones (Peer Assessment)**
- **Creación de evaluaciones**: Los profesores pueden crear evaluaciones entre pares
- **Configuración flexible**:
  - **Escalas de evaluación**: Estrellas (1-5), Numérica (0-100), Binaria (Sí/No)
  - **Criterios personalizables**: Definir qué aspectos evaluar
  - **Comentarios opcionales/obligatorios**: Permitir retroalimentación escrita
- **Ventanas temporales**: Establecer fechas de inicio y fin para las evaluaciones
- **Control de visibilidad**: Activar/desactivar evaluaciones para los estudiantes
- **Estados de evaluación**: Borrador, Activa, Finalizada

### 👥 **Sistema de Evaluación Entre Pares**
- **Evaluación por pares**: Los estudiantes evalúan a sus compañeros de grupo
- **Exclusión de autoevaluación**: Los estudiantes no pueden evaluarse a sí mismos
- **Interfaz intuitiva**: Formularios fáciles de usar para realizar evaluaciones
- **Criterios específicos**: Evaluar aspectos específicos según la configuración del profesor

### 📊 **Reportes y Análisis**
- **Resultados consolidados**: Vista general de todas las evaluaciones realizadas
- **Promedios por estudiante**: Cálculo automático de calificaciones promedio
- **Análisis por grupo**: Comparación de desempeño entre grupos
- **Exportación de datos**: Generar reportes para análisis posterior

### 🔄 **Integración con Roble API**
- **Sincronización de datos**: Todos los datos se almacenan en la API de Roble
- **Fallback local**: Sistema de respaldo cuando la API no está disponible
- **Gestión de errores**: Manejo robusto de errores de conectividad
- **Almacenamiento híbrido**: Combinación de almacenamiento remoto y local

---

## 🏗️ Arquitectura

El proyecto sigue los principios de **Clean Architecture** y **SOLID**, separando claramente la lógica de negocio, la gestión de datos y la presentación. Esto facilita el mantenimiento, la escalabilidad y la futura integración con bases de datos o servicios externos.

### **Estructura del Proyecto:**
```
lib/
├── core/                    # Configuración central
│   ├── app_theme.dart      # Temas y estilos
│   ├── i_local_preferences.dart
│   ├── local_preferences_secured.dart
│   ├── local_preferences_shared.dart
│   ├── refresh_client.dart
│   └── router/              # Navegación
│       ├── app_pages.dart
│       └── app_routes.dart
├── features/               # Funcionalidades por módulos
│   ├── auth/               # Autenticación
│   ├── courses/            # Cursos, categorías, grupos, actividades
│   └── splash/             # Pantalla de carga
└── injection_container.dart # Inyección de dependencias
```

### **Tecnologías Utilizadas:**
- **Flutter**: Framework de desarrollo móvil
- **GetX**: Gestión de estado, navegación y dependencias
- **Clean Architecture**: Separación de responsabilidades
- **Roble API**: Integración con sistema universitario
- **HTTP Client**: Comunicación con APIs externas

---

## 📦 Entregas Implementadas

### **Primera Entrega - Base del Sistema**
- ✅ **Autenticación de usuario** con integración Roble
- ✅ **Gestión de cursos** (CRUD completo)
- ✅ **CRUD de categorías** con métodos de agrupación
- ✅ **Visualización de cursos inscritos**
- ✅ **Pantalla Home integradora**

### **Segunda Entrega - Gestión de Grupos y Actividades**
- ✅ **Sistema de grupos** con métodos de asignación
- ✅ **CRUD de actividades** por categoría
- ✅ **Gestión de estudiantes** en grupos
- ✅ **Interfaz de administración** para profesores

### **Tercera Entrega - Evaluaciones Entre Pares**
- ✅ **Módulo de evaluaciones** completo
- ✅ **Sistema de escalas flexibles** (estrellas, numérica, binaria)
- ✅ **Evaluación entre pares** con exclusión de autoevaluación
- ✅ **Reportes consolidados** para profesores
- ✅ **Integración completa con Roble API**
- ✅ **Sistema de fallback local** para robustez

---

## 🛠️ Cómo ejecutar

### **Prerrequisitos:**
- Flutter SDK (versión 3.0 o superior)
- Dart SDK
- Android Studio / VS Code
- Dispositivo Android o emulador

### **Instalación:**
1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/lellerena/PeerReview.git
   cd PeerReview
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

### **Configuración de Usuarios de Prueba:**
- **Profesor:** `admin@example.com` / `123456`
- **Estudiantes:** `b@a.com` a `g@a.com` / `123456`

---

## 📱 Funcionalidades por Pantalla

### **Pantalla de Login**
- Autenticación con credenciales
- Validación de campos
- Integración con Roble API

### **Pantalla Home**
- Navegación a todas las funcionalidades
- Vista de cursos inscritos
- Acceso rápido a evaluaciones

### **Gestión de Cursos**
- Lista de cursos disponibles
- Crear nuevo curso
- Ver detalles del curso
- Gestionar participantes

### **Gestión de Categorías**
- Crear categorías de evaluación
- Configurar métodos de agrupación
- Gestionar grupos dentro de categorías
- Asignar estudiantes a grupos

### **Módulo de Evaluaciones**
- Crear evaluaciones con criterios personalizados
- Configurar escalas de evaluación
- Activar/desactivar evaluaciones
- Ver resultados consolidados

### **Evaluación Entre Pares**
- Interfaz para estudiantes
- Formularios de evaluación
- Criterios específicos
- Comentarios opcionales

---

## 🔧 Configuración Técnica

### **Dependencias Principales:**
```yaml
dependencies:
  flutter: ^3.0.0
  get: ^4.6.6
  http: ^1.1.0
  loggy: ^1.0.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
```

### **Estructura de Datos:**
- **Usuarios**: Información personal y roles
- **Cursos**: Metadatos y participantes
- **Categorías**: Criterios de evaluación
- **Grupos**: Asignación de estudiantes
- **Actividades**: Tareas colaborativas
- **Evaluaciones**: Configuración y criterios
- **Respuestas**: Evaluaciones realizadas por estudiantes


---

## 📥 Descargas

- [PeerReview v0.0.1 APK](https://github.com/lellerena/PeerReview/releases/download/v0.0.1/PeerReview-0.0.1.apk)

---

## 👥 Equipo

- **Héctor Suarez**
- **Luis Llerena**
- **Jhon Jimenez**

---

## 🎯 Estado del Proyecto

### **✅ Completado (90%)**
- Sistema de autenticación
- Gestión completa de cursos
- Sistema de categorías y grupos
- Módulo de evaluaciones entre pares
- Integración con Roble API
- Interfaz de usuario completa

### **🔄 En Desarrollo**
- Reportes avanzados
- Optimizaciones de rendimiento
- Pruebas de integración

### **📋 Pendiente**
- Modo offline completo
- Notificaciones push
- Analytics avanzados

---

![Peer Review Demo](https://cdn.dribbble.com/users/1787323/screenshots/5602466/peer_review.png)

---

✨ **¡Gracias por revisar nuestro proyecto!** ✨
