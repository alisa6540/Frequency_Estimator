# FPGA-based Digital IF Frequency Estimator

![Vivado](https://img.shields.io/badge/Vivado-2023.x-blue)
![VHDL](https://img.shields.io/badge/VHDL-2008-green)
![MATLAB](https://img.shields.io/badge/MATLAB-R2023a-orange)
![License](https://img.shields.io/badge/License-MIT-yellow)

A real-time FPGA implementation of a digital IF frequency estimator using 128-point FFT, CORDIC, and parabolic interpolation.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [System Specifications](#-system-specifications)
- [System Architecture](#-system-architecture)
- [Design Methodology](#-design-methodology)
- [MATLAB Reference Model](#-matlab-reference-model)
- [VHDL Implementation](#-vhdl-implementation)
- [Module Description](#-module-description)
- [Resource Utilization](#-resource-utilization)
- [Timing Analysis](#-timing-analysis)
- [Power Analysis](#-power-analysis)
- [How to Use](#-how-to-use)
- [Project Structure](#-project-structure)
- [License](#-license)

---

## 🎯 Overview

This project implements a **real-time digital frequency estimator** for IF (Intermediate Frequency) signals on an FPGA. The system:

1. **Receives** a 14-bit digital IF signal sampled at 128 MHz
2. **Demodulates** the signal into I/Q components using a digital IQ demodulator
3. **Detects** the presence of a pulse using envelope detection and adaptive thresholding
4. **Computes** the 128-point FFT of the detected pulse
5. **Estimates** the frequency using parabolic interpolation for high accuracy

The design is fully pipelined and can process continuous input streams, making it suitable for radar and communication applications where real-time frequency estimation is required.

---

## 📊 System Specifications

| Parameter | Value |
|:---|:---|
| **Sampling Frequency** | 128 MHz |
| **IF Center Frequency** | 160 MHz |
| **Bandwidth** | 40 MHz |
| **Input Resolution** | 14-bit signed (fix14_13) |
| **FFT Length** | 128 points |
| **FFT Resolution** | 1 MHz (fs/N) |
| **Minimum Pulse Width** | 200 ns |
| **Input SNR** | ≥ 15 dB |
| **FFT Latency** | 3.6 µs |
| **Target Device** | Xilinx Zynq UltraScale+ (xczu9eg-ffvb1156-2-i) |
| **Clock Frequency** | 128 MHz |

---

## 🏗️ System Architecture

The block diagram of the system is shown below:
