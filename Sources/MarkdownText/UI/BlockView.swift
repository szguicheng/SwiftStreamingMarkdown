//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation
import SwiftUI

struct BlockView: View {

  @Environment(\.markdownConfig) var config: MarkdownRenderConfig

  let renderables: [MarkdownRenderable]

  init(renderables: [MarkdownRenderable]) {
    self.renderables = renderables
  }

  /// Block-to-block spacing proportional to paragraph font size.
  /// At the default 17pt font: 17 × 0.6 ≈ 10pt. Scales automatically with DynamicType.
  private var blockSpacing: CGFloat {
    config.paragraphStyle.textFonts.normal.pointSize * 0.6
  }

  var body: some View {
    VStack(alignment: .leading, spacing: blockSpacing) {
      ForEach(renderables) { renderable in
        SingleBlockView(renderable: renderable)
      }
    }
  }
}

struct SingleBlockView: View {

  @Environment(\.markdownConfig) var config: MarkdownRenderConfig

  let renderable: MarkdownRenderable

  init(renderable: MarkdownRenderable) {
    self.renderable = renderable
  }

  var body: some View {
    Group {
      switch renderable {
      case .heading(_, _, let contents):
        HStack(spacing: 0) {
          ParagraphView(contents: contents)
            .transition(.opacity)
            .accessibilityAddTraits(.isHeader)
          Spacer()
        }
      case .paragraph(_, let contents):
        HStack(spacing: 0) {
          ParagraphView(contents: contents, lineSpacing: 5)
            .fixedSize(horizontal: false, vertical: true)
            .transition(.opacity)
          Spacer()
        }
      case .latex(_, let latexString):
        ScrollView(.horizontal) {
          HStack(spacing: 0) {
            BlockMathView(latex: latexString, color: Color(config.paragraphStyle.textColor))
            Spacer()
          }
        }.scrollIndicators(.hidden)
      case .orderedList(_, let items):
        OrderedListView(items: items)
      case .unorderedList(_, let items, let nestedLevel):
        UnorderedListView(items: items, nestedLevel: nestedLevel)
      case .codeBlock(_, let language, let code):
        CodeBlockView(language: language ?? "",
                      code: code)
      case .thematicBreak:
        ThematicBreakView()
      case .table(_, let headers, let rows, let rawMarkdown):
        TableView(headings: headers,
                  rows: rows,
                  rawMarkdown: rawMarkdown)
      case .blockQuote(_, let item):
        BlockQuoteView(item: item)
      }
    }
  }
}
