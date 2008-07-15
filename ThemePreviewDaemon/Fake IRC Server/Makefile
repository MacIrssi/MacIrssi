TARGET=textserver
OBJS=textserver.o
CC=gcc
CFLAGS=
LIBS=

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -o $(TARGET) $(OBJS) $(LIBS)

%.o: %.c
	$(CC) -c -o $(CFLAGS) $@ $<
	
clean:
	rm -f $(OBJS) $(TARGET)