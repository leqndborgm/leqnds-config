import App from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import { createState, For } from "ags"
import { execAsync } from "ags/process"
import Apps from "gi://AstalApps"

// Single shared query manager. Multipliers bias the fuzzy score so a match in
// the app *name* outranks one buried in the description/keywords — feels closer
// to "type the app you mean" than a raw substring search.
const apps = new Apps.Apps({
  nameMultiplier: 2,
  entryMultiplier: 0,
  executableMultiplier: 0.5,
  descriptionMultiplier: 0.5,
  keywordsMultiplier: 0.5,
})

const MAX_RESULTS = 12
// How many rows are visible at once before the list scrolls. Kept below
// MAX_RESULTS so the panel stays compact and fits under the bar on a 1080p
// laptop screen instead of running off the bottom edge.
const VISIBLE_ROWS = 8
// Uniform row height (button padding + content) used for keyboard auto-scroll.
// Keep in sync with `.launcher-item` padding in style.css.
const ROW_H = 56

// Web-search providers — mirrors the old `web-search` rofi script. The query is
// appended (URL-encoded) to the chosen provider's base URL.
const WEB_PROVIDERS = [
  { glyph: "󰖟", label: "Brave Suche",       url: "https://search.brave.com/search?q=" },
  { glyph: "󱄅", label: "NixOS Pakete",      url: "https://search.nixos.org/packages?channel=unstable&type=packages&query=" },
  { glyph: "󰗃", label: "YouTube",           url: "https://www.youtube.com/results?search_query=" },
  { glyph: "󰣇", label: "Arch Wiki",         url: "https://wiki.archlinux.org/index.php?search=" },
] as const

// Terminal used for the shell-command mode. Both hosts set terminal = "kitty".
const TERMINAL = "kitty"

type Mode = "apps" | "calc" | "shell" | "web"

const MODE_META: Record<Mode, { glyph: string; placeholder: string }> = {
  apps:  { glyph: "󰍉", placeholder: "Anwendung suchen …" },
  calc:  { glyph: "󰪚", placeholder: "Rechnen, z. B. 12 * (3 + 4)" },
  shell: { glyph: "", placeholder: "Shell-Befehl ausführen …" },
  web:   { glyph: "󰖟", placeholder: "Im Web suchen …" },
}

// A uniform, render-agnostic result. The list doesn't care which mode produced
// it — it draws an icon (themed image or a nerd-font glyph), a title, an
// optional subtitle, and fires `action()` on click/Enter. `inert` rows are
// hints (e.g. "type an expression") that can't be activated.
type Result = {
  icon: { kind: "image"; name: string } | { kind: "glyph"; text: string; tone?: string }
  title: string
  subtitle?: string
  action: () => void
  inert?: boolean
}

function detectMode(text: string): { mode: Mode; rest: string } {
  if (text.startsWith("=")) return { mode: "calc", rest: text.slice(1).trim() }
  if (text.startsWith(">")) return { mode: "shell", rest: text.slice(1).trim() }
  if (text.startsWith("?")) return { mode: "web", rest: text.slice(1).trim() }
  return { mode: "apps", rest: text }
}

function close() {
  App.toggle_window("launcher")
}

