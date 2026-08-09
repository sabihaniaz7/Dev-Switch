# Dev Switch

A single-screen Flutter app (Android only) with real switches for three
system settings:

- Developer options
- USB debugging
- Wireless debugging

Toggling a switch changes the setting directly on the device. There is no
redirect to the system Settings app.

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

Then reopen the app. The switches will now write directly to
`Settings.Global` and take effect immediately, with no extra screens.

If the permission has not been granted yet, tapping a switch shows a dialog
with this exact command instead of changing the setting, so the failure
mode is clear rather than silent.

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
    main.dart              Flutter UI, single screen
  android/
    app/src/main/kotlin/com/example/dev_switch/
      MainActivity.kt      Platform channel: reads settings, opens intents
  pubspec.yaml
```

## How the native bridge works

The Flutter side talks to Android over a `MethodChannel` named
`dev_switch/settings`, defined in `main.dart` as `DevSettingsBridge`, with
these methods:

- `isDeveloperOptionsEnabled`
- `isUsbDebuggingEnabled`
- `isWirelessDebuggingEnabled`
- `openDeveloperOptions`
- `openWirelessDebugging`

- `hasWriteSecureSettingsPermission`
- `setDeveloperOptionsEnabled`
- `setUsbDebuggingEnabled`
- `setWirelessDebuggingEnabled`

On the Android side, `MainActivity.kt` implements the writes with
`Settings.Global.putInt(...)` calls, and implements `openDeveloperOptions`
/ `openWirelessDebugging` as a fallback the UI no longer uses by default
but keeps available in the bridge.

## Setup

1. Make sure Flutter is installed and `flutter doctor` passes for Android.
2. Create a new Flutter project as a base, then copy in the `lib/main.dart`
   and `android/app/src/main/kotlin/.../MainActivity.kt` files from this
   package, matching your own package name, or use the files as-is with
   package name `com.example.dev_switch`:

   ```
   flutter create dev_switch
   cd dev_switch
   # then replace lib/main.dart and MainActivity.kt with the files here
   ```

3. Install dependencies:

   ```
   flutter pub get
   ```

4. Run on a connected Android device or emulator:

   ```
   flutter run
   ```

## Minimum SDK

`isWirelessDebuggingEnabled` reads a settings key that is only meaningful on
Android 11 (API 30) and above, since wireless debugging as a distinct
feature was introduced there. On older devices this will simply read as
off, and tapping the wireless debugging card still opens Developer options
where the equivalent ADB-over-network option, if present on that device,
can be found.

## Design notes

The UI uses a dark, muted-purple palette (`#21222D` background,
`#958CE8` accent, `#ACD1FD` accent-light, `#DBDBE5` muted text) with status
cards showing an ON/OFF pill for each setting, a refresh button, and a short
explanatory note at the bottom about why direct toggling is not possible.