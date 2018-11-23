# Pantheon Auto-update

Run updates on your Pantheon site on a separate multi-dev environment.
If any updates found -- also runs visual regression testing using https://diffy.website
service.

Borrowed a lot of code from https://github.com/pantheon-systems/example-terminus-auto-update-script

Script does:
* checks if your site needs updates
* drops and recreate auto-updates multidev environment
* deploy all the updates there
* trigger Diffy compare job to verify against Live

In order to set it up check ```configuration.sh``` script for required variables.

Also set up a project in Diffy for the Live environment of the site.
