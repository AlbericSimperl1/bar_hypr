// Tui.qml - de TUI-stijl van rust-launcher (ui/theme.rs) voor alle panels
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: tui

    readonly property color text: "#d4d6db"
    readonly property color dim: "#9a9b9b"
    readonly property color rule: "#5b5b5a"
    readonly property color selBg: "#ffffff"
    readonly property color selText: "#1f1f21"
    readonly property color on: "#83c679"
    readonly property color danger: "#ff453a"
    readonly property color accent: "#aaadb4"
    readonly property color statusText: "#17181b"
    readonly property color modeBg: "#1f1f21"
    readonly property string rest: "rgba(255, 255, 255, 0.22)"

    readonly property string family: Config.fontFamily
    readonly property int size: 17
    readonly property int statusSize: 16
    readonly property int lineH: 24
    readonly property int meterH: 12

    // selectie: de regel onder de muis, of waar de pijltjes staan zolang de muis niet bewoog
    property Item cursor: null
    property Item sub: null       // actie op de regel, gekozen met links/rechts
    property bool keys: false

    readonly property Item current: cursor && cursor.visible ? cursor : null
    readonly property string enterLabel: {
        const c = current;
        if (!c)
            return "";
        if (sub && sub.visible)
            return sub.text;
        if (c.hint)
            return c.hint;
        const acts = c.rowActions ? c.rowActions() : [];
        return acts.length ? acts[0].text : "";
    }

    function reset() {
        cursor = null;
        sub = null;
        keys = false;
    }

    function isCursor(item) {
        return keys && cursor === item;
    }

    // stops zijn items met tuiStop, in beeldvolgorde
    function stopsIn(item, out) {
        const kids = item.children;
        for (let i = 0; i < kids.length; i++) {
            const c = kids[i];
            if (!c.visible)
                continue;
            if (c.tuiStop && c.enabled)
                out.push(c);
            else if (!c.tuiStop)
                stopsIn(c, out);
        }
        return out;
    }

    function step(root, d) {
        const all = stopsIn(root, []);
        keys = true;
        sub = null;
        if (all.length === 0)
            return;
        const i = all.indexOf(current);
        cursor = i < 0 ? all[d > 0 ? 0 : all.length - 1] : all[(i + d + all.length) % all.length];
    }

    // links/rechts: waarde aanpassen, door de acties van de regel, of naar de buur (tabs, knoppen)
    function sideways(root, d) {
        const c = current;
        keys = true;
        if (c && c.adjust) {
            c.adjust(d);
        } else if (c && c.rowActions) {
            const acts = c.rowActions();
            const i = acts.indexOf(sub) + d;
            sub = i === -2 ? acts[acts.length - 1] || null : acts[i] || null;
        } else {
            step(root, d);
        }
    }

    function enter() {
        if (sub && sub.visible)
            sub.activate();
        else if (current)
            current.activate();
    }

    // zichtbare, bruikbare TuiActions in de gegeven rijen
    function actionsIn(rows) {
        const out = [];
        rows.forEach(r => stopsIn(r, out));
        return out;
    }

    // tekst voor de statusregel, als in rust-launcher: vette toets + wat hij doet
    function keyHints(typing) {
        const key = (k, label) => "<b>" + k + "</b> " + label.replace(/&/g, "&amp;").replace(/</g, "&lt;");
        if (typing)
            return key("⏎", "done") + "  " + key("esc", "back");
        const c = current;
        const parts = [];
        if (!c)
            parts.push(key("↑↓", "select"));
        if (enterLabel)
            parts.push(key("⏎", enterLabel));
        if (c && c.adjust)
            parts.push(key("←→", "adjust"));
        else if (c && c.rowActions && c.rowActions().length > 0)
            parts.push(key("←→", "actions"));
        return parts.join("  ");
    }
}
