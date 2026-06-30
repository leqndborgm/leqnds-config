import App from "ags/gtk4/app"
import { createState, onCleanup } from "ags"
import Network from "gi://AstalNetwork"

function wifiIcon(strength: number): string {
  if (strength < 25) return "󰤯"
  if (strength < 50) return "󰤟"
  if (strength < 75) return "󰤢"
  return "󰤨"
}

function getIcon(net: Network.Network): string {
  if (net.primary === Network.Primary.WIRED) return "󰈁"
  if (net.primary === Network.Primary.WIFI) {
    if (net.wifi && !net.wifi.enabled) return "󰤭"
    return wifiIcon(net.wifi?.strength ?? 0)
  }
  return "󰤭"
}

function getTooltip(net: Network.Network): string {
  if (net.primary === Network.Primary.WIFI) return net.wifi?.ssid ?? "WiFi"
  if (net.primary === Network.Primary.WIRED) return "Ethernet"
  return "Nicht verbunden"
}

export default function NetworkWidget() {
  const net = Network.get_default()

  const [icon, setIcon] = createState(getIcon(net))
  const [tooltip, setTooltip] = createState(getTooltip(net))

  const update = () => {
    setIcon(getIcon(net))
    setTooltip(getTooltip(net))
  }

  let wifiStrengthId = 0
  let wifiSsidId = 0
  let wifiEnabledId = 0
  let currentWifi: Network.Wifi | null = null

  const connectWifi = (wifi: Network.Wifi | null) => {
    if (currentWifi) {
      if (wifiStrengthId) currentWifi.disconnect(wifiStrengthId)
      if (wifiSsidId) currentWifi.disconnect(wifiSsidId)
      if (wifiEnabledId) currentWifi.disconnect(wifiEnabledId)
      wifiStrengthId = 0
      wifiSsidId = 0
      wifiEnabledId = 0
    }
    currentWifi = wifi
    if (wifi) {
      wifiStrengthId = wifi.connect("notify::strength", update)
      wifiSsidId = wifi.connect("notify::ssid", update)
      wifiEnabledId = wifi.connect("notify::enabled", update)
    }
    update()
  }

  const netId = net.connect("notify::primary", update)
  const wifiChangedId = net.connect("notify::wifi", () => connectWifi(net.wifi ?? null))
  connectWifi(net.wifi ?? null)

  onCleanup(() => {
    net.disconnect(netId)
    net.disconnect(wifiChangedId)
    if (currentWifi) {
      if (wifiStrengthId) currentWifi.disconnect(wifiStrengthId)
      if (wifiSsidId) currentWifi.disconnect(wifiSsidId)
      if (wifiEnabledId) currentWifi.disconnect(wifiEnabledId)
    }
  })

  return (
    <button
      class="tray-item network"
      tooltipText={tooltip}
      onClicked={() => App.toggle_window("network-popup")}
    >
      <label label={icon} />
    </button>
  )
}
