# Guia de Creacion de Elementos

Documento de referencia para crear cada tipo de elemento en este addon de Minecraft Bedrock (namespace `everything:`). Incluye los archivos necesarios, campos clave y errores encontrados durante el desarrollo.

---

## Prerequisitos de Depuracion

Antes de crear cualquier elemento, es imprescindible configurar lo siguiente:

1. **Content Log**: Activar en Settings > Creator > Enable Content Log GUI y Enable Content Log File. Sin esto, los errores de configuracion no se muestran y se pierde tiempo depurando a ciegas.

2. **Recarga de cambios**: Despues de cualquier cambio en los archivos del dev pack, se debe **SALIR del mundo y volver a entrar**. Recargar desde el menu de pausa NO es suficiente para que los cambios tomen efecto.

---

## Item Basico

Patron documentado a partir de `custom_sword`.

### Archivos Requeridos

| Archivo | Pack | Rol |
|---------|------|-----|
| `behavior_pack/items/custom_sword.json` | BP | Define el item: identificador, categoria del menu, icono, dano, durabilidad |
| `resource_pack/textures/items/custom_sword.png` | RP | Textura del item (16x16 PNG) |
| `resource_pack/textures/item_texture.json` | RP | Mapea el nombre corto de textura al archivo PNG |
| `resource_pack/texts/en_US.lang` | RP | Nombre visible del item en el juego |

### Campos Clave

**Item JSON** (`behavior_pack/items/custom_sword.json`):

- `format_version`: `"1.21.10"`
- `description.identifier`: `"everything:custom_sword"`
- `description.menu_category`: Categoria y grupo para el menu creativo
- `components.minecraft:icon.textures.default`: Nombre corto que debe coincidir con la clave en `item_texture.json`
- `components.minecraft:damage.value`: Dano del item
- `components.minecraft:durability.max_durability`: Durabilidad maxima
- `components.minecraft:hand_equipped`: `true` para que se renderice como herramienta en mano

**Item Texture JSON** (`resource_pack/textures/item_texture.json`):

- `texture_data.<nombre_corto>.textures`: Ruta al PNG sin extension (ej: `"textures/items/custom_sword"`)

**Localizacion** (`resource_pack/texts/en_US.lang`):

- Formato: `item.everything:<nombre>.name=Nombre Visible`

### Errores Comunes

- El nombre corto en `minecraft:icon.textures.default` no coincide con la clave en `item_texture.json` — el item aparece con textura de "missing".
- Olvidar la entrada en `en_US.lang` — el item aparece con su identificador tecnico en vez del nombre legible.

---

## Item con Script

Patron documentado a partir de `mega_sword`. Agrega scripting sobre la base de un item basico. Puede incluir componentes adicionales como `minecraft:glint` (efecto de encantamiento visual).

### Archivos Requeridos

Todos los del item basico, mas:

| Archivo | Pack | Rol |
|---------|------|-----|
| `behavior_pack/scripts/main.js` | BP | Logica del script (eventos, efectos) |
| `behavior_pack/manifest.json` (modificado) | BP | Debe incluir modulo `script` y dependencia `@minecraft/server` |

### Campos Clave Adicionales

**Manifest** (`behavior_pack/manifest.json`) — requiere estas adiciones:

- Un modulo adicional en `modules[]` con `"type": "script"`, `"language": "javascript"`, y `"entry": "scripts/main.js"`.
- Una dependencia en `dependencies[]` con `"module_name": "@minecraft/server"` y la version requerida (ej: `"1.13.0"`).

**Script** (`behavior_pack/scripts/main.js`):

- Importar de `@minecraft/server` (ej: `import { world } from "@minecraft/server"`).
- Suscribirse a eventos del mundo (ej: `world.afterEvents.entityHitEntity`).

### Errores Comunes

- Faltar el modulo `script` en el manifest — el script no se carga, sin error visible.
- Faltar la dependencia `@minecraft/server` en el manifest — error al cargar el pack.
- El campo `entry` no apunta al archivo correcto — el script no se ejecuta.

---

## Entidad

Patron documentado a partir de la entidad shark. Una entidad completa requiere 10 archivos (9 nuevos y 1 modificado).

### Archivos Requeridos

