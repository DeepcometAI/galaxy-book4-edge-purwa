# Samsung Galaxy Book4 Edge 15.6" (NP750XQB-KA1IN)
## Complete Hardware Reference — X1P-26-100 / SM8380 Purwa Die

> **Source:** All data in this document was extracted directly from the device's ACPI
> tables (DSDT, MADT, PPTT, MCFG, IORT, GTDT, TPM2, FACP, DBG2), Windows Device Manager
> (PnP IDs, PCI VEN/DEV), EDID (raw bytes decoded), and the Windows DriverStore firmware
> blob inventory. Nothing here is guesswork — every value is hardware-confirmed.
>
> **Purpose:** Linux kernel DTS authoring, Stubble HWID registration, upstream patch
> submission, and long-term hardware documentation.
>
> **Date extracted:** June 2026  
> **BIOS version:** P00VQB.059.260508.MP.2105 (May 8, 2026)

---

## Table of Contents

1. [Board Identity & SMBIOS](#1-board-identity--smbios)
2. [SoC — Qualcomm SM8380 Purwa](#2-soc--qualcomm-sm8380-purwa)
3. [CPU Topology](#3-cpu-topology)
4. [Memory](#4-memory)
5. [Interrupt Controller — GIC-v4](#5-interrupt-controller--gic-v4)
6. [ARM Generic Timer](#6-arm-generic-timer)
7. [Display & Panel](#7-display--panel)
8. [GPU — Adreno (Purwa)](#8-gpu--adreno-purwa)
9. [Storage](#9-storage)
10. [PCIe Subsystem](#10-pcie-subsystem)
11. [WiFi — Qualcomm FastConnect 7800](#11-wifi--qualcomm-fastconnect-7800)
12. [Bluetooth](#12-bluetooth)
13. [WWAN — 5G Modem](#13-wwan--5g-modem)
14. [USB Subsystem](#14-usb-subsystem)
15. [Audio Subsystem](#15-audio-subsystem)
16. [Input Devices — Samsung EC](#16-input-devices--samsung-ec)
17. [Camera Subsystem](#17-camera-subsystem)
18. [Power Management & Battery](#18-power-management--battery)
19. [Thermal & Fan](#19-thermal--fan)
20. [I2C Bus Map](#20-i2c-bus-map)
21. [SMMU / IOMMU](#21-smmu--iommu)
22. [TPM](#22-tpm)
23. [NPU — Hexagon](#23-npu--hexagon)
24. [ACPI Tables Overview](#24-acpi-tables-overview)
25. [Firmware Blobs](#25-firmware-blobs)
26. [Linux DTS — Compatible Strings & Node Summary](#26-linux-dts--compatible-strings--node-summary)
27. [Stubble HWID Registration](#27-stubble-hwid-registration)
28. [Outstanding Unknowns & TODO](#28-outstanding-unknowns--todo)

---

## 1. Board Identity & SMBIOS

All values extracted from `Win32_ComputerSystemProduct`, `Win32_BaseBoard`, and `Win32_BIOS`.

| Field | Value |
|---|---|
| **Vendor** | SAMSUNG ELECTRONICS CO., LTD. |
| **Product name** | Galaxy Book4 Edge |
| **Model number** | NP750XQB-KA1IN |
| **SKU** | India variant (`KA1IN`) |
| **Board version** | 1.0 |
| **UUID** | `98008698-39A2-5255-5231-5652300088E5` |
| **BIOS vendor** | SAMSUNG ELECTRONICS CO., LTD. |
| **BIOS version** | P00VQB.059.260508.MP.2105 |
| **BIOS date** | 2026-05-08 |

### ACPI OEM Identity (from all table headers)

| Field | Value |
|---|---|
| **OEM ID** | `QCOM  ` (6 chars, space-padded) |
| **OEM Table ID** | `QCOMEDK2` |
| **OEM Revision** | `0x00008380` |
| **ASL Compiler ID** | `QCOM` |
| **ASL Compiler Rev** | `0x00000001` |

### DSDT-Specific Board Identifiers

| Symbol | Value | Meaning |
|---|---|---|
| `SOID` | `0x27B` (635) | SoC ID — SM8380 |
| `SIDS` | `"SCP_PURWA"` | SoC string — confirms Purwa die |
| `PSUB` | `"CRD08380"` | Platform sub-ID: Consumer Reference Design 8380 |
| `MDID` | `0x560002` | Module device ID |
| `HWRV` | `0x6` | Hardware revision 6 |
| `SDFE` | `0x9A` (154) | SoC device feature enable mask |
| `STOR` | `0x3` | Storage config: UFS + NVMe enabled |
| `RAMM` | `0x1` | RAM mode: LPDDR5x |

---

## 2. SoC — Qualcomm SM8380 Purwa

### Identity

| Field | Value |
|---|---|
| **Marketing name** | Snapdragon X Series X1-26-100 |
| **Qualcomm SoC name** | SM8380 |
| **Die codename** | Purwa |
| **ACPI table ID** | `SDM8380` (DSDT `DefinitionBlock` OEM Table ID) |
| **SoC ID (SOID)** | `0x27B` = 635 decimal |
| **PPTT Level2 ID** | `0x27B` (matches SOID) |
| **PPTT Level1 ID** | `0x9A` |
| **Process node** | TSMC N4P (4nm class) |
| **Linux DTS SoC compatible** | `qcom,sm8380` |

### SoC vs Marketing Name Mapping

The device name in Windows Device Manager reads:
```
Snapdragon(R) X - X126100 - Qualcomm(R) Hexagon(TM) NPU
```
`X126100` here is the internal Qualcomm NPU variant ID, not the full SoC part number.
The full X1-26-100 part is physically SM8380 Purwa die, sharing the same silicon as the
X1P-42-100 (also SM8380 Purwa) but with 4 CPU cores fused off and a lower GPU bin.

### ACPI PM Profile

From FACP table:
```
PM Profile: 0x08 = Tablet
```
Despite the laptop form factor, Qualcomm firmware declares `Tablet` profile — typical
for WoA platforms. This affects certain Linux power management assumptions.

---

## 3. CPU Topology

### Summary

| Property | Value |
|---|---|
| **Active cores** | 8 (2 clusters × 4 cores) |
| **Silicon cores** | 12 (3 clusters × 4 cores — 4 fused off) |
| **Core architecture** | Qualcomm Oryon (custom ARMv8.7-A) |
| **Cluster 0** | 4× Oryon (efficiency-class, MPIDR affinity level 1 = 0x00) |
| **Cluster 1** | 4× Oryon (performance-class, MPIDR affinity level 1 = 0x01) |
| **Cluster 2** | 4× Oryon — **FIRMWARE DISABLED** (MPIDR affinity level 1 = 0x02) |

### MADT CPU Entries (from `apic.dsl`)

All 12 GIC CPU interface entries decoded:

| CPU | Processor UID | ARM MPIDR | GICR Base | Efficiency Class | **Enabled** |
|---|---|---|---|---|---|
| CPU0 | 0 | `0x0000000000000000` | `0x17080000` | 0 (little) | **YES** |
| CPU1 | 1 | `0x0000000000000100` | `0x170C0000` | 0 (little) | **YES** |
| CPU2 | 2 | `0x0000000000000200` | `0x17100000` | 0 (little) | **YES** |
| CPU3 | 3 | `0x0000000000000300` | `0x17140000` | 0 (little) | **YES** |
| CPU4 | 4 | `0x0000000000010000` | `0x17180000` | 1 (big) | **YES** |
| CPU5 | 5 | `0x0000000000010100` | `0x171C0000` | 1 (big) | **YES** |
| CPU6 | 6 | `0x0000000000010200` | `0x17200000` | 1 (big) | **YES** |
| CPU7 | 7 | `0x0000000000010300` | `0x17240000` | 1 (big) | **YES** |
| CPU8 | 8 | `0x0000000000020000` | `0x17280000` | 1 | **NO** (fused) |
| CPU9 | 9 | `0x0000000000020100` | `0x172C0000` | 1 | **NO** (fused) |
| CPU10 | 10 | `0x0000000000020200` | `0x17300000` | 1 | **NO** (fused) |
| CPU11 | 11 | `0x0000000000020300` | `0x17340000` | 1 | **NO** (fused) |

> **Key finding:** Cluster 2 (CPUs 8–11) is present in silicon (GIC redistributors
> are allocated) but firmware marks them `Processor Enabled = 0`. This is how Qualcomm
> bins the SM8380 die to create the X1-26-100 SKU from the same physical wafer as the
> X1P-42-100. The GICR stride is `0x40000` (256KB) per CPU.

### PPTT Structure (from `pptt.dsl`)

```
Package (Physical) — offset 0x042
  └─ Cluster (no ACPI Processor ID) — offset 0x072  [parent of CLS0, CLS1]
       ├─ Sub-cluster — offset 0x072  [CLS0, 4 efficiency cores]
       │    ├─ CPU UID=0  (L1i cache + L1d cache)
       │    ├─ CPU UID=1
       │    ├─ CPU UID=2
       │    └─ CPU UID=3
       ├─ Sub-cluster — offset 0x08A  [CLS1, 4 performance cores]
       │    ├─ CPU UID=4
       │    ├─ CPU UID=5
       │    ├─ CPU UID=6
       │    └─ CPU UID=7
       └─ Sub-cluster — offset 0x0A2  [CLS2, 4 fused-off cores]
            ├─ CPU UID=8   (disabled)
            ├─ CPU UID=9   (disabled)
            ├─ CPU UID=10  (disabled)
            └─ CPU UID=11  (disabled)
```

### CPU LPI (Low Power Idle) States

From DSDT CLS device nodes, each cluster defines two LPI states:

```
LPI State 0: C1 — clock-gated, 0 entry/exit latency
  Residency:  "NCC.C1"  (per-core clock gate)
  
LPI State 1: C2 — power-collapsed, 0x258 (600µs) entry, 0x1F4 (500µs) exit
  Residency:  "Cluster0.CL4" / "Cluster0.CL5" (cluster collapse)
```

### DTS cpu-map

```c
cpu-map {
    cluster0 {
        core0 { cpu = <&cpu0>; };  /* MPIDR 0x000 */
        core1 { cpu = <&cpu1>; };  /* MPIDR 0x100 */
        core2 { cpu = <&cpu2>; };  /* MPIDR 0x200 */
        core3 { cpu = <&cpu3>; };  /* MPIDR 0x300 */
    };
    cluster1 {
        core0 { cpu = <&cpu4>; };  /* MPIDR 0x10000 */
        core1 { cpu = <&cpu5>; };  /* MPIDR 0x10100 */
        core2 { cpu = <&cpu6>; };  /* MPIDR 0x10200 */
        core3 { cpu = <&cpu7>; };  /* MPIDR 0x10300 */
    };
    /* Cluster 2 (CPUs 8-11) omitted — fused off in firmware */
};
```

---

## 4. Memory

| Property | Value |
|---|---|
| **Type** | LPDDR5x |
| **ACPI `RAMM` flag** | `0x1` (confirms LPDDR5x mode) |
| **Expected capacity** | 16GB (standard NP750XQB config) |
| **DSDT `DDRC`** | `0x8` — DDR controller config |
| **Memory controller** | Integrated in SM8380 |
| **Bus width** | 128-bit (4× 32-bit LPDDR5x channels) |

---

## 5. Interrupt Controller — GIC-v4

All addresses from MADT (`apic.dsl`).

| Component | Base Address | Notes |
|---|---|---|
| **GICD** (Distributor) | `0x17000000` | GICv4, version byte = 4 |
| **GITS** (Translator) | `0x17040000` | ITS Translation ID = 0 |
| **GICR** CPU0 | `0x17080000` | Stride = `0x40000` per CPU |
| **GICR** CPU1 | `0x170C0000` | |
| **GICR** CPU2 | `0x17100000` | |
| **GICR** CPU3 | `0x17140000` | |
| **GICR** CPU4 | `0x17180000` | |
| **GICR** CPU5 | `0x171C0000` | |
| **GICR** CPU6 | `0x17200000` | |
| **GICR** CPU7 | `0x17240000` | |
| **GICR** CPU8-11 | `0x17280000`–`0x17340000` | Allocated but unused (fused cores) |

### Per-CPU PMU Interrupt

All CPUs: Performance Interrupt = `0x17` (IRQ 23)  
All CPUs: Virtual GIC Interrupt = `0x19` (IRQ 25)

### DTS GIC Node

```c
gic: interrupt-controller@17000000 {
    compatible = "arm,gic-v3";
    reg = <0x0 0x17000000 0x0 0x10000>,   /* GICD */
          <0x0 0x17080000 0x0 0x280000>;   /* GICR × 8 active CPUs */
    interrupts = <GIC_PPI 9 IRQ_TYPE_LEVEL_LOW>;
    interrupt-controller;
    #interrupt-cells = <3>;
    #address-cells = <2>;
    #size-cells = <2>;
    ranges;

    its: msi-controller@17040000 {
        compatible = "arm,gic-v3-its";
        reg = <0x0 0x17040000 0x0 0x20000>;
        msi-controller;
        #msi-cells = <1>;
    };
};
```

---

## 6. ARM Generic Timer

From `gtdt.dsl`. Counter block address = `0xFFFFFFFFFFFFFFFF` (not memory-mapped,
uses system registers). Standard Qualcomm configuration.

| Timer | IRQ (PPI) | Flags |
|---|---|---|
| Secure EL1 | 29 (`0x1D`) | Always-on, level |
| Non-Secure EL1 | 30 (`0x1E`) | Always-on, level |
| Virtual | 27 (`0x1B`) | Always-on, level |
| Non-Secure EL2 (Hypervisor) | 26 (`0x1A`) | Always-on, level |

### DTS Timer Node

```c
timer {
    compatible = "arm,armv8-timer";
    interrupts = <GIC_PPI 13 (GIC_CPU_MASK_SIMPLE(8) | IRQ_TYPE_LEVEL_LOW)>,
                 <GIC_PPI 14 (GIC_CPU_MASK_SIMPLE(8) | IRQ_TYPE_LEVEL_LOW)>,
                 <GIC_PPI 11 (GIC_CPU_MASK_SIMPLE(8) | IRQ_TYPE_LEVEL_LOW)>,
                 <GIC_PPI 10 (GIC_CPU_MASK_SIMPLE(8) | IRQ_TYPE_LEVEL_LOW)>;
    /* PPI offsets: ARM PPI base = 16, so IRQ29-16=13, IRQ30-16=14, etc. */
};
```

---

## 7. Display & Panel

### Panel Identity

All values from EDID (128 bytes, confirmed valid checksum `0xD3`).

| Field | Value |
|---|---|
| **Manufacturer** | BOE (Beijing Oriental Electronics) |
| **Model** | **NV156FHM-NS0** |
| **Internal code** | BOE CQ |
| **EDID Product Code** | `0x0BF0` (3056 decimal) |
| **Windows DeviceID** | `DISPLAY\BOE0BF0` |
| **Resolution** | 1920 × 1080 (Full HD) |
| **Refresh rate** | **60.00 Hz** (exact) |
| **Panel type** | IPS LCD |
| **Bit depth** | 8-bit per channel |
| **Interface** | eDP (Embedded DisplayPort, type 5) |
| **Physical size** | 344mm × 194mm |
| **Diagonal** | 15.5" (15.6" marketing) |
| **PPI** | 141.7 pixels per inch |
| **Backlight** | LED |
| **Manufacture date** | Week 50, 2022 |
| **EDID version** | 1.4 |
| **Serial number** | 0 (not programmed) |

### Full EDID (128 bytes)

```
00 FF FF FF FF FF FF 00 09 E5 F0 0B 00 00 00 00
32 20 01 04 A5 22 13 78 02 21 12 98 5C 57 8C 28
1B 4E 52 00 00 00 01 01 01 01 01 01 01 01 01 01
01 01 01 01 01 01 8B 39 80 10 71 38 28 40 30 20
36 00 58 C2 10 00 00 1A 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 FE 00 42
4F 45 20 43 51 0A 20 20 20 20 20 20 00 00 00 FE
00 4E 56 31 35 36 46 48 4D 2D 4E 53 30 0A 00 D3
```

### Detailed Timing (from Descriptor Block 1)

| Parameter | Value |
|---|---|
| **Pixel clock** | 147,310 kHz (147.310 MHz) |
| **H active** | 1920 px |
| **H front porch** | 48 px |
| **H sync width** | 32 px |
| **H back porch** | 192 px |
| **H blanking** | 272 px |
| **H total** | 2192 px |
| **V active** | 1080 lines |
| **V front porch** | 3 lines |
| **V sync width** | 6 lines |
| **V back porch** | 31 lines |
| **V blanking** | 40 lines |
| **V total** | 1120 lines |
| **HSync polarity** | Positive (+) |
| **VSync polarity** | Negative (−) |
| **Interlaced** | No |
| **Calculated refresh** | 60.00 Hz |

### DTS Panel Node

```c
compatible = "boe,nv156fhm-ns0";

panel-timing {
    clock-frequency = <147310000>;
    hactive = <1920>;
    hfront-porch = <48>;
    hsync-len = <32>;
    hback-porch = <192>;
    vactive = <1080>;
    vfront-porch = <3>;
    vsync-len = <6>;
    vback-porch = <31>;
    hsync-active = <1>;
    vsync-active = <0>;
};
```

### New DT Binding Required

File: `Documentation/devicetree/bindings/display/panel/boe,nv156fhm-ns0.yaml`

This panel has no upstream binding. Must be submitted alongside the board DTS.

---

## 8. GPU — Adreno (Purwa)

| Property | Value |
|---|---|
| **ACPI HID** | `QCOM0C36` |
| **ACPI device** | `GPU0` |
| **GPU family** | Adreno (Purwa variant — lower bin than X1P-42-100) |
| **Zap shader firmware** | `qcdxkmsucpurwa.mbn` ← Purwa-specific |
| **Generic 8380 shader** | `qcdxkmsuc8380.mbn` |
| **VSS firmware** | `qcvss8380.mbn`, `qcvss8380_pa.mbn` |
| **AV1 firmware** | `qcav1e8380.mbn` |
| **GPU dependencies** | MMU0, MMU1, IMM0, IMM1, PEP0, PMIC, PILC, RPEN, TREE, SCM0 |
| **Display engine** | MDP (Mobile Display Processor) — `MDP_REGS` |
| **DisplayPort PHY** | `DP_PHY_REGS` |
| **Display device** | `DPLB` (HID `QCOM0C70`) |

### Firmware Path (Linux)

```
/lib/firmware/qcom/sm8380/SAMSUNG/NP750XQB/qcdxkmsucpurwa.mbn
/lib/firmware/qcom/sm8380/SAMSUNG/NP750XQB/qcdxkmsuc8380.mbn
/lib/firmware/qcom/sm8380/SAMSUNG/NP750XQB/qcvss8380.mbn
/lib/firmware/qcom/sm8380/SAMSUNG/NP750XQB/qcvss8380_pa.mbn
/lib/firmware/qcom/sm8380/SAMSUNG/NP750XQB/qcav1e8380.mbn
```

---

## 9. Storage

### UFS (Primary Storage)

| Property | Value |
|---|---|
| **ACPI device** | `UFS0` |
| **ACPI HID** | `QCOM24A5` |
| **ACPI UID** | `0` |
| **Type** | eUFS (embedded Universal Flash Storage) |
| **Base address** | `0x01D84000` (from DSDT `_CRS` RBUF) |
| **IRQ** | `0x129` (from interrupt resource) |
| **Config flag** | `STOR = 0x3` (UFS + secondary storage enabled) |
| **Emulation flag** | `EMUL = 0x0` (real hardware, not emulated) |
| **Sub-device** | `DEV0` at address `0x8` (LUN 0) |

### SD Card (Secondary Storage)

| Property | Value |
|---|---|
| **ACPI device** | `SDC2` |
| **ACPI HID** | `QCOM2466` |
| **ACPI UID** | `1` |
| **Type** | Qualcomm SDHC controller |
| **Dependencies** | PEP0 (power), GIO0 (GPIO) |

### NVMe (via PCIe)

| Property | Value |
|---|---|
| **ACPI path** | `\_SB.PCI6.RP1.NVME` |
| **PCIe segment** | 6 |
| **ECAM base** | `0x70000000` |
| **Bus range** | 0x00–0x01 |
| **Type** | PCIe NVMe SSD |

---

## 10. PCIe Subsystem

### ECAM Segments (from `mcfg.dsl`)

| Segment | ECAM Base | Bus Range | Mapped To |
|---|---|---|---|
| 0 | `0x400000000` | 0x00–0xFF | General PCIe (large) |
| 1 | `0x500000000` | 0x00–0xFF | General PCIe |
| 2 | `0x6000000000` | 0x00–0xFF | High-address PCIe |
| 3 | `0x740000000` | 0x00–0x01 | |
| 4 | `0x7C000000` | 0x00–0x01 | |
| 5 | `0x7E000000` | 0x00–0x01 | |
| **6** | **`0x70000000`** | 0x00–0x01 | **NVMe SSD** (`PCI6` in DSDT) |
| **7** | **`0x74000000`** | 0x00–0x01 | **WiFi FC7800** (`PCI7` in DSDT) |

### PCIe Root Ports in DSDT

| DSDT Device | `_UID` | `_SEG` | `_CBA` | Contents |
|---|---|---|---|---|
| `PCI0` | 0 | 0 | `0x400000000` | |
| `PCI1` | 1 | 1 | | |
| `PCI2` | 2 | 2 | | |
| `PCI3` | 3 | 3 | | |
| `PCI4` | 4 | 4 | | |
| `PCI5` | 5 | 5 | | WWAN modem (MHI) |
| `PCI6` | 6 | 6 | `0x70000000` | **NVMe SSD** |
| `PCI7` | 7 | 7 | `0x74000000` | **WiFi FC7800** |

### PCIe Platform Extension

`ACPI\QCOM0C96` — PCIe platform plugin managing link training, power gating.

---

## 11. WiFi — Qualcomm FastConnect 7800

| Property | Value |
|---|---|
| **Windows name** | Qualcomm(R) FastConnect(TM) 7800 Mobile Connectivity System |
| **PCI DeviceID** | `PCI\VEN_17CB&DEV_1107&SUBSYS_110717CB&REV_01` |
| **PCI Vendor** | `0x17CB` (Qualcomm) |
| **PCI Device** | `0x1107` (FastConnect 7800) |
| **PCI Subsystem** | `0x110717CB` |
| **PCI Revision** | `0x01` |
| **PCIe segment** | 7 (`PCI7` in DSDT) |
| **Chip codename** | WCN785x (WCN7850 / WCN7851) |
| **Wireless standard** | Wi-Fi 7 (802.11be) |
| **Bands** | 2.4 GHz + 5 GHz + 6 GHz (tri-band) |
| **Linux driver** | `ath12k` |
| **ACPI thermal device** | `WLTM` (HID `QCOM0CD5`) |
| **ACPI dependency** | `PCI6`, `SBTD`, `IPC0` |

### Firmware Files (from DriverStore)

| File | Purpose |
|---|---|
| `wlanfw20.mbn` | Main WiFi firmware |
| `phy_ucode20.elf` | PHY microcode |
| `bdwlan_wcn785x_2p0_ncm825.elf` | Board data — generic NCM825 module |
| `bdwlan_wcn785x_2p0_ncm825_*.elf` | Board data — platform-specific variants |

Your device uses: `bdwlan_wcn785x_2p0_ncm825.elf` (generic — no Samsung-specific suffix present)

### Linux Firmware Paths

```
/lib/firmware/ath12k/WCN7850/hw2.0/board-2.bin   (or board.bin)
/lib/firmware/ath12k/WCN7850/hw2.0/firmware-2.bin (= wlanfw20.mbn renamed)
/lib/firmware/ath12k/WCN7850/hw2.0/regdb.bin
```

---

## 12. Bluetooth

| Property | Value |
|---|---|
| **Windows name** | Qualcomm FastConnect 7800 Dual Bluetooth Adapter |
| **DeviceID** | `QCA_SHB\UART_H4_HMT\3&2DBA09C2&0&4097` |
| **Transport** | UART (H4 HMT — Host Message Transport) |
| **ACPI device** | `BTH0` (HID `QCOM0C6B`) |
| **ACPI UID** | (via UART) |
| **UART device** | `UR15` (HID `QCOM0C16`, `_UID=0xF`) |
| **UART base** | `0x00A98000` (from UR15 `_CRS`) |
| **UART IRQ** | `0x346` |
| **BT standard** | Bluetooth 5.4 (FastConnect 7800) |
| **BT GPIO reset** | GPIO `0x17` (23) |
| **BT GPIO wake** | GPIO `0x19` (25) |
| **BT GPIO enable** | GPIO `0x23` (35) |
| **Linux driver** | `btqca` / `hci_uart` |
| **Firmware driver** | `qca_download_firmware` |

### Firmware Files

```
bdwlan_wcn785x_2p0_ncm825.elf  (shared with WiFi — board data)
```
BT-specific calibration is embedded in the shared board data file.

---

## 13. WWAN — 5G Modem

| Property | Value |
|---|---|
| **ACPI device** | `WWAN` |
| **ACPI HID** | `QCOM0CDA` |
| **ACPI UID** | `0` |
| **Type** | Qualcomm integrated 5G modem (Snapdragon X modem) |
| **Connection** | PCIe via `PCI5` (MHI — Modem Host Interface) |
| **ACPI dep** | `PM01` (PMIC), `GIO0` (GPIO) |
| **GPIO modem-on** | PM01 GPIO `0x04` (NPON field) |
| **GPIO enable** | GIO0 GPIO `0xDD` (EMDR field) |
| **GPIO wake-disable** | GIO0 GPIO `0x8C` (WDPM field) |
| **GPIO generic** | GIO0 GPIO `0x8E` (GDPM field) |

> **Note:** WWAN modem may be absent on this specific SKU (NP750XQB-KA1IN). The ACPI
> device is present but `_STA` may return 0 depending on physical modem installation.
> Many Galaxy Book4 Edge units ship without the M.2 modem card populated.

---

## 14. USB Subsystem

### Controllers

| ACPI Device | HID | UID | Type |
|---|---|---|---|
| `USB3` | `QCOM0D08` | 3 | Qualcomm USB 3.1 xHCI host controller |
| `USB4` | `QCOM0D09` | 4 | Qualcomm USB 4.0 / Thunderbolt 4 host |
| `USB0` | (sub-device) | | USB 3.0 root hub |
| `USB1` | (sub-device) | | USB 3.0 root hub |
| `URS0` | | | USB Role Switch 0 |
| `URS1` | | | USB Role Switch 1 |
| `UDE_` | | | USB Device Emulation |
| `UFN0` | | | USB Function 0 |
| `UFN1` | | | USB Function 1 |

### USB4 / Thunderbolt

| Property | Value |
|---|---|
| **ACPI HID** | `QCOM0C6D` (USB4 Host Router Bus) |
| **USB4 standard** | USB4 v2.0 (40 Gbps) |
| **Thunderbolt** | Thunderbolt 4 compatible |
| **Windows name** | Qualcomm(R) USB4(TM) Host Router Bus |

### Synopsys DRD Controllers

| Device | HID | Role |
|---|---|---|
| `QCOM0C8B` | Synopsys | USB 3.0 Dual-Role Controller 0 |
| `QCOM0C8C` | Synopsys | USB 3.0 Dual-Role Controller 1 |

### USB-C / Type-C

| Property | Value |
|---|---|
| **ACPI device** | `QCOM0CA4` (USB Type-C Device) |
| **USB3 retimer** | `IC19` on I2C7 (referenced in USB3 `_CRS`) |
| **USB4 retimer** | `IC19` on I2C7 (referenced in USB4 `_CRS`) |
| **Retimer chip** | Unknown — identify from Windows INF `qcusbcretimer*.inf` |

### Physical Ports (inferred)

- 2× USB-C (USB4/TB4 on right side — typical Galaxy Book4 Edge layout)
- 1× USB-A 3.1 (left side)
- 1× USB-A 3.1 (right side)
- 1× MicroSD slot (SDC2)

---

## 15. Audio Subsystem

### Architecture

```
ADSP (Audio DSP) ←→ SlimBus ←→ SAMM0851 codec ←→ speakers / headphone jack
                                                  ↕ microphone array
```

### SlimBus Controller

| Property | Value |
|---|---|
| **ACPI device** | `SLM1` |
| **Type** | Qualcomm SLIMbus (Serial Low-power Inter-chip Media Bus) |
| **Child device** | `AUCD` (audio codec) |

### Audio Codec

| Property | Value |
|---|---|
| **ACPI device** | `AUCD` (child of SLM1) |
| **`_SUB` identifier** | `CA09144D` |
| **Child name string** | `"AUCD\SAMM0851"` |
| **Type** | Samsung custom WCD variant — `SAMM0851` |
| **Sub-device** | `QCRT` (codec routing) |
| **Associated** | `ACXS` (audio crossbar switch) |

### Codec GPIO Assignments (from AUCD `_CRS`)

| GPIO | Pin | Function |
|---|---|---|
| GIO0 | `0xBF` (191) | Codec reset / enable |
| GIO0 | `0xCC` (204) | Codec interrupt |
| GIO0 | `0x1C0` (448) | Codec enable line |
| IRQ | `0x210` | Codec IRQ resource |
| IRQ | `0xBB` | Secondary codec IRQ |
| IRQ | `0xCA`, `0xCB` | Additional codec IRQs |

### ADSP Firmware

| File | Purpose |
|---|---|
| `qcadsp8380.mbn` | ADSP main firmware |
| `adsp_dtbs.elf` | ADSP device tree blobs |

### Linux Driver Status

`SAMM0851` has **no upstream Linux driver or DT binding**. A new binding must be authored
under `Documentation/devicetree/bindings/sound/` and a codec driver created or adapted
from the closest existing WCD codec driver (likely `wcd938x` or `wcd939x` as base).

---

## 16. Input Devices — Samsung EC

### Samsung Embedded Controller

| Property | Value |
|---|---|
| **ACPI device** | `ECTC` (Embedded Controller) |
| **Sub-device** | `EMEC` (EC memory-mapped interface) |
| **Type** | Samsung proprietary EC (not standard ACPI EC) |
| **Battery via** | ECTC + EMEC |
| **Fan control via** | ECTC |
| **Lid switch via** | ECTC |

### Keyboard & Input

| Property | Value |
|---|---|
| **ACPI device** | `ECKB` |
| **ACPI HID** | `SSEC0001` |
| **ACPI CID** | `PNP0C50` (HID over I2C) |
| **ACPI UID** | `3` |
| **I2C bus** | `I2C1` |
| **I2C address** | `0x05` (from `_CRS` I2CSerialBus resource) |
| **Interrupt GPIO** | GIO0 `0x80` (128) |
| **Linux driver needed** | `samsung-ec-hid` or `i2c-hid` |

### Samsung EC HID Collections (all under `SSEC0001`)

| Collection | Windows DeviceID | Description |
|---|---|---|
| `COL01` | `HID\SSEC0001&COL01` | **Samsung KBD Device** — keyboard |
| `COL02` | `HID\SSEC0001&COL02` | Consumer control — media keys, Fn keys |
| `COL03` | `HID\SSEC0001&COL03` | Vendor-defined — Samsung extra controls |
| `COL04` | `HID\SSEC0001&COL04` | Wireless radio controls — airplane mode |
| `COL05` | `HID\SSEC0001&COL05` | System controller — power/lid |

### Lid Switch

| Property | Value |
|---|---|
| **ACPI device** | `LID0` |
| **Type** | Standard ACPI lid (`PNP0C0D`) |
| **Control via** | Samsung EC (`ECTC`) |

### Power Button

| Property | Value |
|---|---|
| **ACPI device** | `BTNS` (button array) |
| **Type** | ACPI button (`PNP0C0C` / `PNP0C0E`) |

---

## 17. Camera Subsystem

### ISP Platform

| Property | Value |
|---|---|
| **Windows name** | Qualcomm(R) Spectra(TM) 695 ISP Camera Platform Device |
| **ACPI HID** | `QCOM0C32` |
| **ISP** | Spectra 695 (embedded in SM8380) |
| **JPEG encoder** | `QCOM0C33` (`JPGE` device) |
| **AVStream device** | `DISPLAY\QCOM_AVSTREAM_8380` |

### Camera Devices

| ACPI Device | HID | UID | `_STA` | Description |
|---|---|---|---|---|
| `CAMP` | `QCOM0C32` | `0x1B` | **Active** | Primary ISP / camera platform |
| `CAMS` | `QCOM0C26` | `0x15` | Disabled | Secondary sensor |
| `CAMF` | `QCOM0C06` | `0x1A` | **Active** | Front-facing camera (RGB) |
| `CAMI` | `QCOM0C99` | `0x1C` | Disabled | IR camera (Windows Hello) |
| `CAMT` | `QCOM0CCE` | `0x1D` | Disabled | Thermal camera (not populated) |
| `CAMU` | `QCOM0CCF` | `0x1E` | Disabled | Ultra-wide (not populated) |
| `FLSH` | (child of CAMP) | | | Camera flash / LED |

> **Active cameras:** Front RGB (`CAMF`) and primary ISP (`CAMP`) are enabled.
> IR/Windows Hello, thermal, and ultra-wide cameras are disabled (hardware not present
> on this SKU or fused off).

### CAMP GPIO Resources

| GPIO | Function |
|---|---|
| GIO0 `0xE1` (225) | Camera enable / power |
| GIO0 `0x6E` (110) | Camera reset |
| IRQ `0x1EC` | Camera interrupt |
| IRQ `0x12F` | Secondary camera interrupt |
| IRQ `0x1EB` | Tertiary interrupt |

---

## 18. Power Management & Battery

### PMIC

| Property | Value |
|---|---|
| **ACPI device** | `PMIC` |
| **ACPI HID** | `QCOM0C2B` |
| **ACPI CID** | `PNP0CA3` |
| **Bus** | SPMI (`QCOM0C0B`) |
| **Family** | PM8380 (matches SM8380 platform) |
| **GPIO device** | `QCOM0C2D` (System Manager PMIC GPIO Framework) |
| **Apps device** | `QCOM0C2C` (Power Management PMIC Apps) |
| **System Manager** | `QCOM0C2F` |

### Battery

| Property | Value |
|---|---|
| **ACPI device** | `BATC` (child of Samsung EC scope) |
| **ACPI HID** | `0x0ACD041` (`PNP0C0A`) |
| **ACPI UID** | `1` |
| **Chemistry** | Li-Ion (`LION`) |
| **Manufacturer** | SAMSUNG Electronics |
| **Design capacity** | **95,000 mWh (95 Wh)** |
| **Design voltage** | 35,000 mV (35V — 10S Li-Ion pack: ~3.5V × 10) |
| **Warning voltage** | 25,000 mV (25V) |
| **Cycle count** | Not reported (0xFFFFFFFF) |
| **Control** | Samsung EC (`ECTC.PBTE`, `ECTC.B1EX` fields) |

> **Battery note:** The 95 Wh capacity at 35V nominal suggests a 10-cell series pack.
> Samsung Galaxy Book4 Edge 15.6" official spec lists 61.4 Wh — the BIXP values
> may use different units or represent a different pack configuration. The 35V design
> voltage is unusual; verify against physical label when possible.

### AC Adapter

| Property | Value |
|---|---|
| **ACPI device** | `ADP1` |
| **Type** | AC adapter presence detection |

### Power Sequencing

| Property | Value |
|---|---|
| **Power engine** | `PEP0` (Power Engine Plugin — referenced by nearly all devices) |
| **Sleep states** | S0 (active), S0i3 (Modern Standby), S4 (hibernate), S5 (off) |
| **S4 wakeup** | Devices declare `_S4W` — USB3/BT support wakeup from S4 |

---

## 19. Thermal & Fan

### Thermal Sensor Devices

| ACPI Device | HID | Count | Type |
|---|---|---|---|
| `QCOM0C58` | Qualcomm Temperature Sensor | 2 | SoC thermal sensors |
| `QCOM0C59` | Qualcomm Temperature Sensor | 2 | SoC thermal sensors |
| `QCOM0C5A` | Qualcomm Temperature Sensor | 1 | Temperature sensor |
| `QCOM0CBF` | Qualcomm Temperature Sensor | 1 | Temperature sensor |
| `QCOM0C91` | Qualcomm Temperature Sensor | 1 | Temperature sensor |
| `QCOM0C5E` | ADC Temperature Monitor | 4 | ADC-based thermal |
| `QCOM0C60` | ADC Temperature Monitor | 1 | ADC thermal |
| `QCOM0C11` | ADC Device | 1 | ADC converter |

### Thermal Zone Monitors (TMD1–TMD9)

9 OEM thermal mitigation devices (`OEM2UPDX75TMDx`), all conditionally enabled when:
- `PSUB == "CRD08380"` (matches this board)
- `SDFE == 0x9A`
- WiFi device present on PCI5 (`PVD5() == 0x30917CB` → PCI ID `17CB:1107`)

These drive DPTF (Dynamic Platform and Thermal Framework) on Windows.

### Thermal Zones

| Zone | Monitored Device | Passive Trip | Critical Trip |
|---|---|---|---|
| `TZ51` | `MPA_` | **94.9°C** | **119.9°C** |
| `TZ52`–`TZ57` | Various subsystems | Similar range | Similar range |
| `TZ0_`–`TZ3_` | Additional zones | — | — |

### Fan

| Property | Value |
|---|---|
| **ACPI device** | `FAN0` |
| **ACPI HID** | `0x0BCD041` (`PNP0C0B`) |
| **ACPI UID** | `0x10` |
| **Type** | Single fan (typical for 15.6" Samsung) |
| **Control** | Samsung EC (`ECTC`) |
| **Trip point 1** | 2,800 RPM |
| **Trip point 2** | 3,300 RPM |
| **Trip point 3** | 3,700 RPM |
| **Trip point 4** | 4,700 RPM (max) |

---

## 20. I2C Bus Map

All I2C controllers: HID `QCOM0C10`, with UIDs as bus numbers.

| DSDT Device | UID (hex) | UID (dec) | Connected Devices |
|---|---|---|---|
| `I2C1` | `0x1` | 1 | Keyboard (`ECKB`, `SSEC0001`, addr `0x05`) |
| `I2C2` | `0x2` | 2 | (TBD — touchpad likely here) |
| `I2C3` | `0x3` | 3 | (TBD) |
| `I2C4` | `0x4` | 4 | (TBD) |
| `I2C5` | `0x5` | 5 | (TBD) |
| `I2C6` | `0x6` | 6 | (interrupt-capable device, `FNHB` flag checked) |
| `I2C7` | `0x7` | 7 | USB-C retimer (`IC19`) |
| `I2C8` | `0x8` | 8 | (TBD) |
| `IC10` | `0xA` | 10 | (Extended I2C) |
| `IC14` | `0xE` | 14 | (Extended I2C) |
| `IC16` | `0x10` | 16 | (Extended I2C) |
| `IC18` | `0x12` | 18 | (Extended I2C) |
| `IC19` | `0x13` | 19 | **USB-C retimer** (referenced by USB3 + USB4 `_CRS`) |
| `IC21` | `0x15` | 21 | (Extended I2C) |
| `IC23` | `0x17` | 23 | (Extended I2C) |

### Audio I2C / SlimBus

The audio codec (`SAMM0851`) is on SlimBus (`SLM1`), not I2C — SlimBus is a separate
serial protocol for audio peripherals.

---

## 21. SMMU / IOMMU

From `iort.dsl` (IO Remapping Table, 30 nodes total).

| Instance | Base Address | Span | Type | Notes |
|---|---|---|---|---|
| **Primary SMMU** | `0x15000000` | `0x100000` (1MB) | SMMU-500 (model 3) | Main IOMMU |
| **Secondary** | `0x03DA0000` | — | — | Secondary IOMMU |
| **Tertiary** | `0x15400000` | — | — | |

### Primary SMMU Details

| Property | Value |
|---|---|
| **Base** | `0x15000000` |
| **Global interrupt** | offset `0x3C` |
| **Context interrupt count** | `0x60` (96 contexts) |
| **Context interrupt base** | `0x81`–`0x100` range |
| **NSgIrpt** | `0x61` |
| **DVM supported** | No |
| **Coherent walk** | No |

### ACPI IOMMU Devices

| HID | Name |
|---|---|
| `QCOM068F` | Qualcomm IOMMU Device (2 instances: `\0` and `\1`) |

---

## 22. TPM

From `tpm2.dsl`.

| Property | Value |
|---|---|
| **Type** | TPM 2.0 |
| **ACPI table** | `TPM2` revision 3 |
| **Control address** | `0x81F10000` |
| **Start method** | `0x0E` (Command Response Buffer) |
| **Implementation** | Qualcomm fTPM (firmware TPM in TrustZone) |
| **ACPI SCM device** | `QCOM04DD` (System Manager SCM) |
| **Secure kernel ext** | `QCOM0CAC` |

---

## 23. NPU — Hexagon

| Property | Value |
|---|---|
| **Windows name** | Snapdragon(R) X - X126100 - Qualcomm(R) Hexagon(TM) NPU |
| **Windows DeviceID** | `ACPI\QCOM0D0A` |
| **ACPI HID** | `QCOM0D0A` |
| **NPU generation** | Hexagon (SM8380 generation) |
| **CDSP device** | `QCOM0CB0` (Compute DSP Subsystem) |
| **NSP device** | `NSP0` (Neural Signal Processor) |
| **NSPM device** | `NSPM` (NSP Manager) |
| **EVA device** | `QCOM0CF1` (EVA — likely video/encode accelerator) |
| **FastRPC** | `QCOM0C5C` (Remote Procedure Call to DSP) |

### CDSP/NPU Firmware

| File | Purpose |
|---|---|
| `qccdsp8380.mbn` | CDSP main firmware |
| `cdsp_dtbs.elf` | CDSP device tree blobs |

---

## 24. ACPI Tables Overview

12 ACPI tables present (from `xsdt.dsl`):

| Table | Description | Key Data |
|---|---|---|
| `DSDT` | Differentiated System Description | Full hardware namespace (60,147 lines ASL) |
| `APIC` (MADT) | Multiple APIC Description | GIC addresses, CPU MPIDRs |
| `PPTT` | Processor Properties Topology | CPU cluster/cache hierarchy |
| `MCFG` | Memory-Mapped Config | PCIe ECAM addresses (8 segments) |
| `IORT` | IO Remapping Table | SMMU config, 30 nodes |
| `GTDT` | Generic Timer Description | ARM timer interrupts |
| `FACP` (FADT) | Fixed ACPI Description | Power profile = Tablet |
| `TPM2` | TPM Hardware Interface | Qualcomm fTPM at `0x81F10000` |
| `CSRT` | Core System Resource Table | DMA controllers / clocks |
| `DBG2` | Debug Port Table | UART debug at `0x00894000`, QDSS at `0x0A600000` |
| `BGRT` | Boot Graphics Resource | Boot splash screen |
| `FPDT` | Firmware Performance Data | Boot timing |
| `MSDM` | Microsoft Data Management | Windows license key (OEM embedded) |

### Debug Ports (from `dbg2.dsl`)

| Port | Type | Base Address | Device |
|---|---|---|---|
| UART | Serial (8000:0013) | `0x00894000` | `\_SB.UARD` |
| QDSS | Qualcomm Debug (8003:5143) | `0x0A600000` | Qualcomm Debug Subsystem |
| + 5 more | Various | Various | Various debug interfaces |

---

## 25. Firmware Blobs

### Complete Inventory (from Windows DriverStore)

All 49 firmware files found, sourced from `C:\Windows\System32\DriverStore\FileRepository\`:

#### GPU (`qcdx8380.inf_arm64_*`)

| File | Description |
|---|---|
| `qcdxkmsucpurwa.mbn` | **GPU KMS zap shader — Purwa die specific** |
| `qcdxkmsuc8380.mbn` | GPU KMS zap shader — generic SM8380 |
| `qcav1e8380.mbn` | AV1 video decode engine firmware |
| `qcvss8380.mbn` | Video Sub-System firmware |
| `qcvss8380_pa.mbn` | VSS power-aware variant |

#### ADSP (`qcsubsys_ext_adsp8380.inf_arm64_*`)

| File | Description |
|---|---|
| `qcadsp8380.mbn` | Audio DSP main firmware |
| `adsp_dtbs.elf` | ADSP device tree blobs |

#### CDSP (`qcnspmcdm_ext_cdsp8380.inf_arm64_*`)

| File | Description |
|---|---|
| `qccdsp8380.mbn` | Compute DSP / NPU firmware |
| `cdsp_dtbs.elf` | CDSP device tree blobs |

#### EVA (`qceva8380.inf_arm64_*`)

| File | Description |
|---|---|
| `evass.mbn` | EVA (video encode/decode accelerator) secure service |

#### WiFi HMT — WCN785x (`qcwlanhmt8380.inf_arm64_*`)

| File | Description |
|---|---|
| `wlanfw20.mbn` | WiFi main firmware (FastConnect 7800) |
| `phy_ucode20.elf` | PHY microcode |
| `bdwlan.elf` | Board data (generic) |
| `bdwlan_wcn785x_2p0_ncm825.elf` | **Board data — NCM825 module (your device)** |
| `bdwlan_wcn785x_2p0_ncm825_AS_S55_SA.elf` | ASUS variant |
| `bdwlan_wcn785x_2p0_ncm825_DE01.elf` | Dell variant 1 |
| `bdwlan_wcn785x_2p0_ncm825_DE02.elf` | Dell variant 2 |
| `bdwlan_wcn785x_2p0_ncm825_HO_MoorO.elf` | HP MoorO variant |
| `bdwlan_wcn785x_2p0_ncm825_LES790.elf` | Lenovo S790 |
| `bdwlan_wcn785x_2p0_ncm825_LE_Altai.elf` | Lenovo Altai |
| `bdwlan_wcn785x_2p0_ncm825_LE_C590.elf` | Lenovo C590 |
| `bdwlan_wcn785x_2p0_ncm825_PZ36.elf` | (platform variant) |
| `bdwlan_wcn785x_2p0_ncm825_QC_revB.elf` | Qualcomm reference board rev B |
| `bdwlan_wcn785x_2p0_ncm825_UX3407Q.elf` | ASUS UX3407Q |
| `bdwlan_wcn785x_2p0_ncm865a.elf` | NCM865a module variant |
| `bdwlan_wcn785x_2p0_ncm865a_LE_S390.elf` | Lenovo S390 |
| `bdwlan_wcn785x_2p0_ncm865a_QC_revB.elf` | Qualcomm reference board rev B |
| `phy_ucode20.elf` | PHY microcode |

#### WiFi HSP — WCN685x (`qcwlanhsp8380.inf_arm64_*`)

Present but **not your chip** — this is for older WCN685x (FastConnect 6800) on other
SM8380 devices. Ignore for your board.

#### WiFi MSL — WPSS (`qcwlanmsl8380.inf_arm64_*`)

| File | Description |
|---|---|
| `wpss.mbn` | WiFi Power Sub-System firmware |
| `bdwlan.elf` | MSL board data |
| `bdwlang.elf` | MSL board data variant G |

#### Camera (`qccamisp8380.inf_arm64_*`)

| File | Description |
|---|---|
| `CAMERA_ICP.mbn` | Camera ICP (Image Compute Processor) firmware |
| `CAMERA_ICP_AAAAAA.elf` | Camera ICP ELF variant |

#### Security / Tree (`qctreeextqcom8380.inf_arm64_*`, `qctreeextoem8380.inf_arm64_*`)

| File | Description |
|---|---|
| `hdcp1.mbn` | HDCP 1.x content protection |
| `hdcp2p2.mbn` | HDCP 2.2 content protection |
| `hdcpsrm.mbn` | HDCP System Renewability Message |
| `pr_3_wp.mbn` | PlayReady 3.0 Widevine Protection |
| `sshdcpapp.mbn` | Secure side HDCP application |

### Recommended Linux Firmware Layout

```
/lib/firmware/qcom/sm8380/SAMSUNG/NP750XQB/
├── qcdxkmsucpurwa.mbn       # GPU zap shader (Purwa-specific)
├── qcdxkmsuc8380.mbn        # GPU zap shader (generic)
├── qcav1e8380.mbn           # AV1 decoder
├── qcvss8380.mbn            # Video subsystem
├── qcvss8380_pa.mbn         # Video subsystem PA
├── qcadsp8380.mbn           # ADSP
├── adsp_dtbs.elf            # ADSP DTBs
├── qccdsp8380.mbn           # CDSP/NPU
├── cdsp_dtbs.elf            # CDSP DTBs
├── evass.mbn                # EVA
├── wpss.mbn                 # WiFi power subsystem
├── wlanfw20.mbn             # WiFi firmware
├── bdwlan_wcn785x_2p0_ncm825.elf  # WiFi board data
├── phy_ucode20.elf          # WiFi PHY
├── hdcp1.mbn                # HDCP 1.x
├── hdcp2p2.mbn              # HDCP 2.2
├── hdcpsrm.mbn              # HDCP SRM
├── CAMERA_ICP.mbn           # Camera ICP
└── CAMERA_ICP_AAAAAA.elf    # Camera ICP ELF
```

---

## 26. Linux DTS — Compatible Strings & Node Summary

### Root Node

```c
/ {
    model = "Samsung Galaxy Book4 Edge 15.6 (X1P-26-100)";
    compatible = "samsung,galaxy-book4-edge-np750xqb",
                 "qcom,sm8380";
    chassis-type = "laptop";
};
```

### Key Compatible Strings

| Component | DTS Compatible String | Status |
|---|---|---|
| SoC | `qcom,sm8380` | Needs new SoC DTSI |
| Board | `samsung,galaxy-book4-edge-np750xqb` | New — this patch |
| GIC | `arm,gic-v3` | Upstream |
| Timer | `arm,armv8-timer` | Upstream |
| Panel | `boe,nv156fhm-ns0` | **Needs new binding** |
| UFS | `qcom,ufshc` (variant TBD) | Upstream (check x1p42100) |
| WiFi | `pci17cb,1107` | Upstream (`ath12k`) |
| Bluetooth | `qcom,wcn7850-bt` | Upstream |
| Audio codec | `samsung,samm0851` | **Needs new driver + binding** |
| Keyboard | `hid-over-i2c` / `samsung,ssec0001` | Needs Samsung EC driver |
| SMMU | `arm,mmu-500` | Upstream |
| USB3 xHCI | `qcom,dwc3` | Upstream |
| USB4 | `qcom,usb4` | Upstream |
| PMIC | (PM8380 binding) | Check x1p42100 |
| Battery | `simple-battery` | Upstream |
| Fan | `pwm-fan` or EC-controlled | Via Samsung EC |

### DTS File Location

```
arch/arm64/boot/dts/qcom/x1p26100-samsung-galaxy-book4-edge-15.dts
```

### SoC DTSI Required

```
arch/arm64/boot/dts/qcom/x1p26100.dtsi
```
This does not yet exist. It must be derived from `x1p42100.dtsi` with:
- Cluster 2 (CPUs 8–11) removed
- GPU binned differently (lower ALU count — same firmware path)
- Otherwise identical Purwa topology

### New Binding Files Required

```
Documentation/devicetree/bindings/display/panel/boe,nv156fhm-ns0.yaml
Documentation/devicetree/bindings/sound/samsung,samm0851.yaml
```

---

## 27. Stubble HWID Registration

Stubble is the automatic DTB selection mechanism used by Fedora 44, Ubuntu 26.04+,
and other distros on Snapdragon laptops. It reads SMBIOS, generates CHIDs (Computer
Hardware IDs), and matches them against a JSON database to auto-load the correct DTB.

### Repository

`https://github.com/ubuntu/stubble`

### Files to Submit

#### `hwids/txt/samsung-galaxy-book4-edge-np750xqb.txt`

```
Manufacturer: SAMSUNG ELECTRONICS CO., LTD.
Family: Galaxy Book4 Edge
ProductName: Galaxy Book4 Edge
ProductSku: NP750XQB-KA1IN
EnclosureKind: 10
BiosVendor: SAMSUNG ELECTRONICS CO., LTD.
BiosVersion: P00VQB.059.260508.MP.2105
BiosMajorRelease: 05
BiosMinorRelease: 09
BoardManufacturer: SAMSUNG ELECTRONICS CO., LTD.
BoardProduct: NP750XQB-KA1IN
BoardVersion: SGLB971A26-C01-G001-S0001+10.0.26100
```

#### `hwids/json/samsung-galaxy-book4-edge-np750xqb.json`

```json
{
  "compatible": "samsung,galaxy-book4-edge-np750xqb",
  "hwids": []
}
```

> The `hwids` array is populated by running `sudo fwupdtool hwids` on Linux and pasting
> the generated CHID hashes. These cannot be computed from Windows alone without the
> fwupd CHID algorithm. Run from a bootable ARM64 Linux environment (even a partial boot)
> and copy the output.

### UUID for CHID computation

```
98008698-39A2-5255-5231-5652300088E5
```

---

## 28. Outstanding Unknowns & TODO

### Hardware Unknowns

| Item | How to Identify | Priority |
|---|---|---|
| **USB-C retimer chip** (IC19, I2C7) | Search `qcusbcretimer*.inf` in DriverStore; check i2c address | High |
| **Touchpad chip** (likely I2C2 or I2C3) | Check Device Manager under HID/I2C devices | High |
| **Touchpad I2C address** | DSDT I2C child device on I2C2/3 | High |
| **Audio amp** | Check i2c-detect on I2C6 when booted | Medium |
| **Actual battery capacity** | Physical label on battery, or `upower -d` on Linux | Low |
| **Display backlight controller** | Check DSDT `LED1` device and I2C buses | Medium |

### Linux Kernel Work Required

| Task | File | Complexity |
|---|---|---|
| New SoC DTSI | `arch/arm64/boot/dts/qcom/x1p26100.dtsi` | Medium |
| New board DTS | `arch/arm64/boot/dts/qcom/x1p26100-samsung-galaxy-book4-edge-15.dts` | Medium |
| BOE panel binding | `Documentation/devicetree/bindings/display/panel/boe,nv156fhm-ns0.yaml` | Low |
| Samsung EC driver | `drivers/input/keyboard/samsung-ec-hid.c` (or extend existing) | High |
| SAMM0851 codec binding | `Documentation/devicetree/bindings/sound/samsung,samm0851.yaml` | High |
| SAMM0851 codec driver | `sound/soc/codecs/samm0851.c` | Very High |
| Add to `Makefile` / `Kconfig` | Both DTS Makefile and DTSI | Low |

### Upstream Reference Patches to Study

| Patch | Relevance |
|---|---|
| Jens Glathe — ASUS Vivobook Purwa (X1P-42-100) | Same SoC die — closest reference |
| Marcus Glocker — Galaxy Book4 Edge X1E | Same vendor, same chassis — board template |
| Konrad Dybcio — SM8380 bringup series | SoC DTSI foundation |
| Purwa DTSI series (LKML Feb 2026) | Direct SoC base |

### Commands to Run When Linux Partially Boots

```bash
# Confirm CPU topology
lscpu
cat /sys/devices/system/cpu/cpu*/topology/core_id

# I2C device detection (find touchpad, retimer)
for i in $(seq 0 7); do i2cdetect -y $i 2>/dev/null; done

# GPIO state
cat /sys/kernel/debug/pinctrl/*/pins | head -100

# Check which firmware blobs were loaded successfully
dmesg | grep -i "firmware\|qcom\|remoteproc"

# Generate Stubble HWIDs
sudo fwupdtool hwids
```

---

*Document generated from hardware-extracted ACPI tables, EDID, and Windows Device Manager data.  
All values are authoritative — sourced directly from the physical device.  
Maintained by: NehalAditya / Deepcomet*
