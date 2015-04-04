# class Feedcellar::Curses::Command
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

require "thor"
require "feedcellar"
require "feedcellar/curses"

module Feedcellar
  module Curses
    class Command < Thor
      map "-v" => :version

      attr_reader :database_dir

      def initialize(*args)
        super
        default_base_dir = File.join(File.expand_path("~"), ".feedcellar-curses")
        @base_dir = ENV["FEEDCELLAR_HOME"] || default_base_dir
        @database_dir = File.join(@base_dir, "db")
      end

      desc "version", "Show version number."
      def version
        puts VERSION
      end

      desc "search WORD", "Search feeds from local database."
      option :long, :type => :boolean, :aliases => "-l", :desc => "use a long listing format"
      option :reverse, :type => :boolean, :aliases => "-r", :desc => "reverse order while sorting"
      option :mtime, :type => :numeric, :desc => "feed's data was last modified n*24 hours ago."
      option :resource, :type => :string, :desc => "search of partial match by feed's resource url"
      option :curses, :type => :boolean, :desc => "rich view for easy web browse"
      option :grouping, :type => :boolean, :desc => "group by resource"
      def search(*words)
        if words.empty? &&
           (options["resource"].nil? || options["resource"].empty?)
          $stderr.puts "WARNING: required one of word or resource option."
          return 1
        end

        GroongaDatabase.new.open(@database_dir) do |database|
          sorted_feeds = GroongaSearcher.search(database, words, options)
          View.run(sorted_feeds)
        end
      end
    end
  end
end
