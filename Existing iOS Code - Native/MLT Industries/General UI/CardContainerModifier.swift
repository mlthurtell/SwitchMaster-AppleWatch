//
//  CardContainerModifier.swift
//  MLT Industries
//
//  Created by Davis Allie on 30/10/21.
//

import SwiftUI

struct CardContainerModifier: ViewModifier {
    
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .containerShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(radius: 4)
            .padding(4)
    }
    
}

extension View {
    
    func embedInCardContainer(horizontalPadding: CGFloat = 8, verticalPadding: CGFloat = 12) -> some View {
        self.modifier(CardContainerModifier(horizontalPadding: horizontalPadding, verticalPadding: verticalPadding))
    }
    
}
