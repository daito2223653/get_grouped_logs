#NOTE: don't config!
our @_CONTAINERS = (sw360_dev_sw360, sw360_dev_sw360couchdb, sw360_dev_sw360postgresql, sw360_dev_sw360nginx, sw360_dev_sw360cvs_search, test, daito_fossology); 
our @_containers_nos = (0, 1, 2, 3, 4, 5, 6);
our @_CMD = ("jounalctl -l --no-paper -u", "docker logs", "cat /var/log/message grep");
our @_cmd_names = (journald, json, syslog);  
our @_cmd_nos = (0, 1, 2);
our @_USING = (1, 1, 1, 1, 1, 0, 2);
our @_DEFAULT_CONTAINERS =  (0, 1, 2, 5);
1;
