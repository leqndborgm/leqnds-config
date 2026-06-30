import { createState, onCleanup } from "ags"
import Wp from "gi://AstalWp"

function volumeIcon(vol: number, muted: boolean): string {
  if (muted || vol === 0) return "󰝟"
  if (vol < 0.33) return "󰕿"
  if (vol < 0.66) return "󰖀"
  return "󰕾"
}

export default function Audio() {
  const wp = Wp.get_default()
  const speaker = wp?.audio.default_speaker
  if (!speaker) return <box />

  const [vol, setVol] = createState(speaker.volume)
  const [muted, setMuted] = createState(speaker.mute)

  const volId = speaker.connect("notify::volume", () => setVol(speaker.volume))
  const muteId = speaker.connect("notify::mute", () => setMuted(speaker.mute))
  onCleanup(() => { speaker.disconnect(volId); speaker.disconnect(muteId) })

  return (
    <button
      class={muted.as((m: boolean) => `bar-module audio${m ? " muted" : ""}`)}
      onClicked={() => (speaker.mute = !speaker.mute)}
      tooltipText="Left click: mute"
    >
      <box spacing={5}>
        <label label={muted.as((m: boolean) => volumeIcon(vol(), m))} />
        <label label={vol.as((v: number) => `${Math.round(v * 100)}%`)} />
      </box>
    </button>
  )
}
