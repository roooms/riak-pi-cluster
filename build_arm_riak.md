# Build Riak for ARM on Raspberry Pi

```
default username: pi
default password: raspberry

# Add Erlang Solutions as a source
echo 'deb http://binaries.erlang-solutions.com/debian wheezy contrib' | sudo tee -a /etc/apt/sources.list
wget -O - http://binaries.erlang-solutions.com/debian/erlang_solutions.asc | sudo apt-key add -

# Update apt list
sudo apt-get update --fix-missing

# Install some useful packages
sudo apt-get install --yes \
vim \
libpam0g-dev

# Install Erlang R16B02
sudo apt-get install --yes \
erlang-xmerl=1:16.b.2 \
erlang-os-mon=1:16.b.2 \
erlang-snmp=1:16.b.2 \
erlang-reltool=1:16.b.2 \
erlang-wx=1:16.b.2 \
erlang-ssh=1:16.b.2 \
erlang-parsetools=1:16.b.2 \
erlang-tools=1:16.b.2 \
erlang-webtool=1:16.b.2 \
erlang-inets=1:16.b.2 \
erlang-eunit=1:16.b.2 \
erlang-runtime-tools=1:16.b.2 \
erlang-mnesia=1:16.b.2 \
erlang-ssl=1:16.b.2 \
erlang-public-key=1:16.b.2 \
erlang-asn1=1:16.b.2 \
erlang-syntax-tools=1:16.b.2 \
erlang-crypto=1:16.b.2 \
erlang-dev=1:16.b.2 \
erlang-base=1:16.b.2

# Switch to Debian Jessie to install later GCC and G++ version
sudo sed -i 's/wheezy/jessie/g' /etc/apt/sources.list
sudo apt-get update --fix-missing
sudo apt-get install gcc=4:4.9.2-2 g++=4:4.9.2-2 --yes
sudo sed -i 's/jessie/wheezy/g' /etc/apt/sources.list

# Download and unpack Riak 2.0.6
wget http://s3.amazonaws.com/downloads.basho.com/riak/2.0/2.0.6/riak-2.0.6.tar.gz
tar xf riak-2.0.6.tar.gz && cd riak-2.0.6

# Switch out basho/eleveldb for roooms/eleveldb for ARM support
sed -e "s/basho\/eleveldb/roooms\/eleveldb/" -i rebar.config.lock
sed -e "s/8ddfc6a497f817e6eace808936e6a123ff405aa8/cca79915085277d41cffae8d4d14405e034de776/" -i rebar.config.lock
sed -e "s/basho\/eleveldb/roooms\/eleveldb/" -i deps/riak_core/rebar.config
sed -e "s/basho\/eleveldb/roooms\/eleveldb/" -i deps/riak_ensemble/rebar.config

# Make the release
make rel
```
