# Patimovil Rider

Aplicación móvil (Flutter) para **pasajeros** del servicio de transporte **Patimovil**. Permite a los usuarios registrarse, solicitar viajes en tiempo real, seguir al conductor en el mapa, comunicarse por chat y calificar el servicio.

Este repositorio corresponde a la app del **pasajero/cliente** (rider). Está construida con Flutter y se apoya en Firebase y Google Maps como backend de tiempo real y geolocalización.

## Características

- **Autenticación de usuarios** con Firebase Auth (registro, inicio de sesión, recuperación de contraseña).
- **Solicitud de viajes en tiempo real**: el pasajero fija origen y destino y la app busca conductores cercanos.
- **Mapa interactivo** con Google Maps: ubicación actual, marcadores, trazado de ruta (polylines) y seguimiento del conductor.
- **Búsqueda de direcciones** con autocompletado de Google Places (Places Autocomplete y Place Details).
- **Detección de conductores cercanos** mediante GeoFire sobre Firebase Realtime Database.
- **Estimación de tarifa** calculada a partir de la distancia y duración de la ruta (Google Directions API) y tarifas configuradas en Firebase.
- **Chat en tiempo real** entre pasajero y conductor.
- **Notificaciones push** con Firebase Cloud Messaging (asignación de viaje, estado del servicio, etc.).
- **Reconexión al viaje en curso**: si el usuario cierra la app durante un servicio, la retoma al reabrirla.
- **Historial de viajes** y **calificación del conductor** al finalizar el viaje.
- **Viajes programados** (scheduled trips).
- **Métodos de pago**, sección de **viajes gratis**, **políticas**, **acerca de** y **soporte / mesa de ayuda** (contacto vía correo y WhatsApp).

## Tecnologías

- **Flutter** / Dart (SDK Dart `>=2.7.0 <3.0.0`).
- **Firebase**: Core, Auth, Realtime Database, Cloud Firestore, Cloud Messaging, Storage.
- **Google Maps Flutter**, **Geolocator**, **flutter_geofire**, **flutter_polyline_points**, **maps_toolkit**.
- **Google Maps Platform APIs**: Geocoding, Directions, Places.
- **Provider** para el manejo de estado.
- Otros: `image_picker`, `permission_handler`, `sliding_up_panel`, `flutter_rating_bar`, `webview_flutter`, `audioplayer`, `mailer`, `whatsapp_unilink`, entre otros.

## Estructura del proyecto

```
lib/
├── main.dart                # Punto de entrada, inicialización de Firebase y rutas
├── firebase/                # Lógica de autenticación
├── helpers/                 # Métodos de mapas, base de datos, notificaciones y peticiones HTTP
├── models/                  # Modelos de datos (dirección, viaje, conductor, usuario, etc.)
├── provider/                # Manejo de estado con Provider (AppDataProvider)
├── screens/                 # Pantallas: login, registro, mapa principal, chat, historial, etc.
├── styles/                  # Estilos de la app y del mapa
├── utils/                   # Colores de marca, variables globales y utilidades
└── widgets/                 # Componentes reutilizables (botones, hojas deslizables, marcadores...)
```

Otros directorios: `android/` e `ios/` (proyectos nativos), `assets` en `images/`, `sounds/`, `icons/` y `fonts/`.

## Requisitos previos

- [Flutter](https://flutter.dev/docs/get-started/install) instalado (compatible con Dart `>=2.7.0 <3.0.0`).
- Un proyecto de **Firebase** configurado (archivos `google-services.json` para Android y `GoogleService-Info.plist` para iOS).
- Una **API key de Google Maps Platform** con Maps, Geocoding, Directions y Places habilitados.

## Instalación y ejecución

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en un dispositivo o emulador
flutter run
```

Para generar una versión de lanzamiento:

```bash
flutter build apk        # Android
flutter build ios        # iOS
```

## Configuración

- **Firebase**: la app inicializa el proyecto `patimovil-ccb6a`. Reemplaza las credenciales de Firebase (en `lib/main.dart` y los archivos de configuración nativos) por las de tu propio proyecto si vas a desplegarla.
- **Google Maps API key**: se referencia como `mapKey` en las utilidades globales; configúrala con una clave válida.
- **Iconos de la app**: se generan con `flutter_launcher_icons` a partir de `icons/icono_pasajero.png`.

---

> Proyecto privado de Patimovil. Para soporte: soporte@patimovil.net
