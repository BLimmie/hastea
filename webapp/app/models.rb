# Sets up database connection and includes all the models for convenience.

require "sequel"

require_relative "models/run.rb"
require_relative "models/user.rb"
require_relative "models/order.rb"
require_relative "models/comment.rb"
