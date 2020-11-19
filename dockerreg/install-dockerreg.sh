#mount storage volumes
sudo mkdir /home/dockerreg_bucket
sudo mkdir /home/ssl_certificates_bucket
#run docker regestry
docker run -d \
  --restart=always \
  --name registry \
  -v /home/dockerreg_bucket:/var/lib/registry \
  -v /home/ssl_certificates_bucket:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -p 443:443 \
  registry:2
