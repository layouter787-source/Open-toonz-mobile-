package com.toonz.tab

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.*
import androidx.compose.runtime.snapshots.SnapshotStateMap
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

private data class InkStroke(
    val points: List<Offset>,
    val color: Color = Color(0xFF17191D),
    val width: Float = 5f
)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { MaterialTheme { MobileEditor() } }
    }
}

@Composable
private fun MobileEditor() {
    var activeTool by remember { mutableStateOf("Pencil") }
    val frames = remember { mutableStateMapOf(1 to emptyList<InkStroke>()) }
    val redoByFrame = remember { mutableStateMapOf<Int, List<InkStroke>>() }
    var draft by remember { mutableStateOf(emptyList<Offset>()) }
    var selectedFrame by remember { mutableIntStateOf(1) }
    var playing by remember { mutableStateOf(false) }
    var onionSkin by remember { mutableStateOf(true) }
    val tools = listOf("Pencil", "Eraser", "Lasso", "Move", "Hand")
    val maxFrame = maxOf(12, frames.keys.maxOrNull() ?: 1)
    val currentStrokes = frames[selectedFrame] ?: emptyList()

    LaunchedEffect(playing, maxFrame) {
        while (playing) {
            delay(83L)
            selectedFrame = if (selectedFrame >= maxFrame) 1 else selectedFrame + 1
        }
    }

    Surface(Modifier.fillMaxSize(), color = Color(0xFF202226)) {
        Column(Modifier.fillMaxSize().padding(8.dp)) {
            Row(
                Modifier.fillMaxWidth().height(44.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column {
                    Text("ToonzTab", color = Color.White, fontSize = 16.sp)
                    Text("Tablet animation workspace · 12 FPS", color = Color(0xFF9DA3AD), fontSize = 10.sp)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    TextButton(onClick = {
                        val items = frames[selectedFrame] ?: emptyList()
                        if (items.isNotEmpty()) {
                            frames[selectedFrame] = items.dropLast(1)
                            redoByFrame[selectedFrame] = (redoByFrame[selectedFrame] ?: emptyList()) + items.last()
                        }
                    }) { Text("Undo") }
                    TextButton(onClick = {
                        val redoItems = redoByFrame[selectedFrame] ?: emptyList()
                        if (redoItems.isNotEmpty()) {
                            frames[selectedFrame] = currentStrokes + redoItems.last()
                            redoByFrame[selectedFrame] = redoItems.dropLast(1)
                        }
                    }) { Text("Redo") }
                }
            }

            Row(Modifier.weight(1f).fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Column(
                    Modifier.width(72.dp).fillMaxHeight().background(Color(0xFF292C31), RoundedCornerShape(10.dp)).padding(4.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    tools.forEach { tool ->
                        val selected = activeTool == tool
                        TextButton(
                            onClick = { activeTool = tool },
                            modifier = Modifier.fillMaxWidth().background(
                                if (selected) Color(0xFF444A53) else Color.Transparent,
                                RoundedCornerShape(7.dp)
                            )
                        ) {
                            Text(tool, color = if (selected) Color.White else Color(0xFFB8BDC6), fontSize = 10.sp)
                        }
                    }
                    Spacer(Modifier.height(6.dp))
                    Text("ONION", color = Color(0xFF9DA3AD), fontSize = 9.sp)
                    TextButton(onClick = { onionSkin = !onionSkin }) {
                        Text(if (onionSkin) "On" else "Off", color = if (onionSkin) Color(0xFFFFC36B) else Color.LightGray, fontSize = 10.sp)
                    }
                }

                Column(Modifier.weight(1f).fillMaxHeight()) {
                    Row(
                        Modifier.fillMaxWidth().height(36.dp).background(Color(0xFF292C31), RoundedCornerShape(topStart = 10.dp, topEnd = 10.dp)).padding(horizontal = 10.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text("Scene 01  •  Frame ${selectedFrame.toString().padStart(2, '0')}", color = Color(0xFFE5E7EB), fontSize = 12.sp)
                        Text("100%  ·  $activeTool", color = Color(0xFFB8BDC6), fontSize = 11.sp)
                    }
                    Canvas(
                        Modifier.weight(1f).fillMaxWidth().background(Color(0xFFF9F8F4)).pointerInput(activeTool, selectedFrame) {
                            detectDragGestures(
                                onDragStart = { point ->
                                    if (activeTool == "Pencil" || activeTool == "Eraser") draft = listOf(point)
                                },
                                onDrag = { change, _ ->
                                    if (activeTool == "Pencil" || activeTool == "Eraser") {
                                        draft = draft + change.position
                                        change.consume()
                                    }
                                },
                                onDragEnd = {
                                    if (draft.size > 1 && (activeTool == "Pencil" || activeTool == "Eraser")) {
                                        val stroke = InkStroke(
                                            points = draft,
                                            color = if (activeTool == "Eraser") Color(0xFFF9F8F4) else Color(0xFF17191D),
                                            width = if (activeTool == "Eraser") 24f else 5f
                                        )
                                        frames[selectedFrame] = (frames[selectedFrame] ?: emptyList()) + stroke
                                        redoByFrame[selectedFrame] = emptyList()
                                    }
                                    draft = emptyList()
                                }
                            )
                        }
                    ) {
                        val grid = 32f
                        for (x in 0..(size.width / grid).toInt()) {
                            drawLine(Color(0xFFEDEBE5), Offset(x * grid, 0f), Offset(x * grid, size.height), 0.6f)
                        }
                        for (y in 0..(size.height / grid).toInt()) {
                            drawLine(Color(0xFFEDEBE5), Offset(0f, y * grid), Offset(size.width, y * grid), 0.6f)
                        }

                        if (onionSkin && selectedFrame > 1) {
                            (frames[selectedFrame - 1] ?: emptyList()).forEach { stroke ->
                                drawStroke(stroke.copy(color = Color(0xFFDA6D6D).copy(alpha = 0.22f)))
                            }
                        }
                        currentStrokes.forEach { drawStroke(it) }
                        if (draft.size > 1) {
                            drawStroke(
                                InkStroke(
                                    draft,
                                    if (activeTool == "Eraser") Color(0xFFF9F8F4) else Color(0xFF17191D),
                                    if (activeTool == "Eraser") 24f else 5f
                                )
                            )
                        }
                    }
                }
            }

            Row(
                Modifier.fillMaxWidth().height(112.dp).padding(top = 8.dp).background(Color(0xFF292C31), RoundedCornerShape(10.dp)).padding(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(Modifier.width(76.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("TIMELINE", color = Color(0xFFB8BDC6), fontSize = 9.sp)
                    TextButton(onClick = {
                        val next = maxOf(1, frames.keys.maxOrNull() ?: 0) + 1
                        frames[next] = emptyList()
                        selectedFrame = next
                        playing = false
                    }) { Text("+ Frame", fontSize = 10.sp) }
                    TextButton(onClick = { playing = !playing }) {
                        Text(if (playing) "Pause" else "Play", fontSize = 10.sp)
                    }
                }
                Row(
                    Modifier.weight(1f).fillMaxHeight().horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    (1..maxFrame).forEach { frame ->
                        val selected = frame == selectedFrame
                        Column(
                            Modifier.width(54.dp).fillMaxHeight()
                                .border(if (selected) 2.dp else 1.dp, if (selected) Color(0xFFFFB84D) else Color(0xFF4A4E55), RoundedCornerShape(6.dp))
                                .background(if (selected) Color(0xFF41454D) else Color(0xFF353940), RoundedCornerShape(6.dp))
                                .padding(4.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(frame.toString().padStart(2, '0'), color = Color.White, fontSize = 10.sp)
                            Canvas(Modifier.size(24.dp)) {
                                drawRect(Color(0xFF777D87), style = Stroke(width = 1f))
                                if (!(frames[frame] ?: emptyList()).isEmpty()) {
                                    drawLine(Color(0xFFFFC36B), Offset(4f, size.height - 4f), Offset(size.width - 4f, 4f), 2f)
                                }
                            }
                            Text(if ((frames[frame] ?: emptyList()).isEmpty()) "Blank" else "Drawn", color = Color(0xFFB8BDC6), fontSize = 8.sp)
                        }
                        .pointerInput(frame) {
                            detectDragGestures(onDragStart = { selectedFrame = frame })
                        }
                    }
                }
            }
        }
    }
}

private fun androidx.compose.ui.graphics.drawscope.DrawScope.drawStroke(stroke: InkStroke) {
    if (stroke.points.isEmpty()) return
    val path = Path()
    stroke.points.forEachIndexed { index, point ->
        if (index == 0) path.moveTo(point.x, point.y) else path.lineTo(point.x, point.y)
    }
    drawPath(path, stroke.color, style = Stroke(width = stroke.width, cap = StrokeCap.Round))
}
