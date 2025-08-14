package main

import "core:math/rand"
import "core:time"
import rl "vendor:raylib"

WINDOW_WIDTH: i32 : 1280
WINDOW_HEIGHT: i32 : 720

TARGET_TPS :: 20
TICK_TIME_DIFF :: f64(1.0) / TARGET_TPS

CELL_SIZE: i32 : 10

GRID_WIDTH: i32 : WINDOW_WIDTH / CELL_SIZE
GRID_HEIGHT: i32 : WINDOW_HEIGHT / CELL_SIZE

grid := new([GRID_WIDTH * GRID_HEIGHT]bool)

last_mouse_pos := Vec2{0, 0}
mouse_pressed := false
time_of_next_tick := TICK_TIME_DIFF

Vec2 :: [2]i32

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Game of Life")
	defer rl.CloseWindow()

	for !rl.WindowShouldClose() {
		game_loop()
		draw()
	}
}

cell_idx :: proc(pos: Vec2) -> i32 {
	return pos.y * GRID_WIDTH + pos.x
}

mouse_pos :: proc() -> Vec2 {
	return Vec2{rl.GetMouseX() / CELL_SIZE, rl.GetMouseY() / CELL_SIZE}
}

place_cell_handle :: proc(value: bool) {
	mouse_pos := mouse_pos()
	mouse_pos.x = min(mouse_pos.x, GRID_WIDTH - 1)
	mouse_pos.y = min(mouse_pos.y, GRID_HEIGHT - 1)

	current_pos := last_mouse_pos if mouse_pressed else mouse_pos
	last_mouse_pos = mouse_pos

	for {
		grid[cell_idx(current_pos)] = value
		if current_pos == mouse_pos {
			break
		}

		diff_x := mouse_pos.x - current_pos.x
		diff_y := mouse_pos.y - current_pos.y

		if abs(diff_x) > abs(diff_y) {
			current_pos.x += diff_x / abs(diff_x)
		} else if abs(diff_x) == abs(diff_y) {
			current_pos.x += diff_x / abs(diff_x)
			current_pos.y += diff_y / abs(diff_y)
		} else {
			current_pos.y += diff_y / abs(diff_y)
		}
	}
}

count_neighbors :: proc(pos: Vec2) -> i32 {
	count: i32 = -i32(grid[cell_idx(pos)]) // reduce count by 1 when cell is alive
	for x in pos.x - 1 ..< pos.x + 2 {
		for y in pos.y - 1 ..< pos.y + 2 {
			px := x
			if px < 0 {px += GRID_WIDTH} else if px >= GRID_WIDTH {px -= GRID_WIDTH}

			py := y
			if py < 0 {py += GRID_HEIGHT} else if py >= GRID_HEIGHT {py -= GRID_HEIGHT}

			count += i32(grid[cell_idx({px, py})])
		}
	}
	return count
}

update_cells :: proc() {
	new_grid := new([GRID_WIDTH * GRID_HEIGHT]bool)

	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			switch count_neighbors({x, y}) {
			case 0 ..= 1, 4 ..= 8:
				new_grid[cell_idx({x, y})] = false
			case 2:
				new_grid[cell_idx({x, y})] = grid[cell_idx({x, y})]
			case 3:
				new_grid[cell_idx({x, y})] = true
			}
		}
	}

	free(grid)
	grid = new_grid
}

clear_board :: proc() {
	for i in 0 ..< len(grid) {
		grid[i] = false
	}
}

game_loop :: proc() {
	if rl.IsMouseButtonDown(.LEFT) {
		place_cell_handle(true)
		mouse_pressed = true
	} else if rl.IsMouseButtonDown(.RIGHT) {
		place_cell_handle(false)
		mouse_pressed = true
	} else {
		mouse_pressed = false
	}

	time.now()
	if rl.IsKeyDown(.C) {
		clear_board()
	}

	if !rl.IsKeyDown(.SPACE) {
		if rl.GetTime() > time_of_next_tick || rl.IsKeyDown(.RIGHT) {
			update_cells()
			time_of_next_tick = rl.GetTime() + TICK_TIME_DIFF
		}
	} else {
		time_of_next_tick = rl.GetTime() + TICK_TIME_DIFF
	}
}

draw :: proc() {
	rl.BeginDrawing()

	pixel_width := WINDOW_WIDTH / GRID_WIDTH
	pixel_height := WINDOW_HEIGHT / GRID_HEIGHT

	rl.ClearBackground(rl.BLACK)
	for x in 0 ..< GRID_WIDTH {
		for y in 0 ..< GRID_HEIGHT {
			if grid[cell_idx({x, y})] {
				rl.DrawRectangle(
					x * pixel_width,
					y * pixel_height,
					pixel_width,
					pixel_height,
					rl.WHITE,
				)
			}
		}
	}
	rl.EndDrawing()
}
