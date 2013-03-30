require 'rack'
require 'tilt'
require 'erb'

module EPUB
  module Search
    class Server
      include ERB::Util
      TEMPLATE_DIR = File.join(__dir__, '../../../template')

      # @param [Database] database
      def initialize(database)
        @db = database
      end

      def call(env)
        @env = env
        @request = Rack::Request.new(@env)
        @response = Rack::Response.new
        @query = @request['query']
        if @query
          @db.search @query do |result|
            @result = result
            @search_result = Tilt.new(File.join(TEMPLATE_DIR, 'result.html.erb')).render(self)
          end
        end
        @response.headers['Content-Type'] = 'text/html; charset=UTF-8'
        @response.body = Tilt.new(File.join(TEMPLATE_DIR, 'index.html.erb')).render(self).each_line
        @response.finish
      end
    end
  end
end
