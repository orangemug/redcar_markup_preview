# Add all gems from vendor to the load path.
$:.unshift(File.dirname(__FILE__) + '/../vendor/creole/')
$:.unshift(File.dirname(__FILE__) + '/../vendor/maruku/lib')
$:.unshift(File.dirname(__FILE__) + '/../vendor/org-ruby/lib')
$:.unshift(File.dirname(__FILE__) + '/../vendor/redcloth/lib')
$:.unshift(File.dirname(__FILE__) + '/../vendor/rubypants/')

# Libs
require 'maruku'
require 'org-ruby' # currently not used, but fails to load the plugin when not required
require 'redcloth'

module Redcar

  class MarkupViewer  
    def self.keymaps
      osx = Keymap.build("main", :osx) do
        link "Cmd+Shift+M", MarkupViewer::Render
      end
      
      linwin = Keymap.build("main", [:linux, :windows]) do
        link "Ctrl+Shift+M", MarkupViewer::Render
      end
      
      [linwin, osx]
    end
    
    def self.menus
      Menu::Builder.build do
        sub_menu "Plugins" do
          sub_menu "Markup Viewer " do
            item "Generate from filename", Render
            item "Generate MarkupViewer", RenderMarkupViewer
            item "Generate Textile", RenderTextile
          end
        end
      end
    end

    class Render < Redcar::Command
      def execute
        MarkupViewerGenerator.new(win)
      end
    end

    class RenderMarkupViewer < Redcar::Command
      def execute
        MarkupViewerGenerator.new(win, :markdown)
      end
    end

    class RenderTextile < Redcar::Command
      def execute
        MarkupViewerGenerator.new(win, :textile)
      end
    end

    private

    class MarkupViewerView
      class InvalidType < StandardError; end
      include HtmlController

      def initialize(file, html, type = "markdown")
        @title          = "[%s] %s" % [type, file]
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
    
    class MarkupViewerGenerator
      def initialize(win, type=nil)
        begin
          win = Redcar.app.focussed_window
          tab = win.focussed_notebook.focussed_tab          
          
          # Is there a tab open?
          if tab && tab.document then
            file = tab.document.path
            
            if !type then
              type = case file
                when /.*\.(markdown|md)$/: :markdown
                when /.*\.(textile)$/:     :textile
                # when /.*\.(org)$/:         :org
                else
                  nil
              end
            end            
                        
            generated_html = case type
              when :markdown: Maruku.new(File.read(file)).to_html
              when :textile:  RedCloth.new(File.read(file)).to_html
              # when :org:      Orgmode::Parser.new(File.read(file)).to_html
              else
                Application::Dialog.message_box("Unsupported file type.")
                return
            end
            
            controller = MarkupViewerView.new(file, generated_html, type.to_s)
            tab = win.new_tab(HtmlTab)
            tab.html_view.controller = controller
            tab.focus
          else
            Application::Dialog.message_box("There's no editable tab open. Open a tab with markdown to generate output.")
          end          
        rescue Object => e
          Application::Dialog.message_box("MarkupViewer error: #{e}")
        end
      end
    end

  end
end
