# stock_app

Esta aplicacion escanea codigos de barras de productos en locales comerciales, los almacena temporalmente en una base de datos SQLite y luego al final del ciclo se sincroniza a una base de datos central, con el fin de llevar un stock de la tienda.

## Features
- Manejo Firebird hacia SQLite.
- Base de datos SQLite para flutter.
- Conexion mediante web service.

## Requerimientos
- Dispositivo mobil (Android o iOS)
- Dependencias
  - ver más abajo.

## Instalacion
1. Clone the repository:

    ```bash
    codigo va aqui
    ```
## Uso

1. Otorgar permisos para utilizar camara del mobil.
2. Sincronizar para comprobar que no hayan productos nuevos en la base de datos central.
3. Escanear codigo de barras y selecciona la cantidad de productos.
4. Al final del ciclo de control de stock, presionar **Enviar** para llevar los cambios a la base central.
