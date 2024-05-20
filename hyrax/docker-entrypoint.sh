#!/bin/sh

if [ ! -d "/data/public/assets" ] && [ "${RAILS_ENV}" = "production" ]; then
    cp -Rp /data-backup/public/assets /data/public/
fi

echo "Creating log folder"
mkdir -p "${APP_WORKDIR}/log"

if [ "${RAILS_ENV}" = "production" ]; then
    # Verify all the production gems are installed
    bundle check
else
    # install any missing development gems (as we can tweak the development container without rebuilding it)
    bundle check || bundle install --without production
fi

## Run any pending migrations, if the database exists
## If not setup the database
bundle exec rake db:exists && bundle exec rake db:migrate || bundle exec rake db:setup

# Check solr is running
n=0
solr_running=0
while [ ${n} -lt 15 ]
do
    # check Solr is running
    if [ ${solr_running} -eq 0 ] ; then
      solr_curl=$(curl --fail --silent --connect-timeout 45 "http://${SOLR_HOST:-solr}:${SOLR_PORT:-8983}/solr/" | grep "Apache SOLR")
      if [ -n "${solr_curl}" ] ; then
          echo "Solr is running"
          solr_running=1
      fi
    fi

    if [ ${solr_running} -eq 1 ] ; then
      break
    else
      sleep 1
    fi
    n=$(( n+1 ))
done

# Exit if Solr is not running
if [ ${solr_running} -eq 0 ] ; then
    echo "ERROR: Solr is not running"
    exit 1
fi


echo "Setting up hyrax... (this can take a few minutes)"
bundle exec rake rdms:setup_hyrax["seed/setup.json"]

# echo "--------- Starting Hyrax in ${RAILS_ENV} mode ---------"
rm -f /tmp/hyrax.pid
bundle exec rails server -p 3000 -b '0.0.0.0' --pid /tmp/hyrax.pid