export default function Launcher() {
  // Plain mirrors for synchronous reads inside the key handler; the `createState`
  // pair drives the reactive UI (list contents + which row is highlighted).
  let resultsArr: Result[] = []
  let selIdx = 0
  let querySeq = 0
  let calcTimer: ReturnType<typeof setTimeout> | null = null

  const [rows, setRows] = createState<{ r: Result; idx: number }[]>([])
  const [selected, setSelected] = createState(0)
  const [mode, setMode] = createState<Mode>("apps")

  let entry: Gtk.Entry | null = null
  let scroller: Gtk.ScrolledWindow | null = null

  function setSel(i: number) {
    selIdx = i
    setSelected(i)
    ensureVisible(i)
  }

  function ensureVisible(n: number) {
    if (!scroller) return
    const adj = scroller.get_vadjustment()
    if (!adj) return
    const top = n * ROW_H
    const bottom = top + ROW_H
    const viewTop = adj.get_value()
    const viewH = adj.get_page_size()
    if (top < viewTop) adj.set_value(top)
    else if (bottom > viewTop + viewH) adj.set_value(bottom - viewH)
  }

  function commit(results: Result[]) {
    resultsArr = results
    setRows(results.map((r, idx) => ({ r, idx })))
    setSel(0)
  }

  // ── App mode ───────────────────────────────────────────────────────────
  function appResults(query: string): Result[] {
    const found = query === ""
      // Empty query → full list, most-used first (frequency is bumped by launch()).
      ? apps.get_list().slice().sort((a, b) => b.frequency - a.frequency)
      : apps.fuzzy_query(query)
    return found.slice(0, MAX_RESULTS).map(app => ({
      icon: { kind: "image", name: app.iconName || "application-x-executable" },
      title: app.name,
      subtitle: app.description || undefined,
      action: () => { app.launch(); close() },
    }))
  }

  // ── Calculator mode (qalc, debounced + stale-guarded) ──────────────────
  function evalCalc(expr: string, seq: number) {
    execAsync(["qalc", "-t", expr])
      .then(out => {
        if (seq !== querySeq) return
        const value = out.trim()
        commit([{
          icon: { kind: "glyph", text: "󰪚", tone: "accent" },
          title: value,
          subtitle: `${expr}  —  ↵ kopiert das Ergebnis`,
          action: () => { execAsync(["wl-copy", value]).catch(console.error); close() },
        }])
      })
      .catch(() => {
        if (seq !== querySeq) return
        commit([{
          icon: { kind: "glyph", text: "󰜺", tone: "urgent" },
          title: "Kein Ergebnis",
          subtitle: expr,
          action: () => {},
          inert: true,
        }])
      })
  }

  // ── Shell mode ─────────────────────────────────────────────────────────
  function shellResults(cmd: string): Result[] {
    if (cmd === "") {
      return [{
        icon: { kind: "glyph", text: "", tone: "accent" },
        title: "Shell-Befehl eingeben …",
        subtitle: "Wird im Terminal ausgeführt",
        action: () => {},
        inert: true,
      }]
    }
    return [{
      icon: { kind: "glyph", text: "", tone: "accent" },
      title: cmd,
      subtitle: `Im Terminal ausführen  —  ↵`,
      action: () => {
        execAsync([TERMINAL, "-e", "bash", "-c", `${cmd}; exec bash`]).catch(console.error)
        close()
      },
    }]
  }

  // ── Web mode ───────────────────────────────────────────────────────────
  function webResults(query: string): Result[] {
    const hint = query === "" ? "Suchbegriff eingeben …" : `Suche: ${query}`
    return WEB_PROVIDERS.map(p => ({
      icon: { kind: "glyph", text: p.glyph, tone: "accent" } as const,
      title: p.label,
      subtitle: hint,
      action: () => {
        if (query === "") return
        execAsync(["xdg-open", p.url + encodeURIComponent(query)]).catch(console.error)
        close()
      },
      inert: query === "",
    }))
  }

  function runQuery(text: string) {
    const seq = ++querySeq
    if (calcTimer) { clearTimeout(calcTimer); calcTimer = null }

    const { mode: m, rest } = detectMode(text)
    setMode(m)

    switch (m) {
      case "calc":
        if (rest === "") {
          commit([{
            icon: { kind: "glyph", text: "󰪚", tone: "accent" },
            title: "Ausdruck eingeben …",
            subtitle: "z. B. = 1920 / 16 * 9",
            action: () => {},
            inert: true,
          }])
        } else {
          // Keep the previous value on screen and recompute after a short pause,
          // so we don't spawn a qalc process on every keystroke.
          calcTimer = setTimeout(() => { calcTimer = null; evalCalc(rest, seq) }, 120)
        }
        break
      case "shell":
        commit(shellResults(rest))
        break
      case "web":
        commit(webResults(rest))
        break
      default:
        commit(appResults(text))
    }
  }

  function activate(r: Result) {
    if (r.inert) return
    r.action()
  }

  function activateSelected() {
    const r = resultsArr[selIdx]
    if (r) activate(r)
  }

  function moveSel(delta: number) {
    const len = resultsArr.length
    if (len === 0) return
    let n = selIdx + delta
    if (n < 0) n = len - 1
    if (n >= len) n = 0
    setSel(n)
  }

  function onShow() {
    if (entry) {
      entry.set_text("")
      entry.grab_focus()
    }
    runQuery("")
    if (scroller) {
      const adj = scroller.get_vadjustment()
      if (adj) adj.set_value(0)
    }
  }

  return (
    <window
      name="launcher"
      namespace="launcher"
      class="launcher-window"
      anchor={Astal.WindowAnchor.TOP}
      // NORMAL so the launcher drops in *below* the bar rather than overlapping
      // it (IGNORE rendered it from the very top of the screen, over the bar).
      exclusivity={Astal.Exclusivity.NORMAL}
      keymode={Astal.Keymode.EXCLUSIVE}
      application={App}
      visible={false}
      $={(self: Astal.Window) => {
        self.connect("notify::visible", () => {
          if (self.visible) onShow()
        })

        // Capture-phase key controller: sees keystrokes before the entry, so
        // arrows/Enter/Escape drive the list while everything else still types
        // into the search box.
        const keys = new Gtk.EventControllerKey()
        keys.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
        keys.connect("key-pressed", (_c, keyval: number) => {
          switch (keyval) {
            case Gdk.KEY_Down:
            case Gdk.KEY_Tab:
              moveSel(1)
              return true
            case Gdk.KEY_Up:
            case Gdk.KEY_ISO_Left_Tab:
              moveSel(-1)
              return true
            case Gdk.KEY_Return:
            case Gdk.KEY_KP_Enter:
              activateSelected()
              return true
            case Gdk.KEY_Escape:
              close()
              return true
            default:
              return false
          }
        })
        self.add_controller(keys)
      }}
    >
      <box class="launcher-panel" orientation={1} valign={Gtk.Align.START}>

        {/* Search row — mode glyph + entry. The glyph (and its tint) switch
            with the active mode so the input itself signals which mode is on. */}
        <box class={mode.as(m => `launcher-search mode-${m}`)} spacing={10}>
          <label class="launcher-search-icon" label={mode.as(m => MODE_META[m].glyph)} />
          <entry
            class="launcher-entry"
            hexpand={true}
            placeholderText={mode.as(m => MODE_META[m].placeholder)}
            $={(self: Gtk.Entry) => {
              entry = self
              self.connect("notify::text", () => runQuery(self.text))
            }}
            onActivate={activateSelected}
          />
        </box>

        {/* Results */}
        <scrolledwindow
          class="launcher-scroll"
          vexpand={true}
          hscrollbarPolicy={Gtk.PolicyType.NEVER}
          minContentHeight={VISIBLE_ROWS * ROW_H}
          $={(self: Gtk.ScrolledWindow) => { scroller = self }}
        >
          <box orientation={1} spacing={2}>
            <label
              class="launcher-empty"
              label="Keine Treffer"
              visible={rows.as(r => r.length === 0)}
              halign={Gtk.Align.CENTER}
            />
            <For each={rows}>
              {(row: { r: Result; idx: number }) => (
                <button
                  class={selected.as(s => {
                    const base = row.r.inert ? "launcher-item inert" : "launcher-item"
                    return s === row.idx ? `${base} selected` : base
                  })}
                  onClicked={() => activate(row.r)}
                >
                  <box spacing={12}>
                    {row.r.icon.kind === "image" ? (
                      <image
                        class="launcher-item-icon"
                        iconName={row.r.icon.name}
                        pixelSize={32}
                      />
                    ) : (
                      <label
                        class={`launcher-item-glyph${row.r.icon.tone ? ` ${row.r.icon.tone}` : ""}`}
                        label={row.r.icon.text}
                      />
                    )}
                    <box orientation={1} valign={Gtk.Align.CENTER} hexpand={true}>
                      <label
                        class="launcher-item-name"
                        label={row.r.title}
                        xalign={0}
                        maxWidthChars={44}
                        ellipsize={3 /* PANGO_ELLIPSIZE_END */}
                      />
                      {row.r.subtitle ? (
                        <label
                          class="launcher-item-desc"
                          label={row.r.subtitle}
                          xalign={0}
                          maxWidthChars={52}
                          ellipsize={3}
                        />
                      ) : <box />}
                    </box>
                  </box>
                </button>
              )}
            </For>
          </box>
        </scrolledwindow>

        {/* Footer — keyboard + mode legend, doubles as a discoverability hint */}
        <box class="launcher-footer" spacing={12}>
          <label class="launcher-hint" label="↵ Öffnen" />
          <label class="launcher-hint" label="↑↓ Navigieren" />
          <box hexpand={true} />
          <label class="launcher-hint dim" label="= Rechner" />
          <label class="launcher-hint dim" label="> Shell" />
          <label class="launcher-hint dim" label="? Web" />
        </box>

      </box>
    </window>
  )
}
