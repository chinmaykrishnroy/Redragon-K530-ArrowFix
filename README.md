# RDK530RGB-ArrowFix

A tiny but stubborn Windows helper that fixes the strange RGB arrow-layer behavior of the **Redragon K530 Draconic** keyboard. If your arrow keys sometimes think they're decorative mood lights instead of actual navigation keys, this tool brings them back to reality :-)

This utility quietly runs a background Python script at startup to keep your arrow-layer sane. No bloated UI, no nonsense, just a practical fix.

## Why I Created This

Because my Redragon K530 Draconic keyboard decided its fancy RGB lighting was more important than functioning arrow keys. The FN arrow-layer kept overriding navigation, and eventually I had enough. I wrote a script to force the keyboard to behave like a normal keyboard again.

Then I wrapped it into a small Windows installer. Then I made an uninstaller. And now you're reading this.

## What This Project Contains

### arrow_layer.pyw

A silent background Python script that monitors arrow-layer behavior on the Redragon K530 Draconic and prevents the keyboard from hijacking your arrow keys for RGB effects. It runs invisibly and uses almost no resources.

### install.bat

A clean, production-style installer that:

1. Automatically elevates to Administrator
2. Detects your Python installation
3. Creates an isolated virtual environment
4. Installs required dependencies (keyboard and pystray, listed in requirements.txt)
5. Registers a Scheduled Task that runs the script on user login with highest privileges
6. Starts the task immediately

It prints only minimal status lines so you know what is happening without drowning in debug output.

### uninstall.bat

A simple but decisive uninstaller that:

* Auto-elevates if needed
* Stops and removes the scheduled task
* Shows a bright red warning telling you to press ENTER to permanently delete the entire app folder
* Uses a delayed PowerShell cleanup helper to delete all files, including itself

It removes everything, but only after you confirm it.

### requirements.txt

Contains the minimal Python dependencies used by the project: keyboard and pystray.

## Installation

Double-click:

install.bat

The installer handles everything automatically: admin elevation, environment setup, package installation, scheduled task creation, and immediate launch of the background script.

After installation, the fix runs silently at every startup.

## Uninstallation

Run:

uninstall.bat

You'll get a clear red warning asking you to press ENTER if you truly want to delete the entire application folder, including all data and scripts. Press Ctrl+C to cancel if you change your mind.

Once confirmed, everything is removed cleanly.

## How It Works (in Human Language)

1. Windows boots
2. Task Scheduler launches the background script
3. The script listens for the Redragon K530 Draconic’s FN-layer interference
4. Whenever the keyboard tries to override arrow keys with RGB functions, the script gently tells it:
   "No. You’re a keyboard. Please act like one."
5. Arrow keys return to behaving like arrow keys, not disco buttons :-)

## Requirements

* Windows 10 or Windows 11
* Python 3 installed
* A Redragon K530 Draconic keyboard with rebellious arrow keys

## License

This project is intentionally simple and free. Use it, modify it, extend it, break it, fix it again. Whatever helps your keyboard behave.

## Final Note

This tool was born out of pure frustration with a keyboard that insisted on being both decoration and device. If it saves even one more person from RGB-induced madness, I consider it a win :-)
