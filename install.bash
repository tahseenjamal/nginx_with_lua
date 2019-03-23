sudo apt-get update

sudo apt-get --assume-yes install cmake g++ gcc libpcre3-dev zlib1g-dev libgeoip-dev libssl-dev libpcre++-dev libxslt1-dev libgd-dev libperl-dev

git clone https://github.com/openresty/lua-nginx-module.git
git clone https://github.com/simplresty/ngx_devel_kit.git
git clone https://github.com/openssl/openssl.git

wget https://github.com/openresty/luajit2/archive/v2.1-20190302.tar.gz
tar xvf v2.1-20190302.tar.gz 
rm v2.1-20190302.tar.gz 
cd luajit2-2.1-20190302/
make
sudo make install 
cd

export LUAJIT_LIB=/usr/local/lib
#Note the version of LuaJIT and basis that include file is 2.1
export LUAJIT_INC=/usr/local/include/luajit-2.1


wget http://nginx.org/download/nginx-1.15.9.tar.gz
tar xvf nginx-1.15.9.tar.gz 
rm nginx-1.15.9.tar.gz 
cd nginx-1.15.9/

./configure \
  --prefix=/etc/nginx \
  --sbin-path=/usr/sbin/nginx \
  --modules-path=/usr/lib/nginx/modules \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock \
  --user=nginx \
  --group=nginx \
  --build=Ubuntu \
  --builddir=nginx-1.15.0 \
  --with-select_module \
  --with-poll_module \
  --with-threads \
  --with-file-aio \
  --with-http_ssl_module \
  --with-http_v2_module \
  --with-http_realip_module \
  --with-http_addition_module \
  --with-http_xslt_module=dynamic \
  --with-http_image_filter_module=dynamic \
  --with-http_geoip_module=dynamic \
  --with-http_sub_module \
  --with-http_dav_module \
  --with-http_flv_module \
  --with-http_mp4_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_auth_request_module \
  --with-http_random_index_module \
  --with-http_secure_link_module \
  --with-http_degradation_module \
  --with-http_slice_module \
  --with-http_stub_status_module \
  --with-http_perl_module=dynamic \
  --with-perl_modules_path=/usr/share/perl/5.26.1 \
  --with-perl=/usr/bin/perl \
  --http-log-path=/var/log/nginx/access.log \
  --http-client-body-temp-path=/var/cache/nginx/client_temp \
  --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
  --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
  --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
  --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
  --with-mail=dynamic \
  --with-mail_ssl_module \
  --with-stream=dynamic \
  --with-stream_ssl_module \
  --with-stream_realip_module \
  --with-stream_geoip_module=dynamic \
  --with-stream_ssl_preread_module \
  --with-compat \
  --with-openssl=$HOME/openssl \
  --with-openssl-opt=no-nextprotoneg \
  --with-debug \
  --with-ld-opt="-Wl,-rpath,/usr/local/lib" \
  --add-module=$HOME/ngx_devel_kit \
  --add-module=$HOME/lua-nginx-module

make
sudo make install
cd

sudo rm -rf lua-nginx-module ngx_devel_kit openss luajit2-2.1-20190302 nginx-1.15.9

sudo ln -s /usr/lib/nginx/modules /etc/nginx/modules
sudo adduser --system --home /nonexistent --shell /bin/false --no-create-home --disabled-login --disabled-password --gecos "nginx user" --group nginx

sudo mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/proxy_temp /var/cache/nginx/scgi_temp /var/cache/nginx/uwsgi_temp /var/log/nginx
sudo chmod 700 /var/cache/nginx/*
sudo chown nginx:root /var/cache/nginx/*
sudo chown -R nginx:nginx /var/log/nginx

echo '''
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target''' | sudo tee /etc/systemd/system/nginx.service


sudo systemctl enable nginx.service
sudo systemctl start nginx.service


