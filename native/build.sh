#!/bin/bash
set -euo pipefail
cd /work
make -s -C hiredis static -j2

mkdir -p CCHallServer/{bin,lib,dependence}
ln -s ../../hiredis CCHallServer/dependence/hiredis-master
make -s -C CCHallServer/src/core -j2
cp CCHallServer/bin/libcore.a CCHallServer/lib/
make -s -C CCHallServer/src/proxy -j2
install -D CCHallServer/bin/CCHallServer /out/hall/bin/CCHallServer

mkdir -p CCUserServer/{bin,lib}
make -s -C CCUserServer/src -j2
make -s -C CCUserServer/Server -j2 \
    INC="-I. -I../include -I../include/Json -I/work/hiredis -I/usr/include/libmemcached" \
    LIBS="/work/hiredis/libhiredis.a ../lib/libreactor.a -ldl -lz -lmemcached"
install -D CCUserServer/bin/UserServerSHM /out/user/bin/UserServerSHM

build_data_service() {
    local project=$1 module=$2 binary=$3 role=$4
    mkdir -p "$project"/{bin,lib}
    ln -s ../../hiredis "$project/$module/hiredis-master"
    make -s -C "$project/src" -j2
    make -s -C "$project/$module" -j2 \
        INC="-I../include -I./hiredis-master -I./Json -I./Process -I. -I/usr/include/mysql" \
        LIB="-L../lib -lreactor -lpthread -lmariadb /work/hiredis/libhiredis.a"
    install -D "$project/bin/$binary" "/out/$role/bin/$binary"
    install "$project/lib/libreactor.so" "/out/$role/bin/"
}
build_data_service CCMDataServerNew mdata CCMemDataServer data
build_data_service CCGoldUpdateServer goldupdate CCGoldUpdateServer gold

# Build the room allocator against the same ACE ABI shipped with the game.
make -s -C NewAllocServer -j2
install -D NewAllocServer/AllocRoomServer /out/alloc/bin/AllocRoomServer
