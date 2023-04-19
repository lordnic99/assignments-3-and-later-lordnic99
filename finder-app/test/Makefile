write: writer.o
	gcc writer.o -o writer
writer.o: writer.c
	gcc -c writer.c -o writer.o
clean:
	rm -rf writer.o writer
CROSS_COMPILE:
	aarch64-none-linux-gnu-gcc -static writer.c -o writer

