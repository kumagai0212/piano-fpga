# Piano - fpga

FPGA上で動作するピアノタイル風の音楽ゲームです。上から落ちてくるノーツに合わせてタイミングよくボタンを押してください。

## Demo
<img src="placeholder_image_url" alt="Gameplay Screen" width="300">

## Contents
* **func_2.v** : ゲームのメインロジック (Verilog HDL)
* **main.xdc** : Arty A7-35T用制約ファイル (ピン配置定義)

## Environment
* **FPGA Board** : Digilent [Arty A7-35T](https://digilent.com/reference/programmable-logic/arty-a7/start)
* **FPGA Chip** : Xilinx Artix-7 (xc7a35ticsg324-1L)
* **Toolchain** : Vivado 2024.2
* **Display** : ST7789 TFT LCD Display Module (240x240 pixels)

## Hardware Setup
ST7789 ディスプレイモジュールを Arty A7 ボードの **Pmod Header JC** に接続してください。

| Display Pin | Pmod JC Pin | FPGA Pin | Description |
| :--- | :--- | :--- | :--- |
| **DC** | Pin 1 | U12 | Data/Command |
| **RES** (RST) | Pin 2 | V12 | Reset |
| **SDA** (MOSI) | Pin 3 | V10 | SPI Data |
| **SCL** (SCK) | Pin 4 | V11 | SPI Clock |
| **GND** | Pin 5 | - | Ground |
| **VCC** | Pin 6 | - | 3.3V Power |

## How to Play
4つのレーンに落ちてくるノーツを、対応するボタンで叩きます。

### Controls
* **BTN0 - BTN3**: 各レーンの入力
    * `BTN0`: 一番右のレーン
    * `BTN1`: 右から2番目のレーン
    * `BTN2`: 左から2番目のレーン
    * `BTN3`: 一番左のレーン
* **SW0 - SW3 (All ON)**: ゲームのリセット
    * 4つのスイッチすべてをオン (`4'b1111`) にするとゲームがリセットされます。

## License
Released under the [MIT license](https://opensource.org/licenses/mit).
Copyright (c) 2024 Kumagai Daichi, Science Tokyo
