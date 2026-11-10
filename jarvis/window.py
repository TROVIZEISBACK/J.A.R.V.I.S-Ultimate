"""Open the interface when running from a terminal (./run.sh).

JARVIS.app shows the interface in its own native window, so this is only the
fallback: a chromeless app window in a Chromium browser, else a normal tab.
"""
import os
import subprocess
import webbrowser

from . import config

CHROMIUM = ["Google Chrome", "Vivaldi", "Brave Browser", "Microsoft Edge", "Chromium"]


def _installed(app: str) -> bool:
    return any(os.path.isdir(f"{root}/Applications/{app}.app") for root in ("", os.path.expanduser("~")))


def open_interface():
    url = f"http://{config.HOST}:{config.PORT}"
    app_mode = os.path.isdir(os.path.expanduser("~/Applications/JARVIS.app")) or os.path.isdir("/Applications/JARVIS.app")
    if app_mode and os.environ.get("JARVIS_WINDOW", "app") == "app":
        subprocess.Popen(["open", "-a", "JARVIS"])  # attaches to this running server
        return
    for browser in CHROMIUM:
        if _installed(browser):
            subprocess.Popen(["open", "-na", browser, "--args", f"--app={url}", "--window-size=1440,900"])
            return
    webbrowser.open(url)
