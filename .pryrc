# this loads all of 'git-multi'
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git/multi'

# this loads all 'git multi' contribs
# rubocop:disable Lint/NonDeterministicRequireOrder
Dir.glob File.join(__dir__, 'contrib', '**', '*.rb'), &method(:require)
# rubocop:enable Lint/NonDeterministicRequireOrder

# configure a logger
require 'logger'
logger = Logger.new($stdout)
logger.level = Logger::INFO

# configure Octokit middleware with logger
require 'octokit'
Octokit.middleware.response :logger, logger

# enumerator for Faraday middleware apps
def (_middleware = Octokit.middleware).each_app
  Enumerator.new do |yielder|
    next_app = app
    while next_app
      yielder << next_app
      next_app = next_app.instance_variable_get(:@app)
    end
  end
end

# utility function to set pry context
# to an instance of <Octokit::Client>
def client
  pry(Git::Hub.send(:client))
end

# utility function to set pry context
# to the Array of github repositories
def repos
  pry(Git::Multi.repositories)
end

# utility function to set pry context
# to the various 'git multi' commands:
def cmds
  pry(Git::Multi::Commands)
end

# utility function to set context
# to the named github repository:
def repo_named(full_name)
  pry(Git::Multi.repositories.find { |repo| repo.full_name == full_name })
end
