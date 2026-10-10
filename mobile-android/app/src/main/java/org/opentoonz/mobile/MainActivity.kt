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

private data class InkStroke(val points: List<Offset>, val color: Color = Color(0xFF17191D), val width: Float = 5f)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { MaterialTheme { MobileEditor() } }
    }
}

@Composable
private fun MobileEditor() {
    var activeTool by remember { mutableStateOf("Pencil") }
    var strokes by remember { mutableStateOf(listOf<InkStroke>()) }
    var redo by remember { mutableStateOf(listOf<InkStroke>()) }
    var draft by remember { mutableStateOf(listOf<Offset>()) }
    var selectedFrame by remember { mutableIntStateOf(1) }
    var playing by remember { mutableStateOf(false) }
    val tools = listOf("Pencil", "Eraser", "Lasso", "Move", "Hand")

    Surface(Modifier.fillMaxSize(), color = Color(0xFF202226)) {
        Column(Modifier.fillMaxSize().padding(8.dp)) {
            Row(Modifier.fillMaxWidth().height(44.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {
                Text("ToonzTab", color = Color.White, fontSize = 16.sp)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    TextButton(onClick = { if (strokes.isNotEmpty()) { redo = redo + strokes.last(); strokes = strokes.dropLast(1) } }) { Text("Undo") }
                    TextButton(onClick = { if (redo.isNotEmpty()) { strokes = strokes + redo.last(); redo = redo.dropLast(1) } }) { Text("Redo") }
                }
            }
            Row(Modifier.weight(1f).fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Column(Modifier.width(66.dp).fillMaxHeight().background(Color(0xFF292C31), RoundedCornerShape(10.dp)).padding(4.dp), verticalArrangement = Arrangement.spacedBy(4.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    tools.forEach { tool ->
                        val selected = activeTool == tool
                        TextButton(onClick = { activeTool = tool }, modifier = Modifier.fillMaxWidth().background(if (selected) Color(0xFF444A53) else Color.Transparent, RoundedCornerShape(7.dp))) {
                            Text(tool, color = if (selected) Color.White else Color(0xFFB8BDC6), fontSize = 10.sp)
                        }
                    }
                }
                Column(Modifier.weight(1f).fillMaxHeight()) {
                    Row(Modifier.fillMaxWidth().height(36.dp).background(Color(0xFF292C31), RoundedCornerShape(topStart = 10.dp, topEnd = 10.dp)).padding(horizontal = 10.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Scene 01  •  Frame $selectedFrame", color = Color(0xFFE5E7EB), fontSize = 12.sp)
                        Text("100%  ·  $activeTool", color = Color(0xFFB8BDC6), fontSize = 11.sp)
                    }
                    Canvas(Modifier.weight(1f).fillMaxWidth().background(Color(0xFFF9F8F4)).pointerInput(activeTool, selectedFrame, strokes, draft) {
                        detectDragGestures(
                            onDragStart = { point -> if (activeTool == "Pencil" || activeTool == "Eraser") draft = listOf(point) },
                            onDrag = { change, _ ->
                                if (activeTool == "Pencil" || activeTool == "Eraser") {
                                    draft = draft + change.position
                                    change.consume()
                                }
                            },
                            onDragEnd = {
                                if (draft.size > 1) {
                                    strokes = strokes + InkStroke(draft, if (activeTool == "Eraser") Color(0xFFF9F8F4) else Color(0xFF17191D), if (activeTool == "Eraser") 24f else 5f)
                                    redo = emptyList()
                                }
                                draft = emptyList()
                            }
                        )
                    }) {
                        val grid = 32f
                        for (x in 0..(size.width / grid).toInt()) drawLine(Color(0xFFEDEBE5), Offset(x * grid, 0f), Offset(x * grid, size.height), 0.6f)
                        for (y in 0..(size.height / grid).toInt()) drawLine(Color(0xFFEDEBE5), Offset(0f, y * grid), Offset(size.width, y * grid), 0.6f)
                        (strokes + listOfNotNull(if (draft.size > 1) InkStroke(draft, if (activeTool == "Eraser") Color(0xFFF9F8F4) else Color(0xFF17191D), if (activeTool == "Eraser") 24f else 5f) else null)).forEach { stroke ->
                            val path = Path()
                            stroke.points.forEachIndexed { index, point -> if (index == 0) path.moveTo(point.x, point.y) else path.lineTo(point.x, point.y) }
                            drawPath(path, stroke.color, style = Stroke(width = stroke.width, cap = StrokeCap.Round))
                        }
                    }
                }
            }
            Row(Modifier.fillMaxWidth().height(112.dp).padding(top = 8.dp).background(Color(0xFF292C31), RoundedCornerShape(10.dp)).padding(8.dp), verticalAlignment = Alignment.CenterVertically) {
                Column(Modifier.width(66.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("TIMELINE", color = Color(0xFFB8BDC6), fontSize = 9.sp)
                    TextButton(onClick = { selectedFrame += 1 }) { Text("+ Frame", fontSize = 10.sp) }
                    TextButton(onClick = { playing = !playing }) { Text(if (playing) "Pause" else "Play", fontSize = 10.sp) }
                }
                Row(Modifier.weight(1f).fillMaxHeight().horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(6.dp), verticalAlignment = Alignment.CenterVertically) {
                    (1..maxOf(12, selectedFrame)).forEach { frame ->
                        Column(Modifier.width(54.dp).fillMaxHeight().border(if (frame == selectedFrame) 2.dp else 1.dp, if (frame == selectedFrame) Color(0xFFFFB84D) else Color(0xFF4A4E55), RoundedCornerShape(6.dp)).background(Color(0xFF353940), RoundedCornerShape(6.dp)).padding(4.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.SpaceBetween) {
                            Text(frame.toString().padStart(2, '0'), color = Color.White, fontSize = 10.sp)
                            Canvas(Modifier.size(24.dp)) { drawRect(Color(0xFF555B64), style = Stroke(width = 1f)) }
                            Text("1", color = Color(0xFFB8BDC6), fontSize = 9.sp)
                        }
                    }
                }
            }
        }
    }
}
