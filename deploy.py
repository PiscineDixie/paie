#
# fabric file for deploying
#   fab -u root -f paieapp/deploy.py -H dixie backup deploy
#

import fabric.api

def backup():
    fabric.api.run("rm -rf /var/www/paieapp-prev")
    fabric.api.run("cp -a /var/www/paieapp /var/www/paieapp-prev")
    
def deploy():
    fabric.api.local("rsync -a --copy-links --delete paieapp %s@%s:/var/www/." % (fabric.api.env.user, fabric.api.env.host))
    with fabric.api.cd("/var/www/paieapp"):
      fabric.api.run("bundle install")
      fabric.api.run("RAILS_ENV=production bundle exec rake db:migrate")
    fabric.api.run("chown -R www-data.www-data /var/www/paieapp")
    fabric.api.run("apache2ctl graceful")
    fabric.api.run("wget https://apps.piscinedixiepool.com:8483/ -o /dev/null -O /dev/null")
    pass