import { createBinding, For } from "ags"
import Tray from "gi://AstalTray"
import GLib from "gi://GLib"
import Network from "./Network"
import BluetoothWidget from "./Bluetooth"

const isBluetooth = (item: Tray.TrayItem) => {
  const id = (item.id ?? "").toLowerCase()
  return id.includes("bluetooth") || id.includes("blueman")
}

export default function TrayWidget() {
  const tray = Tray.get_default()

  return (
    <box class="tray" spacing={2}>
      <Network />
      <BluetoothWidget />
      <For each={createBinding(tray, "items").as(items => (items || []).filter(i => !isBluetooth(i)))}>
        {(item: Tray.TrayItem) => (
          <menubutton
            class="tray-item"
            $={(self: any) => {
              // Hold strong JS references so GC can't free menu objects
              // while GTK's PopoverMenu still holds internal C pointers to them.
              // nm-applet updates its DBusMenu mid-interaction which frees
              // GMenuItems that close_submenu() still dereferences → SIGSEGV.
              let snapshotModel: any = null
              let releaseTimer: number | null = null
              let agSignal: number | null = null

              const takeSnapshot = () => {
                snapshotModel = (item as any).menu_model ?? null
                self.set_menu_model(snapshotModel)
              }

              const releaseSnapshot = () => {
                if (releaseTimer !== null) return
                // Delay release so GTK finishes all submenu-close animations
                releaseTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 800, () => {
                  releaseTimer = null
                  snapshotModel = null
                  return GLib.SOURCE_REMOVE
                })
              }

              self.connect("activate", () => {
                if (releaseTimer !== null) {
                  GLib.source_remove(releaseTimer)
                  releaseTimer = null
                }
                // Fire async so menu opens immediately without blocking on D-Bus roundtrip
                GLib.idle_add(GLib.PRIORITY_DEFAULT_IDLE, () => {
                  try { item.about_to_show() } catch { /* not all items support it */ }
                  takeSnapshot()
                  return GLib.SOURCE_REMOVE
                })
              })

              self.connect("notify::active", () => {
                if (!self.active) releaseSnapshot()
              })

              // Initial model
              takeSnapshot()

              const syncAg = () => {
                self.insert_action_group("dbusmenu", (item as any).action_group ?? null)
              }
              syncAg()
              agSignal = item.connect("notify::action-group", syncAg)

              // Disconnect when widget is destroyed
              self.connect("destroy", () => {
                if (agSignal !== null) {
                  item.disconnect(agSignal)
                  agSignal = null
                }
                if (releaseTimer !== null) {
                  GLib.source_remove(releaseTimer)
                  releaseTimer = null
                }
              })
            }}
          >
            <image gicon={createBinding(item, "gicon").as(i => i ?? null)} pixelSize={16} />
          </menubutton>
        )}
      </For>
    </box>
  )
}
