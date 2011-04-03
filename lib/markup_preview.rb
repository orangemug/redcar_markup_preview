# Add all gems from vendor to the load path.
$:.unshift(File.dirname(__FILE__) + '/../vendor/maruku/lib')
$:.unshift(File.dirname(__FILE__) + '/../vendor/redcloth/gems/RedCloth-4.2.2-universal-java/lib')

require "maruku"
require "redcloth"
require "markup_preview/list_dialog"
require 'rdoc/markup/simple_markup'
require 'rdoc/markup/simple_markup/to_html'

module Redcar
  module MarkupPreview
    class MarkupPreview
      def self.keymaps
        osx = Keymap.build("main", :osx) do
          link "Ctrl+Shift+P", RenderMarkupAuto
          link "Cmd+Shift+M",  RenderMarkupPreview
        end
        
        linwin = Keymap.build("main", [:linux, :windows]) do
          link "Ctrl+Shift+P", RenderMarkupAuto
          link "Ctrl+Shift+M", RenderMarkupPreview
        end
        
        [linwin, osx]
      end
      
      def self.menus
        Menu::Builder.build do
          sub_menu "Plugins" do
            sub_menu "Markup Preview" do
              item "Preview (Auto)",   RenderMarkupAuto
              item "Preview (Choice)", RenderMarkupPreview
            end
          end
        end
      end
      
      class RenderMarkupPreview < Redcar::Command
        def initialize(type = nil)
          @type = type
        end

        def execute()
          unless @type
            win = Redcar.app.focussed_window
            dialog = ListDialog.new
            dialog.update_list([ "Preview Markdown", "Preview Textile", "Preview RDoc" ])
            offset = Redcar.app.focussed_window.focussed_notebook_tab.edit_view.document.cursor_offset
            dialog.set_location(offset)
            dialog.open
          else
            MarkupPreviewGenerator.new(@type)
          end
        end
      end

      class RenderMarkupAuto < Redcar::Command
        def execute()
          type = case tab.document.path
            when /.*\.(markdown|md)$/: :markdown
            when /.*\.(textile)$/:     :textile
            when /.*\.(rdoc)$/:        :rdoc
            # when /.*\.(org)$/:         :org
            else
              nil
          end

          Redcar::MarkupPreview::MarkupPreview::RenderMarkupPreview.new(type).run
        end
      end
      
      private
      
      class MarkupPreviewView
        class InvalidType < StandardError; end
        include HtmlController
        
        def initialize(file, html, type)
          @title          = "[%s] %s" % [type.to_s, file]
          @generated_html = html
        end
        
        def title
          # Title of the tab
          @title
        end
        
        def index
          # Render
          rhtml = ERB.new(File.read(File.join(File.dirname(__FILE__), "..", "views", "index.html.erb")))
          rhtml.result(binding)
        end
      end
      
      class MarkupPreviewGenerator
        def initialize(type)
          begin
            win = Redcar.app.focussed_window
            tab = win.focussed_notebook.focussed_tab
            
            # Is there a tab open?
            if tab && tab.document then
              doc = tab.document
              if doc.path
                file = doc.path.gsub(Redcar::Project::Manager.focussed_project.path + "/", "")
              else
                file = "not saved yet"
              end

              doc = doc.to_s
              generated_html = case type
              when :markdown: Maruku.new(doc).to_html
              when :textile:  RedCloth.new(doc).to_html
              when :rdoc:
                sm = SM::SimpleMarkup.new
                th = SM::ToHtml.new()
                sm.convert(doc, th).to_s
              else
                Application::Dialog.message_box("Unsupported file type.")
                return
              end
              
              controller = MarkupPreviewView.new(file, generated_html, type)
              tab = win.new_tab(HtmlTab)
              tab.html_view.controller = controller
              tab.focus
            else
              Application::Dialog.message_box("There's no editable tab open. Open a tab with supported markup to generate output.")
            end
          rescue Object => e
            Application::Dialog.message_box("MarkupViewer error: #{e}")
          end
        end
      end
    end
  end
end
