import GLib from "gi://GLib"
import Gio from "gi://Gio"
import { createState, onCleanup } from "ags"
import { execAsync } from "ags/process"

// Marker file written/removed by the `toggle-bluelight` script. We treat its
// existence as the single source of truth for the filter state, so this widget
// and the SUPER+B keybind never disagree.
const STATE_PATH = (GLib.getenv("XDG_RUNTIME_DIR") || "/tmp") + "/bluelight.state"

// Swap these glyphs if you prefer a different look (Nerd Font Material icons).
const ICON_ON = "󰖔" // weather-night
const ICON_OFF = "󰖙" // white-balance-sunny

function isActive(): boolean {
  return GLib.file_test(STATE_PATH, GLib.FileTest.EXISTS)
}

export default function BlueLightWidget() {
  const [active, setActive] = createState(isActive())

  // Watch the marker file so the icon stays in sync regardless of whether the
  // filter was toggled from this button or via the keybind.
  const monitor = Gio.File.new_for_path(STATE_PATH)
    .monitor(Gio.FileMonitorFlags.NONE, null)
  const handler = monitor.connect("changed", () => setActive(isActive()))
  onCleanup(() => {
    monitor.disconnect(handler)
    monitor.cancel()
  })

  return (
    <button
      class={active.as((a: boolean) => a ? "tray-item bluelight active" : "tray-item bluelight")}
      tooltipText={active.as((a: boolean) => a ? "Blaulichtfilter an" : "Blaulichtfilter aus")}
      onClicked={() => execAsync(["toggle-bluelight"]).catch(console.error)}
    >
      <label label={active.as((a: boolean) => a ? ICON_ON : ICON_OFF)} />
    </button>
  )
}
