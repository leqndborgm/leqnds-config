import App from "ags/gtk4/app"
import { createState, onCleanup } from "ags"
import Bluetooth from "gi://AstalBluetooth"

function getState(bt: Bluetooth.Bluetooth) {
  if (!bt.is_powered) return { icon: "󰂲", tooltip: "Bluetooth aus" }
  const connected = (bt.devices ?? []).filter(d => d.connected)
  if (connected.length > 0)
    return { icon: "󰂱", tooltip: connected.map(d => d.name ?? d.address).join(", ") }
  return { icon: "󰂯", tooltip: "Bluetooth an" }
}

export default function BluetoothWidget() {
  const bt = Bluetooth.get_default()
  const initial = getState(bt)
  const [icon, setIcon] = createState(initial.icon)
  const [tooltip, setTooltip] = createState(initial.tooltip)

  const update = () => {
    const s = getState(bt)
    setIcon(s.icon)
    setTooltip(s.tooltip)
  }

  const ids: number[] = []
  ids.push(bt.connect("notify::is-powered", update))
  ids.push(bt.connect("notify::devices", update))
  onCleanup(() => ids.forEach(id => bt.disconnect(id)))

  return (
    <button
      class="tray-item bluetooth"
      tooltipText={tooltip}
      onClicked={() => App.toggle_window("bluetooth-popup")}
    >
      <label label={icon} />
    </button>
  )
}
