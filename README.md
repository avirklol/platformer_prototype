# Dynamic NPC Platformer Prototype

This project is a 2D platformer that showcases several advanced systems designed to create a dynamic and immersive player experience. The prototype features a sophisticated audio system, a robust player character controller, and, most notably, NPCs powered by Large Language Models (LLMs) to enable dynamic, context-aware interactions.

## Key Features

### Sound Database and Sound-to-Tile Mapping

The game's audio landscape is managed by a dynamic sound database that recursively loads and catalogues sound assets from the project's file system. This system allows for a highly organized and scalable approach to managing audio resources. The sound-to-tile mapping feature enables the game to play specific sounds based on the type of tile the player is traversing, adding a layer of auditory feedback that enhances the sense of immersion.

### State Machine for Player Movement

The player character's movement is governed by a finite state machine (FSM). This architecture provides a robust and extensible framework for managing the player's various states, such as walking, running, jumping, and interacting with objects. The state machine ensures smooth transitions between different animations and actions, resulting in a fluid and intuitive control scheme.

Some movement in action:

![ledge climb, crawl, climb ladder, jump to platform](https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExdmNoZnNlMWkydHk4dXgxNHJpNTMzYm9qOHdxZHE0MTduc2Zzcno1eSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/HfUsBu0tVNOdKPm17x/giphy.gif)
![ledge climb, drop to ledge hang](https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExemNpbDFmMTNueGM0eWthaDdhdTV2anMwaXF2OHdreWw0ZzZ3MmxsZSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/YqJGoMvii94LTw8I6U/giphy.gif)
![wall jump to platform](https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExcDFhMTczdTlrbzlodG0xdHZiZ3Y1M2xwMXE0eWI1dWgwNm03dzNwZCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/yCSyTGtxhVZSmCuHIJ/giphy.gif)
![jump to wallslide, wall jump](https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExZ2dpZWwyanEwYWNqeGtmNzUwdTFtdWZld3Vsd2VrOTUyNnIxbml3MyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/8c7L34sNqj4gol2fOh/giphy.gif)

### LLM-Powered NPCs for Dynamic Interactions

The core of this prototype is its use of Large Language Models to create NPCs that are more than just static entities. These NPCs leverage LLMs to generate dialogue and reactions in real-time, resulting in conversations that are dynamic, context-aware, and unique to each player interaction.

Here are a series of interactions with a basic NPC that has been configured to detest the player:

![first npc interaction](https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExMHVua3J6bHl0MThiOW5kbmMwNjlhaWFmNGRmY3F2M3g4NjFqa2UzcCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/1wlozmYXfTin10WHpK/giphy.gif)
![second npc interaction](https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExZXA5NGxhZjNnZXJtdjJxcHN1NDUzc3FlazRwMjdlYmR0MmVqNmNwZiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/snzrVF1mYwJmvt8YG4/giphy.gif)
![third npc interaction](https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExdmxkcDNid3RicTN4M25wOXowbjJ3YnJtYm1jYTB1Y2oxN2xoODJpZyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/4taUjsDwgbzOM9hPkC/giphy.gif)
![fourth npc interaction](https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExZ2dpZWwyanEwYWNqeGtmNzUwdTFtdWZld3Vsd2VrOTUyNnIxbml3MyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/8c7L34sNqj4gol2fOh/giphy.gif)

#### Conversation Design and Architecture

The conversation system is designed to be highly modular and scalable, with a clear separation between the AI's "brain" and its "personality."

*   **Conversation Systems:** The `AIBrain` class governs how AI characters communicate, managing their internal state (memory, tone, persona) and external interactions (dialogue, storytelling).
*   **Scalable Prompt Frameworks:** The system uses a sophisticated prompt generation process that combines a base set of instructions with character-specific details, conversation history, and the player's relationship with the NPC. This allows for a balance of creative freedom and product consistency.
*   **Emotional Design Patterns:** The AI's responses are guided by a defined set of emotional design patterns, with the LLM generating not just dialogue but also the character's current mood and emotions.
*   **Multi-Turn Dialogue Systems:** The use of LLMs and orchestration tools allows for the prototyping and testing of multi-turn dialogue systems, with the ability to refine them through data and user feedback.
*   **Agentic Architectures:** The system is designed to be extended with more advanced agentic architectures, with the `AIBrain` class capable of managing long-term memory, relationships, and goals.

This project serves as a demonstration of how AI techniques can be integrated into game development to create more engaging and believable virtual worlds.
