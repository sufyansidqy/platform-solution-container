#!/bin/bash

/opt/actimize/ais_server/Instances/actimize_server_1/ais_status --processes --user admin --password password | grep 'All Sublists Loaded' | grep 'running'