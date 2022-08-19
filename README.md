# Using pgbadger in Kubernetes with Zalando Postgres operator

You may use my container image from `vvang/pgbadger:0.1` or build your own. `Dockerfile` is in this repo for your reference.

You will need to make changed in the `pgdabger.yaml` file which offered here as an example:
- adjust the `namespace`
- `nodeName` must be the same as the one where the postgres master is running (because pvc accessModes ReadWriteOnce)

```
kubectl -n apigateway-dev get pod apigateway-dev-minimal-cluster-0 -o jsonpath='{.spec.nodeName}'; echo
          # ^- your namespace     # ^- your postgres master pod
```
- persistentVolumeClaim must be the same as the one used by the postgres master pod
```
kubectl -n apigateway-dev get pod apigateway-dev-minimal-cluster-0 -o jsonpath='{.spec.volumes[0].persistentVolumeClaim.claimName}'; echo
           # ^- your namespace    # ^- your postgres master pod
# confirm the result with
kubectl -n apigateway-dev get pvc
```

Once you have the manifest file `pgdabger.yaml`, run something like

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

