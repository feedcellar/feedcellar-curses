# module Feedcellar::Curses::View
#
# Copyright (C) 2013-2015  Masafumi Yokoyama <myokoym@gmail.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require "curses"

module Feedcellar
  module Curses
    module View
      module_function
      def run(feeds)
        ::Curses.init_screen
        ::Curses.noecho
        ::Curses.nonl

        # TODO
        feeds = feeds.to_a
        feeds.reject! {|feed| feed.title.nil? }

        render_feeds(feeds)
        ::Curses.setpos(0, 0)

        pos = 0
        begin
          loop do
            case ::Curses.getch
            when "j"
              pos += 1 if pos < ::Curses.lines - 1
              ::Curses.setpos(pos, 0)
            when "k"
              pos -= 1 if pos > 0
              ::Curses.setpos(pos, 0)
            when "f", 13
              spawn("firefox",
                    feeds[pos].link,
                    [:out, :err] => "/dev/null")
            when "d"
              mainwin = ::Curses.stdscr
              mainwin.clear
              subwin = mainwin.subwin(mainwin.maxy, mainwin.maxx, 0, 0)
              subwin.setpos(0, 0)
              subwin.addstr(feeds[pos].title)
              subwin.setpos(3, 0)
              subwin.addstr(feeds[pos].resource.title)
              subwin.setpos(6, 0)
              subwin.addstr(feeds[pos].description)
              subwin.refresh
              ::Curses.getch
              subwin.clear
              subwin.close
              render_feeds(feeds)
              ::Curses.setpos(pos, 0)
            when "q"
              break
            end
          end
        ensure
          ::Curses.close_screen
        end
      end

      module_function
      def render_feeds(feeds)
        feeds.each_with_index do |feed, i|
          ::Curses.setpos(i, 0)
          title = feed.title.gsub(/\n/, " ")
          date = feed.date.strftime("%Y/%m/%d")
          ::Curses.addstr("#{date} #{title}")
        end
      end

      private_class_method :render_feeds
    end
  end
end
