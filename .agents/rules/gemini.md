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

## 🎨 6. Strict UI Architecture & 3D Styling System

### A. Mobile-First Responsive Breakpoint Philosophy
- **Base Design on Mobile (Portrait & Landscape):** All UI sizing and layouts must be designed and verified for narrow mobile screens first.
- **Scale over Offset (with Constraints):**
  - Use **Scale** for relative container sizing, coupled with `UIAspectRatioConstraint` to prevent buttons, slots, and frames from stretching or distorting across varied aspect ratios.
  - Use `UISizeConstraint` to define `MinSize` (preventing text/buttons from becoming illegible or unclickable on phones) and `MaxSize` (preventing elements from ballooning on 1440p/4K PC displays).
- **Breakpoint Context Hook:** Implement a screen breakpoint provider (`useDeviceType()` or `useScreenBounds()`) that automatically shifts layout layouts when switching between Mobile (`CurrentCamera.ViewportSize.X < 700`) and Tablet/PC.

### B. Procedural 3D Bevel & Container Hierarchy
3D bevel buttons, progress bars, and containers must NOT rely on static 9-slice image assets. Instead, construct them via procedural declarative sub-layering:
1. **Base / Shadow Layer (Bottom):**
   - Color: Procedurally darkened base color (`Color3:Lerp(Color3.fromRGB(0, 0, 0), 0.35)`).
   - Shape: Matches the parent container using identical `UICorner` radius.
2. **Top Face Surface Layer (Interactive Element):**
   - Positioned above the shadow layer with a vertical offset (e.g., `-4px` to `-8px` or `-0.08 scale Y`) to establish genuine 3D visual depth.
   - Color: The designated primary theme color (e.g., Lime Green, Cyan, Purple).
3. **Glossy / Shine Overlay (Reflective Gradient):**
   - **Strict Containment & Clipping:** MUST be parented DIRECTLY inside the Top Face Surface Layer (or an inner clipped container). The parent layer MUST have `ClipsDescendants = true` so the shine NEVER overflows outside the border edges or rounded corners.
   - **Position & Sizing:** Positioned flush inside the top boundary (`Position = UDim2.fromScale(0.02, 0.04)` or `fromScale(0, 0)` with proper padding), occupying only the upper half of the face (`Size = UDim2.new(0.96, 0, 0.42, 0)`).
   - **Styling:** Styled with a transparent white `UIGradient` (`Transparency = NumberSequence.new({0.25, 0.9})`, `Rotation = 90`) and an inner `UICorner` to produce a tight, enclosed specular glass highlight without edge bleeding.
4. **Border Stroke Layer:**
   - Use `UIStroke` configured with a contrasting darker tone (`Thickness = 2-3px`, `ApplyStrokeMode = Border`) to deliver a sharp, stylized cartoon border.

### C. Hover & Press Physics (Spring-Driven Animation)
- **Zero TweenService for Hover/Press Interactions:** Do not use linear or rigid `TweenService` routines for cursor or touch feedback.
- **Spring-Driven Displacement (`Spring` library):**
  - **Idle State:** Surface face elevated (`Y Offset = -6px`).
  - **Hover State (PC):** Surface face springs upward (`Y Offset = -8px`) with micro-scaling (`1.03x`).
  - **Pressed State (Click/Touch):** Surface face depresses downward flush against the Shadow Layer (`Y Offset = -1px`) to replicate tactile mechanical button physics.
- **Client-Side Only:** All spring state simulations, hover transitions, and click bounces must execute entirely on the client with zero network invocation.

### D. Component Reusability & Pure Theming
- All 3D containers and buttons must be implemented as atomic, reusable components accepting dynamic props:
  - `baseColor: Color3` (Used to procedurally derive shadow, stroke, and highlight palettes via `:Lerp()`).
  - `size: UDim2`
  - `aspectRatio: number?`
  - `onActivated: () -> ()`
  - `children: any` (Text, Icon, ProgressBar fill, or item slot content).
- UI components must remain completely decoupled from game transactions: never query `DataStore` or invoke network events directly from within a UI component.

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