//
//  TabControl.swift
//

import SwiftUI

public struct TabControl<Content: View, ItemType>: View {
    
    public enum TabControlStyle: Hashable {
        case fit(_ maxItem: Int)
        case fill
    }
    
    public enum IndicatorPosition: Hashable {
        case top
        case bottom
    }
    
    private let bottomIndicatorBackgroundColor: Color
    private let bottomIndicatorHeight: CGFloat
    private let bottomIndicatorWidth: CGFloat?
    private let bottomIndicatorPosition: IndicatorPosition
    private let items: [ItemType]
    private let isFullWidthIndicator: Bool
    private let onItemSelection: ((ItemType, Int) -> Void)?
    private let style: TabControlStyle
    
    @Binding private var selection: Int
    @State private var activeIdx: Int = 0
    @State private var maxHeight: CGFloat = .zero
    
    @ViewBuilder private let content: (_ item: ItemType, _ index: Int) -> Content
    
    public init(
        items: [ItemType],
        selection: Binding<Int>,
        @ViewBuilder content: @escaping (_ item: ItemType, _ index: Int) -> Content
    ) {
        self.bottomIndicatorBackgroundColor = .primary
        self.bottomIndicatorHeight = 3.0
        self.bottomIndicatorWidth = nil
        self.bottomIndicatorPosition = .bottom
        self.items = items
        self.isFullWidthIndicator = true
        self.onItemSelection = nil
        self.style = .fill
        self._selection = selection
        self.activeIdx = selection.wrappedValue
        self.content = content
    }
    
    private init(
        items: [ItemType],
        isFullWidthIndicator: Bool,
        indicatorBackgroundColor: Color,
        indicatorHeight: CGFloat,
        indicatorWidth: CGFloat?,
        indicatorPosition: IndicatorPosition,
        onItemSelection: ((ItemType, Int) -> Void)?,
        style: TabControlStyle,
        selection: Binding<Int>,
        @ViewBuilder content: @escaping (_ item: ItemType, _ index: Int) -> Content
    ) {
        self.bottomIndicatorBackgroundColor = indicatorBackgroundColor
        self.bottomIndicatorHeight = indicatorHeight
        self.bottomIndicatorWidth = indicatorWidth
        self.bottomIndicatorPosition = indicatorPosition
        self.items = items
        self.isFullWidthIndicator = isFullWidthIndicator
        self.onItemSelection = onItemSelection
        self.style = style
        self._selection = selection
        self.activeIdx = selection.wrappedValue
        self.content = content
    }
    
    
    public var body: some View {
        if items.count < 2 { EmptyView() }
        
        GeometryReader { geometry in
            switch style {
            case .fit(let maxItem) where maxItem >= items.count:
                content(geometry)
            default:
                ScrollView(.horizontal, showsIndicators: false) { scrollViewProxy in
                    content(geometry, scrollViewProxy: scrollViewProxy)
                }
            }
        }
        .frame(maxHeight: maxHeight)
        .observeChange(of: activeIdx) { newValue in
            selection = newValue
            onItemSelection?(items[newValue], newValue)
        }
    }
    
    
    private func content(_ geometry: GeometryProxy, scrollViewProxy: RapidSwiftUI.ScrollViewProxy? = nil) -> some View {
        HStack(alignment: .bottom, spacing: 2.0) {
            ForEach(items.indices) { index in
                VStack {
                    content(items[index], index)
                        .padding(12)
                        .anchorPreference(key: TextPreferenceKey.self, value: .bounds, transform: { [TextPreferenceData(viewIdx: index, viewType: .item, bounds: $0)]})
                }.frame(
                    width: {
                        switch style {
                        case .fit(let maxItem): return abs((geometry.size.width - 12) / CGFloat(maxItem))
                        case .fill: return nil
                        }
                    }()
                ).transformAnchorPreference(
                    key: TextPreferenceKey.self, value: .bounds,
                    transform: { $0.append(TextPreferenceData(viewIdx: index, viewType: .itemContainer, bounds: $1)) }
                ).background(GeometryReader {
                    Color.white.opacity(0.0000000000001)
                        .preference(key: ViewHeightKey.self, value: $0.frame(in: .local).size.height)
                }).onPreferenceChange(ViewHeightKey.self) {
                    self.maxHeight = $0 + 4
                }.onTapGesture {
                    self.activeIdx = index
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        scrollViewProxy?.scrollTo(index, alignment: .center, animated: true)
                    }
                }
                .scrollId(index)
            }
        }
        .padding(.top, 4)
        .backgroundPreferenceValue(TextPreferenceKey.self) { preferences in
            GeometryReader { geometry in
                indicator(geometry, preferences)
            }
        }
    }
    
    private func indicator(_ geometry: GeometryProxy, _ preferences: [TextPreferenceData]) -> some View {
        let viewType: TextPreferenceData.ViewType = isFullWidthIndicator ? .itemContainer : .item
        let preference = preferences.first(where: { $0.viewIdx == activeIdx && $0.viewType == viewType })
        
        let bounds = preference.map { geometry[$0.bounds] } ?? .zero
        
        let width = bottomIndicatorWidth ?? bounds.size.width
        let height = bottomIndicatorHeight
        
        return RoundedRectangle(cornerRadius: 0)
            .fill(bottomIndicatorBackgroundColor)
            .frame(width: width, height: height)
            .fixedSize()
            .offset(x: bounds.midX  - width * 0.5, y: bottomIndicatorPosition == .bottom ? bounds.maxY : 0)
            .animation(.easeInOut(duration: 0.5), value: activeIdx)
    }
}

