[33mf73e41c[m[33m ([m[1;31morigin/test[m[33m)[m Update get_ConpornentLog.pl
[33md778518[m Create configuration.pl
[33m1e4b295[m[33m ([m[1;36mHEAD -> [m[1;32mtest[m[33m)[m add get_compornent_log.pl
[33m550e5f3[m deleted testfile and modefiled someFiles to back to first.
[33m82c93f2[m add getAndCopy_couchdbLog.sh. modified same files to connect to fossology.
[33m6384a89[m modify2...
[33m4b66148[m modify formor commit
[33m0d0425b[m add sed -e "s/file = \/dev\/null/file = \/usr\/local\/var\/log\/couchdb\/couch.log/g" to create couchdb's log file
[33mdbb7f32[m[33m ([m[1;31morigin/master[m[33m, [m[1;31morigin/HEAD[m[33m, [m[1;32mmaster[m[33m)[m test2 commit
[33mbb190ec[m test commit
[33m57719dd[m Merge pull request #64 from bsinno/maxhbr/tryToFixAuthRestConfig
[33mb1137a6[m[33m ([m[1;31morigin/lepokle/#59/liferay-7[m[33m)[m chores(liferay): make compatible with Liferay 7.2
[33m3e7f2a4[m fix(rest): try to configure auth rest server crrectly
[33ma509a6f[m Merge pull request #58 from bsinno/maxhbr/minorImprovements
[33mf9d7201[m Merge pull request #57 from bsinno/maxhbr/minorDocUpdate
[33m1e991ba[m[33m ([m[1;31morigin/lepokle/add-quick-deploy[m[33m)[m chores(quick-deploy): add quick deploy
[33m3931b6f[m chore: downgrade chores version, disable default password and more
[33md9eaa6c[m doc(README): describe how to deactivate authentication for CouchDB
[33m424338c[m Merge pull request #56 from bsinno/maxhbr/refactorComposeTo3
[33m9927ce4[m Refactor to current docker-compose version and to support docker swarm
[33mfd652ae[m Merge remote-tracking branch 'public/greimela/feature/provision_couchdb'
[33m60d5b54[m Add provisioning option to couchdb container
[33m1b04056[m Merge pull request #50 from sw360/maxhbr/clearifyStuffInTheReadme
[33mf0a7710[m doc(README): clearify how to continue after `sw360chores.pl -- up`
[33mc116637[m Merge pull request #48 from sw360/dev/cleanupForSwarm
[33m583cccf[m fix(sw360chores): pass proxy args in correct order
[33mb3f19d5[m feat(sw360chores): allow to build only one image
[33m1a0695f[m fix(sw360chores): proxy for `docker build ...` was not passed
[33m44d631d[m fix(proxy): couchdb-lucene/prepare proxy was incorrect
[33m58b93c2[m feat(sw360chores): serve tomcat logs under `https://localhost:8443/logs` in dev mode
[33m6481431[m feat(sw360chores): cleanup and fixes
[33mfc5ff5b[m feat(sw360chores): prepare sw360liferay via external script
[33mf1f943a[m feat(sw360chores): add support for docker within Vagrant
[33md55e08f[m feat(sw360chores): add support for docker within Vagrant
[33mc2a055d[m feat(couchdb-lucen): add script to build war file
[33m6289993[m chores(sw360chores): cleanup and update readme
[33mc7d39e2[m feat(sw360chores): add travis support
[33m75311a4[m feat(sw360chores): add functionallity to push images
[33mc908e62[m fix(sw360chores): change TMPDIR on darwin
[33m9d7318d[m feat(sw360chores): bump couchdb-lucene verison + bugfixes
[33m53e1ed5[m feat(sw360chores): rewrite and simplification
[33m1361296[m[33m ([m[1;31morigin/dev/fixEtrypointSameCA[m[33m)[m fix(docker): sw360/docker-entrypoint should not fail if certificate already known
[33m443f3ad[m[33m ([m[1;31morigin/dev/fixLuceneConfiguration[m[33m)[m fix(couchdb-lucene): configuration.yml was not used for lucene container
[33mba095f7[m Merge pull request #38 from sw360/dev/httpsForCveSearch
[33m715b003[m[33m ([m[1;31morigin/dev/addCleanupFunctionallity[m[33m)[m feat(docker-compose.sh): add cleanup functionallity
[33mfeeb69d[m Merge pull request #44 from sw360/dev/fixBackup
[33m847239c[m fix(backup): rearange arguments of tar
[33m2e26c6f[m[33m ([m[1;31morigin/dev/webappsAsVolume[m[33m)[m feat(docker): webapps as volume
[33m2d6f2ad[m[33m ([m[1;31morigin/dev/useContainersFromSW360Rest[m[33m)[m feat(rest): use containers from sw360rest project
[33ma3a8894[m Merge pull request #40 from sw360/dev/setupNginxCache
[33m113c1f3[m feat(nginx): setup client cache
[33m0e4b807[m feat(cve-search): always start https on port 5443
[33me942faa[m[33m ([m[1;31morigin/dev/fix#36[m[33m)[m fix(proxy): couchdb-lucene/prepare proxy was incorrect
[33m70429db[m Merge pull request #35 from sw360/fix/typoInDockerComposeSH
[33mf2298d9[m fix(chore): typo in docker-compose.sh
[33mb7cfe69[m Merge pull request #34 from sw360/fix/missingFontsInTomcatContainer
[33m7db859a[m fix(spreadsheetExport): add fonts package to docker container
[33mefa2218[m Merge pull request #32 from sw360/fix-url-matching
[33m9ac25f5[m fix(nginx): fix url matching
[33m1593da5[m[33m ([m[1;31morigin/feat/addTravis[m[33m)[m feat(test): support travis
[33md6badae[m Merge pull request #30 from sw360/fix/doNotDestroyLiferayInTomcat
[33m6cb8ac2[m fix(chore): Dockerfile did remove the `ROOT` folder belonging to liferay
[33m1134317[m Merge remote-tracking branch 'origin/dev/addMissingCouchdbLuceneOption'
[33m7d15bec[m Merge remote-tracking branch 'origin/dev/increaseDefaultHeapSize'
[33m2d77d35[m Merge remote-tracking branch 'origin/dev/useLightweightBaseImages'
[33m391741d[m Merge pull request #25 from sw360/dev/userSampleCsvWithSecurityAndSetupAdmin
[33m3e19148[m[33m ([m[1;31morigin/feat/serveTomcatLogs[m[33m)[m feat(dev): serve tomcat logs under https://localhost:8443/logs in dev mode
[33m980a902[m users.csv with setup and security admin
[33ma1296f4[m feat(chore): support Tomcat Native Libs in sw360
[33m223403b[m chore(docker): nginx now needs openssl installed
[33m9b8b2df[m chore(docker): add cve-search debug/dev mode
[33m983e7be[m chore(docker): change posgres dev port on host
[33mcc9f5ad[m chore(docker): use leightweight alpine images
[33m5ff89fc[m chore(docker): replace utility by build-in
[33m3d208a9[m chore(docker): make missing option configurable
[33m010f237[m perf(liferay): optimize `portal-ext.properties`
[33m3592737[m perf(tomcat): modify $JAVA_OPTS
[33m16fb57d[m Merge remote-tracking branch 'origin/fix/issue#17'
[33mba63f3d[m Merge remote-tracking branch 'origin/dev/ldapCertsAndProxy'
[33mc3dd0e8[m fix(packaging): deployed lucene needs to be renamed
[33m0dc04c7[m fix(backup): adding on demand function for realpath
[33m1ed93c8[m Merge remote-tracking branch 'origin/dev/pinCveSearchVersion'
[33m012d782[m Merge remote-tracking branch 'bs-jokri/dev/addScriptsForBackupAndRestoreToJSON'
[33m62339a5[m Merge remote-tracking branch 'bs-jokri/contrib/mergePRs'
[33m4e797de[m Merge remote-tracking branch 'bs-jokri/dev/addBackupAndRestore'
[33m9cc368d[m Merge remote-tracking branch 'origin/dev/addPossibilityToChangeSW360Port'
[33mc3af0ad[m Merge remote-tracking branch 'origin/dev/restrictSomeSuburls'
[33m08660a1[m cve-search: checkout specific version
[33mc84ad15[m Add scripts to backup couchdb to JSON over HTTP
[33mb86cd53[m one should be asked before hard restoring of an volume
[33me0280c3[m Implement backup and restore of all volumes generically
[33m2488d1d[m add option to modify sw360.properties in docker setup
[33mb4a62b2[m Extend docker-compose `links` with `networks`
[33m73aef42[m add proxy configuration for cve-search updater
[33m343c61d[m[33m ([m[1;31morigin/integration/2016_09_30[m[33m)[m Merge commit '589bedb6216afe31bfa82d66e0aa53dc1d78e137' into integration/2016_09_30
[33m589bedb[m add possibility to change the SW360 port in `configurations.yml`
[33m239ddae[m Merge commit 'ef29c1cfc58b0bccdb9e2d222bc71bba1ec9e5b1' into integration/2016_09_30
[33m5a5f0c5[m Merge commit 'bddce55a288ab245bb851412b6ba9c4559dd2187' into integration/2016_09_30
[33m8c40276[m Merge commit 'a4c01e4bd71fb870c9cb21a1c2a500d398b16776' into integration/2016_09_30
[33mef29c1c[m restrict some suburls via nginx
[33mbddce55[m Add possibility to set nginx certificates
[33m3d7de9d[m add comment to show how to set DNS
[33m4911530[m add proxy configuration for cve-search updater
[33ma4c01e4[m added import of explicitly provided trusted CA certificates and setting up ldap-importer.properties
[33mee17a7d[m forwarding proxy conf to docker for prepare.sh to work behind proxy
[33m1e6ef10[m refactor(deploymen): `prepare.sh` should not depend on rake
[33m826ab6b[m Merge pull request #2 from sw360/contrib/miscellaneous
[33m7e90663[m Merge pull request #3 from sw360/contrib/deployment
[33ma48f68a[m Merge pull request #1 from sw360/contrib/packaging
[33m5c7a6e4[m deployment: add configuration possibilities for FOSSology connection
[33m7eb7108[m add SW360 deployment related files
[33m7cd47b0[m add root readme
[33m48a1475[m add miscellaneous stuff
[33m698c931[m add SW360 dependencies packaging mechanism
[33mdf7e04d[m Add EPL license file
[33m295d89e[m initial commit
