import { createBinding } from "ags"
import Hyprland from "gi://AstalHyprland"
import Pango from "gi://Pango"

export default function WindowTitle() {
  const hypr = Hyprland.get_default()

  return (
    <label
      class="window-title"
      ellipsize={Pango.EllipsizeMode.END}
      maxWidthChars={48}
      xalign={0}
      label={createBinding(hypr, "focused-client").as(c => c?.title ?? "Desktop")}
    />
  )
}
