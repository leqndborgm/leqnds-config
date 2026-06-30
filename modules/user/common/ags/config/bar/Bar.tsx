import App from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import Workspaces from "./Workspaces"
import Clock from "./Clock"
import WindowTitle from "./WindowTitle"
import Audio from "./Audio"
import Battery from "./Battery"
import BlueLight from "./BlueLight"
import Tray from "./Tray"
import NotifButton from "./NotifButton"
import { PowerButton } from "./PowerMenu"

function Left() {
  return (
    <box class="bar-left" spacing={4} hexpand={true} halign={Gtk.Align.START}>
      <button
        class="bar-launcher"
        onClicked={() => App.toggle_window("launcher")}
      >
        <label label="󱓞" />
      </button>
      <Workspaces />
      <WindowTitle />
    </box>
  )
}

function Center() {
  return (
    <box class="bar-center">
      <Clock />
    </box>
  )
}

function Right() {
  return (
    <box class="bar-right" spacing={2} hexpand={true} halign={Gtk.Align.END}>
      <Audio />
      <Battery />
      <BlueLight />
      <Tray />
      <NotifButton />
      <PowerButton />
    </box>
  )
}

export default function Bar(monitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor
  const monitorName = monitor.connector || monitor.model || App.get_monitors().indexOf(monitor).toString()

  return (
    <window
      name={`bar-${monitorName}`}
      class="bar-window"
      gdkmonitor={monitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={App}
      visible={true}
    >
      <centerbox
        class="bar"
        startWidget={<Left />}
        centerWidget={<Center />}
        endWidget={<Right />}
      />
    </window>
  )
}
