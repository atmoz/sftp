# K8s

Example on how to setup.

## Install process

1. run `./keygen.sh`. take a look at script for what it does but gens keys and copies the secret-*.yml fiels into keys dir for editing. the keys dir should be in .gitignore and should not be checked in to github. 

2. Edit secret-host-keys.yml and copy in the keys that were generated into the the dir.

3. Edit secret-user-conf.yml to add or update users and set to initial secure passwords. 

    >NOTE: UPDATE THE pAsWoRd to something secure, DO NOT RUN IT AS IS! This is just a githuib checked in example

4. Run the `./install.sh` script or look inside it and run each item by hand. 

    >NOTE: the end of the install script will delete the keys dir so keep that in mind!

5. if you have a botched run and need to clean up then run
    ```
    kubectl delete deployment,svc,configmap,secret --namespace=storage --selector=role=sftp
    ```

6. add a tcp entry to the Linode node balancer to pass 30022 to the nodes 30022. Add an entry to the DNS to point sftp.9ci.com to that nodebalancer


## Maintain Users

To add or remove users just edit the sftp-user-conf secret. Easy to do in Rancher. Will need to redeploy ("restart") the  deployment
