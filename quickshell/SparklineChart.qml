import QtQuick

Canvas {
    id: root
    
    property var values: []
    property real maxValue: 100
    property color color: "#89b4fa"
    property color fillColor: Qt.rgba(0.5, 0.7, 0.98, 0.2)
    property real lineWidth: 2
    
    onValuesChanged: requestPaint()
    
    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        
        if (values.length === 0) return
        
        var w = width
        var h = height
        var padding = 4
        var plotHeight = h - padding * 2
        var pointSpacing = w / Math.max(values.length - 1, 1)
        
        // Create gradient for fill
        var gradient = ctx.createLinearGradient(0, padding, 0, h - padding)
        gradient.addColorStop(0, fillColor)
        gradient.addColorStop(1, Qt.rgba(fillColor.r, fillColor.g, fillColor.b, 0))
        
        // Draw filled area
        ctx.beginPath()
        ctx.moveTo(0, h - padding)
        
        for (var i = 0; i < values.length; i++) {
            var x = i * pointSpacing
            var normalizedValue = Math.min(values[i] / maxValue, 1.0)
            var y = h - padding - (normalizedValue * plotHeight)
            
            if (i === 0) {
                ctx.lineTo(x, y)
            } else {
                ctx.lineTo(x, y)
            }
        }
        
        ctx.lineTo(w, h - padding)
        ctx.closePath()
        ctx.fillStyle = gradient
        ctx.fill()
        
        // Draw line
        ctx.beginPath()
        for (var i = 0; i < values.length; i++) {
            var x = i * pointSpacing
            var normalizedValue = Math.min(values[i] / maxValue, 1.0)
            var y = h - padding - (normalizedValue * plotHeight)
            
            if (i === 0) {
                ctx.moveTo(x, y)
            } else {
                ctx.lineTo(x, y)
            }
        }
        
        ctx.strokeStyle = color
        ctx.lineWidth = lineWidth
        ctx.lineCap = "round"
        ctx.lineJoin = "round"
        ctx.stroke()
        
        // Draw last point
        if (values.length > 0) {
            var lastX = (values.length - 1) * pointSpacing
            var lastNormalizedValue = Math.min(values[values.length - 1] / maxValue, 1.0)
            var lastY = h - padding - (lastNormalizedValue * plotHeight)
            
            ctx.beginPath()
            ctx.arc(lastX, lastY, 3, 0, 2 * Math.PI)
            ctx.fillStyle = color
            ctx.fill()
        }
    }
}
