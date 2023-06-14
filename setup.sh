# script written by logzinga, feel free to modify to fit your needs
# this script is intended to be run with root

clear
echo "Installing Dependencies"
pacman -Syu ffmpeg imagemagick libidn libpqxx libxml2 libxslt libyaml nodejs postgresql redis ruby-bundler protobuf yarn zlib base-devel


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
echo "Creating mastodon DB user" # super experimental aaaa
sudo -l -u postgres psql -c "CREATE USER mastodon CREATEDB; \q"

clear
echo "Checking out Code"
su - mastodon -c "git clone https://github.com/glitch-soc/mastodon.git live"

clear
echo "Installing final dependencies"
su - mastodon -c "cd live && bundle config deployment 'true'"
su - mastodon -c "cd live && bundle config without 'development test'"
su - mastodon -c "cd live && bundle install -j$(getconf _NPROCESSORS_ONLN)"
su - mastodon -c "cd live && yarn install --pure-lockfile"