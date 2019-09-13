#NOTE: don't config!
CONTAINERS => test sw360_dev_sw360 sw360_dev_sw360couchdb sw360_dev_sw360postgresql sw360_dev_sw360nginx sw360_dev_sw360cvs_search daito_fossology; 
containers_nos => 0 1 2 3 4 5 6;
CMD => jounalctl -l --no-paper -u, docker logs, cat /var/log/message grep;
cmd_names => journald json syslog;  
cmd_nos => 0 1 2;
USING =>  1 1 1 1 1 2;
DEFAULT_CONTAINERS => 1 2 3 0;
