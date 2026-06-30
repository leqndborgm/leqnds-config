import App from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { createState, onCleanup, For } from "ags"
import { execAsync } from "ags/process"
import Network from "gi://AstalNetwork"

// NM_802_11_AP_FLAGS_PRIVACY = 0x1 → access point requires a key/password
const AP_PRIVACY = 0x1
const isSecured = (ap: Network.AccessPoint) => ((ap.flags as number) & AP_PRIVACY) !== 0

function apStrengthIcon(strength: number): string {
  if (strength < 25) return "󰤯"
  if (strength < 50) return "󰤟"
  if (strength < 75) return "󰤢"
  return "󰤨"
}

// Dedupe APs by SSID (keep strongest), put the active one first, then sort by strength.
function buildApList(wifi: Network.Wifi): Network.AccessPoint[] {
  const aps = wifi.get_access_points() ?? []
  const activeSsid = wifi.active_access_point?.ssid ?? null
  const byssid = new Map<string, Network.AccessPoint>()
  for (const ap of aps) {
    if (!ap.ssid) continue
    const existing = byssid.get(ap.ssid)
    if (!existing || ap.strength > existing.strength) byssid.set(ap.ssid, ap)
  }
  return [...byssid.values()].sort((a, b) => {
    if (a.ssid === activeSsid) return -1
    if (b.ssid === activeSsid) return 1
    return b.strength - a.strength
  })
}

type VpnConn = { name: string; active: boolean }

function APRow(props: {
  ap: Network.AccessPoint
  wifi: Network.Wifi
  saved: Set<string>
  activeSsid: string | null
}) {
  const { ap, wifi, saved, activeSsid } = props
  const secured = isSecured(ap)
  const active = ap.ssid === activeSsid
  const isSaved = saved.has(ap.ssid)

  const [showPw, setShowPw] = createState(false)
  let entry: Gtk.Entry | null = null

  // AstalNetwork's AccessPoint has no activate() binding, so drive nmcli directly.
  // `nmcli device wifi connect <ssid>` reuses a saved profile if one exists,
  // otherwise creates a new wpa-psk connection with the given password.
  const tryConnect = (password: string | null) => {
    const cmd = ["nmcli", "device", "wifi", "connect", ap.ssid]
    if (password) cmd.push("password", password)
    execAsync(cmd).catch(console.error)
    App.toggle_window("network-popup")
  }

  const onClick = () => {
    if (active) {
      // Disconnect from the currently active network
      execAsync(["nmcli", "connection", "down", "id", ap.ssid]).catch(console.error)
      return
    }
    if (!secured || isSaved) {
      tryConnect(null)
      return
    }
    setShowPw(p => !p)
  }

  return (
    <box class="net-ap-wrapper" orientation={1}>
      <button class={`net-ap${active ? " active" : ""}`} onClicked={onClick}>
        <box spacing={8}>
          <label class="net-ap-icon" label={apStrengthIcon(ap.strength)} />
          <label class="net-ap-ssid" label={ap.ssid} hexpand={true} xalign={0} />
          {secured ? <label class="net-ap-lock" label="󰌾" /> : <box />}
          {isSaved ? <label class="net-ap-saved" label="󰆼" tooltipText="Gespeichert" /> : <box />}
          {active ? <label class="net-ap-check" label="󰄬" /> : <box />}
        </box>
      </button>
      <revealer
        revealChild={showPw}
        transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
        transitionDuration={150}
      >
        <box class="net-pw-row" spacing={6}>
          <entry
            class="net-pw-entry"
            hexpand={true}
            visibility={false}
            placeholderText="Passwort"
            $={(self: Gtk.Entry) => { entry = self }}
            onActivate={() => tryConnect(entry?.text ?? null)}
          />
          <button class="net-pw-connect" onClicked={() => tryConnect(entry?.text ?? null)}>
            <label label="Verbinden" />
          </button>
        </box>
      </revealer>
    </box>
  )
}

