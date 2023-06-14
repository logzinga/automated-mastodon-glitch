# script written by logzinga, feel free to modify to fit your needs
# this script is intended to be run with root

clear
echo "Installing Dependencies"
pacman -Syu ffmpeg imagemagick libidn libpqxx libxml2 libxslt libyaml nodejs postgresql redis ruby-bundler protobuf yarn zlib base-devel


clear
echo "Adding Mastodon User"
useradd -m mastodon

clear
echo "Installing Ruby for user Mastodon"
su - mastodon -c "git clone https://github.com/rbenv/rbenv.git ~/.rbenv"
su - mastodon -c "cd ~/.rbenv && src/configure && make -C src"
su - mastodon -c "echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc"
su - mastodon -c "echo 'eval "$(rbenv init -)"' >> ~/.bashrc"
su - mastodon -c "exec bash"
su - mastodon -c "git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build"

