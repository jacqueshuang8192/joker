
BIN = UserServerSHM

INC = -I. -I../include	-I/usr/local/include/libmemcached/ ../dependence/hiredis-master/libhiredis.a -lz -I.  -I../include/Json ../dependence/libreactor.a

FILES = $(wildcard *.cpp) 
C_FILES = 
SRC = $(FILES) $(C_FILES)

OBJ = $(patsubst %.c, %.o, $(C_FILES)) $(patsubst %.cpp, %.o, $(FILES))

LIBS = -ldl -lz -L../lib -lmemcached
CFLAGS = -fpermissive -g -std=c++0x
BUILD = $(VBIN)

CFLAGS += -fPIC -D_MP_MODE

TARGET = $(BIN)



$(TARGET):$(OBJ)
	$(CXX) -o $@ $^ $(INC) $(CFLAGS) $(LIBS) $(LINK)
	install $(TARGET) ../bin/	
%.o:%.cpp
	$(CXX) $(CFLAGS) -c -o $@ $< $(INC) $(CFLAGS)
%.o:%.c
	$(CC) $(CFLAGS) -c -o $@ $< $(INC) $(CFLAGS)
clean:
	rm -f $(OBJ) $(TARGET)

	