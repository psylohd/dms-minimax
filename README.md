# MiniMax Code Usage

A [DMS (Dank Material Shell)](https://github.com/AvengeMedia/DankMaterialShell) plugin that monitors your MiniMax Code subscription usage directly from the taskbar.

![Screenshot](screenshot.png)

## Features

- **Taskbar pill** with circular progress ring showing 5-hour rate limit utilization
- **Detailed popout** with:
  - 5-hour and 7-day rate window utilization with countdown timers
  - Pacing indicator showing whether you're over or under a linear burn rate for each window (e.g. "6% over pace", "25% under pace")
  - Included quota breakdown per period
  - Weekly activity bar chart with interactive hover tooltips
- **Automatic rate limit monitoring** via the MiniMax Token Plan API
- **Hardcoded MiniMax pricing** — no external pricing fetch needed
- **Currency support** — costs displayed in EUR for French locale, USD otherwise (exchange rate from ECB via [Frankfurter](https://www.frankfurter.app/))
- **Configurable refresh interval** (2 to 15 minutes)
- **Localization support** (English, French, and Spanish)

## Requirements

- [DMS Shell](https://github.com/AvengeMedia/DankMaterialShell)
- [jq](https://jqlang.github.io/jq/) (JSON processor)
- An active MiniMax account with a Token Plan or pay-as-you-go API key

## Installation

### From the DMS Plugin Registry

```
:dms plugins install minimaxCodeUsage
```

Or browse the plugin list in DMS Settings (`Mod + ,` > Plugins).

### Manual

Clone this repository into your DMS plugins directory:

```bash
git clone https://github.com/titeya/dms-minimax \
  ~/.config/DankMaterialShell/plugins/minimaxCodeUsage
```

Then restart DMS.

## Configuration

Open DMS Settings (`Mod + ,` > Plugins > MiniMax Code Usage) to adjust the refresh interval
and toggle pacing indicators.

## How It Works

The plugin runs a lightweight bash script at the configured interval that:

1. Reads your MiniMax credentials from `~/.mmx/config.json`
2. Queries the MiniMax Token Plan API (`/v1/token_plan/remains`) for current quota status
3. Caches responses for 90 seconds (`~/.mmx/quota-cache.json`)

All data stays local. Network requests are limited to the official MiniMax API.

## License

[MIT](LICENSE)
