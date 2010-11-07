# Add all gems from vendor to the load path.
Dir.glob(File.dirname(__FILE__) + "/../vendor/*").each do |path|
  gem_name = File.basename(path.gsub(/-[\d\.]+$/, ''))
  puts "loading %s" % gem_name
  $LOAD_PATH << path + "/lib/"
end

require 'maruku'

module Redcar

  class Markdown  
    def self.keymaps
      osx = Keymap.build("main", :osx) do
        link "Cmd+Shift+M", Markdown::Render
      end
      
      linwin = Keymap.build("main", [:linux, :windows]) do
        link "Ctrl+Shift+M", Markdown::Render
      end
      
      [linwin, osx]
    end
    
    def self.menus
      Menu::Builder.build do
        sub_menu "Plugins" do
          sub_menu "Markdown " do
            item "Render current file", Render            
          end
        end
      end
    end

    class Render < Redcar::Command
      def execute
        MarkdownTab.new(win)
      end
    end

    private

    class MarkdownView
      include HtmlController

      def initialize(file)
        @title         = "[markdown] %s" % file
        @markdown_html = Maruku.new(File.read(file)).to_html
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
    
    class MarkdownTab
      def initialize(win)
        begin
          win = Redcar.app.focussed_window
          tab = win.focussed_notebook.focussed_tab
          
          # Is there a tab open?
          if tab then
            controller = MarkdownView.new(tab.document.path)
            tab = win.new_tab(HtmlTab)
            tab.html_view.controller = controller
            tab.focus
          else
            Application::Dialog.message_box("There's no tab open. Open a tab with markdown to generate output.")
          end
        rescue Object => e
          Application::Dialog.message_box("Markdown error: #{e}")
        end
      end
    end

  end
end
