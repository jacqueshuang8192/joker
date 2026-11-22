CFLAGS += -g -O0 -Wall -fPIC 

INC += -I../include -I./hiredis-master -I./Json -I./Process -I./ -I/usr/local/mysql/include/mysql
LIB += -L../lib -L/usr/local/mysql/lib/mysql -lreactor -lpthread /usr/local/mysql/lib/mysql/libmysqlclient_r.a ./hiredis-master/libhiredis.a
TARGET = CCMemDataServer 
CPP_FILES = $(wildcard *.cpp) $(wildcard Json/*.cpp) $(wildcard Process/*.cpp)
OBJ = $(patsubst %.cpp,%.o,$(CPP_FILES))
all :   $(TARGET)
include ./incl_comm.mk
