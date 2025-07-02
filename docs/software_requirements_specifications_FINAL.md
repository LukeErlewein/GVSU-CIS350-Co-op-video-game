# Overview
This document is the software requirements document for Core Protocol Zero.
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
- **FR13**: Players shall be able to interact with dropped power cells to charge the core.
- **FR14**: When a player with the Fighter class picks up a dropped power cell, the power core shall charge up by 5%.
- **FR15**: Combat mechanics shall include attacking, taking damage, and dying.
- **FR16**: When a player's health is reduced to zero, the player character shall die.
- **FR17**: Players shall respawn by waiting 10 seconds after dying.
- **FR18**: Players shall respawn next to the main power core.

### 4. Player Mechanics
- **FR19**: There shall be two classes: Fighter and Ranger.
- **FR20**: The Fighter player shall shoot faster and deal less damage, the ranger shall shoot slower and deal more damage.
- **FR21**: The Fighter class shall have 4 abilities. Shotgun, Grenade, Freeze Grenade, and orbital strike.
- **FR22**: The Ranger class shall have 4 abilities. Piercing shot, Dash, Vortex Grenade, and Teleport.
- **FR23**: Abilites of the classes shall unlock every 25% of the cores charge.
- **FR24**: Players shall have a cooldown mechanic for using abilities.

### 5. Enemy Mechanics
- **FR25**: There shall be two types of enemies, a Grunt enemy and a Power Carrier enemy.
- **FR26**: The Power Carrier enemy shall drop power cells.
- **FR27**: Additional enemies shall spawn as time progresses.
- **FR28**: The Cell carrier enemy shall target the player and try to attack them.
- **FR29**: The Grunt enemy shall target the core and try and attack the core.

### 6. Game Rules
- **FR30**: The game shall support a tower defense gamemode.
- **FR31**: In order to win, the players shall charge the power core to 100%.
- **FR32**: The players shall lose if the power core's health is reduced to 0%.
- **FR33**: The game shall end and prompt the user to quit the game upon win or loss.
- **FR34**: The game shall have an approximate length of 5 minutes.

### 7. User Interface
- **FR35**: The HUD shall display the following:
    - Health of player
    - Health of core
    - Current core charge
    - Time elapsed since game started
    - Current abilities and their cooldowns
    - Direction of the core
- **FR36**: Players shall receive visual/audio feedback when picking up power cells or taking damage.
- **FR37**: The power core locator shall point to the power core even if it is off the screen.
- **FR38**: The Power core health and charge bars shall be centered in the top of the screen.
- **FR39**: The Abilities shall be in the lower right corner of the screen and only show the unlocked abilities.

---

# Non-Functional Requirements

### 1. Performance
- **NFR1**: The game shall maintain at least 60 FPS on target hardware.
- **NFR2**: Network latency shall be able to be handled by the players' systems.
- **NFR3**: Game loading time shall be under 10 seconds.
- **NFR4**: The game shall have frame pacing consistent with its tick/update loop.
- **NFR5**: The game shall take up no more than 500mb of a file size.

### 2. Usability
- **NFR6**: The game UI shall have contrast from the surrounding game spaces.
- **NFR7**: A tutorial shall be available on the main screen.
- **NFR8**: Controls and UI text shall be readable and properly scaled on different resolutions.
- **NFR9**: The game shall be used with a QUERTY style keyboard.
- **NFR10**: The player shall be able to launch the game with a .exe file.

### 3. Compatibility
- **NFR11**: The game shall be able to run on Windows.
- **NFR12**: Keyboard and mouse inputs shall be supported.
- **NFR13**: The game shall run on a screen resolution of 1080p.
- **NFR14**: The game shall support the English language.
- **NFR15**: The game shall require a internet connection.

### 4. Maintainability
- **NFR16**: Code shall be modular and documented to support future updates and patches.
- **NFR17**: A logging system shall track errors, player actions, and system events.
- **NFR18**: The game shall use version control for all source code and assets.
- **NFR19**: The game shall be coded in the godot language.
- **NFR20**: Assets used in the game shall be open source assets or created by AI.

# Hyperlinks to other files

- [Object Diagram](ObjectDiagram.png)
- [Communication Diagram](CommunicationDiagramGameplay.pdf)
- [Use Case Diagram](use_case_diagram/UseCaseDiagramV2.png)
- [Trello Board](https://trello.com/b/MpvpjLm7/co-op-video-game)
- [Project Github](https://github.com/LukeErlewein/GVSU-CIS350-Co-op-video-game)
- [Gannt Chart](GanntChartPDF.pdf)
- [Burndown Chart](BurndownChart.png)