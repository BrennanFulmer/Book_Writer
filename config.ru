require './config/environment'

if ActiveRecord::Migrator.needs_migration?
  raise 'Migrations are pending run `rake db:migrate` to resolve the issue.'
end

use Rack::MethodOverride
run ApplicationController
use BooksController
use ChaptersController
use UsersController
