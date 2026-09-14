---
trigger: always_on
---

# 🤖 AI Assistant Rules for Roblox Project (GEMINI.md)

You are an expert Roblox Lua/Luau software engineer. When generating, modifying, or reviewing code for this project, you MUST strictly adhere to the following architectural pillars, rules, and best practices.

## 🛑 AI Context & File Reading Constraints
- **IGNORE LARGE DIRECTORIES:** **DO NOT** read, scan, index, or analyze dependency folders such as `Packages`, `ServerPackages`, `Index`, or `node_modules`. These contain massive auto-generated Wally/npm packages. 
- Assume standard behaviors for the approved libraries (ProfileService, Trove, React-Luau, etc.) based on their official documentation. Only analyze the actual source code (`src/` or `lib/`) written by the developer.

---

## 🏗️ 1. Core Architecture & Tech Stack
This project uses a modern Roblox toolchain (Rojo, Wally) with a strict layered architecture:
- **Language:** `--!strict` Luau is MANDATORY for all files.
- **Dependency Manager:** Wally (`ReplicatedStorage.Packages` / `ServerScriptService.ServerPackages`).
- **Approved Core Libraries:**
  - `ProfileService`: Server-side data persistence.
  - `Trove` / `Janitor`: Lifecycle and memory management.
  - `React-Luau` / `Fusion`: Declarative UI rendering.
  - `Reflex`: Immutable global state management.
  - `Blink` / `ByteNet`: High-performance buffer networking.
  - `Promise`: Asynchronous control flow.
  - `ZonePlus`: Spatial and volume detection.

## 🧼 2. Strict Clean Code & Modularization
Follow the **Controller-Service-Repository** pattern. Never mix network, business, and data logic.
- **Network/Controller (Client/Server):** Only handles `Blink` events, sanitizes inputs, and routes data to Services. NO game logic here.
- **Service (Server Logic):** Executes business logic (e.g., `CombatService`, `CraftingService`).
- **Repository (Data):** The ONLY layer allowed to mutate `ProfileService` data or fetch raw data.
- **Pure Functions:** Math, RNG (e.g., Loot tables), and validation formulas must be pure functions completely decoupled from Roblox Instances.

## 🧠 3. Immutable State & Data-Driven Design
- **Data-Driven Design (Configs):** NEVER hardcode values (prices, health, cooldowns, drop rates) inside functions. All balancing metrics must live in static tables under `ReplicatedStorage.Shared.Configs`.
- **Immutable State:** Use `Reflex` for global state (Inventory, Money, Ship Status). 
- **Unidirectional Data Flow:** UI listens to State. State is mutated via Actions/Dispatchers. Do not mutate state directly from the UI.

## 🎨 4. UI is ONLY for UI (Declarative & Reusable)
- **Declarative Approach:** Use `React-Luau` or `Fusion`. NEVER use procedural UI generation (`Instance.new("Frame")`) or manually mutate UI properties (`TextLabel.Text = ...`).
- **Reusable Components:** Break down UI into atomic, pure reusable components (e.g., `Button`, `ItemSlot`, `ProgressBar`). 
- **Separation of Concerns:** UI components must NOT contain game logic. They only receive `props` from Reflex selectors and render them.

## 🚀 5. Performance, Animation, & Anti-Memory Leak
- **Server is Blind:** The Server ONLY calculates math, validates rules, and updates State. The Server MUST NOT create visual parts, particle emitters, sounds, or tweens.
- **Client Animates:** All visual interpolations, `Spring` physics, camera shakes, and VFX must be handled 100% Client-side, triggered by State changes or lightweight network signals.
- **Zero Memory Leaks:** 
  - EVERY `RBXScriptConnection`, Thread, and dynamically created Instance MUST be tracked by `Trove`.
  - Use `Trove:Extend()` for temporary states (Equipped Tool, Combat, Zone Entry) and call `subTrove:Clean()` when the state ends.
  - NEVER use `:Remove()` or `Parent = nil`. Always use `:Destroy()`.

---

## 🚫 DON'TS (Strict Prohibitions)
1. **DO NOT** read or index `Packages` or `ServerPackages` directories to save context tokens.
2. **DO NOT** use `wait()` (Use `task.wait()` or `Promise`).
3. **DO NOT** use 60 FPS loops (`RunService.Heartbeat`) for polling conditions. Use Event-Driven architecture (Signals) or state changes.
4. **DO NOT** use deep OOP hierarchies (Inheritance). Favor Component-based architecture (Composition) and pure functions.
5. **DO NOT** pass full Instances (`Player.Character`) into calculation functions; pass only the required primitive data (`Vector3`, `number`).
6. **DO NOT** leave a Promise unhandled (always include `:catch()` or `onCancel`).

## ✅ DO'S (Enforced Practices)
1. **DO** use `export type` for all data structures, network payloads, and function signatures in a dedicated `Types` folder.
2. **DO** handle cleanup for disconnected players immediately by listening to `Players.PlayerRemoving` and calling `Profile:Release()`.
3. **DO** return explicit Result objects or Promises instead of silent `pcall` failures for complex operations (e.g., Crafting/Buying).