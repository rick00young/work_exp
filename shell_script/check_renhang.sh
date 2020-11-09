 #!/usr/bin/env bash

cure_rules=$(ps aux | grep -v 'grep' | grep cube_rules.jar | wc -l)
cube_transfer=$(ps aux | grep -v 'grep' | grep cube_transfer.jar | wc -l)

if [ 1 -eq $cure_rules -a 1 -eq $cube_transfer ]
        then
                echo 1 
        else
                echo 0
fi