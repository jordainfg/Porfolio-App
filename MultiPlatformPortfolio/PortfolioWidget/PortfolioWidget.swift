import WidgetKit
import SwiftUI


// MARK: - Widget Bundle
@main
struct PortfolioWidgets: WidgetBundle {
    var body: some Widget {
        SimplePortfolioWidget()
        ComplexPortfolioWidget()
    }
}




// MARK: - Preview
// Determines how our widget should be previewed inside Xcode
