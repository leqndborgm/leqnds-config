import App from "ags/gtk4/app"
import { Astal, Gdk } from "ags/gtk4"
import { createState } from "ags"
import Wp from "gi://AstalWp"

function volumeIcon(vol: number, muted: boolean): string {
  if (muted || vol === 0) return "󰝟"
  if (vol < 0.33) return "󰕿"
  if (vol < 0.66) return "󰖀"
  return "󰕾"
}

export default function OSD(monitor: Gdk.Monitor) {
  const wp = Wp.get_default()
  const speaker = wp?.audio.default_speaker

  const [visible, setVisible] = createState(false)
  const [value, setValue] = createState(0)
  const [icon, setIcon] = createState("󰕾")

  let hideTimer: ReturnType<typeof setTimeout> | null = null

  function showOSD(vol: number, muted: boolean) {
    setValue(Math.min(vol, 1))
    setIcon(volumeIcon(vol, muted))
    setVisible(true)
    if (hideTimer) clearTimeout(hideTimer)
    hideTimer = setTimeout(() => setVisible(false), 1800)
  }

  if (speaker) {
    speaker.connect("notify::volume", () => showOSD(speaker.volume, speaker.mute))
    speaker.connect("notify::mute", () => showOSD(speaker.volume, speaker.mute))
  }

  const { BOTTOM } = Astal.WindowAnchor
  const monitorName = monitor.connector || monitor.model || App.get_monitors().indexOf(monitor).toString()

  return (
    <window
      name={`osd-${monitorName}`}
      class="osd-window"
      gdkmonitor={monitor}
      anchor={BOTTOM}
      exclusivity={Astal.Exclusivity.IGNORE}
      application={App}
      visible={visible}
    >
      <box class="osd" spacing={12} halign={2 /* CENTER */}>
        <label class="osd-icon" label={icon} />
        <levelbar
          hexpand
          minValue={0}
          maxValue={1}
          value={value}
        />
      </box>
    </window>
  )
}
