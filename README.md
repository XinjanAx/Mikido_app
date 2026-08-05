# Torneo App — Club MIKIDO

Aplicación móvil para la gestión integral de torneos deportivos del Club MIKIDO: creación de torneos, inscripción de participantes, generación de encuentros, registro de resultados, tablas de posiciones y reportes en PDF. 

## Objetivo

Un club que organiza torneos internos necesita: registrar quién participa, decidir el formato de competencia (liga, grupos o eliminación directa), llevar el calendario de encuentros, capturar resultados y mantener una tabla de posiciones actualizada, sin depender de planillas manuales.

El problema adicional que resuelve esta app es el de **conectividad no garantizada**: el encargado de cargar resultados suele estar en la cancha, no en una oficina con wifi estable. Por eso el requisito de diseño no es solo "gestionar torneos", sino que la app funcione con normalidad sin conexión y sincronice sola cuando la red vuelve, sin que el usuario tenga que pensar en ello.

## Funcionalidades principales

**Torneos**
- Crear, editar y eliminar torneos, con modalidad (liga, grupos, eliminación simple) y ciclo de vida (`draft` → `active` → `finished` / `cancelled`).

**Participantes**
- Alta, baja y edición de jugadores (catálogo global, reutilizable entre torneos).

**Encuentros (fixtures)**
- Generación automática según modalidad:
  - **Liga**: round-robin por el método del círculo, con opción de ida y vuelta.
  - **Grupos**: reparto automático (aleatorio) o manual de jugadores en grupos, round-robin dentro de cada grupo.
  - **Eliminación simple**: cuadro de tamaño potencia de 2 con siembra estándar, orden manual o aleatorio, y BYE automático para los sembrados que exceden el número real de jugadores.

**Resultados y posiciones**
- Registro de marcador por encuentro.
- Recálculo automático de la tabla de posiciones (partidos jugados, ganados, empatados, perdidos, goles a favor/en contra, puntos) cada vez que se guarda un resultado.

**Reportes**
- Exportación a PDF de la tabla de posiciones y los resultados de un torneo, con membrete del club.

**Notificaciones**
- Avisos locales antes del inicio y del cierre de un torneo (a los 30/10/5 minutos de empezar, a 60/30/10/5 minutos de terminar).

**Cuentas**
- Registro e inicio de sesión contra Supabase Auth, con dos roles (`admin`, `user`) que determinan qué pantallas son editables.

## Arquitectura

El proyecto sigue **Clean Architecture** combinada con **MVVM**, aplicada de forma idéntica en cada feature (`tournaments`, `players`, `fixtures`, `results`, `standings`, `auth`, `notifications`, `reports`). La razón de mantener esta estructura repetida en vez de compartir código entre features es que cada una tiene su propio ciclo de vida de sincronización (outbox por tabla) y sus propias reglas de negocio; forzar una capa compartida hubiera acoplado features que en la práctica cambian por separado.


## Tecnologías utilizadas

| Tecnología 				                  | Función 					                            | Justificación |
|---					                        |---						                                |---
| Flutter / Dart 		                 	| Framework de UI multiplataforma 		          | Requisito del cambio de stack aprobado para el proyecto; permite compilar a Android y Windows desde una sola base de código. |
| Riverpod (`flutter_riverpod`)     	| Gestión de estado e inyección de dependencias | Reemplazo directo de Hilt/ViewModel de Android. Los providers son la unidad de DI (repositorios, datasources, casos de uso) y de estado (`StateNotifier`) a la vez, sin generar código adicional ni depender de `BuildContext`. |
| GoRouter 				                    | Navegación declarativa 			                  | Permite definir rutas anidadas y un `redirect` centralizado que aplica el guard de sesión y de rol admin en un solo lugar, en vez de repetir el chequeo en cada pantalla. |
| Drift + `sqlite3_flutter_libs`	    | Persistencia local (SQLite) 			            | Equivalente directo a Room. Genera código type-safe a partir de las tablas (`app_database.g.dart`) y expone `Stream` reactivos (`watch...`) que alimentan la UI sin necesidad de un mecanismo de notificación aparte. |
| Supabase (`supabase_flutter`) 	    | Backend remoto: PostgreSQL + Auth		          | Evita mantener un backend propio para un proyecto académico, sin perder autenticación real ni una base de datos relacional real. `supabase_flutter` además expone directamente el cliente de Postgres y de Auth que ya se necesitan. |
| `dartz` (`Either<Failure, T>`) 	   | Manejo de errores en la capa de dominio 	      | Obliga a que cada repositorio declare explícitamente sus casos de fallo (`CacheFailure`, `NotFoundFailure`, `AuthException`, etc.) en la firma del método, en vez de propagar excepciones no tipadas hasta la UI. |
| `equatable` 				                | Comparación de valor en entidades y estados 	| Necesario para que Riverpod detecte correctamente cuándo un `StateNotifier` cambió de estado y evite reconstruir la UI si el contenido es igual. |
| `flutter_local_notifications` + `timezone` | Notificaciones locales programadas 	  | Los avisos de inicio/fin de torneo son eventos locales al dispositivo; `timezone` es necesario porque `zonedSchedule` exige una hora con zona horaria explícita. |
| `pdf` + `printing` + `file_picker` 	| Generación y guardado de reportes PDF 	      | `pdf` arma el documento en memoria, `printing` cubre el flujo de compartir como respaldo, y `file_picker` permite elegir dónde guardar el archivo tanto en Android (SAF) como en Windows (diálogo nativo). |
| `connectivity_plus` 			          | Detección de conectividad 			              | Dispara una sincronización apenas el sistema reporta que volvió la red, sin necesidad de que el usuario reabra la app. |
| `uuid` 			                       	| Generación de identificadores 	            	| Los ids se generan en el cliente (no autoincrementales) porque una fila puede crearse offline y sincronizarse más tarde; un id autoincremental de servidor no está disponible en ese momento. |


