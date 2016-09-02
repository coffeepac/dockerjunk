FROM ubuntu:14.04

ADD entrypoint.sh /

# Execute the entrypoint
WORKDIR /
ENTRYPOINT ["/entrypoint.sh"]