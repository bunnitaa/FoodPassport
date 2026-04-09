//
//  FullScreenPhotoView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-03-30.
//

import SwiftUI

struct FullScreenPhotoView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    
    // gesture states for zooming/panning
    @State private var scale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                // zoom/drag values
                .scaleEffect(scale)
                .offset(offset)
                // pinch to zoom
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScaleValue
                            lastScaleValue = value
                            scale *= delta
                        }
                        .onEnded { _ in
                            lastScaleValue = 1.0
                            // bounce back if they zoom out too far
                            if scale < 1.0 {
                                withAnimation(.spring()) {
                                    scale = 1.0
                                    offset = .zero
                                }
                            }
                        }
                )
                // drag to pan
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            // only allow dragging if zoomed in
                            if scale > 1.0 {
                                offset = value.translation
                            }
                        }
                        .onEnded { value in
                            // swipe down to dismiss
                            if scale == 1.0 && value.translation.height > 100 {
                                dismiss()
                            }
                        }
                )
        }
        // floating X button in the top right
        .overlay(alignment: .topTrailing) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
            }
        }
    }
}