## Organización del proyecto

```
lib/
├── core/                         # código transversal, sin lógica de negocio de ningún feature
│   ├── database/                 # esquema Drift (tablas + AppDatabase) y outbox de sincronización
│   ├── sync/                     # SyncEngine + contrato SyncAdapter
│   ├── connectivity/             # provider de estado de red
│   ├── errors/                   # Failure (dominio) y Exception (datasources)
│   ├── constants/                # constantes de app, rutas y credenciales/tablas de Supabase
│   ├── theme/                    # colores, tipografía y modo claro/oscuro
│   ├── extensions/                # extensiones sobre String/DateTime
│   ├── utils/                    # generación de PDF
│   └── widgets/                  # widgets compartidos (estado vacío, error, loading, footer)
│
├── features/
│   └── <feature>/
│       ├── domain/
│       │   ├── entities/          # modelos puros de negocio (sin serialización)
│       │   ├── repositories/      # interfaces (contrato que implementa data/)
│       │   └── usecases/          # una acción de negocio por clase
│       ├── data/
│       │   ├── models/            # entidad + (de)serialización JSON / Drift
│       │   ├── datasources/       # local (Drift) y remoto (Supabase)
│       │   ├── repositories/      # implementación concreta de domain/repositories
│       │   ├── services/          # lógica de dominio que no encaja en un UseCase simple
│       │   │                      #   (FixtureGenerator, EliminationBracketService, StandingsCalculator)
│       │   └── sync/               # SyncAdapter concreto del feature
│       └── presentation/
│           ├── providers/          # StateNotifier + providers de Riverpod
│           ├── screens/            # pantallas
│           └── widgets/            # widgets propios del feature
│
└── navigation/                    # configuración de GoRouter y guard de sesión/rol
```

Las ocho features siguen esta misma subdivisión (`tournaments`, `players`, `fixtures`, `results`, `standings`, `auth`, `notifications`, `reports`), excepto: `auth` y `notifications`, no tienen `sync/` porque no son offline-first (ver sección de sincronización).


## Ejecución del proyecto

### Requisitos
- Flutter SDK (canal estable, Dart >= 3.0).
- Un proyecto de Supabase propio (o acceso al existente del Club MIKIDO) con las tablas `tournaments`, `players`, `enrollments`, `matches`, `results`, `standings`, `profiles`.

### Instalación

```bash
flutter pub get
```

### Configurar Supabase

Editar `lib/core/constants/supabase_constants.dart` con la URL y la anon key del proyecto de Supabase a usar. Las políticas RLS de las tablas deben permitir lectura/escritura según el rol (`profiles.role`) esperado por la app.

### Ejecutar

```bash
flutter run                    # Android (dispositivo o emulador conectado)
flutter run -d windows          # ejecutable de escritorio Windows
```

### Compilar para producción

```bash
flutter build apk --release        # Android
flutter build windows --release    # Windows
```

## Licencia

Proyecto académico desarrollado para la asignatura de Actualización de Dispositivos Móviles, sin licencia de distribución pública.
