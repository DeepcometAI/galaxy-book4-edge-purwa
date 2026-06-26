# Samsung Galaxy Book4 Edge DTS Support

This repository contains hardware documentation and Device Tree Source (DTS) work
for the **Samsung Galaxy Book4 Edge 15.6" (NP750XQB-KA1IN)** powered by the
Qualcomm **SM8380 Purwa (Snapdragon X1-26-100)** SoC.

## Purpose

- Provide a complete, hardware-confirmed reference extracted from ACPI tables,
  EDID, PCI IDs, and Windows DriverStore firmware blobs.
- Author and maintain a Linux DTS for this laptop.
- Upstream missing bindings (panel, audio codec, EC) to the Linux kernel.
- Serve as a reproducible archive for long-term hardware documentation.

## Repository Layout

```
docs/        → Raw hardware documentation (Markdown)
dts/         → Board-level DTS files
bindings/    → New YAML bindings for panel, audio codec, etc.
firmware-notes/ → Notes on firmware blobs and paths
```

## Hardware Highlights

- **SoC:** Qualcomm SM8380 Purwa (Snapdragon X1-26-100)
- **CPU:** 8 active Oryon cores (4 efficiency + 4 performance, 4 fused off)
- **Memory:** 16 GB LPDDR5X, 128-bit bus
- **Display:** BOE NV156FHM-NS0, 1920×1080 IPS, 60 Hz
- **GPU:** Adreno (Purwa bin), firmware in `/lib/firmware/qcom/sm8380/...`
- **Storage:** UFS0, NVMe SSD via PCIe6, microSD slot
- **WiFi/BT:** Qualcomm FastConnect 7800 (Wi-Fi 7, BT 5.4)
- **Audio:** Samsung SAMM0851 codec via SlimBus (new binding required)
- **Camera:** Spectra 695 ISP, front RGB camera active
- **Battery:** Samsung Li-Ion, design capacity ~95 Wh
- **EC:** Samsung proprietary EC for keyboard, lid, fan, battery

## Status

- Hardware documentation: ✅ complete
- DTS skeleton: 🚧 in progress
- Panel binding (`boe,nv156fhm-ns0`): 🚧 to be authored
- Audio codec binding (`samsung,samm0851`): 🚧 to be authored
- EC HID driver: 🚧 needed

## Contributing

Pull requests are welcome for:
- DTS improvements
- Binding YAMLs
- Driver references
- Documentation corrections

## License

MIT License (see [LICENSE](LICENSE))