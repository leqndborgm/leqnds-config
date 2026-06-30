import GLib from "gi://GLib"
import { createState, onCleanup } from "ags"

const BAT = "/sys/class/power_supply/BAT0"

function readSysfs(path: string): string {
  try {
    const [, contents] = GLib.file_get_contents(path)
    return new TextDecoder().decode(contents).trim()
  } catch {
    return ""
  }
}

function getBatteryPct(): number {
  const val = parseInt(readSysfs(`${BAT}/capacity`))
  return isNaN(val) ? 0 : val
}

function isCharging(): boolean {
  return readSysfs(`${BAT}/status`) === "Charging"
}

function batteryIcon(pct: number, charging: boolean): string {
  if (charging) return "󰂄"
  if (pct < 10) return "󰂎"
  if (pct < 20) return "󰁺"
  if (pct < 30) return "󰁻"
  if (pct < 40) return "󰁼"
  if (pct < 50) return "󰁽"
  if (pct < 60) return "󰁾"
  if (pct < 70) return "󰁿"
  if (pct < 80) return "󰂀"
  if (pct < 90) return "󰂁"
  return "󰂂"
}

export default function BatteryWidget() {
  if (!GLib.file_test(`${BAT}/capacity`, GLib.FileTest.EXISTS)) return <box />

  const [pct, setPct] = createState(getBatteryPct())
  const [charging, setCharging] = createState(isCharging())

  const id = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5000, () => {
    setPct(getBatteryPct())
    setCharging(isCharging())
    return GLib.SOURCE_CONTINUE
  })
  onCleanup(() => GLib.source_remove(id))

  return (
    <box
      class={charging.as((c: boolean) => c ? "bar-module battery charging" : "bar-module battery")}
      spacing={5}
    >
      <label label={pct.as((p: number) => batteryIcon(p, charging()))} />
      <label label={pct.as((p: number) => `${p}%`)} />
    </box>
  )
}
