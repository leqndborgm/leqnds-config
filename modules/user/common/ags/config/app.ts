import App from "ags/gtk4/app"
import { Gdk, Gtk } from "ags/gtk4"
import GLib from "gi://GLib"
import Bar from "./bar/Bar"
import NotificationCenter from "./notifications/NotificationCenter"
import NotifPopups from "./notifications/NotifPopups"
import NetworkPopup from "./bar/NetworkPopup"
import BluetoothPopup from "./bar/BluetoothPopup"
import PowerMenu from "./bar/PowerMenu"
import CalendarPopup from "./bar/CalendarPopup"
import Launcher from "./launcher/Launcher"
import OSD from "./osd/OSD"

const SRC = GLib.get_user_config_dir() + "/ags"

// Track which Gtk.Window instances belong to which Gdk.Monitor so we can
// surgically destroy only the windows for a disconnected monitor and only
// create windows for a newly connected one — instead of nuking and rebuilding
// all bars on every monitor event.
const monitorWindows = new Map<Gdk.Monitor, Gtk.Window[]>()

function setupMonitor(m: Gdk.Monitor) {
  const wins = [Bar(m), OSD(m), NotifPopups(m)] as unknown as Gtk.Window[]
  monitorWindows.set(m, wins)
}

function teardownMonitor(m: Gdk.Monitor) {
  const wins = monitorWindows.get(m)
  if (!wins) return
  for (const w of wins) {
    try { w.destroy() } catch { /* already gone */ }
  }
  monitorWindows.delete(m)
}

function syncMonitors() {
  const current = new Set(App.get_monitors())

  // Drop windows for monitors that vanished.
  for (const m of [...monitorWindows.keys()]) {
    if (!current.has(m)) teardownMonitor(m)
  }

  // Create windows for monitors that appeared.
  for (const m of current) {
    if (!monitorWindows.has(m)) setupMonitor(m)
  }
}

App.start({
  instanceName: "shell",
  css: `${SRC}/style.css`,
  main() {
    NotificationCenter()
    NetworkPopup()
    BluetoothPopup()
    PowerMenu()
    CalendarPopup()
    Launcher()

    syncMonitors()

    // AGS's gtk4 App emits `notify::monitors` whenever the underlying
    // Gdk.Display monitor list changes (see ags/lib/gtk4/app.ts). There are
    // no `monitor-added`/`monitor-removed` signals — connecting to those is a
    // silent no-op.
    //
    // Debounce because the signal can fire several times in a burst during a
    // hot-plug (e.g. one remove + one add on a mode change), and GDK needs a
    // moment to fully populate `connector` on freshly added monitors.
    let rebuildTimer: number | null = null
    App.connect("notify::monitors", () => {
      if (rebuildTimer !== null) GLib.source_remove(rebuildTimer)
      rebuildTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 500, () => {
        rebuildTimer = null
        syncMonitors()
        return GLib.SOURCE_REMOVE
      })
    })
  },
})
