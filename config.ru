require_relative 'lotto.rb'

require 'rack/conditionalget'
require 'rack/deflater'

use Rack::ConditionalGet
use Rack::Deflater

run Sinatra::Application
# run LottoApp.new
