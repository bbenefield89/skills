---
name: android-wireless-debug
description: Connects an Android phone to adb over Wi-Fi for wireless debugging, pairs it with a pairing code when necessary, and checks the Godot Android SDK path. Use when the user asks to pair, connect, or reconnect a phone for wireless debugging or adb over Wi-Fi.
---

# Android Wireless Debug

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

## How this skill works

The script `scripts/connect-android.ps1` does all of the work. Your task is to run it, give it the one value that it asks for, and report. `<skill-dir>` is the folder of this `SKILL.md`. The script runs on Windows only.

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>/scripts/connect-android.ps1" -NoPrompt
```

Always pass `-NoPrompt`. Without it, the script waits for keyboard input. The last line of a good run is `ANDROID WIRELESS DEBUG OK`.

Pairing is necessary only one time for each device and PC. After that, only the connect port changes, for example after a restart of the device. Thus most runs need no value from the user.

## Steps

1. Run the command with no values.
2. Read the exit code, and do the action in the table. Ask the user only for the values in that row.
3. Run the command again with those values. Repeat from step 2.
4. Report the `DEVICE:` line and each `WARNING:` line.

| Exit | Meaning | Action |
|---|---|---|
| 0 | One device is connected. | Report. |
| 2 | adb was not found. | Tell the user to install Android SDK Platform-Tools. Stop. |
| 3 | The connect address is necessary. | Ask for the connect IP address and port. Add `-ConnectAddress <ip:port>`. |
| 4 | Pairing is necessary. | Ask for the pairing IP address, port and code. Add `-PairAddress <ip:port> -PairCode <code>`, and keep `-ConnectAddress`. |
| 5 | The connection failed. | Ask the user to check the items in the error line, and to send the current connect address. |
| 6 | The pairing failed. | Ask the user to open the pairing dialog again, and to send the new pairing address and code. |
| 7 | More than one device is connected. | Show the device list. Ask which devices to disconnect. |

## Where the user finds the values

On the device, open **Settings > Developer options > Wireless debugging**, and turn it on. The device and the PC must use the same Wi-Fi network.

- **Connect address**: "IP address & Port" on the main Wireless debugging screen, for example `192.168.1.42:41567`.
- **Pairing address and code**: tap **Pair device with pairing code**. The dialog shows an IP address and port, for example `192.168.1.42:37123`, and a 6-digit code. The pairing port is different from the connect port.

The pairing code becomes invalid when the dialog closes. Tell the user to keep the dialog open until the script reports the result.

## Values

Use each address and code for one run only. The addresses change, so do not save them in a file or in memory.

## Godot check

The script reads `android_sdk_path` in each Godot `editor_settings-*.tres` file. It reads the files in `%APPDATA%\Godot` and in the `editor_data` folder of a Steam install. A `WARNING:` line shows a file whose path is empty or points to a different SDK. The script does not change these files. If the user wants a change, tell the user to set **Editor Settings > Export > Android > Android SDK Path** in Godot.

## Out of scope

This skill stops when the device is connected. Export, install, and USB debugging are separate tasks.
