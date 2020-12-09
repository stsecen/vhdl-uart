# vhdl-uart
  UART for FPGA is UART (Universal Asynchronous Receiver & Transmitter) controller for serial communication with an FPGA. The UART controller was implemented using VHDL.

## Parity (STOP BIT WIDTH=1)
```
  EVEN --- 1 start bit, 8 data bits, 1 parity bit, 1 stop bit!
  ODD  --- 1 start bit, 8 data bits, 1 parity bit, 1 stop bit!
  NONE --- 1 start bit, 8 data bits, 1 stop bit!
```
# Table of resource usage summary:
  Parity type | LE (LUT+FF) |
  :---:|:---:|
  none        | 76 |
  even/odd    | 86 |


