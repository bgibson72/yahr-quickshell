# Workspace Attention Highlighting

## Feature Status: Implemented but Limited by Hyprland

The workspace attention highlighting feature has been implemented in WorkspaceBar.qml, but **currently does not function** due to Hyprland limitations.

### What Was Implemented

The code checks two properties to determine if a workspace needs attention:
- `workspace.urgent` - Workspace-level urgent flag
- `toplevel.demanding` - Individual window demanding attention flag

When either property is true, the workspace indicator:
- Highlights the workspace number in **red** (accentRed)
- Shows a **red underline** indicator

### Current Limitation

**Hyprland does not currently expose or implement the `urgent` or `demanding` properties** in its IPC API. 

Testing shows:
```bash
$ hyprctl clients -j | jq '.[0] | {urgent, demanding}'
{
  "urgent": null,
  "demanding": null
}
```

These properties exist in the JSON but are always `null`.

### Hyprland Support

The ICCCM `WM_HINTS` urgent flag is part of the X11 protocol. Hyprland as a Wayland compositor may:
1. Not fully implement ICCCM hints yet
2. Not expose these flags through its IPC
3. Have different mechanism for window attention

### Future Compatibility

When Hyprland adds support for urgent/demanding window states:
- **No code changes needed** - the feature will automatically work
- The logic is already in place and will activate once Hyprland populates these properties

### Workarounds

For now, workspace attention highlighting cannot be reliably tested. Applications that would normally set urgent state (Discord, Slack, Firefox alerts, etc.) will not trigger the highlighting.

### Related Issues

- Check Hyprland GitHub for issues related to `urgent` or `WM_HINTS` support
- Monitor Hyprland changelog for IPC API updates

---

**Last Updated:** January 14, 2026  
**Hyprland Version Tested:** Current stable
