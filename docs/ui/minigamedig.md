# ⛏️ UI Specification: Digging Minigame (`DigMinigame`)

Dokumen ini menjelaskan spesifikasi lengkap, struktur visual, aset Roblox, sistem responsif multi-device, kontrol Roact Refs, dan micro-animations untuk komponen **Digging Minigame UI**.

---

## 📌 Lokasi File Sumber
- **Komponen UI:** `src/client/Components/DigMinigame.luau`
- **Helper Animasi & Timer:** `src/client/Components/Common/DigMinigameHelper.luau`
- **Controller Lifecycle:** `src/client/Controllers/DigController.luau`

---

## 🖼️ Daftar ID Aset Roblox (Images / Textures)

| Nama Aset | Asset ID | Kegunaan |
| :--- | :--- | :--- |
| `OuterContainer` | `rbxassetid://77990043906183` | Bingkai luar kontainer progress bar (tebal & bertekstur) |
| `InnerProgressBar` | `rbxassetid://105807504905048` | Bar hijau glossy isi penuh |
| `Countdown` | `rbxassetid://126607445864603` | Kotak merah indikator waktu di kiri bawah |
| `TimerIcon` | `rbxassetid://109376754540674` | Ikon jam alarm kartun di samping kiri countdown |
| `Shovel` | `rbxassetid://83791111239909` | Ikon sekop penanda posisi progress penggalian |

---

## 🏗️ Hierarki Objek UI (Tree Structure)

```
ScreenGui (Name: "DigMinigameUI", DisplayOrder: 20, ResetOnSpawn: false)
 └── MainContainer (Frame)
      ├── UIAspectRatioConstraint (AspectRatio: 7.05, DominantAxis: Width)
      ├── UISizeConstraint (MinSize: 280x40, MaxSize: 540x76)
      │
      ├── OuterContainer (ImageButton - Bingkai Luar & Tombol Tap Alternatif)
      │    └── InnerSlotFrame (Frame - Area Klip Bar Dalam)
      │         │
      │         ├── ClipFrame (Frame - ClipsDescendants=true, Lebar Dinamis = Progress)
      │         │    └── InnerBarImage (ImageLabel - Bar Hijau Lebar Penuh)
      │         │         └── UIGradient (Dinamis: Memudar Lembut di Dekat Ujung Sekop)
      │         │
      │         ├── TapText (TextLabel - "TAP" Berdenyut Lembut di Tengah Bar)
      │         │    ├── UIStroke (Color: #000000, Thickness: 2.0)
      │         │    └── UIAspectRatioConstraint (AspectRatio: 2.5)
      │         │
      │         └── ShovelMarker (ImageLabel - Bergerak Mengikuti Progress + Bounce Hit)
      │              └── UIAspectRatioConstraint (AspectRatio: 1.0)
      │
      └── CountdownContainer (ImageLabel - Kotak Merah Waktu)
           ├── UIAspectRatioConstraint (AspectRatio: 3.8, DominantAxis: Height)
           │
           ├── TimerIcon (ImageLabel - Jam Alarm Animasi Getar Kiri-Kanan)
           │    └── UIAspectRatioConstraint (AspectRatio: 1.0)
           │
           └── TimerText (TextLabel - "15s" Angka Sisa Waktu)
                └── UIStroke (Color: #000000, Thickness: 2.5)
```

---

## 📐 Properti Detail Elemen

### 1. `MainContainer` (Root Wrapper)
| Properti | Nilai Desktop | Nilai Mobile | Keterangan |
| :--- | :--- | :--- | :--- |
| `AnchorPoint` | `Vector2.new(0.5, 0.5)` | `Vector2.new(0.5, 0.5)` | Titik tengah |
| `Position` | `UDim2.fromScale(0.5, 0.70)` | `UDim2.fromScale(0.5, 0.625)` | Disesuaikan agar tidak tertutup jempol di HP |
| `Size` | `UDim2.fromScale(0.65, 0.088)` | `UDim2.fromScale(0.65, 0.088)` | Skala responsif |
| `BackgroundTransparency` | `1` | `1` | Wadah tak terlihat |

- **`UIAspectRatioConstraint`**:
  - `AspectRatio`: `7.05`
  - `DominantAxis`: `Enum.DominantAxis.Width`
- **`UISizeConstraint`**:
  - `MinSize`: `Vector2.new(280, 40)` (Layar smartphone kecil)
  - `MaxSize`: `Vector2.new(540, 76)` (Layar monitor ultrawide)

---

### 2. `OuterContainer` (ImageButton Bingkai Luar)
- **`Image`**: `rbxassetid://77990043906183`
- **`ScaleType`**: `Enum.ScaleType.Stretch`
- **`Size`**: `UDim2.fromScale(1, 1)`
- **Event `[Roact.Event.Activated]`**: Memanggil `OnSwing()` jika pemain mengklik langsung pada bar.

---

