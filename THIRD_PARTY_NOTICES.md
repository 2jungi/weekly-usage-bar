# Third-party notices and trademarks

## OpenAI, ChatGPT and Codex

Weekly Usage Bar is an independent community project. It is not an official
OpenAI product and is not affiliated with, endorsed by, or sponsored by OpenAI.

OpenAI, ChatGPT, Codex, and the associated names and logos belong to OpenAI.
The project's MIT license does **not** grant rights to those trademarks,
logos, the Codex executable, or any other third-party software or artwork.

The repository and public release archives do not bundle standalone OpenAI logo assets,
the Codex executable, account credentials, or any part of the official apps.
At runtime, the app may read an unmodified menu bar logo from an official
ChatGPT or Codex app that the user has separately installed, solely to identify
the service whose quota is displayed. The app does not copy that artwork into
its installer. If no matching asset exists, it uses a macOS system
symbol instead.

Use of OpenAI marks remains subject to [OpenAI's brand guidelines and usage
terms](https://openai.com/brand/). Local loading does not transfer ownership
or grant additional reuse or redistribution rights.

## Anthropic and Claude

The Claude Code companion in `claude/` is an independent utility, not an official
Anthropic product. Anthropic and Claude names and logos belong to their respective
rights holders; the MIT license grants no trademark or artwork rights.

No standalone Anthropic artwork, Claude Code executable, or credentials are bundled. The
Claude menu bar app can read a logo from the user's separately installed official
Claude desktop app at runtime. This does not grant redistribution rights. Claude
Code and Anthropic services remain subject to their own licenses and terms.
See the [Claude-specific notices](https://github.com/2jungi/weekly-usage-bar/blob/main/claude/THIRD_PARTY_NOTICES.md).

## Documentation screenshot

`docs/assets/menu-bar-preview.png` is a user-provided screenshot showing both apps
in use. It includes OpenAI and Anthropic service icons for identification and
illustration. The screenshot is documentation, not a source of reusable logo
assets. Third-party marks shown in it remain the property of their owners and
are not licensed by the project's MIT license. Its inclusion does not imply
affiliation or endorsement.

## macOS and system symbols

macOS, AppKit and SF Symbols are Apple technologies. The fallback symbol is
requested from the operating system at runtime; no Apple symbol artwork is
included in the repository or release archive. The MIT license does not
relicense Apple technologies or assets.

## External runtime

Users install and authenticate the official Codex or Claude Code runtime
separately. Their licenses and applicable service terms are independent of this
project's MIT license. Neither app bundles third-party package dependencies.
