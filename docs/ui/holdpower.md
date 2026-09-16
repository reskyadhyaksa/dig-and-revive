# 🔋 UI Specification: Hold Power Bar (`HoldPowerBarGui`)

Dokumen ini menjelaskan spesifikasi lengkap, struktur visual, properti Roact/Roblox, dan formula matematika untuk komponen **Hold Power Bar UI** serta pop-up tier keberuntungan di atas kepala karakter.

---

## 📌 Lokasi File Sumber
- **Komponen UI:** `src/client/Components/HoldPowerBarGui.luau`
- **Controller:** `src/client/Controllers/HoldPowerController.luau`
- **Helper & Formula:** `src/shared/Common/PowerBarHelper.luau`

---

## 🎨 Gambaran & Desain Visual
- **Fungsi:** Menampilkan indikator osilasi kekuatan (charge power) saat pemain menahan klik/layar untuk menentukan *Luck Boost Multiplier* (1.0X s/d 2.5X).
- **Posisi:** Samping kanan karakter (Anchor `(0.5, 0.5)`, Position `(0.64, 0.44)`).
- **Style:** Kapsul vertikal *Glassmorphism Dark* berbingkai stroke putih tebal dengan fill bar gradasi multi-warna halus dari Merah (bawah) ke Hijau Neon (atas).

---

## 🏗️ Hierarki Objek UI (Tree Structure)

```
ScreenGui (Name: "HoldPowerBarUI", DisplayOrder: 15, ResetOnSpawn: false)
 └── PowerBarWrapper (Frame)
      ├── UIAspectRatioConstraint (AspectRatio: 0.364)
      │
      ├── MultiplierLabel (TextLabel - "1.0X" s/d "2.5X")
      │    └── UIStroke (Color: #000000, Thickness: 2)
      │
      ├── LuckBoostLabel (TextLabel - "LUCK BOOST")
      │    └── UIStroke (Color: #000000, Thickness: 1.5)
      │
      └── CapsuleContainer (Frame - Kapsul Luar Gelap Transparan)
           ├── UICorner (CornerRadius: UDim.new(1, 0))
           ├── UIStroke (Color: #FFFFFF, Thickness: 2.5, Mode: Border)
           │
           └── FillBar (Frame - Layer Warna Gradasi Penuh)
                ├── UICorner (CornerRadius: UDim.new(1, 0))
                └── ColorGradient (UIGradient - Vertikal Cutoff Dinamis)
```

---

## 📐 Properti Detail Setiap Elemen

### 1. `PowerBarWrapper` (Root Frame)
| Properti | Nilai Desktop | Nilai Mobile | Catatan |
| :--- | :--- | :--- | :--- |
| `AnchorPoint` | `Vector2.new(0.5, 0.5)` | `Vector2.new(0.5, 0.5)` | Titik tengah |
| `Position` | `UDim2.fromScale(0.64, 0.44)` | `UDim2.fromScale(0.64, 0.44)` | Sisi kanan tengah layar |
| `Size` | `UDim2.fromScale(0.06, 0.28)` | `UDim2.fromScale(0.10, 0.32)` | Disesuaikan perangkat |
| `BackgroundTransparency` | `1` | `1` | Transparan |

- **`UIAspectRatioConstraint`**:
  - `AspectRatio`: `0.364` (Proporsi lebar 80px : tinggi 220px).
  - `DominantAxis`: `Enum.DominantAxis.Height`.

---

### 2. `MultiplierLabel` (Teks Pengali Luck)
Menampilkan angka pengali keberuntungan secara real-time yang berubah warna dinamis sesuai progress saat ini.

| Properti | Nilai | Catatan |
| :--- | :--- | :--- |
| `AnchorPoint` | `Vector2.new(0.5, 1)` | Menempel di atas kapsul |
| `Position` | `UDim2.fromScale(0.5, 0.08)` | Tepat di atas batas atas kapsul |
| `Size` | `UDim2.fromScale(1.0, 0.12)` | Lebar penuh kontainer |
| `Font` | `Enum.Font.LuckiestGuy` | Tipografi kartun tebal |
| `Text` | Format `string.format("%.1fX", multiplier)` | Contoh: `"1.5X"`, `"2.5X"` |
| `TextColor3` | Dinamis via `PowerBarHelper.GetDynamicProgressColor(progress)` | Interpolasi warna aktif |
| `TextScaled` | `true` | Responsif terhadap ukuran layar |
| `ZIndex` | `5` | Di atas semua layer kapsul |

- **`UIStroke`**: `Color3.fromRGB(0, 0, 0)`, `Thickness = 2`.

---

### 3. `LuckBoostLabel` (Teks Vertikal Samping Kiri)
Teks keterangan vertikal `"LUCK BOOST"` yang diputar -90 derajat di sisi kiri kapsul.

| Properti | Nilai Desktop | Nilai Mobile |
| :--- | :--- | :--- |
| `AnchorPoint` | `Vector2.new(0.5, 0.5)` | `Vector2.new(0.5, 0.5)` |
| `Position` | `UDim2.fromScale(0.18, 0.67)` | `UDim2.fromScale(0.10, 0.69)` |
| `Size` | `UDim2.fromScale(2.0, 0.09)` | `UDim2.fromScale(2.0, 0.10)` |
| `Rotation` | `-90` | Orientasi vertikal tegak |
| `TextColor3` | `Color3.fromRGB(255, 255, 255)` | Putih bersih |
| `Font` | `Enum.Font.LuckiestGuy` | - |
| `TextScaled` | `true` | - |

