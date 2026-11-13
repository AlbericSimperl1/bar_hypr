-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("xhost +SI:localuser:root")
    hl.exec_cmd("quickshell -p ~/bar_hypr/b2")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("/home/alberic/launcher/target/release/rust-launcher --daemon")
    hl.exec_cmd("hyprctl setcursor MacTahoe-cursors 28")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpm reload -n")
    -- Hyprspace.so is built by hand against old Hyprland headers and crashes on load after updates (safe mode on boot); overview uses hymission now
    -- hl.exec_cmd("hyprctl plugin load /home/alberic/Projects/HyprspaceF/Hyprspace.so")
    hl.exec_cmd("~/.config/hypr/scripts/ws.py")
end)
