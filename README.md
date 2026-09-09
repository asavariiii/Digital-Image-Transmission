# Digital Image Transmission with Error Correction using MATLAB

## 📌 Project Overview

This project demonstrates the transmission of a digital image through a simulated noisy communication channel using MATLAB. The main objective is to study how transmission errors affect digital image data and how error-correcting techniques can improve the reliability of communication.

The input image is processed and converted into grayscale form. The pixel values are then converted into binary data to create a digital bit stream. During transmission, random bit errors are introduced to simulate noise in the communication channel.

To reduce the effect of transmission errors, the project implements **Hamming (7,4) error-correcting code**. The encoded data is transmitted through the noisy channel, decoded at the receiver, and reconstructed into an image.

The performance of the system is evaluated using **Bit Error Rate (BER)**, **Mean Squared Error (MSE)**, and **Peak Signal-to-Noise Ratio (PSNR)**.

---

## 🎯 Objectives

The main objectives of this project are:

- To select and process a digital image using MATLAB.
- To convert a color image into a grayscale image.
- To extract pixel values from the image.
- To convert pixel values into 8-bit binary data.
- To create a continuous binary bit stream for transmission.
- To simulate transmission errors using random bit flipping.
- To implement Hamming (7,4) error-correcting code.
- To detect and correct single-bit errors.
- To reconstruct the received image.
- To compare the transmission performance using BER, MSE, and PSNR.

---

## 🔄 System Workflow

```text
Original Color Image
        │
        ▼
Grayscale Conversion
        │
        ▼
Pixel Extraction
        │
        ▼
8-bit Binary Conversion
        │
        ▼
Continuous Bit Stream
        │
        ▼
─────────────────────────────────────
│                                   │
▼                                   ▼
Transmission Without           Hamming (7,4)
Error Correction                  Encoding
│                                   │
▼                                   ▼
Noisy Channel                    Noisy Channel
│                                   │
▼                                   ▼
Corrupted Data                  Hamming Decoding
│                                   │
▼                                   ▼
Corrupted Image                 Error Correction
                                    │
                                    ▼
                            Reconstructed Image
                                    │
                                    ▼
                         Performance Analysis
                         BER / MSE / PSNR
