FROM ubuntu:22.04 AS build

RUN apt update && \
    apt install -yq cmake build-essential ninja-build \
    libcrypto++-dev libfmt-dev libluajit-5.1-dev libmysqlclient-dev \
    libboost-filesystem-dev libboost-iostreams-dev libboost-locale-dev libboost-system-dev libpugixml-dev

COPY cmake /usr/src/tvp/cmake/
COPY src /usr/src/tvp/src/
COPY CMakeLists.txt /usr/src/tvp/
WORKDIR /usr/src/tvp

RUN mkdir build
RUN cd build && cmake ..
RUN cd build && make -j$(nproc)
RUN cd build && find .

FROM ubuntu:22.04

RUN apt update && \
    apt install -yq cmake build-essential ninja-build \
    libcrypto++-dev libfmt-dev libluajit-5.1-dev libmysqlclient-dev \
    libboost-filesystem-dev libboost-iostreams-dev libboost-locale-dev libboost-system-dev libpugixml-dev

# rest of files will be synchronized from local directory by docker compose
COPY --from=build /usr/src/tvp/tvp /bin/tvp

EXPOSE 7171 7172
WORKDIR /srv
VOLUME /srv
ENTRYPOINT ["/bin/tvp"]
