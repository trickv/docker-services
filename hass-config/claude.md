# Home Assistant Configuration Notes

This document contains useful information for working with this Home Assistant setup.

## Docker Setup

This Home Assistant instance runs in Docker (container name: `hass`).

### Viewing Logs

**Basic log viewing:**
```bash
docker logs hass 2>&1 | tail -100          # Last 100 lines
docker logs hass --follow                   # Real-time log streaming
```

**Time-filtered logs:**
```bash
docker logs hass --since 1m 2>&1           # Last 1 minute
docker logs hass --since 5m 2>&1           # Last 5 minutes
docker logs hass --since 10m 2>&1          # Last 10 minutes
```

**Filtered/searched logs:**
```bash
docker logs hass 2>&1 | grep -i "error"                    # Only error lines
docker logs hass 2>&1 | grep -i "sonos"                    # Only Sonos-related
docker logs hass --since 1m 2>&1 | grep -i error           # Recent errors
```

Note: `2>&1` redirects stderr to stdout so you get all output (errors and regular logs).

### Configuration Validation

Since this is a Docker installation (not Home Assistant OS), the `ha` CLI command is not available. Instead, use:

```bash
docker exec hass python -m homeassistant --script check_config --config /config
```

Or use the Home Assistant UI:
- Developer Tools > YAML > "Check Configuration" button

### Reloading Configuration

After making changes, reload via the UI:
- **Scripts**: Developer Tools > YAML > Scripts
- **Automations**: Developer Tools > YAML > Automations
- **Templates**: Developer Tools > YAML > Template Entities
- **All**: Developer Tools > YAML > All YAML Configuration

## Configuration Conventions

### Scripts

When calling scripts from automations, use `action:` not `service:`:

```yaml
# Correct
- action: script.my_script
  data:
    param: value

# Incorrect
- service: script.my_script
  data:
    param: value
```

### Parameterized Scripts

Scripts can accept parameters using the `fields:` section:

```yaml
my_script:
  alias: My Script Name
  fields:
    media_player:
      description: The media player entity
      example: media_player.living_room
      required: true
      selector:
        entity:
          domain: media_player
  sequence:
  - action: media_player.volume_set
    target:
      entity_id: '{{ media_player }}'
    data:
      volume_level: 0.5
```

### Template Conditions

When using template variables in conditions, use `template` conditions not `state` conditions:

```yaml
# Correct - template condition with variable
- condition: template
  value_template: '{{ is_state(media_player, "playing") }}'

# Incorrect - state condition doesn't support template variables for entity_id
- condition: state
  entity_id: '{{ media_player }}'
  state: playing
```

## Recent Refactoring

### Sonos Reset Scripts (Oct 2025)

Consolidated two duplicate Sonos reset scripts into a single parameterized script:
- Old: `stop_and_reset_office_sonos_for_nap` and `stop_and_reset_kids_br_sonos_for_nap`
- New: `reset_sonos_for_nap` (accepts `media_player` and `volume_level` parameters)

This reduces code duplication and makes it easier to add more Sonos speakers in the future.
