# Findings

- Live instance PID 2056: `qs -c end4-pC`, Wayland `wayland-1`.
- Branch `my-setup`; HEAD `c9f19adefd9bd88cfd0317293cab3019c1787a1b`.
- Existing edits in sidebar/Tailscale, ResourceUsage and its lifecycle test
  are outside this task. Baseline diff/status archived privately.
- One connected 1920x1200 display, scale 1.
- Quickshell 0.3.2; qmlformat/qmllint installed; qsb at `/usr/lib/qt6/bin/qsb`.
- Existing root planning documents describe earlier work and are preserved.

- Final live process PID172879 after a targeted restart. The runtime retains one Cava process and the user's original placement/layout; new theme flags default off/classic and persist.
- Active legacy bar media is Media.qml (Tacet visual only); its native popup/input/lyrics code was preserved. No shader files or desktop adaptive-governor changes.
- Native captures cover resource orientations, clock80/100/125 and all9 filler styles. Actual-source fixtures pass53 behavior assertions; independent AGY review agrees. Physical input, multiple monitors and fractional compositor scaling remain manual.
- Shared bar time once stalled during hot reload and resynced through the existing precision setting. Fresh startup advanced correctly; desktop hour/minute/seconds now use the existing local seconds clock.
- Original clock shadow target block emits an anchor warning on startup; unchanged from baseline. Matching Qt6 parsers pass; semantic lint cannot fully resolve Quickshell's dynamic qs.* modules.
