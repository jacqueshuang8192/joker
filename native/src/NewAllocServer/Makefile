# The archived ACE library has SONAME 6.3.0 and the older glibc ucontext symbol spelling.
SOURCES = $(wildcard Game/*.cpp GameLib/*.cpp Json/*.cpp)
OBJECTS = $(SOURCES:.cpp=.o)
CPPFLAGS = -D__cpu_set_t_defined -Ducontext_t=ucontext -IGame -IGameLib -IJson -I/work/hiredis -I/work/hiredis/adapters -I/sdk -I/usr/include/mysql -I/usr/include/libmemcached
CXXFLAGS = -std=gnu++11 -fpermissive -Wno-deprecated-declarations
AllocRoomServer: $(OBJECTS)
	$(CXX) -o $@ $^ /sdk/libACE.so.6.3.0 /work/hiredis/libhiredis.a -lmariadb -lmemcached -lz -ldl -lpthread
