# Using pgbadger in Kubernetes with Zalando Postgres operator

You may use my container image from `vvang/pgbadger:0.1` (see https://hub.docker.com/repository/docker/vvang/pgbadger )
or build your own. `Dockerfile` is in this repo for your reference.

You will need to make changes in the `pgdabger.yaml` file which offered here as an example:
1. edit `pgdbager.yaml` - adjust the `namespace` (change from `namespace: apigateway-dev`)
2. edit `pgdbager.yaml` - `nodeName` must be the same as the one where the postgres master is running (because pvc accessModes ReadWriteOnce). get the nodeName with something like:
```
# kubectl -n <NAMESPACA> get pod <PG_MASTER_POD_NAME> -o jsonpath='{.spec.nodeName}'; echo

# for example, where i'm testing this is:
kubectl -n apigateway-dev get pod apigateway-dev-minimal-cluster-0 -o jsonpath='{.spec.nodeName}'; echo
          # ^- your namespace     # ^- your postgres master pod
```
3. edit `pgdbager.yaml` - persistentVolumeClaim must be the same as the one used by the postgres master pod. a command like this one might be used:
```
# kubectl -n <NAMESPACE> get pod <PG_MASTER_POD_NAME> -o jsonpath='{.spec.volumes[0].persistentVolumeClaim.claimName}'; echo

# for example, where i'm testing this is:
kubectl -n apigateway-dev get pod apigateway-dev-minimal-cluster-0 -o jsonpath='{.spec.volumes[0].persistentVolumeClaim.claimName}'; echo

# confirm the result with
kubectl -n apigateway-dev get pvc
```

Once you have the manifest file `pgdbager.yaml`, run something like

```
kubectl apply -f pgdabger.yaml

export NS=apigateway-dev  # replace with your namespace
                          # $NS used below
# exec inside the pod and run pgbadger
kubectl -n $NS exec -ti pgbadger -- bash 
    $ cd /pgdata/pgroot/pg_log/
    $ pgbadger *.csv
    $ ls -l out.html
    $ exit

# copy the file from container to your host
kubectl -n $NS cp pgbadger:/pgdata/pgroot/pg_log/out.html out.html  

# cleanup
kubectl -n $NS exec -ti pgbadger -- rm /pgdata/pgroot/pg_log/out.html
kubectl -n $NS delete pod pgbadger

# use a browser to look at the file out.html
```

