import { createBinding } from "ags"
import { Gtk } from "ags/gtk4"
import Notifd from "gi://AstalNotifd"

interface Props {
  notification: Notifd.Notification
}

function urgencyClass(n: Notifd.Notification): string {
  if ((n as any).urgency === Notifd.Urgency.CRITICAL) return "notif-item critical"
  return "notif-item"
}

function relTime(t: number): string {
  if (!t) return "now"
  const diff = Math.floor(Date.now() / 1000) - t
  if (diff < 60) return "now"
  if (diff < 3600) return `${Math.floor(diff / 60)}m ago`
  if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`
  return `${Math.floor(diff / 86400)}d ago`
}

export default function NotifItem({ notification }: Props) {
  const n = notification as any
  const actions: { id: string; label: string }[] = n.actions ?? []
  const appIcon = n.app_icon ?? n["app-icon"] ?? ""
  const desktopEntry = n.desktop_entry ?? n["desktop-entry"] ?? ""

  return (
    <box class={urgencyClass(notification)} spacing={0}>
      {/* Node column — the continuous timeline rail is painted here in CSS */}
      <box class="notif-node" valign={Gtk.Align.FILL}>
        <box class="notif-icon-chip" valign={Gtk.Align.START} halign={Gtk.Align.CENTER}>
          <image
            class="notif-icon"
            iconName={appIcon || desktopEntry || "dialog-information-symbolic"}
            pixelSize={18}
          />
        </box>
      </box>

      {/* Content column */}
      <box class="notif-content" orientation={1} hexpand={true} spacing={2}>
        <box class="notif-top" spacing={6} valign={Gtk.Align.CENTER}>
          <label
            class="notif-app-name"
            xalign={0}
            label={createBinding(notification, "app_name").as((v: string) => v || "Notification")}
          />
          <label class="notif-sep" label="·" />
          <label class="notif-time" label={relTime(n.time ?? 0)} hexpand={true} xalign={0} />
          <button class="notif-close" valign={Gtk.Align.START} onClicked={() => notification.dismiss()}>
            <label label="✕" />
          </button>
        </box>
        <label
          class="notif-summary"
          xalign={0}
          wrap={true}
          label={createBinding(notification, "summary").as((v: string) => v || "")}
        />
        <label
          class="notif-body"
          xalign={0}
          wrap={true}
          maxWidthChars={46}
          visible={createBinding(notification, "body").as((b: string) => !!b && b.length > 0)}
          label={createBinding(notification, "body").as((b: string) => b || "")}
        />
        {actions.length > 0 && (
          <box class="notif-actions" spacing={6}>
            {actions.map(a => (
              <button class="notif-action" onClicked={() => notification.invoke(a.id)} hexpand={true}>
                <label label={a.label ?? ""} halign={Gtk.Align.CENTER} hexpand={true} />
              </button>
            ))}
          </box>
        )}
      </box>
    </box>
  )
}
