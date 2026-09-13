package com.example.dev_switch

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class DevSwitchWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_TOGGLE_DEV = "com.example.dev_switch.TOGGLE_DEV"
        const val ACTION_TOGGLE_USB = "com.example.dev_switch.TOGGLE_USB"
        const val ACTION_TOGGLE_WIRELESS = "com.example.dev_switch.TOGGLE_WIRELESS"

        /** Called by MainActivity after a successful write, so the widget
         *  updates immediately if it's on the home screen. */
        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, DevSwitchWidgetProvider::class.java)
            )
            if (ids.isNotEmpty()) {
                val intent = Intent(context, DevSwitchWidgetProvider::class.java)
                intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                context.sendBroadcast(intent)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, buildViews(context))
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        val handled = when (intent.action) {
            ACTION_TOGGLE_DEV -> {
                handleToggle(context) {
                    DevSettingsHelper.setDeveloperOptionsEnabled(
                        context, !DevSettingsHelper.isDeveloperOptionsEnabled(context)
                    )
                }
            }

            ACTION_TOGGLE_USB -> {
                handleToggle(context) {
                    if (!DevSettingsHelper.isDeveloperOptionsEnabled(context)) {
                        false // locked, same rule as in-app
                    } else {
                        DevSettingsHelper.setUsbDebuggingEnabled(
                            context, !DevSettingsHelper.isUsbDebuggingEnabled(context)
                        )
                    }
                }
            }

            ACTION_TOGGLE_WIRELESS -> {
                handleToggle(context) {
                    if (!DevSettingsHelper.isDeveloperOptionsEnabled(context)) {
                        false
                    } else {
                        DevSettingsHelper.setWirelessDebuggingEnabled(
                            context, !DevSettingsHelper.isWirelessDebuggingEnabled(context)
                        )
                    }
                }
            }

            else -> null
        }

        if (handled != null) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, DevSwitchWidgetProvider::class.java)
            )
            for (id in ids) {
                manager.updateAppWidget(id, buildViews(context))
            }
        }
    }

    /** Runs [action] if permission is granted; otherwise opens the app so
     *  the user can see the one-time setup dialog, instead of failing silently. */
    private fun handleToggle(context: Context, action: () -> Boolean): Boolean {
        if (!DevSettingsHelper.hasPermission(context)) {
            val launch = Intent(context, MainActivity::class.java)
            launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(launch)
            return false
        }
        return action()
    }

    private fun buildViews(context: Context): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_dev_switch)

        val devOn = DevSettingsHelper.isDeveloperOptionsEnabled(context)
        val usbOn = DevSettingsHelper.isUsbDebuggingEnabled(context)
        val wirelessOn = DevSettingsHelper.isWirelessDebuggingEnabled(context)
        val locked = !devOn

        setIconState(views, R.id.icon_dev, devOn, false)
        setIconState(views, R.id.icon_usb, usbOn, locked)
        setIconState(views, R.id.icon_wireless, wirelessOn, locked)

        views.setOnClickPendingIntent(R.id.icon_dev, pendingIntent(context, ACTION_TOGGLE_DEV))
        views.setOnClickPendingIntent(R.id.icon_usb, pendingIntent(context, ACTION_TOGGLE_USB))
        views.setOnClickPendingIntent(
            R.id.icon_wireless, pendingIntent(context, ACTION_TOGGLE_WIRELESS)
        )

        val appIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val appPendingIntent = PendingIntent.getActivity(
            context,
            0,
            appIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root, appPendingIntent)

        return views
    }

    private fun setIconState(views: RemoteViews, viewId: Int, on: Boolean, locked: Boolean) {
        val background = when {
            locked -> R.drawable.icon_circle_locked
            on -> R.drawable.icon_circle_on
            else -> R.drawable.icon_circle_off
        }
        views.setInt(viewId, "setBackgroundResource", background)
        views.setInt(viewId, "setImageAlpha", if (locked) 130 else 255)
    }

    private fun pendingIntent(context: Context, action: String): PendingIntent {
        val intent = Intent(context, DevSwitchWidgetProvider::class.java)
        intent.action = action
        return PendingIntent.getBroadcast(
            context,
            action.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}