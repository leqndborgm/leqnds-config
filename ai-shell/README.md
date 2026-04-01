# AI Shell

A Nix dev shell with AI tools — `oterm` with direct file access to your project folders.

## Usage

```bash
cd ai-shell
nix develop
oterm
```

oterm is configured with an MCP filesystem server that gives the AI **direct access** to `~/Projekte`. You can ask it to:
- Read and analyze files in your projects
- Search through your codebase
- List directory contents
- Edit files

## Changing the accessible folder

Edit `~/.local/share/oterm/config.json` and change the path in `args`:

```json
{
  "mcpServers": {
    "filesystem": {
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/martinb/Projekte"]
    }
  }
}
```

You can add multiple folders by adding more paths to the `args` array.
