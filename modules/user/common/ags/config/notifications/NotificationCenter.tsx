import App from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { createState, onCleanup, For } from "ags"
import Notifd from "gi://AstalNotifd"
import NotifItem from "./NotifItem"

export default function NotificationCenter() {
  const notifd = Notifd.get_default()
  const { RIGHT, TOP, BOTTOM } = Astal.WindowAnchor

  const [notifications, setNotifications] = createState<Notifd.Notification[]>(
    [...notifd.get_notifications()].reverse()
  )

  function sync() {
    setNotifications([...notifd.get_notifications()].reverse())
  }

  const onNotified = notifd.connect("notified", sync)
  const onResolved = notifd.connect("resolved", sync)

  onCleanup(() => {
    notifd.disconnect(onNotified)
    notifd.disconnect(onResolved)
  })

  function clearAll() {
    notifd.get_notifications().forEach((n: Notifd.Notification) => n.dismiss())
  }

  return (
    <window
      name="notification-center"
      namespace="notification-center"
      class="notification-center"
      anchor={RIGHT | TOP | BOTTOM}
      // NORMAL (not IGNORE) so the panel respects the bar's exclusive zone and
      // starts *below* the bar instead of rendering underneath it. The Hyprland
      // blur layerrule matches by namespace, so frosted glass still applies.
      exclusivity={Astal.Exclusivity.NORMAL}
      application={App}
      visible={false}
      keymode={Astal.Keymode.ON_DEMAND}
    >
      <box class="notif-panel" orientation={1} spacing={10}>
        <box class="notif-header" spacing={8} valign={Gtk.Align.CENTER}>
          <box hexpand={true} spacing={8} valign={Gtk.Align.CENTER}>
            <label class="notif-header-title" label="NOTIFICATIONS" xalign={0} />
            <label
              class="notif-count"
              xalign={0}
              visible={notifications.as((n: Notifd.Notification[]) => n.length > 0)}
              label={notifications.as((n: Notifd.Notification[]) => `[ ${n.length} ]`)}
            />
          </box>
          <button class="notif-clear-btn" onClicked={clearAll} valign={Gtk.Align.CENTER}>
            <label label="Clear all" />
          </button>
          <button
            class="notif-close-panel-btn"
            onClicked={() => App.toggle_window("notification-center")}
            valign={Gtk.Align.CENTER}
          >
            <label label="✕" />
          </button>
        </box>

        <scrolledwindow vexpand={true} hscrollbarPolicy={Gtk.PolicyType.NEVER}>
          <box class="notif-timeline" orientation={1} spacing={0}>
            <box
              class="notif-empty"
              orientation={1}
              spacing={8}
              valign={Gtk.Align.CENTER}
              halign={Gtk.Align.CENTER}
              vexpand={true}
              visible={notifications.as((n: Notifd.Notification[]) => n.length === 0)}
            >
              <label class="notif-empty-icon" label="󰂜" halign={Gtk.Align.CENTER} />
              <label class="notif-empty-text" label="— ALL CLEAR —" halign={Gtk.Align.CENTER} />
            </box>
            <For each={notifications}>
              {(n: Notifd.Notification) => <NotifItem notification={n} />}
            </For>
          </box>
        </scrolledwindow>
      </box>
    </window>
  )
}
