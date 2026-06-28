# Inventario final de la PC - 2026-06-15

Estado resumido de la limpieza y del cierre de superficie auxiliar en esta sesión.

## Verde

- `Codex`
- `pwsh` / `powershell`
- `node` / `node_repl`
- `explorer`
- `SecurityHealth`

## Amarillo

- `edgeupdate` / `edgeupdatem` - deshabilitados
- `AnyDesk` - deshabilitado
- `AdobeARMservice` / `AdobeUpdateService` - deshabilitados
- `GoogleUpdater*` - deshabilitados
- `McAfee WebAdvisor` - deshabilitado
- `HP*` auxiliares - deshabilitados
- `PAD*` / `UIFlow*` - deshabilitados
- `WAPC*` - deshabilitados
- `GlobalSecureAccess*` - deshabilitados
- `OneDrive Updater Service` - detenido
- `WSearch` - deshabilitado
- `Spooler` - deshabilitado
- `SearchHost` / `msedgewebview2` - componentes de busqueda moderna de Windows, reaparecen como parte del shell

## Rojo

- `BrokerInfrastructure`
- `DcomLaunch`
- `PlugPlay`
- `Power`
- `SystemEventsBroker`
- `svchost.exe` base que hospeda esos servicios

## Ajustes de busqueda aplicados en usuario

- `DisableSearchBoxSuggestions = 1`
- `BingSearchEnabled = 0`
- `CortanaConsent = 0`
- `ShowSearchHighlights = 0`

## Observacion

- La superficie de busqueda visible quedo recortada.
- `SearchHost` y `msedgewebview2` se comportan como parte de la experiencia moderna de Windows, no como un servicio extra aislado.
- La infraestructura base de Windows quedo intacta.
