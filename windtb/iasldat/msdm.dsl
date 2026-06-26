/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260408 (32-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 * 
 * Disassembly of msdm.dat
 *
 * ACPI Data Table [MSDM]
 *
 * Format: [HexOffset DecimalOffset ByteLength]  FieldName : FieldValue (in hex)
 */

[000h 0000 004h]                   Signature : "MSDM"    [Microsoft Data Management Table]
[004h 0004 004h]                Table Length : 00000055
[008h 0008 001h]                    Revision : 03
[009h 0009 001h]                    Checksum : DE
[00Ah 0010 006h]                      Oem ID : "QCOM  "
[010h 0016 008h]                Oem Table ID : "QCOMEDK2"
[018h 0024 004h]                Oem Revision : 00000000
[01Ch 0028 004h]             Asl Compiler ID : "QCOM"
[020h 0032 004h]       Asl Compiler Revision : 00000000

[024h 0036 031h] Software Licensing Structure : 01 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 /* ................ */\
/* 034h 0052  16 */                            1D 00 00 00 50 57 4E 33 33 2D 36 47 33 58 39 2D /* ....PWN33-6G3X9- */\
/* 044h 0068  16 */                            42 32 47 47 50 2D 46 37 4D 57 46 2D 4D 57 52 54 /* B2GGP-F7MWF-MWRT */\
/* 054h 0084   1 */                            51                                              /* Q */\

Raw Table Data: Length 85 (0x55)

    0000: 4D 53 44 4D 55 00 00 00 03 DE 51 43 4F 4D 20 20  // MSDMU.....QCOM  
    0010: 51 43 4F 4D 45 44 4B 32 00 00 00 00 51 43 4F 4D  // QCOMEDK2....QCOM
    0020: 00 00 00 00 01 00 00 00 00 00 00 00 01 00 00 00  // ................
    0030: 00 00 00 00 1D 00 00 00 50 57 4E 33 33 2D 36 47  // ........PWN33-6G
    0040: 33 58 39 2D 42 32 47 47 50 2D 46 37 4D 57 46 2D  // 3X9-B2GGP-F7MWF-
    0050: 4D 57 52 54 51                                   // MWRTQ
