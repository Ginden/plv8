FROM ubuntu:xenial AS build

ENV PGVERSION="12"

RUN apt-get update
RUN apt-get -y --purge remove postgresql libpq-dev libpq5 postgresql-client-common postgresql-common || true
RUN rm -rf /var/lib/postgresql
RUN apt-get -y install wget
RUN wget --no-check-certificate  --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN sh -c "echo deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main $PGVERSION >> /etc/apt/sources.list.d/postgresql.list"
RUN apt-get update -qq
RUN apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::="--force-confnew" install postgresql-$PGVERSION postgresql-server-dev-$PGVERSION
RUN echo "local   all         postgres                          trust" > /etc/postgresql/$PGVERSION/main/pg_hba.conf
RUN echo "local   all         all                               trust" >> /etc/postgresql/$PGVERSION/main/pg_hba.conf
RUN echo "host    all         all         127.0.0.1/32          trust" >> /etc/postgresql/$PGVERSION/main/pg_hba.conf
RUN echo "host    all         all         ::1/128               trust" >> /etc/postgresql/$PGVERSION/main/pg_hba.conf
RUN /etc/init.d/postgresql restart
RUN apt-get update -qq
RUN apt-get install -y libc6-dev-i386 libc++-dev make git libv8-dev python3 lbzip2 libc++abi-dev pkg-config
WORKDIR /plv8
COPY . .
RUN make

FROM build as artifact
COPY --from=build /build /build

