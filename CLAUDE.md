# 🤖 AI Assistant Rules for Roblox Project

You are an expert Roblox Lua/Luau software engineer. When generating, modifying, or reviewing code for this project, you MUST strictly adhere to the following architectural pillars, rules, and best practices. All of client return is purely with english language

## 🛑 AI Context & File Reading Constraints
- **IGNORE LARGE DIRECTORIES:** **DO NOT** read, scan, index, or analyze dependency folders such as `Packages`, `ServerPackages`, `Index`, or `node_modules`. These contain massive auto-generated Wally/npm packages. 
- Assume standard behaviors for the approved libraries (ProfileService, Trove, React-Luau, etc.) based on their official documentation. Only analyze the actual source code (`src/` or `lib/`) written by the developer.

---

## 🚫 0. THE PRIME DIRECTIVE: ANTI-MONOLITH (HARD CEILING)
* **Maximum Line Limit:** **STRICT 100-120 LINES PER FILE.** No exceptions.
* **Single Responsibility Only:** A file does ONE thing:
  * Markup is purely markup (`*View.luau`).
  * Logic is purely logic (`use*.luau`, `*Utils.luau`).
  * Configuration is purely data (`*Config.luau`).
* If any component or helper approaches the limit: **STOP AND DECOMPOSE INTO SUB-MODULES IMMEDIATELY.**
* **Package Quarantine:** **NEVER** scan, read, or index `Packages/`, `ServerPackages/`, or `Index/`.

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

## 🎨 6. Strict UI Architecture & Procedural 3D Styling System
### A. Mobile-First Responsive Breakpoint Philosophy
- **Viewport Agnostic First (Mobile Dominant):** All UI sizing and layouts must be designed and verified for narrow mobile viewports prior to adapting to tablet, console, or desktop displays.
- **Scale over Offset (with Strict Boundary Constraints):**
  - Use **Scale** for relative layout framing, paired strictly with `UIAspectRatioConstraint` to prevent geometric distortion across dynamic aspect ratios.
  - Use **Offset** exclusively for tactile bevel depth, shadow displacements, and pixel-crisp borders.
  - Apply **Conditional Device-Based Sizing** via device detection hooks (e.g., `local isMobile = useDeviceType().isMobile`) to tailor base dimensions contextually (e.g., `Size = if isMobile then UDim2.fromScale(0.5, 0.5) else UDim2.fromScale(0.75, 0.75)`), ensuring interactive tap targets preserve a minimum `44x44` px footprint on mobile.
- **Reactive Breakpoint Context Hook:**
  - Consume a centralized viewport observer (`useDeviceBreakpoint()` or `Camera:GetPropertyChangedSignal("ViewportSize")`) that emits distinct device tiers:
    * `Compact` (`ViewportSize.X < 700`)
    * `Medium` (`700 <= ViewportSize.X < 1100`)
    * `Expanded` (`ViewportSize.X >= 1100`)
  - Redundant local `ViewportSize` polling across individual components is strictly prohibited.

### B. Procedural 3D Bevel, Layer Hierarchy & Technical Art Pipeline
Static 9-slice raster/PNG assets for 3D buttons, progress bars, and modular panels are strictly prohibited. Construct tactile components procedurally via native engine sub-layering:

1. **Base / Shadow Layer (Bezel Datum):**
   - **Position & Sizing:** Anchored at the root level (`ZIndex = 1`), establishing the downward extrusion profile.
   - **Color Formulation:** Procedurally derived via mathematical lerping (`baseColor:Lerp(Color3.new(0, 0, 0), 0.35)`).
   - **Contour:** Matches parent geometry using a unified `UICorner` radius.
2. **Top Face Surface Layer (Interactive Plate):**
   - **Depth Elevation:** Displaced upward along the Y-axis (`Position = UDim2.new(0, 0, 0, -BezelDepthOffset)`, default `-4px` to `-6px`) to produce genuine visual depth.
   - **Color Tone:** Bound directly to the designated component theme token (`baseColor`).
   - **Border Outline:** Styled with a contrasting darker tone via `UIStroke` (`Thickness = 2-3px`, `ApplyStrokeMode = Border`).
3. **Glossy / Specular Overlay (Dynamic Optical Cap):**
   - **Strict Containment:** Must be parented inside the Top Face Surface Layer with `ClipsDescendants = true` to completely eliminate highlight bleeding outside rounded corners.
   - **Geometry:** Flush along the top boundary (`Position = UDim2.fromScale(0, 0)`), covering the upper portion of the surface (`Size = UDim2.new(1, 0, 0.45, 0)`).
   - **Optical Gradient:** Rendered using a linear white `UIGradient` (`Transparency = NumberSequence.new({0.20, 0.95})`, `Rotation = 90`) paired with matching `UICorner` to produce a crisp specular reflection.
4. **Draw-Call & Batching Integrity:**
   - Maintain uniform `ZIndex` stratification across sibling components to preserve Roblox UI batch rendering.
   - Never nest `CanvasGroup` within another `CanvasGroup` to prevent redundant texture memory allocation and GPU mipmap downscaling artifacts.

### C. Hover & Press Physics (Spring-Driven Animation)
- **Banned: TweenService for Input Transitions:** Linear or easing `TweenService` routines are strictly banned for hover, press, and release micro-interactions.
- **Spring Dynamics Modeling (Physics-Based Feedback):**
  - Implement dynamic transforms via second-order physical spring equations (`Frequency = 4.5`, `DampingRatio = 0.65`):
    * **Idle State:** Surface face rested at elevated default (`Y Offset = -6px`, `Scale = 1.0`).
    * **Hover State (Mouse Input):** Surface face springs upward (`Y Offset = -9px`, `Scale = 1.03`) with an optical gloss boost (`Transparency -0.1`).
    * **Pressed State (InputBegan):** Surface face depresses flush against the base datum (`Y Offset = -1px`, `Scale = 0.97`) to reproduce mechanical switch resistance.
    * **Release State (InputEnded):** Elastic recoil returning cleanly to Hover or Idle state without overshoot vibration.
- **Client-Side Authoritative Runtime:** All physical spring calculations, mouse tracking, and tap animations must execute entirely on the client thread with zero network latency.

### D. Declarative Theming & Component Decoupling
- **Procedural Palette Synthesis:** Hardcoded sub-colors are disallowed. A single input token generates all auxiliary states:
  * `ShadowColor = baseColor:Lerp(Color3.new(0, 0, 0), 0.35)`
  * `StrokeColor = baseColor:Lerp(Color3.new(0, 0, 0), 0.55)`
  * `HighlightColor = baseColor:Lerp(Color3.new(1, 1, 1), 0.20)`
- **Strict Prop Interface Definition:**
  * `Size: UDim2`
  * `AspectRatio: number?`
  * `BaseColor: Color3`
  * `BezelDepth: number?`
  * `Disabled: boolean?` (Triggers grayscale saturation drop and disconnects raycast/hit detection)
  * `OnActivated: () -> ()`
  * `Children: any?`
- **Architectural Separation of Concerns:**
  * UI components serve strictly as presentation layers (View Layer).
  * Direct invocations of `DataStoreService`, `RemoteFunction:InvokeServer()`, or game state mutators from within UI elements are strictly forbidden; all state changes must propagate through a decoupled dispatch layer.

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