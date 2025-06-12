
```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock  -v /root/.docker/config.json:/root/.docker/config.json -e IMAGE_TAG=2.0.9 aayush808/docker-push-image:1.1
```
