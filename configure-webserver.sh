#!/bin/bash
set -eu -o pipefail # fail on error , debug all lines

## Backup original nginx.conf
nginx_conf=/etc/nginx/sites-enabled/coti_fullnode.conf
mv $nginx_conf ~/nginx_conf.bak

# 1) Add new location to nginx.conf
## Add lines to top of file
top_of_nginx_conf="map \$http_upgrade \$connection_upgrade {
  default upgrade;
  '' close;
}
upstream grafana {
  server localhost:3000;
}"
echo -e "$top_of_nginx_conf\n$(cat ~/nginx_conf.bak)" > $nginx_conf

## Remove lines
mv $nginx_conf ~/nginx_conf.intermediate
head -n -9 ~/nginx_conf.intermediate > $nginx_conf
# rm $nginx_conf.intermediate

## Append lines to bottom of file
echo '        image/svg;' >> $nginx_conf
echo '    location /monitoring/ {' >> $nginx_conf
echo '      rewrite  ^/monitoring/(.*)  /$1 break;' >> $nginx_conf
echo '      proxy_set_header Host $http_host;' >> $nginx_conf
echo '      proxy_pass http://grafana;' >> $nginx_conf
echo '    }' >> $nginx_conf
echo '    # Proxy Grafana Live WebSocket connections.' >> $nginx_conf
echo '    location /monitoring/api/live/ {' >> $nginx_conf
echo '      rewrite  ^/monitoring/(.*)  /$1 break;' >> $nginx_conf
echo '      proxy_http_version 1.1;' >> $nginx_conf
echo '      proxy_set_header Upgrade $http_upgrade;' >> $nginx_conf
echo '      proxy_set_header Connection $connection_upgrade;' >> $nginx_conf
echo '      proxy_set_header Host $http_host;' >> $nginx_conf
echo '      proxy_pass http://grafana;' >> $nginx_conf
echo '    }' >> $nginx_conf
echo '    location  / {' >> $nginx_conf
echo '        proxy_redirect off;' >> $nginx_conf
echo '        proxy_set_header Host $host;' >> $nginx_conf
echo '        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' >> $nginx_conf
echo '        proxy_set_header Upgrade $http_upgrade;' >> $nginx_conf
echo '        proxy_set_header Connection "upgrade";' >> $nginx_conf
echo '        proxy_pass http://127.0.0.1:7070;' >> $nginx_conf
echo '    }' >> $nginx_conf
echo '}' >> $nginx_conf


# 2) Restart nginx
sudo systemctl restart nginx
