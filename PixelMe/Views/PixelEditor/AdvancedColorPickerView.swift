//
//  AdvancedColorPickerView.swift
//  PixelMe
//
//  HSB/RGB 슬라이더 기반 고급 색상 피커
//

import SwiftUI

/// HSB/RGB 색상 피커 (픽셀 에디터용)
struct AdvancedColorPickerView: View {
    @Binding var selectedColor: PixelColor
    @Environment(\.dismiss) private var dismiss

    @State private var hue: Double = 0
    @State private var saturation: Double = 1
    @State private var brightness: Double = 1
    @State private var red: Double = 255
    @State private var green: Double = 0
    @State private var blue: Double = 0
    @State private var alpha: Double = 255
    @State private var hexString: String = "FF0000"
    @State private var mode: ColorPickerMode = .hsb

    enum ColorPickerMode: String, CaseIterable {
        case hsb = "HSB"
        case rgb = "RGB"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 색상 미리보기
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(currentColor)
                            .frame(height: 60)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedColor.swiftUIColor)
                            .frame(width: 60, height: 60)
                            .overlay(Text("이전").font(.caption2).foregroundStyle(.white))
                    }
                    .padding(.horizontal)

                    // 모드 선택
                    Picker("모드", selection: $mode) {
                        ForEach(ColorPickerMode.allCases, id: \.self) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if mode == .hsb {
                        hsbSliders
                    } else {
                        rgbSliders
                    }

                    // Alpha
                    SliderRow(label: "A", value: $alpha, range: 0...255, color: .gray)
                        .padding(.horizontal)

                    // Hex 입력
                    HStack {
                        Text("#")
                            .font(.system(.body, design: .monospaced))
                        TextField("HEX", text: $hexString)
                            .font(.system(.body, design: .monospaced))
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.allCharacters)
                            .onChange(of: hexString) { _, newValue in
                                applyHex(newValue)
                            }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("색상 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("적용") {
                        selectedColor = PixelColor(r: UInt8(red), g: UInt8(green), b: UInt8(blue), a: UInt8(alpha))
                        dismiss()
                    }
                }
            }
            .onAppear { loadFromColor() }
        }
    }

    private var hsbSliders: some View {
        VStack(spacing: 12) {
            SliderRow(label: "H", value: $hue, range: 0...360, color: .red)
            SliderRow(label: "S", value: $saturation, range: 0...1, color: .green)
            SliderRow(label: "B", value: $brightness, range: 0...1, color: .blue)
        }
        .padding(.horizontal)
        .onChange(of: hue) { _, _ in hsbToRGB() }
        .onChange(of: saturation) { _, _ in hsbToRGB() }
        .onChange(of: brightness) { _, _ in hsbToRGB() }
    }

    private var rgbSliders: some View {
        VStack(spacing: 12) {
            SliderRow(label: "R", value: $red, range: 0...255, color: .red)
            SliderRow(label: "G", value: $green, range: 0...255, color: .green)
            SliderRow(label: "B", value: $blue, range: 0...255, color: .blue)
        }
        .padding(.horizontal)
        .onChange(of: red) { _, _ in rgbToHSB(); updateHex() }
        .onChange(of: green) { _, _ in rgbToHSB(); updateHex() }
        .onChange(of: blue) { _, _ in rgbToHSB(); updateHex() }
    }

    private var currentColor: Color {
        Color(red: red / 255, green: green / 255, blue: blue / 255, opacity: alpha / 255)
    }

    private func loadFromColor() {
        red = Double(selectedColor.r)
        green = Double(selectedColor.g)
        blue = Double(selectedColor.b)
        alpha = Double(selectedColor.a)
        rgbToHSB()
        updateHex()
    }

    private func hsbToRGB() {
        let c = UIColor(hue: hue / 360, saturation: saturation, brightness: brightness, alpha: 1)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        c.getRed(&r, green: &g, blue: &b, alpha: &a)
        red = Double(r * 255)
        green = Double(g * 255)
        blue = Double(b * 255)
        updateHex()
    }

    private func rgbToHSB() {
        let c = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        c.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        hue = Double(h * 360)
        saturation = Double(s)
        brightness = Double(b)
    }

    private func updateHex() {
        hexString = String(format: "%02X%02X%02X", Int(red), Int(green), Int(blue))
    }

    private func applyHex(_ hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard clean.count == 6, let val = UInt32(clean, radix: 16) else { return }
        red = Double((val >> 16) & 0xFF)
        green = Double((val >> 8) & 0xFF)
        blue = Double(val & 0xFF)
        rgbToHSB()
    }
}

/// 슬라이더 행
private struct SliderRow: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(.caption, design: .monospaced))
                .frame(width: 20)
            Slider(value: $value, in: range)
                .tint(color)
            Text("\(Int(value))")
                .font(.system(.caption, design: .monospaced))
                .frame(width: 36, alignment: .trailing)
        }
    }
}
