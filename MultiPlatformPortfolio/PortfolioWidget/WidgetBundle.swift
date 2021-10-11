import WidgetKit
import SwiftUI

// MARK: - Widget Bundle
@main
struct PortfolioWidgets: WidgetBundle {
    var body: some Widget {
        SimpleWidget()
        ComplexPortfolioWidget()
    }
}
