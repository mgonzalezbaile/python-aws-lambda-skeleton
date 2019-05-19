# Integrations

## Set up
**NOTE**: First of all, ask some mate for the `ansible-vault` password and put it in your profile (`~/.bashrc`):
`ANSIBLE_VAULT_PASSWORD=<password>`

Clone repo:
```.env
git clone git@github.com:ontruck/integrations.git
```

Build docker images:
```.env
./docker/run.sh build
```

Decrypt `local.yml` secrets file:
```.env
./docker/run.sh decrypt secrets/local.yml
```

**NOTE**: Make sure you never push secrets files decrypted.

Start containers:
```.env
./docker/run.sh start
```

**NOTE**: Run `./docker/run.sh` to see more additional and useful commands.

Test that your local environment is properly working:
```.env
curl -i -X POST \
   -H "Content-Type:application/json" \
   -d \
'{
  "some-parameter": "hello",
  "another-paramenter": 2
}' \
 'http://localhost:3000/health'
```

You should see the next response:
```.env
HTTP/1.1 200 OK
content-type: application/json; charset=utf-8
cache-control: no-cache
content-length: 0
vary: accept-encoding
Date: Mon, 13 May 2019 16:36:44 GMT
Connection: keep-alive
```
