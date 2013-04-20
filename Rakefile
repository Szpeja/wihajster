require 'bundler'
require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = [
    'lib/**/*.rb', 
    'app/**/*.rb',
    '-', # Additional files separator
    'doc/*.html',
    'doc/*.md',
  ]
  t.options << '-opublic' << '--title' << "Wihajster Documentation"
end
