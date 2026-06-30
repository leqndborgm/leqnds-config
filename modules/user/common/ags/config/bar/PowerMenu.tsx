import App from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"

const ACTIONS = [
  { icon: "󰌾", label: "Sperren",     cmd: "loginctl lock-session",  cls: ""       },
  { icon: "󰒲", label: "Ruhe",        cmd: "systemctl suspend",      cls: ""       },
  { icon: "󰍃", label: "Abmelden",   cmd: "hyprctl dispatch exit",  cls: ""       },
  { icon: "󰑓", label: "Neustart",   cmd: "systemctl reboot",       cls: "warn"   },
  { icon: "󰐥", label: "Ausschalten",cmd: "systemctl poweroff",     cls: "danger" },
] as const

export function PowerButton() {
  return (
    <button
      class="tray-item power"
      tooltipText="System"
      onClicked={() => App.toggle_window("power-menu")}
    >
      <label label="󰐥" />
    </button>
  )
}

export default function PowerMenu() {
  const { TOP, RIGHT } = Astal.WindowAnchor

  let rev: any = null
  let closeTimer: ReturnType<typeof setTimeout> | null = null

  function close() {
    if (rev) rev.reveal_child = false
    setTimeout(() => App.toggle_window("power-menu"), 220)
  }

  const cancelClose = () => { if (closeTimer !== null) { clearTimeout(closeTimer); closeTimer = null } }
  const scheduleClose = () => {
    cancelClose()
    closeTimer = setTimeout(() => { closeTimer = null; close() }, 400)
  }
  const attachHover = (self: any) => {
    const motion = new Gtk.EventControllerMotion()
    motion.connect("enter", cancelClose)
    motion.connect("leave", scheduleClose)
    self.add_controller(motion)
  }

  return (
    <window
      name="power-menu"
      class="power-menu-window"
      anchor={TOP | RIGHT}
      exclusivity={Astal.Exclusivity.NORMAL}
      application={App}
      visible={false}
      keymode={Astal.Keymode.ON_DEMAND}
      $={(self: any) => {
        self.connect("notify::visible", () => {
          if (self.visible && rev) rev.reveal_child = true
        })
        self.connect("notify::is-active", () => {
          if (self.is_active) cancelClose()
          else if (self.visible) scheduleClose()
        })
      }}
    >
      <revealer
        revealChild={false}
        transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
        transitionDuration={200}
        $={(self: any) => { rev = self }}
      >
        <box class="power-panel" orientation={1} spacing={10} $={attachHover}>

          {/* Header */}
          <box class="power-panel-header" spacing={6}>
            <label class="power-panel-icon" label="󰐥" />
            <label class="power-panel-title" label="System" hexpand={true} xalign={0} />
            <button class="power-close-btn" onClicked={close}>
              <label label="✕" />
            </button>
          </box>

          {/* Icon grid — all 5 in one row */}
          <box class="power-grid" spacing={6} homogeneous={true}>
            {ACTIONS.map(({ icon, label, cmd, cls }) => (
              <button
                class={`power-grid-btn${cls ? ` ${cls}` : ""}`}
                tooltipText={label}
                onClicked={() => {
                  if (rev) rev.reveal_child = false
                  setTimeout(() => {
                    App.toggle_window("power-menu")
                    execAsync(cmd).catch(console.error)
                  }, 200)
                }}
              >
                <box orientation={1 /* VERTICAL */} spacing={5} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
                  <label class="power-grid-icon" label={icon} halign={Gtk.Align.CENTER} />
                  <label class="power-grid-label" label={label} halign={Gtk.Align.CENTER} />
                </box>
              </button>
            ))}
          </box>

        </box>
      </revealer>
    </window>
  )
}
