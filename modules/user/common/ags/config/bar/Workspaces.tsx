import { createBinding, For } from "ags"
import Hyprland from "gi://AstalHyprland"

export default function Workspaces() {
  const hypr = Hyprland.get_default()

  const sorted = createBinding(hypr, "workspaces").as(ws =>
    ws.filter(w => w.id > 0).sort((a, b) => a.id - b.id)
  )
  const focused = createBinding(hypr, "focused-workspace")

  return (
    <box class="workspaces" spacing={2}>
      <For each={sorted}>
        {(ws: Hyprland.Workspace) => (
          <button
            class={focused.as(fw =>
              fw?.id === ws.id ? "workspace-btn active" : "workspace-btn"
            )}
            onClicked={() => hypr.dispatch("workspace", ws.id.toString())}
            tooltipText={ws.name}
          >
            <label label={ws.id.toString()} />
          </button>
        )}
      </For>
    </box>
  )
}
