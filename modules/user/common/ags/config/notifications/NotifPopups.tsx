import App from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import { createState, onCleanup, For } from "ags"
import Notifd from "gi://AstalNotifd"
import GLib from "gi://GLib"

const POPUP_TIMEOUT = 7000

interface NotifAction {
  id: string
  label: string
}

interface PopupNotif {
  id: number
  appName: string
  summary: string
  body: string
  urgency: number
  appIcon: string
  desktopEntry: string
  actions: NotifAction[]
}

export default function NotifPopups(monitor: Gdk.Monitor) {
  const notifd = Notifd.get_default()
  const { TOP, RIGHT } = Astal.WindowAnchor

  const [popups, setPopups] = createState<PopupNotif[]>([])
  const timers = new Map<number, number>()

  function removePopup(id: number) {
    const timer = timers.get(id)
    if (timer !== undefined) {
      GLib.source_remove(timer)
      timers.delete(id)
    }
    setPopups(popups().filter(p => p.id !== id))
  }

  function scheduleTimeout(id: number) {
    const timer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, POPUP_TIMEOUT, () => {
      removePopup(id)
      return GLib.SOURCE_REMOVE
    })
    timers.set(id, timer)
  }

  const onNotified = notifd.connect("notified", (_: any, id: number, replaced: boolean) => {
    if (replaced) removePopup(id)
    const n = notifd.get_notification(id)
    if (!n) return
    const na = n as any
    const popup: PopupNotif = {
      id,
      appName: na.app_name ?? na["app-name"] ?? "",
      summary: na.summary ?? "",
      body: na.body ?? "",
      urgency: na.urgency ?? 1,
      appIcon: na.app_icon ?? na["app-icon"] ?? "",
      desktopEntry: na.desktop_entry ?? na["desktop-entry"] ?? "",
      actions: na.actions ?? [],
    }
    setPopups([popup, ...popups()])
    scheduleTimeout(id)
  })

  const onResolved = notifd.connect("resolved", (_: any, id: number) => {
    removePopup(id)
  })

  onCleanup(() => {
    notifd.disconnect(onNotified)
    notifd.disconnect(onResolved)
    for (const timer of timers.values()) GLib.source_remove(timer)
    timers.clear()
  })

  function invokeAction(notifId: number, actionId: string) {
    notifd.get_notification(notifId)?.invoke(actionId)
    removePopup(notifId)
  }

  const monitorName = monitor.connector || monitor.model || App.get_monitors().indexOf(monitor).toString()

  return (
    <window
      name={`notif-popups-${monitorName}`}
      namespace="notif-popups"
      class="notif-popup-window"
      gdkmonitor={monitor}
      anchor={TOP | RIGHT}
      marginTop={50}
      exclusivity={Astal.Exclusivity.IGNORE}
      application={App}
      visible={popups.as((p: PopupNotif[]) => p.length > 0)}
      keymode={Astal.Keymode.NONE}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={8} valign={Gtk.Align.START}>
        <For each={popups}>
          {(p: PopupNotif) => (
            <box
              class={`notif-popup${p.urgency === 2 ? " critical" : ""}`}
              spacing={12}
              valign={Gtk.Align.START}
            >
              <box class="notif-icon-chip" valign={Gtk.Align.START} halign={Gtk.Align.CENTER}>
                <image
                  class="notif-icon"
                  iconName={p.appIcon || p.desktopEntry || "dialog-information-symbolic"}
                  pixelSize={20}
                />
              </box>
              <box class="notif-content" orientation={Gtk.Orientation.VERTICAL} hexpand={true} spacing={2}>
                <box class="notif-top" spacing={6} valign={Gtk.Align.CENTER}>
                  <label class="notif-app-name" label={p.appName} hexpand={true} xalign={0} valign={Gtk.Align.CENTER} />
                  <button class="notif-close" valign={Gtk.Align.START} onClicked={() => removePopup(p.id)}>
                    <label label="✕" />
                  </button>
                </box>
                <label class="notif-summary" label={p.summary} xalign={0} wrap={true} />
                {p.body.length > 0 && (
                  <label
                    class="notif-body"
                    label={p.body}
                    xalign={0}
                    wrap={true}
                    maxWidthChars={42}
                  />
                )}
                {p.actions.length > 0 && (
                  <box class="notif-actions" spacing={6}>
                    {p.actions.map((a: NotifAction) => (
                      <button
                        class="notif-action"
                        onClicked={() => invokeAction(p.id, a.id)}
                        hexpand={true}
                      >
                        <label label={a.label ?? ""} halign={Gtk.Align.CENTER} hexpand={true} />
                      </button>
                    ))}
                  </box>
                )}
              </box>
            </box>
          )}
        </For>
      </box>
    </window>
  )
}