export default function NetworkPopup() {
  const net = Network.get_default()
  const wifi = net.wifi ?? null
  const { TOP, RIGHT } = Astal.WindowAnchor

  const [aps, setAps] = createState<Network.AccessPoint[]>(wifi ? buildApList(wifi) : [])
  const [saved, setSaved] = createState<Set<string>>(new Set())
  const [activeSsid, setActiveSsid] = createState<string | null>(wifi?.active_access_point?.ssid ?? null)
  const [enabled, setEnabled] = createState(wifi?.enabled ?? false)
  const [scanning, setScanning] = createState(wifi?.scanning ?? false)
  const [vpns, setVpns] = createState<VpnConn[]>([])

  const refreshList = () => { if (wifi) setAps(buildApList(wifi)) }

  const refreshSaved = () => {
    execAsync(["bash", "-c",
      "nmcli -t -g NAME,TYPE connection show | grep ':802-11-wireless$' | cut -d: -f1"])
      .then(out => { setSaved(new Set(out.split("\n").filter(Boolean))); refreshList() })
      .catch(() => {})
  }

  const refreshVpns = () => {
    Promise.all([
      execAsync(["bash", "-c",
        "nmcli -t -g NAME,TYPE connection show | grep -E ':(vpn|wireguard)$' | cut -d: -f1"]).catch(() => ""),
      execAsync(["nmcli", "-t", "-g", "NAME", "connection", "show", "--active"]).catch(() => ""),
    ]).then(([all, act]) => {
      const activeSet = new Set(act.split("\n").filter(Boolean))
      setVpns(all.split("\n").filter(Boolean).map(name => ({ name, active: activeSet.has(name) })))
    })
  }

  const toggleVpn = (vpn: VpnConn) => {
    const verb = vpn.active ? "down" : "up"
    execAsync(["nmcli", "connection", verb, vpn.name])
      .then(() => refreshVpns())
      .catch(console.error)
  }

  // Trigger a fresh scan + metadata refresh each time the popup is shown, so we
  // never scan continuously in the background like nm-applet did.
  const onShow = () => {
    refreshSaved()
    refreshVpns()
    if (wifi) {
      try { wifi.scan() } catch (e) { console.error(e) }
      refreshList()
    }
  }

  // Live updates while the popup is open.
  let ids: { obj: any; id: number }[] = []
  if (wifi) {
    ids.push({ obj: wifi, id: wifi.connect("notify::scanning", () => { setScanning(wifi.scanning); refreshList() }) })
    ids.push({ obj: wifi, id: wifi.connect("notify::enabled", () => setEnabled(wifi.enabled)) })
    ids.push({ obj: wifi, id: wifi.connect("notify::active-access-point", () => { setActiveSsid(wifi.active_access_point?.ssid ?? null); refreshList() }) })
    ids.push({ obj: wifi, id: wifi.connect("notify::state", refreshList) })
  }
  onCleanup(() => ids.forEach(({ obj, id }) => obj.disconnect(id)))

  let rev: any = null
  let closeTimer: ReturnType<typeof setTimeout> | null = null

  const cancelClose = () => { if (closeTimer !== null) { clearTimeout(closeTimer); closeTimer = null } }
  const scheduleClose = () => {
    cancelClose()
    closeTimer = setTimeout(() => {
      closeTimer = null
      if (rev) rev.reveal_child = false
      setTimeout(() => App.toggle_window("network-popup"), 220)
    }, 400)
  }
  const attachHover = (self: any) => {
    const motion = new Gtk.EventControllerMotion()
    motion.connect("enter", cancelClose)
    motion.connect("leave", scheduleClose)
    self.add_controller(motion)
  }

  return (
    <window
      name="network-popup"
      class="network-popup"
      anchor={TOP | RIGHT}
      exclusivity={Astal.Exclusivity.NORMAL}
      application={App}
      visible={false}
      keymode={Astal.Keymode.ON_DEMAND}
      $={(self: any) => {
        self.connect("notify::visible", () => {
          if (self.visible) { onShow(); if (rev) rev.reveal_child = true }
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
      <box class="net-panel" orientation={1} spacing={10} $={attachHover}>
        <box class="net-header" spacing={8}>
          <label class="net-header-title" label="Netzwerk" hexpand={true} xalign={0} />
          <label
            class="net-scanning"
            label="Suche…"
            visible={scanning}
          />
          {wifi ? (
            <switch
              class="net-wifi-switch"
              active={enabled}
              onNotifyActive={(self: any) => { if (wifi.enabled !== self.active) wifi.enabled = self.active }}
            />
          ) : <box />}
          <button
            class="net-close-btn"
            onClicked={() => App.toggle_window("network-popup")}
          >
            <label label="✕" />
          </button>
        </box>

        {wifi ? (
          <scrolledwindow class="net-scroll" vexpand={true} hscrollbarPolicy={Gtk.PolicyType.NEVER} minContentHeight={260}>
            <box orientation={1} spacing={2}>
              <label
                class="net-empty"
                label={enabled.as(e => e ? "Keine Netzwerke gefunden" : "WLAN ist aus")}
                visible={aps.as(a => a.length === 0)}
                halign={Gtk.Align.CENTER}
              />
              <For each={aps}>
                {(ap: Network.AccessPoint) => (
                  <APRow ap={ap} wifi={wifi} saved={saved()} activeSsid={activeSsid()} />
                )}
              </For>
            </box>
          </scrolledwindow>
        ) : (
          <label class="net-empty" label="Kein WLAN-Adapter" />
        )}

        <box
          class="net-vpn-section"
          orientation={1}
          spacing={4}
          visible={vpns.as(v => v.length > 0)}
        >
          <label class="net-section-title" label="VPN" xalign={0} />
          <For each={vpns}>
            {(vpn: VpnConn) => (
              <button class={`net-vpn${vpn.active ? " active" : ""}`} onClicked={() => toggleVpn(vpn)}>
                <box spacing={8}>
                  <label class="net-vpn-icon" label="󰦝" />
                  <label class="net-vpn-name" label={vpn.name} hexpand={true} xalign={0} />
                  <label class="net-vpn-state" label={vpn.active ? "An" : "Aus"} />
                </box>
              </button>
            )}
          </For>
        </box>

        <button
          class="net-advanced-btn"
          onClicked={() => { execAsync("nm-connection-editor").catch(console.error); App.toggle_window("network-popup") }}
        >
          <label label="Erweiterte Einstellungen" />
        </button>
      </box>
      </revealer>
    </window>
  )
}
