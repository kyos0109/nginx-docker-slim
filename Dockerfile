FROM scratch
ADD files.tar.xz /
ENV PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV SSL_CERT_FILE "/etc/ssl/certs/ca-certificates.crt"
EXPOSE 80/tcp
ENTRYPOINT ["nginx","-g","daemon off;"]
