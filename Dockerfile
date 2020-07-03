
FROM ubuntu:bionic
RUN apt-get -y update && apt-get install -y

RUN apt-get -y install curl gnupg2 software-properties-common ninja-build  apt-utils make

# install clang/llvm 9 
#RUN curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
#RUN apt-add-repository "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-8 main"
RUN apt-get -y update && apt-get install -y
RUN apt-get -y install libllvm9 llvm-9 llvm-9-dev
RUN apt-get -y install clang-9 clang-tools-9 libclang-common-9-dev libclang-9-dev libclang1-9
RUN apt-get -y install libc++-9-dev libc++abi-9-dev
RUN apt-get -y install git

#set clang 9 to be the version of clang we use when clang/clang++ is invoked
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-9 100
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-9 100

ADD https://cmake.org/files/v3.13/cmake-3.13.0-Linux-x86_64.sh /cmake-3.13.0-Linux-x86_64.sh
RUN mkdir /opt/cmake
RUN sh /cmake-3.13.0-Linux-x86_64.sh --prefix=/opt/cmake --skip-license
RUN ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake

#install hyde dependencies 
RUN apt-get -y install libboost-system-dev libboost-filesystem-dev

COPY . /usr/src/hyde


# build hyde and run the generate_test_files
WORKDIR /usr/src/hyde
RUN git submodule update --init \
    && mkdir -p build \
    && cd build \
    && rm -rf *  \
    && cmake .. -GNinja \
    && ninja 
WORKDIR /usr/src/hyde
CMD ["./generate_test_files.sh"]