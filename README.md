# Floating-Point-Adder
Originally developed in 2021 as part of a Computer Architecture Course; this repository contains the finalized and cleaned version for public release.
## Overview
This project implements a **Floating Point Adder** using **Verilog HDL**, designed to perform addition on 32-bit IEEE 754 single-precision floating-point numbers. Both inputs and outputs follow the normalized IEEE 754 format, with appropriate handling of special cases and infinity values.

🧩 **Key Features**

- Accepts **IEEE 754 normalized inputs** and produces normalized outputs.

- Handles special conditions:
  - (+∞ – ∞) results in +∞
  - Any operation with ±∞ results in ±∞

- **NaN (Not-a-Number)** inputs are not supported.

- Implements **behavioral modeling** with handshake-based synchronization using always blocks—triggered whenever input signals change.

- **No separate rounding hardware** added; only the least significant bit (LSB) is removed in case of a carry overflow.

🧠 **Design Approach**

- Built using modular design with dedicated blocks for exponent alignment, mantissa addition, normalization, and result assembly.

- Simulated and verified for valid IEEE 754 inputs to ensure correctness of exponent alignment and normalization.
