# PAYSATAPP 🚀

**PAYSATAPP** es una aplicación de pasarela de pagos desarrollada con Flutter, diseñada para ofrecer soluciones financieras rápidas y seguras.  
Permite a empresas y usuarios realizar transacciones, gestionar cuentas, recargas y transferencias.  
Actualmente integra pagos mediante tarjetas **Visa** y otros servicios financieros avanzados.

---

## 📱 Tecnologías utilizadas:

- **Flutter SDK** (versión recomendada: **3.27.x**)
- **Dart**
- **Firebase Functions (Node.js)** para lógica backend específica.
- **Android SDK (API 33/34) y Gradle 7.x**
- **PostgreSQL y APIs externas para procesamiento de pagos.**

---

## ⚙️ Requisitos previos:

Antes de comenzar, asegúrate de tener instalado:

- **Flutter SDK** versión **3.27.x**  
  Verifica con:  
  `flutter --version`


- **Node.js y npm** instalados (mínimo versión 14.x)  
  (Necesario para funciones Firebase en la carpeta `paysat-functions`)

---
## 🛠️ Configuración recomendada de Android Studio

- El proyecto fue desarrollado y probado utilizando **Android SDK versión 33.0.1**.
- Es altamente recomendable instalar y configurar **Android SDK API 33.0.1**, ya que esta versión garantiza compatibilidad total y funcionamiento sin errores con los plugins y dependencias actuales del proyecto.
- Se debe crear un **emulador Android** con API 33 o superior para realizar pruebas locales correctamente.

---

## 📚 Recursos y recomendaciones adicionales

Para una correcta configuración del entorno Android y pruebas móviles, se recomienda consultar:

- Configuración y creación de emuladores Android en **Android Studio**.
- Instalación y configuración del **Android SDK** y variables de entorno.
- Cursos o documentación oficial sobre:
  - Despliegue de aplicaciones móviles en Android Studio.
  - Emulación y testing de aplicaciones Flutter en dispositivos físicos y virtuales.

## 🚀 Instalación del proyecto:

```bash
git clone https://github.com/PAYSat/PAYSATAPP.git
cd PAYSATAPP
flutter pub get
cd paysat-functions
npm install
cd ..


▶️ Ejecutar la app:

flutter run
