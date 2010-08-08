core = 6.x

projects[drupal][type] = core
projects[drupal][download][type] = cvs
projects[drupal][download][revision] = DRUPAL-6-16
projects[drupal][download][root] = ":pserver:anonymous:anonymous@cvs.drupal.org:/cvs/drupal"
projects[drupal][download][module] = drupal

projects[smart_menus][type] = "module"
projects[smart_menus][download][type] = "cvs"
projects[smart_menus][download][module] = "contributions/modules/smart_menus"
projects[smart_menus][download][root] = ":pserver:anonymous:anonymous@cvs.drupal.org:/cvs/drupal"
projects[smart_menus][download][revision] = "DRUPAL-6--1-5"

projects[module_grants][type] = "module"
projects[module_grants][download][type] = "cvs"
projects[module_grants][download][module] = "contributions/modules/module_grants"
projects[module_grants][download][root] = ":pserver:anonymous:anonymous@cvs.drupal.org:/cvs/drupal"
projects[module_grants][download][revision] = "DRUPAL-6--3-5"

projects[revisioning][type] = "module"
projects[revisioning][download][type] = "cvs"
projects[revisioning][download][module] = "contributions/modules/revisioning"
projects[revisioning][download][root] = ":pserver:anonymous:anonymous@cvs.drupal.org:/cvs/drupal"
projects[revisioning][download][revision] = "DRUPAL-6--3-10"

projects[token][type] = module
projects[token][download][type] = "cvs"
projects[token][download][module] = "contributions/modules/token"
projects[token][download][root] = ":pserver:anonymous:anonymous@cvs.drupal.org:/cvs/drupal"
projects[token][download][revision] = "DRUPAL-6--1-13"

projects[workflow][type] = module
projects[workflow][download][type] = "cvs"
projects[workflow][download][module] = "contributions/modules/workflow"
projects[workflow][download][root] = ":pserver:anonymous:anonymous@cvs.drupal.org:/cvs/drupal"
projects[workflow][download][revision] = "DRUPAL-6--1-4"
projects[workflow][patch][] = "http://drupal.org/files/issues/558378-features-support-workflow_1.patch"

projects[diff][type] = "module"
projects[diff][download][type] = "cvs"
projects[diff][download][module] = "contributions/modules/diff"
projects[diff][download][root] = ":pserver:anonymous:anonymous@cvs.drupal.org:/cvs/drupal"
projects[diff][download][revision] = "DRUPAL-6--2-0"

projects[features][type] = "module"
projects[features][download][type] = "cvs"
projects[features][download][module] = "contributions/modules/features"
projects[features][download][root] = ":pserver:anonymous:anonymous@cvs.drupal.org:/cvs/drupal"
projects[features][download][revision] = "DRUPAL-6--1-0-BETA8"

projects[install_profile_api][type] = "module"
projects[install_profile_api][download][type] = "git"
projects[install_profile_api][download][url] = "git://github.com/sillygwailo/install_profile_api.git"
