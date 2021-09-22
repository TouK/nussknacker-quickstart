#!/usr/bin/env bash

ln -sf /opt/ignite/apache-ignite/libs/optional/ignite-zookeeper/ /opt/ignite/apache-ignite/libs/

/opt/ignite/apache-ignite/bin/ignitevisorcmd.sh -cfg=/user_config/visor-config.xml
