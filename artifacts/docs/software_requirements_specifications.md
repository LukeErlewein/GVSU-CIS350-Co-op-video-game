# Overview
This document is the software requirements document for the co-op video game.
# Functional Requirements

### 1. Main Menu
- **FR1**: There shall be a "Join" button.
- **FR2**: There shall be a "Host" button.
- **FR3**: There shall be a "Quit" button.
- **FR4**: When the player clicks the "Join" button, the game shall put the player in a waiting to join state.
- **FR5**: When the player clicks the "Host" button, the game shall put the player in a ready to host state.
- **FR6**: When the player clicks the "Quit" button, the game shall close.

### 2. Multiplayer and Networking
- **FR7**: The game shall support real-time multiplayer with 2 players per session.
- **FR8**: If there is a player in a waiting to join state and a player in a ready to host state, a game shall start.
- **FR9**: Players shall be able to host and join multiplayer game sessions.
- **FR10**: The game shall synchronize player movement, actions, and state across all clients.
- **FR11**: The player hosting will be the Fighter class. The player joining will be the Ranger class.

### 3. Gameplay Mechanics
- **FR12**: Players shall be able to move in 4 or 8 directions using keyboard keys.
- **FR13**: Players shall be able to interact with dropped power cells.
- **FR14**: When a player picks up a dropped power cell, the power core shall charge up by 1%.
- **FR15**: Combat mechanics shall include attacking, taking damage, and dying.
- **FR16**: When a player's health is reduced to zero, the player character shall die.
- **FR17**: Players shall respawn by waiting 10 seconds after dying.
- **FR18**: Players shall respawn next to the main power core.

### 4. Player Mechanics
- **FR19**: There shall be two classes: Fighter and Ranger.
- **FR20**: Each class shall have four unique abilities.
- **FR21**: Abilites of the classes shall unlock as the power core charges up.
- **FR22**: Players shall have a cooldown mechanic for using abilities.

### 5. Enemy Mechanics
- **FR23**: There shall be a variety of enemies for the player to fight.
- **FR24**: The Power Carrier enemy shall drop power cells.
- **FR25**: Additional enemies shall spawn as time progresses.
- **FR26**: Some enemies shall target both players and the power core based on proximity.

### 6. Game Rules
- **FR27**: The game shall support a normal gamemode.
- **FR28**: In order to win, the players shall charge the power core to 100%.
- **FR29**: The players shall lose if the power core's health is reduced to 0%.
- **FR30**: The game shall end and return to the main menu upon win or loss.

### 7. User Interface
- **FR31**: The HUD shall display the following:
    - Health of player
    - Health of core
    - Current core charge
    - Time elapsed since game started
    - Current abilities and their cooldowns
    - Direction of the core
- **FR32**: The pause menu shall provide options to resume or quit.
- **FR33**: Players shall receive visual/audio feedback when picking up power cells or taking damage.

---

# Non-Functional Requirements

### 1. Performance
- **NFR1**: The game shall maintain at least 60 FPS on target hardware.
- **NFR2**: Network latency shall be able to be handled by the players' systems.
- **NFR3**: Game loading time shall be under 10 seconds.
- **NFR4**: The game shall have frame pacing consistent with its tick/update loop.

### 2. Usability
- **NFR5**: The game UI shall be intuitive and easy to navigate for new users.
- **NFR6**: Tutorials shall be available to teach controls and gameplay.
- **NFR7**: Controls and UI text shall be readable and properly scaled on different resolutions.

### 3. Compatibility
- **NFR8**: The game shall be able to run on Windows and Linux.
- **NFR9**: Keyboard and mouse inputs shall be supported.
- **NFR10**: The game shall run on screen resolutions ranging from 720p to 4K.

### 4. Maintainability
- **NFR11**: Code shall be modular and documented to support future updates and patches.
- **NFR12**: A logging system shall track errors, player actions, and system events.
- **NFR13**: The game shall use version control for all source code and assets.

### 5. Localization
- **NFR14**: The game shall support the English language.