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
```
  Implementation was performed using Vivado 2020.1 for Arty Z7-20 (xc7z020clg400-1). 
  Setting of some generics: BAUD_RATE = 115200, CLK_FREQ = 125e6.
```


