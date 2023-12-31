# script written by logzinga, feel free to modify to fit your needs
# this script is intended to be run with root

cd ~
git clone https://github.com/logzinga/automated-mastodon-glitch # for nginx configuration file locations, might not be located in the right spot by default

clear
echo "Installing Dependencies"
pacman -Syu ffmpeg imagemagick libidn libpqxx libxml2 libxslt libyaml nodejs postgresql redis ruby-bundler protobuf yarn zlib base-devel nginx nano


clear
echo "Adding Mastodon User"
useradd -m mastodon

clear
#echo "Installing Ruby for user Mastodon" # i really don't think this is required, keeping here if it is
#git clone https://github.com/rbenv/rbenv.git /home/mastodon/.rbenv
#cd /home/mastodon/.rbenv && src/configure && make -C src
#chown -hR mastodon:mastodon /home/mastodon/.rbenv
#su - mastodon -c "echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc"
#su - mastodon -c "echo 'eval "$(rbenv init -)"' >> ~/.bashrc"
#exec bash
#git clone https://github.com/rbenv/ruby-build.git /home/mastodon/.rbenv/plugins/ruby-build
#chown -hR mastodon:mastodon /home/mastodon/.rbenv/plugins/ruby-build

clear
echo "Initialising PostgreSQL"
su - postgres -c "initdb -D '/var/lib/postgres/data'" # not sure if locales are supposed to be there but whatever
systemctl enable --now postgresql.service

clear
echo "Type 'CREATE USER mastodon CREATEDB;' then press enter, once that is done type '\q' then press enter" # automate this!!!!
sudo -u postgres psql 

clear
echo "Checking out Code"
su - mastodon -c "git clone https://github.com/glitch-soc/mastodon.git live"

clear
echo "Installing final dependencies"
su - mastodon -c "cd live && bundle config deployment 'true'"
su - mastodon -c "cd live && bundle config without 'development test'"
su - mastodon -c "cd live && bundle install -j$(getconf _NPROCESSORS_ONLN)"
su - mastodon -c "cd live && yarn install --pure-lockfile"
systemctl enable --now redis.service

clear
echo "The interactive setup will now run, please keep in mind that the script will automatically precompile the assets so make sure to say NO to any precompiling."
sleep 15
su - mastodon -c "cd live && RAILS_ENV=production bundle exec rake mastodon:setup"

clear 
echo "Precompiling..."
su - mastodon -c "cd live && RAILS_ENV=production NODE_OPTIONS=--openssl-legacy-provider bundle exec rails assets:precompile"

clear 
echo "Copying systemd Units"
cp /home/mastodon/live/dist/mastodon-*.service /etc/systemd/system

clear
echo "Starting and Enabling Systemd"
systemctl daemon-reload
systemctl enable --now mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service

clear
echo "Setting up NGINX"
mkdir /etc/nginx/sites-available
mkdir /etc/nginx/sites-enabled
cp /home/mastodon/live/dist/nginx.conf /etc/nginx/sites-available/mastodon
cp ~/automated-mastodon-glitch/config/nginx.conf /etc/nginx/nginx.conf
ln -s /etc/nginx/sites-available/mastodon /etc/nginx/sites-enabled/mastodon

clear
echo "Now, find 'example.com' and replace it with your domain name that you said in the interactive configuration."
sleep 15
nano /etc/nginx/nginx.conf