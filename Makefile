CC = cc 
CFLAGS = -arch i386 -arch x86_64 -include atadatem_Prefix.pch -I .

all: atadatem

atadatem: atadatem.o
	gcc -arch i386 -arch x86_64 -o atadatem $^ -framework Cocoa -framework Carbon

install: cliclick
	cp cliclick /usr/local/bin/

clean:
	$(RM) -v *.o
	$(RM) -vr atadatem
