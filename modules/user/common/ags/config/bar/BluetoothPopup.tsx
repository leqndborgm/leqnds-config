import App from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { createBinding, For } from "ags"
import { execAsync } from "ags/process"
import Bluetooth from "gi://AstalBluetooth"

function deviceIcon(iconName: string): string {
  const n = (iconName ?? "").toLowerCase()
  if (n.includes("headset") || n.includes("headphone")) return "󰋋"
  if (n.includes("keyboard")) return "󰌌"
  if (n.includes("mouse")) return "󰍽"
  if (n.includes("phone")) return "󰄜"
  if (n.includes("game") || n.includes("joystick")) return "󰖺"
  if (n.includes("speaker") || n.includes("audio")) return "󰓃"
  return "󰂯"
}

function DeviceRow(props: { device: Bluetooth.Device }) {
  const { device } = props
  const connected = createBinding(device, "connected")

  const toggle = () => {
    // astal bumped these to async GIO-style methods: the callback arg is now
    // mandatory (nullable), so calling with 0 args throws. Pass null = fire-and-forget.
    if (device.connected) {
      device.disconnect_device(null)
    } else {
      device.connect_device(null)
    }
  }

  return (
    <button
      class={connected.as(c => `bt-device${c ? " active" : ""}`)}
      onClicked={toggle}
    >
      <box spacing={8}>
        <label class="bt-device-icon" label={deviceIcon(device.icon_name ?? "")} />
        <label
          class="bt-device-name"
          label={device.name ?? device.address}
          hexpand={true}
          xalign={0}
        />
        {(device.battery_percentage ?? -1) > 0 ? (
          <label class="bt-device-battery" label={`󰁹 ${device.battery_percentage}%`} />
        ) : (
          <box />
        )}
        <label class="bt-device-check" label="󰄬" visible={connected} />
      </box>
    </button>
  )
}

export default function BluetoothPopup() {
  const bt = Bluetooth.get_default()
  const { TOP, RIGHT } = Astal.WindowAnchor

  const pairedDevices = createBinding(bt, "devices").as(
    (devs: Bluetooth.Device[]) => (devs ?? []).filter(d => d.paired)
  )
  const enabled = createBinding(bt, "is_powered")

  let rev: any = null
  let closeTimer: ReturnType<typeof setTimeout> | null = null

  const cancelClose = () => { if (closeTimer !== null) { clearTimeout(closeTimer); closeTimer = null } }
  const scheduleClose = () => {
    cancelClose()
    closeTimer = setTimeout(() => {
      closeTimer = null
      if (rev) rev.reveal_child = false
      setTimeout(() => App.toggle_window("bluetooth-popup"), 220)
    }, 400)
  }
  const attachHover = (self: any) => {
    const motion = new Gtk.EventControllerMotion()
    motion.connect("enter", cancelClose)
    motion.connect("leave", scheduleClose)
    self.add_controller(motion)
  }

  return (
    <window
      name="bluetooth-popup"
      class="bluetooth-popup"
      anchor={TOP | RIGHT}
      exclusivity={Astal.Exclusivity.NORMAL}
      application={App}
      visible={false}
      keymode={Astal.Keymode.ON_DEMAND}
      $={(self: any) => {
        self.connect("notify::visible", () => {
          if (self.visible && rev) rev.reveal_child = true
        })
        self.connect("notify::is-active", () => {
          if (self.is_active) cancelClose()
          else if (self.visible) scheduleClose()
        })
      }}
    >
      <revealer
        revealChild={false}
        transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
        transitionDuration={200}
        $={(self: any) => { rev = self }}
      >
      <box class="bt-panel" orientation={1} spacing={10} $={attachHover}>
        <box class="bt-header" spacing={8}>
          <label class="bt-header-title" label="Bluetooth" hexpand={true} xalign={0} />
          <switch
            class="bt-switch"
            active={enabled}
            onNotifyActive={(self: any) => {
              // `is-powered` is now a read-only aggregate in astal (writing it throws).
              // toggle() flips the adapter power; the guard keeps the switch idempotent.
              if (bt.is_powered !== self.active) bt.toggle()
            }}
          />
          <button
            class="bt-close-btn"
            onClicked={() => App.toggle_window("bluetooth-popup")}
          >
            <label label="✕" />
          </button>
        </box>

        <box orientation={1} spacing={2}>
          <label
            class="bt-empty"
            label={enabled.as(e => e ? "Keine gekoppelten Geräte" : "Bluetooth ist aus")}
            visible={pairedDevices.as(d => d.length === 0)}
            halign={Gtk.Align.CENTER}
          />
          <For each={pairedDevices}>
            {(device: Bluetooth.Device) => <DeviceRow device={device} />}
          </For>
        </box>

        <button
          class="bt-advanced-btn"
          onClicked={() => {
            execAsync("blueman-manager").catch(console.error)
            App.toggle_window("bluetooth-popup")
          }}
        >
          <label label="Erweiterte Einstellungen" />
        </button>
      </box>
      </revealer>
    </window>
  )
}
