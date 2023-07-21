#
# fabric file for deploying
#   fab -H ec2-user@apps.piscinedixiepool.com backup deploy
#
# Relies on the ssh key of runner to be in ec2-user/.ssh/authorized_keys

from invoke import task

@task
def backup(c):
    c.run("rm -rf paieapp-prev")
    c.run("cp -r /var/www/paieapp ./paieapp-prev")
    
@task
def deploy(c):
    c.sudo("rm -rf paieapp")
    c.run("git clone https://github.com/PiscineDixie/paie.git")
    c.local("rsync ./config/secrets.yml %s@%s:paie/config/." % (c.user, c.host))
    c.run("cd paie && BUNDLE_DEPLOYMENT=1 BUNDLE_WITHOUT=development bundle install")
    c.run("cd paie && RAILS_ENV=production bin/rails assets:precompile")
    c.run("cd paie && RAILS_ENV=production bundle exec rake db:migrate")
    c.run("rm -rf paie/.git")
    c.sudo("chown -R apache:apache paie")
    c.sudo("rm -rf /var/www/paieapp")
    c.sudo("mv paie /var/www/paieapp")
    c.sudo("systemctl reload httpd")
    c.run("wget https://apps.piscinedixiepool:8483/ -o /dev/null -O /dev/null")
    pass
