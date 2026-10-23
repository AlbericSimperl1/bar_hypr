// node Model.test.js - checks the pure helpers in Model.js
const assert = require("assert");
const M = new Function(require("fs").readFileSync(__dirname + "/Model.js", "utf8") +
  "; return { parseKeyValue, connectionStats, wifiChannel, formatBits, speedTestSummary };")();

const kv = M.parseKeyValue("type\twifi\niface\twlan0\nsignal\t-32\nfreq\t5300.0\nrx_rate\t1134.2\ntx_rate\t1200.9\nwidth\t80\ngen\t6\n" +
  "session_rx\t61886458\nsession_tx\t1236274\nip\t192.168.0.114/24\ngateway\t192.168.0.1\n");
const s = M.connectionStats(kv);
assert.strictEqual(s.signal, "-32 dBm");
assert.strictEqual(s.quality, "Excellent");
assert.strictEqual(s.link, "↓ 1134  ↑ 1201 Mb/s");
assert.strictEqual(s.linkDetail, "5 GHz · ch 60 · 80 MHz · Wi-Fi 6");
assert.strictEqual(s.session, "↓ 59.0 MB  ↑ 1.2 MB this session");
assert.strictEqual(s.ip, "192.168.0.114");
assert.strictEqual(s.gateway, "gateway 192.168.0.1");

assert.strictEqual(M.wifiChannel(2412), 1);
assert.strictEqual(M.wifiChannel(2484), 14);
assert.strictEqual(M.wifiChannel(5180), 36);
assert.strictEqual(M.wifiChannel(5955), 1);

// rates in bits, like speedtests
assert.strictEqual(M.formatBits(474e6 / 8), "474.0 Mb/s");
assert.strictEqual(M.formatBits(728), "5.8 Kb/s");
assert.strictEqual(M.formatBits(0), "0 b/s");

// partial results show what has finished so far
assert.strictEqual(M.speedTestSummary({ ping: "15" }), "15 ms");
assert.strictEqual(M.speedTestSummary({ ping: "15", down: String(455e6 / 8), up: String(29e6 / 8) }), "↓ 455.0 Mb/s  ↑ 29.0 Mb/s  15 ms");
assert.strictEqual(M.speedTestSummary({}), "");

const e = M.connectionStats(M.parseKeyValue("type\tethernet\niface\tenp4s0\nmac\t1c:69:7a:bc:62:3f\nspeed\t1000\nduplex\tfull\n"));
assert.strictEqual(e.link, "1 Gb/s");
assert.strictEqual(e.linkDetail, "full duplex");
assert.strictEqual(e.signal, "");
assert.strictEqual(M.connectionStats({ rx_bytes: "2048", tx_bytes: "0" }).session, "↓ 2.0 KB  ↑ 0 B since up");
assert.strictEqual(M.connectionStats({ type: "ethernet", speed: "-1", duplex: "unknown" }).link, "");
assert.strictEqual(M.connectionStats({ type: "ethernet", speed: "100" }).link, "100 Mb/s");

// missing fields degrade to empty strings, never "NaN"
const empty = M.connectionStats({});
assert.ok(Object.values(empty).every(v => v === ""), JSON.stringify(empty));

console.log("Model.test.js ok");
