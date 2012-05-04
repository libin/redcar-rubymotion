
module Redcar
  class Cocoa
    class URLCommand < ProjectCommand
      def title;"Google";end
      def url
        "www.google.com"
      end
      def execute
        Redcar::HtmlView::DisplayWebContent.new(title,url,true,Cocoa::ReferenceTab).run
      end
    end

    class ShowRMDocs < URLCommand
      def title;"RubyMotion";end
      def url
        "www.rubymotion.com/developer-center/"
      end
    end

    class ShowIOSRefDocs < URLCommand
      def title;"iOS Reference";end
      def url
        "developer.apple.com/library/ios/navigation/#section=Resource%20Types&topic=Reference"
      end
    end

    class ShowDocsCommand < DocumentCommand
      def execute
        win = Redcar.app.focussed_window
        if win and tab = win.focussed_notebook_tab
          word = tab.edit_view.document.current_word
          url  = urlify(word)
          Redcar::HtmlView::DisplayWebContent.new(word,url,true,Cocoa::ReferenceTab).run
        end
      end

      def urlify text
        "developer.apple.com/library/ios/#documentation/UIKit/Reference/#{text}_Class/index.html"
      end
    end

    class AppleScriptCommand < ProjectCommand
      def text
        "echo 'Hello World'"
      end

      def execute
        if Cocoa.storage['save_project_before_running'] == true
          win = Redcar.app.focussed_window
          win.notebooks.each do |notebook|
            notebook.tabs.each do |tab|
              tab.edit_view.document.save! if tab.is_a?(EditTab) and tab.edit_view.document.modified?
            end
          end
        end
        Thread.new do
          system("#{commandline}")
        end
      end

      def terminal_script(preferred, new_session=false)
        if preferred.start_with? "iTerm"
          <<-OSASCRIPT
            tell the first terminal
              # launch session "Default Session"
              tell the last session
                write text "#{text}"
              end tell
            end tell
          OSASCRIPT
        else
          %{ do script "#{text}" }
        end
      end

      def commandline
        preferred = (Project::Manager.storage['preferred_command_line'] ||= "Terminal")
        <<-BASH.gsub(/^\s*/, '')
          osascript <<END
            tell application "#{preferred}"
              #{terminal_script(preferred)}
              activate
            end tell
          END
        BASH
      end
    end

    class BuildCommand < AppleScriptCommand
      def text
        "rake"
      end
    end

    class BuildAndCleanCommand < AppleScriptCommand
      def text
        "rake clean=1"
      end
    end

    class BuildOnDeviceCommand < AppleScriptCommand
      def text
        "rake device"
      end
    end

    class TestCommand < AppleScriptCommand
      def text
        "rake spec"
      end
    end

    class ArchiveCommand < AppleScriptCommand
      def text
        "rake archive"
      end
    end

    class ReleaseCommand < AppleScriptCommand
      def text
        "rake archive:release"
      end
    end

    class ConfigCommand < AppleScriptCommand
      def text
        "rake config"
      end
    end

    class QuitSimCommand < AppleScriptCommand
      def text
        "quit"
      end
    end

    class SendTicketCommand < AppleScriptCommand
      def text
        "motion support"
      end
    end
  end
end