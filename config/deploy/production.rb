set :branch, "main"
set :deploy_to, "/var/apps/digital_stress"

role :app, "app1.kev.cool"

server "app1.kev.cool", user: "deploy", roles: %w{app}

after "deploy:publishing", "bot:restart"

namespace :bot do
  task :restart do
    on roles(:app) do
      execute "sudo service digital_stress restart"
      execute "sudo service clockwork-digital_stress restart"
    end
  end

  task :stop do
    on roles(:app) do
      execute "sudo service digital_stress stop"
      execute "sudo service clockwork-digital_stress stop"
    end
  end

  task :start do
    on roles(:app) do
      execute "sudo service digital_stress start"
      execute "sudo service clockwork-digital_stress start"
    end
  end
end
