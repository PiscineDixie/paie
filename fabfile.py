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
    c.local("rsync -vv -a --delete --exclude='vendor/*' --exclude='.git/*' --exclude=log/development.log  --exclude='tmp/*' . %s@%s:paieapp" % (c.user, c.host))
    c.run("cd paieapp && bundle install --deployment --path vendor/bundle")
    c.run("cd paieapp && RAILS_ENV=production bin/rails assets:precompile")
    c.run("cd paieapp && RAILS_ENV=production bundle exec rake db:migrate")
    c.sudo("chown -R apache:apache paieapp")
    c.sudo("rm -rf /var/www/paieapp")
    c.sudo("mv paieapp /var/www/.")
    c.sudo("systemctl reload httpd")
    c.run("wget http://localhost:8083/ -o /dev/null -O /dev/null")
    pass
