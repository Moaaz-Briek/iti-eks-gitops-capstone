```sh
docker build  -t tf_pod:latest .;
```

```sh
 docker run \ 
    -e REPO_URL=<project-github-url> \
    -e TF_PATH=<relative-path>  \
    -e BUCKET_NAME=<bucket-name> \
    -e BUCKET_STATE=<bucket-key> \
    tf_pod:latest  
```