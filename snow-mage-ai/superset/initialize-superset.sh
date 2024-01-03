#!/bin/sh
#
cd /usr/src/
#
echo "===> Create superset user"
sleep 1
superset fab create-admin --username "$ADMIN_USERNAME" --firstname Superset --lastname Admin --email "$ADMIN_EMAIL" --password "$ADMIN_PASSWORD"
#
echo "===> Migrate superset local DB to latest"
sleep 1
superset db upgrade
#
echo "===> Setup superset roles"
sleep 1
superset superset init
#
# echo "===> Import Data Sources"
# sleep 1
# #
# cd /usr/src/configs/
# rm -f datasources.zip
# zip -r datasources.zip datasources
# superset import_datasources -p /usr/src/configs/datasources.zip
# #
# echo "===> Import Dashbaords"
# sleep 1
# cd /usr/src/configs/
# rm -f dashboards.zip
# zip -r dashboards.zip dashboards
# superset import_dashboards -p /usr/src/configs/dashboards.zip
#
echo "===> Finished Running the startup scripts !!! Have fun with Superset !!!"
sleep 1
#
# Starting server
/bin/sh -c /usr/bin/run-server.sh