- **`UIStroke`**: `Color3.fromRGB(0, 0, 0)`, `Thickness = 1.5`.

---

### 4. `CapsuleContainer` (Latar Belakang Kapsul)
Wadah gelap kapsul rounded dengan border stroke putih di luar.

| Properti | Nilai | Catatan |
| :--- | :--- | :--- |
| `AnchorPoint` | `Vector2.new(0.5, 0.5)` | - |
| `Position` | `UDim2.fromScale(0.5, 0.55)` | - |
| `Size` | `UDim2.fromScale(0.35, 0.82)` | Bentuk kapsul ramping tinggi |
| `BackgroundColor3` | `Color3.fromRGB(20, 25, 35)` | Dark Navy Slate |
| `BackgroundTransparency` | `0.5` | Efek kaca gelap tembus pandang |
| `ClipsDescendants` | `true` | Memotong konten berlebih |
| `ZIndex` | `2` | - |

- **`UICorner`**: `CornerRadius = UDim.new(1, 0)` (Membuat bentuk kapsul lonjong sempurna).
- **`UIStroke`**:
  - `Color`: `Color3.fromRGB(255, 255, 255)`
  - `Thickness`: `2.5`
  - `ApplyStrokeMode`: `Enum.ApplyStrokeMode.Border`

---

### 5. `FillBar` & `ColorGradient` (Pengisian Bar Berwarna)
Fill bar memenuhi wadah kapsul (`Size = UDim2.fromScale(1, 1)`), dan ketinggian pengisian diatur secara presisi menggunakan `UIGradient.Transparency` tanpa merusak sudut rounded kapsul.

#### A. Keypoint Warna Vertikal (`Rotation = 90`):
```lua
ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromHex("00FF44")), -- Atas (100%): Perfect (Emerald Neon Green)
    ColorSequenceKeypoint.new(0.25, Color3.fromHex("68FF00")), -- 75%: Amazing (Vibrant Lime)
    ColorSequenceKeypoint.new(0.50, Color3.fromHex("FFEA00")), -- 50%: Great (Golden Yellow)
    ColorSequenceKeypoint.new(0.75, Color3.fromHex("FF6D00")), -- 25%: Nice (Amber Orange)
    ColorSequenceKeypoint.new(1.00, Color3.fromHex("E51B24")), -- Bawah (0%): Bad (Deep Red)
})
```

#### B. Dynamic Transparency Cutoff:
```lua
function PowerBarHelper.GetProgressTransparency(progress: number): NumberSequence
    local p = math.clamp(progress, 0, 1)
    if p <= 0.001 then
        return NumberSequence.new(1.0)
    elseif p >= 0.999 then
        return NumberSequence.new(0.0)
    else
        local cutoff = math.clamp(1 - p, 0.002, 0.998)
        return NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 1.0),
            NumberSequenceKeypoint.new(cutoff - 0.001, 1.0),
            NumberSequenceKeypoint.new(cutoff, 0.0),
            NumberSequenceKeypoint.new(1.0, 0.0),
        })
    end
end
```

---

## 🏆 Pop-up Tier di Atas Kepala (`LuckTierPopup`)

Ketika tombol hold dilepas (`ReleaseHold`), jika progress >= 20% dan tanah valid untuk digali, munculkan `BillboardGui` di atas kepala karakter.

### Struktur Instance
```lua
local billboard = Instance.new("BillboardGui")
billboard.Name = "LuckTierPopup"
billboard.Adornee = head
billboard.Size = UDim2.new(4.5, 0, 1.4, 0)
billboard.StudsOffset = Vector3.new(0, 4.0, 0)
billboard.AlwaysOnTop = true
billboard.LightInfluence = 0

local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(0.3, 0.3)
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.Position = UDim2.fromScale(0.5, 0.5)
label.BackgroundTransparency = 1
label.Text = tierText -- Contoh: "PERFECT!"
label.TextColor3 = tierColor
label.Font = Enum.Font.LuckiestGuy
label.TextScaled = true
label.Parent = billboard

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 0, 0)
stroke.Thickness = 3
stroke.Parent = label
```

### Animasi Tween Pop & Float:
1. **Pop-In (0.25 Detik):** `label.Size` dari `UDim2.fromScale(0.3, 0.3)` $\to$ `UDim2.fromScale(1.0, 1.0)` dengan `EasingStyle.Back, EasingDirection.Out`.
2. **Hold (0.4 Detik):** Jeda sejenak agar teks terbaca jelas.
3. **Float & Fade Out (0.7 Detik):** `billboard.StudsOffset` naik ke `Vector3.new(0, 5.6, 0)`, `label.TextTransparency` $\to$ `1`, `stroke.Transparency` $\to$ `1` (`EasingStyle.Quad, EasingDirection.Out`), lalu objek di-`Destroy()`.