| Archivo | Pack | Rol |
|---------|------|-----|
| `behavior_pack/entities/<nombre>.json` | BP | Definicion server-side: salud, ataque, IA, movimiento, despawn |
| `behavior_pack/spawn_rules/<nombre>.json` | BP | Condiciones de spawn natural (bioma, grupo, densidad) |
| `behavior_pack/loot_tables/entities/<nombre>.json` | BP | Drops al morir |
| `resource_pack/entity/<nombre>.entity.json` | RP | Definicion client-side: vincula geometria, textura, material, render controller, animaciones |
| `resource_pack/render_controllers/<nombre>.render_controllers.json` | RP | Especifica que geometria, textura y material usar para renderizar |
| `resource_pack/animations/<nombre>.animation.json` | RP | Keyframes de animacion (nadar, atacar) |
| `resource_pack/animation_controllers/<nombre>.animation_controllers.json` | RP | Maquina de estados de animacion |
| `resource_pack/models/entity/<nombre>.geo.json` | RP | Geometria del modelo 3D |
| `resource_pack/textures/entity/<nombre>.png` | RP | Textura del modelo |
| `resource_pack/texts/en_US.lang` (modificado) | RP | Nombre de la entidad y del spawn egg |

### Campos Clave por Archivo

**Entidad BP** (`behavior_pack/entities/<nombre>.json`):

- `format_version`: `"1.21.10"`
- `description.identifier`: `"everything:<nombre>"`
- `description.is_spawnable`: `true`
- `description.is_summonable`: `true`
- Componentes minimos: `minecraft:health`, `minecraft:physics`, `minecraft:collision_box`, `minecraft:movement`, `minecraft:type_family`

**Client Entity RP** (`resource_pack/entity/<nombre>.entity.json`):

- `format_version`: `"1.10.0"`
- `description.identifier`: debe coincidir con el BP
- `description.materials`: `{ "default": "entity" }` — OBLIGATORIO
- `description.textures`: `{ "default": "textures/entity/<nombre>" }`
- `description.geometry`: `{ "default": "geometry.<nombre>" }`
- `description.animations`: mapa con alias para animaciones Y animation controllers
- `description.scripts.animate`: lista de alias a activar automaticamente
- `description.render_controllers`: `["controller.render.<nombre>"]`
- `description.spawn_egg`: colores para el huevo de spawn

**Render Controller** (`resource_pack/render_controllers/<nombre>.render_controllers.json`):

- `format_version`: `"1.8.0"` — usar EXACTAMENTE esta version
- Claves Molang con MAYUSCULA INICIAL: `Geometry.default`, `Material.default`, `Texture.default`

**Geometria** (`resource_pack/models/entity/<nombre>.geo.json`):

- `format_version`: `"1.12.0"`
- `description.identifier`: `"geometry.<nombre>"` — debe coincidir con lo referenciado en client entity
- `description.texture_width` y `texture_height`: deben coincidir con las dimensiones del PNG

**Localizacion** (`resource_pack/texts/en_US.lang`):

- `entity.everything:<nombre>.name=Nombre Visible`
- `item.spawn_egg.entity.everything:<nombre>.name=Nombre Spawn Egg`

### Errores Conocidos (Entidades)

Todos los errores siguientes producen el MISMO sintoma: **la entidad aparece en el mundo pero es invisible, sin mensaje de error ni crash**.

| # | Error | Valor Incorrecto | Valor Correcto |
|---|-------|-------------------|----------------|
| 1 | Claves del render controller en minuscula | `geometry.default`, `material.default`, `texture.default` | `Geometry.default`, `Material.default`, `Texture.default` |
| 2 | Animation controller registrado como array separado | En array `animation_controllers` del client entity | Debe ir en el mapa `animations` con un alias, y activarse en `scripts.animate` |
| 3 | Material incorrecto para mob opaco | `entity_alphatest` | `entity` (para mobs opacos) |
| 4 | format_version incorrecta en render controller | `"1.10.0"` | `"1.8.0"` |
| 5 | Campo materials faltante en client entity | Sin campo `materials` en description | `"materials": { "default": "entity" }` es obligatorio |
| 6 | Falta componente base de movimiento | Solo `minecraft:movement.sway` | Se necesitan AMBOS: `minecraft:movement` (valor base) y `minecraft:movement.sway` |
