FROM postgres:11
COPY main.sh /data/main.sh
RUN chmod +x /data/main.sh
COPY prerequirements.sh /data/prerequirements.sh
RUN chmod +x /data/prerequirements.sh
RUN /data/prerequirements.sh 
ENTRYPOINT [ "/data/main.sh" ]