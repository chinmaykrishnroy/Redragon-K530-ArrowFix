import time
import threading
import keyboard
import pystray
import os
from PIL import Image

# config
TAP_THRESHOLD = 0.25  # seconds

# make sure the file is named icon.ico (or change this to the actual filename)
ICON_PATH = os.path.join(os.path.dirname(__file__), "icon.ico")

# runtime state
modifier_active = False
caps_down_time = 0.0
combo_used = False
paused = False

hooks = []
hooks_lock = threading.Lock()
state_lock = threading.Lock()

MAP = {'w': 'up', 'a': 'left', 's': 'down', 'd': 'right'}


# -------------------
# Handlers
# -------------------
def on_caps_down(e):
    global modifier_active, caps_down_time, combo_used
    with state_lock:
        modifier_active = True
        combo_used = False
        caps_down_time = time.time()


def on_caps_up(e):
    global modifier_active, combo_used
    with state_lock:
        held_time = time.time() - caps_down_time
        was_combo = combo_used
        modifier_active = False

    if paused:
        return

    if (not was_combo) and (held_time <= TAP_THRESHOLD):
        time.sleep(0.02)
        keyboard.send('caps lock')


def make_press_handler(keyname):
    arrow = MAP[keyname]

    def handler(e):
        if paused:
            return
        with state_lock:
            if modifier_active:
                global combo_used
                combo_used = True
                keyboard.press(arrow)
            else:
                keyboard.press(keyname)
    return handler


def make_release_handler(keyname):
    arrow = MAP[keyname]

    def handler(e):
        if paused:
            return
        with state_lock:
            if modifier_active:
                keyboard.release(arrow)
            else:
                keyboard.release(keyname)
    return handler


# -------------------
# Hook control
# -------------------
def register_hooks():
    with hooks_lock:
        if hooks:
            return

        # Caps
        hooks.append(keyboard.on_press_key("caps lock", on_caps_down, suppress=True))
        hooks.append(keyboard.on_release_key("caps lock", on_caps_up, suppress=True))

        # WASD
        for k in ("w", "a", "s", "d"):
            hooks.append(keyboard.on_press_key(k, make_press_handler(k), suppress=True))
            hooks.append(keyboard.on_release_key(k, make_release_handler(k), suppress=True))


def unregister_hooks():
    with hooks_lock:
        for h in hooks:
            try:
                keyboard.unhook(h)
            except:
                pass
        hooks.clear()


# -------------------
# Tray actions
# -------------------
def on_toggle(icon, item):
    global paused
    paused = not paused
    if paused:
        unregister_hooks()
    else:
        register_hooks()
    icon.update_menu()


def on_quit(icon, item):
    unregister_hooks()
    icon.stop()


def build_menu():
    # lambda must accept the menu-item argument (pystray passes one)
    return pystray.Menu(
        pystray.MenuItem(lambda item: "Resume" if paused else "Pause", on_toggle),
        pystray.MenuItem("Quit", on_quit)
    )


# -------------------
# Main tray function
# -------------------
def run_tray():
    # load the ICO file into a PIL Image so pystray can serialise it
    image = None
    try:
        if os.path.exists(ICON_PATH):
            image = Image.open(ICON_PATH)
    except Exception as e:
        image = None
    icon = pystray.Icon("RDK530RGB-ArrowFix", image, "Caps Arrow", build_menu())
    register_hooks()
    icon.run()


if __name__ == "__main__":
    run_tray()