public extension TabControl {
    func fullWidthIndicator(_ bool: Bool) -> TabControl {
        return .init(items: items, isFullWidthIndicator: bool, indicatorBackgroundColor: bottomIndicatorBackgroundColor, indicatorHeight: bottomIndicatorHeight, indicatorWidth: bool ? nil : bottomIndicatorWidth, indicatorPosition: bottomIndicatorPosition, onItemSelection: onItemSelection, style: style, selection: _selection, content: content)
    }
    
    func indicatorBackgroundColor(_ color: Color) -> TabControl {
        return .init(items: items, isFullWidthIndicator: isFullWidthIndicator, indicatorBackgroundColor: color, indicatorHeight: bottomIndicatorHeight, indicatorWidth: bottomIndicatorWidth, indicatorPosition: bottomIndicatorPosition, onItemSelection: onItemSelection, style: style, selection: _selection, content: content)
    }
    
    func onSelect(_ selection: ((ItemType, Int) -> Void)? = nil) -> TabControl {
        return .init(items: items, isFullWidthIndicator: isFullWidthIndicator, indicatorBackgroundColor: bottomIndicatorBackgroundColor, indicatorHeight: bottomIndicatorHeight, indicatorWidth: bottomIndicatorWidth, indicatorPosition: bottomIndicatorPosition, onItemSelection: selection, style: style, selection: _selection, content: content)
    }
    
    func tabControlStyle(_ style: TabControlStyle) -> TabControl {
        return .init(items: items, isFullWidthIndicator: isFullWidthIndicator, indicatorBackgroundColor: bottomIndicatorBackgroundColor, indicatorHeight: bottomIndicatorHeight, indicatorWidth: bottomIndicatorWidth, indicatorPosition: bottomIndicatorPosition, onItemSelection: onItemSelection, style: style, selection: _selection, content: content)
    }
    
    func indicatorFrame(width: CGFloat? = nil, height: CGFloat? = nil) -> TabControl {
        return .init(items: items, isFullWidthIndicator: width != nil ? false : isFullWidthIndicator, indicatorBackgroundColor: bottomIndicatorBackgroundColor, indicatorHeight: height ?? bottomIndicatorHeight, indicatorWidth: width, indicatorPosition: bottomIndicatorPosition, onItemSelection: onItemSelection, style: style, selection: _selection, content: content)
    }
    
    func indicatorPosition(_ position: IndicatorPosition) -> TabControl {
        return .init(items: items, isFullWidthIndicator: isFullWidthIndicator, indicatorBackgroundColor: bottomIndicatorBackgroundColor, indicatorHeight: bottomIndicatorHeight, indicatorWidth: bottomIndicatorWidth, indicatorPosition: position, onItemSelection: onItemSelection, style: style, selection: _selection, content: content)
    }
}


fileprivate struct TextPreferenceData: Equatable {
    let viewIdx: Int
    let viewType: ViewType
    let bounds: Anchor<CGRect>
    
    enum ViewType: Equatable {
        case item
        case itemContainer
    }
}

fileprivate struct TextPreferenceKey: PreferenceKey {
    typealias Value = [TextPreferenceData]
    
    static var defaultValue: [TextPreferenceData] = []
    
    static func reduce(value: inout [TextPreferenceData], nextValue: () -> [TextPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}

fileprivate struct ViewHeightKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
