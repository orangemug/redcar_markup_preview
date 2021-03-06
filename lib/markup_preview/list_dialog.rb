module Redcar
  module MarkupPreview
    class ListDialog < Redcar::ModelessListDialog
      def selected(index)
        case select(index)
        when /textile/i
          Redcar::MarkupPreview::MarkupPreview::RenderMarkupPreview.new(:textile).run
        when /markdown/i
          Redcar::MarkupPreview::MarkupPreview::RenderMarkupPreview.new(:markdown).run
        when /rdoc/i
          Redcar::MarkupPreview::MarkupPreview::RenderMarkupPreview.new(:rdoc).run
        end
      end
    end
  end
end
