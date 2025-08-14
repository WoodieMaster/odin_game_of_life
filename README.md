# Game of Life in Odin
A simple implementation of [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) using Odin and raylib.

## Building / Running

To build and run the game, follow these steps:

1. Clone the repository:
   ```sh
   git clone https://github.com/WoodieMaster/odin_game_of_life.git
   ```

2. Navigate to the project directory:
   ```sh
   cd game_of_life
   ```

3. Build the game using Odin:
   ```sh
   odin build . -out:dist/game_of_life
   ```

4. Run the game:
   ```sh
   ./dist/game_of_life
   ```

Alternatively run the game using `odin run .`

## Controls
- `Left click` to place a cell, hold to draw
- `Right click` to remove a cell, hold to erase
- Press `C` to clear the grid
- Hold `Space` to pause the simulation
- Hold `Right Arrow` to simulate as fast as possible
