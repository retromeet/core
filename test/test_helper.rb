# frozen_string_literal: true

ENV["APP_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "webmock/minitest"

require_relative "../config/environment"
Environment.load

require_relative "../config/zeitwerk"

require_relative "db_helper"
require_relative "rack_helper"

# Make factory_bot methods available in spec-style tests
module Minitest
  class Spec
    include FactoryBot::Syntax::Methods
  end
end
FactoryBot.find_definitions
FactoryBot.define do
  to_create(&:save_changes)
end

# This is needed for the PhotonClient test, since it receives the params repeateadly. If another test breaks because of it, a different way to configure needs to be looked upon
WebMock::Config.instance.query_values_notation = :flat_array

# Adds a helper method that loads a json file from the webfixtures directory
# @raise (see File.open)
# @return [String]
def webfixture_json_file(filename) = File.open("test/webfixtures/#{filename}.json")

require_relative "swagger_helper"

SwaggerHelper.prepare!

# Adapted from https://github.com/rails/rails/blob/97169912f197eee6e76fafb091113bddf624aa67/activesupport/lib/active_support/testing/assertions.rb#L101
# Test numeric difference between the return value of an expression as a
# result of what is evaluated in the yielded block.
# An arbitrary positive or negative difference can be specified.
# The default is +1+.
#
#   assert_difference 'Article.count', -1 do
#     post :delete, params: { id: ... }
#   end
# An array of expressions can also be passed in and evaluated.
#
#   assert_difference [ 'Article.count', 'Post.count' ], 2 do
#     post :create, params: { article: {...} }
#   end
#
# A hash of expressions/numeric differences can also be passed in and evaluated.
#
#   assert_difference ->{ Article.count } => 1, ->{ Notification.count } => 2 do
#     post :create, params: { article: {...} }
#   end
#
# A lambda or a list of lambdas can be passed in and evaluated:
#
#   assert_difference ->{ Article.count }, 2 do
#     post :create, params: { article: {...} }
#   end
#
#   assert_difference [->{ Article.count }, ->{ Post.count }], 2 do
#     post :create, params: { article: {...} }
#   end
def assert_difference(expression, *args, &block)
  expressions =
    if expression.is_a?(Hash)
      message = args[0]
      expression
    else
      difference = args[0] || 1
      message = args[1]
      Array(expression).index_with(difference)
    end

  exps = expressions.keys.map do |e|
    e.respond_to?(:call) ? e : -> { eval(e, block.binding) } # rubocop:disable Security/Eval
  end
  before = exps.map(&:call)

  retval = yield

  expressions.zip(exps, before) do |(code, diff), exp, before_value|
    actual = exp.call
    error  = "#{code.inspect} didn't change by #{diff}, but by #{actual - before_value}"
    error  = "#{message}.\n#{error}" if message

    assert_equal(before_value + diff, actual, error)
  end

  retval
end
