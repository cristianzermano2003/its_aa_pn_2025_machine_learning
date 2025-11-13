// See the following doc for tips on how to build Phoenix assets
// that always have the correct dependencies in place:
// https://hexdocs.pm/phoenix/asset_management.html#webpack-configuration

// We use esbuild and tailwindcss to bundle and minify our css & js.
// Load both DefaultComponents from LiveView and the Vendor Javascript
import "../vendor/topbar"

// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

let Hooks = {}

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:navigate", () => topbar.show(300))
window.addEventListener("phx:navigate-away", () => topbar.hide())

// connect if there are any LiveViews on the page
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: document.querySelector("meta[name='csrf-token']").getAttribute("content")},
  hooks: Hooks
})

// Show the app when it's ready
// The 'phx:page-loading-stop' event is dispatched by the LiveView JS commands
window.addEventListener('phx:page-loading-stop', _info => topbar.hide())

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

liveSocket.connect()
