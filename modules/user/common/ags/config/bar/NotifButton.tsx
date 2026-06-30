import App from "ags/gtk4/app"
import { createBinding } from "ags"
import Notifd from "gi://AstalNotifd"

export default function NotifButton() {
  const notifd = Notifd.get_default()
  const notifs = createBinding(notifd, "notifications")

  return (
    <button
      class={notifs.as(n =>
        `bar-module notif-btn${n.length > 0 ? " has-notifs" : ""}`
      )}
      onClicked={() => App.toggle_window("notification-center")}
      tooltipText="Notifications"
    >
      <box spacing={5}>
        <label label="󰂚" />
        <label
          visible={notifs.as(n => n.length > 0)}
          label={notifs.as(n => n.length.toString())}
        />
      </box>
    </button>
  )
}
