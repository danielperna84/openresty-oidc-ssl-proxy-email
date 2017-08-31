# openresty-oidc-ssl-proxy-email
Openresty based OpenID Connect Single Sign On SSL reverse proxy with E-Mail verification.

This is a slight modification of [openresty-oidc-proxy](https://github.com/flix-tech/openresty-oidc-proxy), which is using [lua-resty-openidc](https://github.com/pingidentity/lua-resty-openidc).

There are currently no images you can pull. Instead you have to build the image locally:

```bash
git clone https://github.com/danielperna84/openresty-oidc-ssl-proxy-email.git
cd openresty-oidc-ssl-proxy-email
docker build -t imagename ./
```

Before you can run the container make sure your `/path/to/ssl_data` contains these three files:
1. fullchain.pem (The SSL certificate)
2. privkey.pem (The private key for your certificate)
3. dhparam.pem (The dhparam file nginx should use. If you don't have one: `openssl dhparam -out dhparam.pem 4096`)

Also you have to modify the env.dist file to match your specific configuration.
`PROXY_PASS` is the internal host to which requests should be forwarded.  
`OID_VALID_EMAILS` is a list of e-mail addresses which are allowed to access the internal host (`a@b.com` or `a@b.com,b@b.com` etc.). The other OpenID relaten options are explained in further detail at [lua-resty-openidc](https://github.com/pingidentity/lua-resty-openidc).  
This has been tested to work with Googles OAuth. If you haven't done it yet, head over to https://console.developers.google.com and create a project to use this with.

Running the container:
```bash
docker run -it --rm --env-file env.dist -p 8123:443 -h public.example.com -v /path/to/ssl_data:/ssl imagename
```