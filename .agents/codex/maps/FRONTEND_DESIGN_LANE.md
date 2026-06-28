# Frontend Design Lane

Estado: `ACTIVE_LOCAL_ONLY`

## Proposito

Este mapa declara como la cabina debe preparar trabajo de UI, apps, sitios,
dashboards y herramientas visuales sin improvisar reglas de layout ni implicar
despliegue productivo.

## Activacion

Usar este carril cuando una orden pida construir, revisar o ajustar una
experiencia frontend visible: sitio, app local, dashboard, juego, herramienta,
landing, componente interactivo o flujo con screenshots.

## Cadena

- lead_agent: `rey.control_plane_orchestrator`
- owner_agent: `codex.workspace_guardian`
- reviewer_agent: `court.thot_schema`
- skill: `browser:control-in-app-browser|playwright|agentation|skill-creator`
- receta: `recipe.workspace_reference_audit|recipe.schema_tool_contract`
- tool: `tool.codex_workspace_audit|tool.local_validate_agent_layer`
- validador: `.agents\codex\tools\local_validate_frontend_design_lane.ps1`

## Estandares Minimos

- La primera pantalla debe ser la experiencia util cuando el usuario pide una
  app, juego o herramienta; no una pagina de marketing salvo orden expresa.
- El diseno se adapta al dominio: herramientas operativas priorizan densidad,
  escaneo, comparacion y accion repetida; piezas editoriales o juegos pueden
  ser mas expresivos.
- Los controles deben usar patrones reconocibles: iconos para herramientas,
  swatches para color, toggles para binarios, sliders o inputs para numeros,
  menus para opciones y tabs para vistas. Si existe una libreria de iconos
  disponible en el proyecto, preferir iconos conocidos y tooltips para
  controles no evidentes.
- Los estados interactivos basicos deben ser visibles: hover, focus,
  disabled, error y seleccion actual cuando correspondan.
- La accesibilidad basica incluye contraste suficiente, labels claros y foco
  navegable en controles principales.
- Los textos deben caber en mobile y desktop sin solaparse ni forzar cambios de
  tamano de layout.
- Los elementos fijos como tableros, toolbars, contadores, icon buttons y tiles
  deben tener dimensiones estables.
- Los sitios, juegos y experiencias visuales deben usar assets visuales
  relevantes cuando el usuario necesita inspeccionar producto, lugar, estado o
  gameplay.
- No se debe usar una paleta monotematica ni decoracion generica que tape la
  funcion.
- No se deben anidar cards dentro de cards.
- Una landing hero, cuando exista, debe mostrar el objeto principal en el primer
  viewport y dejar pista de la seccion siguiente.

## Verificacion

Cuando exista app local o frontend renderizable:

- abrir el target local con Browser o Playwright;
- capturar evidencia desktop y mobile cuando el cambio afecta layout;
- revisar que no haya pantalla en blanco, overflow incoherente, texto
  superpuesto, canvas vacio o controles fuera de cuadro;
- si hay canvas o 3D, verificar pixeles no blancos y encuadre;
- no declarar cierre sin evidencia fresca.

Si no existe app local, documentar `NO_APLICA` con razon en el workpaper o PR.

## Fronteras

Permitido:

- diseno local, screenshots locales, browser local, assets generados o
  referencias saneadas;
- mapas, matrices, validators y workpapers de gobernanza frontend.

Requiere orden separada:

- deploy productivo;
- Microsoft live, tenant, SharePoint, Outlook, Teams, Graph o Power Platform;
- OpenAI API live, agentes remotos persistentes, costos o vector stores;
- secretos, datos regulados o assets con credenciales/licencias inciertas.

Stop condition principal: `production_requested_without_explicit_authorization`.