### 3. `InnerSlotFrame` & `ClipFrame` (Sistem Bar Pemotong Presisi)
Agar bar hijau tidak gepeng saat memendek, digunakan teknik **Inverse Scaled Image Clipping**:
- **`InnerSlotFrame`**: `Size = UDim2.fromScale(0.938, 0.59)`, `Position = UDim2.fromScale(0.5, 0.5)`.
- **`ClipFrame`**:
  - `Size`: `UDim2.new(progress, 0, 1, 0)` di mana $\text{progress} = 1 - \frac{\text{CurrentHP}}{\text{MaxHP}}$.
  - `ClipsDescendants`: `true`
- **`InnerBarImage`**:
  - `Size`: `UDim2.new(1 / math.max(progress, 0.0001), 0, 1, 0)` (Mempertahankan aspect ratio gambar bar hijau asli).
  - `Image`: `rbxassetid://105807504905048`

---

### 4. `UIGradient` Fade Efek Lembut di Ujung Sekop
Bar hijau tidak terpotong kaku, melainkan memudar lembut tepat sebelum mata sekop:
```lua
function DigMinigameHelper.GetFadeTransparencySequence(progress: number, hpRatio: number): NumberSequence
    if progress <= 0.02 then
        return NumberSequence.new(1)
    end
    local fadeLength = math.min(0.06, progress * 0.3)
    local p1 = math.clamp(progress - fadeLength, 0, 0.995)
    local p2 = math.clamp(progress - (fadeLength * 0.5), p1 + 0.001, 0.997)
    local p3 = math.clamp(progress - (fadeLength * 0.15), p2 + 0.001, 0.999)
    local pEnd = math.clamp(progress, p3 + 0.001, 1.0)

    return NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),         -- 100% Opaque (Padat)
        NumberSequenceKeypoint.new(p1, 0),        -- Tetap padat hingga sebelum sekop
        NumberSequenceKeypoint.new(p2, 0.25),     -- Mulai memudar lembut
        NumberSequenceKeypoint.new(p3, 0.95),     -- 5% Opaque
        NumberSequenceKeypoint.new(pEnd, 1.0),    -- 0% Opaque (Habis di ujung sekop)
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
end
```

---

### 5. `TapText` (Teks Kartun "TAP")
- **`Text`**: `"TAP"`
- **`Font`**: `Enum.Font.LuckiestGuy`
- **`TextColor3`**: `Color3.fromRGB(255, 255, 255)`
- **`ZIndex`**: `4` (Di atas bar hijau, di bawah sekop marker)
- **`UIStroke`**: `Color = Color3.fromRGB(0, 0, 0)`, `Thickness = 2.0`.
- **Idle Breathing Animation**:
  - Membesar perlahan ke `UDim2.fromScale(0.38, 0.80)` (durasi `0.5s, Sine InOut`).
  - Mengecil perlahan ke `UDim2.fromScale(0.34, 0.72)` (durasi `0.5s, Sine InOut`).

---

### 6. `ShovelMarker` (Ikon Penanda Sekop Geser)
- **`Image`**: `rbxassetid://83791111239909`
- **`Position`**: `UDim2.new(progress, 0, 0.5, 0)` (Bergeser dari kiri $0$ ke kanan $1$).
- **`Size`**: `UDim2.fromScale(1, 2.5)`
- **`Rotation`**: `-10` derajat.
- **`ZIndex`**: `5`
- **Hit Impact Animation (Setiap Kali Layar Diklik & HP Berkurang)**:
  ```lua
  local hitPop = TweenService:Create(shovel, TweenInfo.new(0.08, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
      Size = UDim2.fromScale(1.2, 3.0),
      Rotation = -24,
  })
  local hitReset = TweenService:Create(shovel, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
      Size = UDim2.fromScale(1, 2.5),
      Rotation = -10,
  })
  ```

---

### 7. `CountdownContainer` & `TimerIcon` (Kotak Waktu & Alarm Getar)
- **`Position`**: `UDim2.fromScale(0, 1.575)`, `AnchorPoint = Vector2.new(0, 1)`.
- **`Size`**: `UDim2.fromScale(0.32, 0.58)`.
- **`Image`**: `rbxassetid://126607445864603` (Kotak merah bertuliskan countdown).
- **`TimerIcon` (`rbxassetid://109376754540674`) Ringing Shake Loop**:
  - Rotasi bergantian cepat: `0°` $\to$ `-16°` $\to$ `+16°` $\to$ `-12°` $\to$ `+12°` $\to$ `0°` (tiap step `0.06s Quad Out`), lalu jeda `0.55s`.
- **`TimerText`**: Format `string.format("%ds", remaining)`.

---

## ⚡ Interaksi Input: Free Screen Tap vs Tombol UI
Minigame mendukung pengetukan layar bebas di seluruh area viewport:
```lua
activeInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Abaikan jika pemain menyentuh elemen GUI interaktif lain (misal tombol Backpack/Shop)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        OnSwingClicked()
    end
end)
```
Setiap klik memicu `swingShovelRF:InvokeServer()`, memainkan ayunan sekop `1.3x`, dan mengupdate state bar secara real-time.
