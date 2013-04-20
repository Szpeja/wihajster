require 'bundler'
require 'yard'
require 'redcarpet'

YARD::Rake::YardocTask.new do |t|
  t.files   = [
    'lib/**/*.rb', 
    'app/**/*.rb',
    '-', # Additional files separator
    'doc/*.html',
    'doc/*.md',
    'Readme.md',
  ]
  t.options << '-opublic' <<
    '--title' << "Wihajster Documentation" <<
    '--readme' << 'Readme.md'
end
