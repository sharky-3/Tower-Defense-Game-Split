@tool
extends Node2D
class_name CarouselContainer

@export var spacing: float = 20.0

@export var wraparound_enabled: bool = false
@export var wraparound_radius: float = 300.0
@export var wraparound_height: float = 50.0

@export_range(0.0, 1.0) var opacity_strength: float = 0.35
@export_range(0.0, 1.0) var scale_strength: float = 0.25
@export_range(0.01, 0.99, 0.01) var scale_min: float = 0.1

@export var smoothing_speed: float = 6.5
@export var selected_index: int = 0
@export var follow_button_focus: bool = false

@export var position_offset_node: Control

func _ready():
    var viewport_size = get_viewport_rect().size
    global_position = viewport_size * 0.5

func _process(delta: float) -> void:
    if position_offset_node == null:
        return

    var children := position_offset_node.get_children()
    if children.is_empty():
        return

    selected_index = clamp(selected_index, 0, children.size() - 1)

    for child in children:
        if not child is Control:
            continue

        var index := child.get_index()
        child.pivot_offset = child.size * 0.5

        # ---------------- POSITION ----------------
        var target_position: Vector2

        if wraparound_enabled:
            var max_range = max(1.0, (children.size() - 1) / 2.0)
            var angle = clamp(
                (index - selected_index) / max_range,
                -1.0,
                1.0
            ) * PI

            var x := sin(angle) * wraparound_radius
            var y := cos(angle) * wraparound_height

            target_position = Vector2(
                x - child.size.x * 0.5,
                y - wraparound_height - child.size.y * 0.5
            )
        else:
            var x := 0.0
            if index > 0:
                var prev := children[index - 1] as Control
                x = prev.position.x + prev.size.x + spacing

            target_position = Vector2(
                x,
                -child.size.y * 0.5
            )

        child.position = child.position.lerp(
            target_position,
            smoothing_speed * delta
        )

        # ---------------- SCALE ----------------
        var target_scale = 1.0 - scale_strength * abs(index - selected_index)
        target_scale = clamp(target_scale, scale_min, 1.0)

        child.scale = child.scale.lerp(
            Vector2.ONE * target_scale,
            smoothing_speed * delta
        )

        # ---------------- OPACITY ----------------
        var target_alpha = 1.0 - opacity_strength * abs(index - selected_index)
        target_alpha = clamp(target_alpha, 0.0, 1.0)

        var mod = child.modulate
        mod.a = lerp(mod.a, target_alpha, smoothing_speed * delta)
        child.modulate = mod

        # ---------------- Z-ORDER ----------------
        child.z_index = -abs(index - selected_index)
        if index == selected_index:
            child.z_index = 1

        # ---------------- FOCUS FOLLOW ----------------
        if follow_button_focus and child.has_focus():
            selected_index = index

    # ---------------- CONTAINER OFFSET ----------------
    if wraparound_enabled:
        position_offset_node.position.x = lerp(
            position_offset_node.position.x,
            0.0,
            smoothing_speed * delta
        )
    else:
        var selected := children[selected_index] as Control
        var target_x := -(selected.position.x + selected.size.x * 0.5)

        position_offset_node.position.x = lerp(
            position_offset_node.position.x,
            target_x,
            smoothing_speed * delta
        )


# ---------------- INPUT HELPERS ----------------
func move_left() -> void:
    selected_index = max(selected_index - 1, 0)


func move_right() -> void:
    if position_offset_node == null:
        return
    selected_index = min(
        selected_index + 1,
        position_offset_node.get_child_count() - 1
    )
