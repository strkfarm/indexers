FROM ubuntu:22.04 as base
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

WORKDIR /app
ADD src /app/src
COPY .env package.json schema.prisma /app
COPY apibara_install.sh /app
COPY deployment/* /app

# install deps
RUN apt-get -y update; apt-get -y install curl
RUN apt-get -y install jq
RUN apt-get install wget -y
RUN apt-get install gzip -y

# install nodejs
RUN echo "installing nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
RUN echo "installed nvm"
RUN nvm install 18.20.1
RUN node -v

#home/teja9999/.nvm/versions/node/v18.20.1/bin/node

# install apibara
RUN chmod +x apibara_install.sh
RUN ./apibara_install.sh

RUN echo "Installed apibara, checking"
RUN /root/.local/share/apibara/bin/apibara --version

# install sink-postgres
RUN wget https://github.com/apibara/dna/releases/download/sink-postgres%2Fv0.8.0/sink-postgres-x86_64-linux.gz
RUN gzip -d sink-postgres-x86_64-linux.gz
RUN chmod +x sink-postgres-x86_64-linux
RUN /root/.local/share/apibara/bin/apibara plugins install --file sink-postgres-x86_64-linux

# create run.sh to run multiple indexers at once
RUN chmod +x run.sh
RUN cat ./run.sh

ENTRYPOINT ["./run.sh"]
