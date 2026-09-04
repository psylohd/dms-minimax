import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import "translations.js" as Tr

PluginComponent {
    id: root

    property string lang: (SessionData.locale || Qt.locale().name).split(/[_-]/)[0]
    function tr(key) { return Tr.tr(key, lang); }

    // API data
    property string subscriptionType: "minimax"
    property string rateLimitTier: ""
    property real fiveHourUtil: 0
    property string fiveHourReset: ""
    property real sevenDayUtil: 0
    property string sevenDayReset: ""

    // Live countdown
    property real countdownNow: Date.now()

    property string fiveHourCountdown: {
        if (!fiveHourReset) return "";
        var remaining = new Date(fiveHourReset).getTime() - countdownNow;
        if (remaining <= 0) return tr("Resetting...");
        var h = Math.floor(remaining / 3600000);
        var m = Math.floor((remaining % 3600000) / 60000);
        return h + "h " + (m < 10 ? "0" : "") + m + "m";
    }

    property string sevenDayCountdown: {
        if (!sevenDayReset) return "";
        var remaining = new Date(sevenDayReset).getTime() - countdownNow;
        if (remaining <= 0) return tr("Resetting...");
        var d = Math.floor(remaining / 86400000);
        var h = Math.floor((remaining % 86400000) / 3600000);
        var m = Math.floor((remaining % 3600000) / 60000);
        if (d > 0) return d + "d " + h + "h " + (m < 10 ? "0" : "") + m + "m";
        return h + "h " + (m < 10 ? "0" : "") + m + "m";
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: countdownNow = Date.now()
    }

    property int refreshInterval: 300000

    property string scriptPath: "/home/intox/.config/DankMaterialShell/plugins/minimaxCodeUsage/minimaxCodeUsage/get-minimax-usage"

    popoutWidth: 340
    popoutHeight: 360

    function progressColor(pct) {
        if (pct > 80) return Theme.error;
        if (pct > 50) return Theme.warning;
        return Theme.primary;
    }

    function parseLine(line) {
        var idx = line.indexOf("=");
        if (idx < 0) return;
        var key = line.substring(0, idx);
        var val = line.substring(idx + 1);
        switch (key) {
        case "SUBSCRIPTION_TYPE": subscriptionType = val; break;
        case "RATE_LIMIT_TIER": rateLimitTier = val; break;
        case "FIVE_HOUR_UTIL": fiveHourUtil = parseFloat(val) || 0; break;
        case "FIVE_HOUR_RESET": fiveHourReset = val; break;
        case "SEVEN_DAY_UTIL": sevenDayUtil = parseFloat(val) || 0; break;
        case "SEVEN_DAY_RESET": sevenDayReset = val; break;
        }
    }

    Process {
        id: usageProcess
        command: ["timeout", "120", "bash", "-c", root.scriptPath]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n");
                for (var i = 0; i < lines.length; i++) {
                    root.parseLine(lines[i]);
                }
            }
        }

        onExited: (code, status) => {
            if (code === 0) isLoading = false;
        }
    }

    Timer {
        interval: root.refreshInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!usageProcess.running)
                usageProcess.running = true;
        }
    }

    // --- Taskbar pill ---
    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS
            Canvas {
                width: root.iconSize
                height: root.iconSize
                anchors.verticalCenter: parent.verticalCenter
                renderStrategy: Canvas.Cooperative
                property real percent: root.fiveHourUtil
                onPercentChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var cx = width / 2, cy = height / 2, r = width * 0.375, lw = width * 0.125;
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                    ctx.lineWidth = lw;
                    ctx.strokeStyle = Theme.surfaceVariant;
                    ctx.stroke();
                    var pct = percent / 100;
                    if (pct > 0) {
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * Math.min(pct, 1));
                        ctx.lineWidth = lw;
                        ctx.strokeStyle = root.progressColor(percent);
                        ctx.lineCap = "round";
                        ctx.stroke();
                    }
                }
            }
            StyledText {
                text: Math.round(root.fiveHourUtil) + "%"
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS
            Canvas {
                width: root.iconSize
                height: root.iconSize
                anchors.horizontalCenter: parent.horizontalCenter
                renderStrategy: Canvas.Cooperative
                property real percent: root.fiveHourUtil
                onPercentChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var cx = width / 2, cy = height / 2, r = width * 0.375, lw = width * 0.125;
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                    ctx.lineWidth = lw;
                    ctx.strokeStyle = Theme.surfaceVariant;
                    ctx.stroke();
                    var pct = percent / 100;
                    if (pct > 0) {
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * Math.min(pct, 1));
                        ctx.lineWidth = lw;
                        ctx.strokeStyle = root.progressColor(percent);
                        ctx.lineCap = "round";
                        ctx.stroke();
                    }
                }
            }
            StyledText {
                text: Math.round(root.fiveHourUtil) + "%"
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // --- Popout ---
    popoutContent: Component {
        PopoutComponent {
            headerText: root.tr("MiniMax Code Usage")
            detailsText: ""
            showCloseButton: true

            Column {
                width: parent.width - Theme.spacingM * 2
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingL

                // 5h card
                StyledRect {
                    width: parent.width
                    height: 120
                    color: Theme.surfaceContainerHigh

                    Row {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingS
                        spacing: Theme.spacingM

                        Canvas {
                            id: fiveHourRing
                            width: 100
                            height: 100
                            anchors.verticalCenter: parent.verticalCenter
                            renderStrategy: Canvas.Cooperative
                            property real percent: root.fiveHourUtil
                            onPercentChanged: requestPaint()
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                var cx = width / 2, cy = height / 2, r = 38, lw = 8;
                                ctx.beginPath();
                                ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                                ctx.lineWidth = lw;
                                ctx.strokeStyle = Theme.surfaceVariant;
                                ctx.stroke();
                                var pct = percent / 100;
                                if (pct > 0) {
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * Math.min(pct, 1));
                                    ctx.lineWidth = lw;
                                    ctx.strokeStyle = root.progressColor(percent);
                                    ctx.lineCap = "round";
                                    ctx.stroke();
                                }
                            }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            StyledText {
                                text: root.tr("5h Rate Window")
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }
                            StyledText {
                                text: Math.round(root.fiveHourUtil) + "% " + root.tr("used")
                                font.pixelSize: Theme.fontSizeXLarge
                                font.weight: Font.DemiBold
                                color: root.progressColor(root.fiveHourUtil)
                            }
                            StyledText {
                                text: root.fiveHourCountdown ? root.tr("Resets in") + " " + root.fiveHourCountdown : ""
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }
                    }
                }

                // 7d card
                StyledRect {
                    width: parent.width
                    height: 120
                    color: Theme.surfaceContainerHigh

                    Row {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingS
                        spacing: Theme.spacingM

                        Canvas {
                            id: sevenDayRing
                            width: 100
                            height: 100
                            anchors.verticalCenter: parent.verticalCenter
                            renderStrategy: Canvas.Cooperative
                            property real percent: root.sevenDayUtil
                            onPercentChanged: requestPaint()
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                var cx = width / 2, cy = height / 2, r = 38, lw = 8;
                                ctx.beginPath();
                                ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                                ctx.lineWidth = lw;
                                ctx.strokeStyle = Theme.surfaceVariant;
                                ctx.stroke();
                                var pct = percent / 100;
                                if (pct > 0) {
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * Math.min(pct, 1));
                                    ctx.lineWidth = lw;
                                    ctx.strokeStyle = root.progressColor(percent);
                                    ctx.lineCap = "round";
                                    ctx.stroke();
                                }
                            }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            StyledText {
                                text: root.tr("7-Day Usage")
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }
                            StyledText {
                                text: Math.round(root.sevenDayUtil) + "% " + root.tr("used")
                                font.pixelSize: Theme.fontSizeXLarge
                                font.weight: Font.DemiBold
                                color: root.progressColor(root.sevenDayUtil)
                            }
                            StyledText {
                                text: root.sevenDayCountdown ? root.tr("Resets in") + " " + root.sevenDayCountdown : ""
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }
                    }
                }
            }
        }
    }
}
