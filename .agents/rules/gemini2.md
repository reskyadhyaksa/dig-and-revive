---
trigger: always_on
---

# ⚡ PROTOCOL: ROBLOX ENGINE ARCHITECTURE (GEMINI.md)

> **Role:** Elite Luau Software Engineer.  
> **Directive:** Strict Separation of Concerns, Zero Memory Leaks, Modular Architecture, Ultra-Clean Codebase.

---

## 🚫 0. THE PRIME DIRECTIVE: ANTI-MONOLITH (HARD CEILING)
* **Maximum Line Limit:** **STRICT 100-120 LINES PER FILE.** No exceptions.
* **Single Responsibility Only:** A file does ONE thing:
  * Markup is purely markup (`*View.luau`).
  * Logic is purely logic (`use*.luau`, `*Utils.luau`).
  * Configuration is purely data (`*Config.luau`).
* If any component or helper approaches the limit: **STOP AND DECOMPOSE INTO SUB-MODULES IMMEDIATELY.**
* **Package Quarantine:** **NEVER** scan, read, or index `Packages/`, `ServerPackages/`, or `Index/`.

---

## 🧱 1. CORE STACK
* **Language:** `--!strict` Luau everywhere.
* **Toolchain:** Rojo + Wally (`Packages` & `ServerPackages`).
* **Approved Standard Stack:**
  * **Persistence:** `ProfileService` (Strictly server-side).
  * **Lifecycle:** `Trove` (Universal garbage & connection cleanup).
  * **UI Engine:** `React-Luau` + `ReactRoblox`.
  * **Global State:** `Reflex` (Unidirectional immutable state).
  * **Networking:** `Blink` or `ByteNet` (High-efficiency buffer remotes).
  * **Spatial / Motion:** `ZonePlus` (Area detection) + `Spring` (Procedural physics).
  * **Async:** `Promise` (Zero unhandled rejections).

---

## 🏛️ 2. BACKEND LAYERED ARCHITECTURE
Strictly implement the **Controller-Service-Repository** pattern:
* **Network/Controller (`*Controller.luau`):** Validates and sanitizes Blink network payloads. Passes clean primitives to Services. **No gameplay rules.**
* **Domain Service (`*Service.luau`):** Processes transactional gameplay rules (Crafting, Combat, Loot, Sailing).
* **Data Repository (`*Repository.luau`):** The **ONLY** layer authorized to mutate or fetch `ProfileService` session states.
* **Pure Math/RNG (`*Utils.luau`):** Decouple formulas and drop-tables entirely from Roblox Instances for deterministic testing.
* **Client Barrier:** `src/client` MUST NEVER require modules from `src/server` or `ServerScriptService`.
* **Data-Driven (Configs):** Zero hardcoded variables. Store balancing values inside `table.freeze()` tables under `Shared/Configs/`.

---

## 🎨 3. PURE DECLARATIVE UI PIPELINE

### Directory Standard (Strict View-Hook Pattern)
Every UI feature screen must follow this modular structure:
```text
features/[feature_name]/
├── components/          # Micro atomic presentational components (<60 lines)
│   ├── [Item]Slot.luau
│   └── Header.luau
├── hooks/               # State, Reflex selectors, sound triggers, actions
│   └── use[Feature].luau
├── [Feature]View.luau   # Pure visual assembler (Dumb View only)
└── init.luau            # Container orchestrator (<40 lines)