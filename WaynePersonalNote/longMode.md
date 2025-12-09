# Long Mode
Check if CPU support Long mode (Most morden CPU Support Long mode)

Check 1GB page feature.

DriveID

## BIOS Drive Number Table

| Drive               | BIOS DL Value |
|--------------------|---------------|
| Floppy A:          | `0x00`        |
| Floppy B:          | `0x01`        |
| First HDD / SSD    | `0x80`        |
| Second HDD / SSD   | `0x81`        |
| Third HDD          | `0x82`        |

**Note:** USB boot drives are usually emulated as HDD (`0x80`).