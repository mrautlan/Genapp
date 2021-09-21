# FROM looks for Docker images locally first, then trys to 'pull from' the registry
FROM jta/wazianalyze:latest
MAINTAINER Joe Taffe-Atkins Genapp Build Admin <Jt-atkins@uk.ibm.com>
COPY devsource /home/wazianalyze/data/project/source/
RUN wa-scan.sh	
EXPOSE 5000

# docker build -t developername:5 .
# docker run -it -p 5000:5000 developername:3