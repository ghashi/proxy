namespace :app do
  desc "This task erases the database and creates new ip file"
  task :restart do
    Rake::Task['db:reset'].invoke
    p "Users detroyed!"

    `touch config/ip`
    `echo 127.1.1.0 > config/ip`
    p "New ip file create"
  end
end
