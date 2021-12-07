# FROM looks for Docker images locally first, then trys to 'pull from' the registry
FROM ibmcom/wazianalyze:latest
MAINTAINER Joe Taffe-Atkins Genapp Build Admin <Jt-atkins@uk.ibm.com>
COPY <local Git branch> /home/wazianalyze/data/project/source/
RUN wa-scan.sh	
EXPOSE 5000
EXPOSE 4680
CMD wa-startup.sh

# docker build -t jtawa:latest .
# docker run -p 5000:5000 -p 4680:4680 -t jtawa:latest
