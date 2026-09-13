# Dev Switch

A single-screen Flutter app (Android only) with real switches for three
system settings:

- Developer options
- USB debugging
- Wireless debugging

Toggling a switch changes the setting directly on the device. There is no
redirect to the system Settings app.

## Why I built this

Every time I needed to enable USB or wireless debugging, I had to dig
through Settings → System → Developer options → scroll → find the right
toggle, every single time. It's a small thing, but it adds up fast for
anyone who debugs on a physical device daily. Dev Switch turns that
multi-tap settings hunt into a single tap, either from the app or directly
from the home screen widget, with no navigation required.

## Required one-time setup

Android treats these settings as protected. A normal app install cannot
write to them no matter what permissions are listed in the manifest — the
`WRITE_SECURE_SETTINGS` permission can only be granted through adb, not
through an in-app runtime permission popup. This is an OS-level restriction,
not a limitation of this app's code.

After installing the app, run this once per device, with the device
connected over adb:

```
adb shell pm grant com.example.dev_switch android.permission.WRITE_SECURE_SETTINGS
```

Then flip a switch in the app. Permission is checked live on every tap, so
it takes effect immediately — no need to reopen or restart the app. This is
a one-time step: it stays granted across every future toggle and every app
launch until you uninstall the app or run the revoke command below.

If the permission has not been granted yet, tapping a switch shows a dialog
with this exact command instead of changing the setting, so the failure
mode is clear rather than silent.

### If the grant command fails
 
Some OEM Android skins add extra restrictions on top of standard Android
and block `pm grant` for this permission, even though it works fine on a
stock/Pixel-style device. If you see a `SecurityException` mentioning
`GRANT_RUNTIME_PERMISSIONS`, your device's manufacturer is very likely one
of them.
 
**Xiaomi / Redmi / POCO (MIUI, HyperOS):**
 
1. Go to Settings → Additional settings → Developer options.
2. Turn on **USB debugging (Security settings)** — this is separate from
   the regular USB debugging toggle.
3. Sign in to any account if it asks for.
4. MIUI/HyperOS may enforce a short cooldown before this actually takes
   effect, even if the toggle shows on immediately. If the grant command
   still fails right after enabling it, wait a while and try again.
5. Re-run the grant command above.
**Other brands (Oppo/Realme/ColorOS, Vivo/Funtouch, Samsung, etc.):**
 
The exact toggle name and location vary, but the fix is the same idea —
look in Developer options for a setting related to "USB debugging
security" or similar, enable it, and sign in to any account it asks for.
If nothing like that exists on your device and the error persists, it may
be a stricter OEM restriction with no in-app workaround; a factory-stock
or near-stock Android device (Pixel, Android One) will not have this
extra step at all.

To revoke it later:

```
adb shell pm revoke com.example.dev_switch android.permission.WRITE_SECURE_SETTINGS
```

## Why this can't be avoided

This is intentional Android security design, not something specific to
Flutter or to this app. `WRITE_SECURE_SETTINGS` is a signature-level
permission, meaning it's normally reserved for apps signed with the same
key as the OS, or explicitly whitelisted. adb is granted a broad set of
shell privileges specifically so that developers and QA tooling can enable
permissions like this on a device they physically control, which is exactly
the situation here since this app isn't going through Google Play.

## Project structure

```
dev_switch/
  lib/
    main.dart                         App entry point
    theme/app_colors.dart             Light color palette
    services/dev_settings_bridge.dart Platform channel calls
    screens/home_screen.dart          Main screen: header + 3 toggles
    screens/instructions_screen.dart  One-time setup guide (from app bar)
    widgets/toggle_row.dart           Reusable toggle card
    widgets/command_box.dart          Copyable command box
    widgets/permission_dialog.dart    Short setup dialog
  android/
    app/src/main/AndroidManifest.xml
    app/src/main/kotlin/com/example/dev_switch/
      MainActivity.kt
      DevSettingsHelper.kt
      DevSwitchWidgetProvider.kt
    app/src/main/res/
      layout/widget_dev_switch.xml
      drawable/ (widget backgrounds and icons)
      values/widget_strings.xml
      xml/dev_switch_widget_info.xml
  pubspec.yaml
```

## Behavior notes

- **Cascade lock**: Developer options is the master switch. Turning it off
  automatically turns off USB debugging and Wireless debugging too, and
  both stay locked (greyed out, cannot be turned on) until Developer
  options is back on. This mirrors real Android behavior, since both
  settings live inside Developer options.
- **Wireless pairing**: the first-time pairing code / QR screen is
  generated by Android itself and cannot be shown or scanned by a
  third-party app. The small scan icon next to Wireless debugging opens
  that exact system screen in one tap instead.
- **Instructions page**: tap the info icon in the header to see the
  one-time setup steps and the reasoning behind each restriction.

## How the native bridge works

The Flutter side talks to Android over a `MethodChannel` named
`dev_switch/settings`, defined as `DevSettingsBridge`, with these methods:

- `isDeveloperOptionsEnabled`
- `isUsbDebuggingEnabled`
- `isWirelessDebuggingEnabled`
- `hasWriteSecureSettingsPermission`
- `setDeveloperOptionsEnabled`
- `setUsbDebuggingEnabled`
- `setWirelessDebuggingEnabled`
- `openDeveloperOptions`
- `openWirelessDebugging`

On the Android side, `MainActivity.kt` and `DevSwitchWidgetProvider.kt`
both call into `DevSettingsHelper.kt`, which does the actual
`Settings.Global.putInt(...)` reads and writes. Keeping that logic in one
shared file means the app and the widget can never disagree on state.

## Home screen widget

There's also a native Android home screen widget: a black rounded pill
with three icons (Developer options, USB debugging, Wireless debugging).
Off icons sit in an outlined dark circle; on icons fill with the primary
blue, matching the look of the phone's own Wi-Fi/data quick toggles.
Locked icons (USB/Wireless while Developer options is off) sit dimmed and
don't respond to taps.

Tapping an icon toggles that setting immediately, using the same
`WRITE_SECURE_SETTINGS` permission and the same cascade rule as the app —
turning Developer options off from the widget also turns off USB and
Wireless debugging. If the permission hasn't been granted yet, tapping any
icon opens the app instead of failing silently.

To add it: long-press the home screen → Widgets → "Dev Switch" → drag it
onto the home screen. No extra setup beyond the one-time adb command
above; the widget and the app share the same permission grant.

## Setup

1. Make sure Flutter is installed and `flutter doctor` passes for Android.
2. Clone the repository:
   ```
   git clone https://github.com/sabihaniaz7/Dev-Switch.git
   cd Dev-Switch
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run on a connected Android device:
   ```
   flutter run
   ```
5. Grant the one-time permission (see above), then use the app or the
   widget freely.

## Tech stack

- Flutter / Dart for the UI
- Kotlin for the native Android bridge and home screen widget
- Platform Channels for Flutter ↔ Android communication
- Android `AppWidgetProvider` and `RemoteViews` for the widget