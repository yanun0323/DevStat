.PHONY:

build:	
	rm -rf appcast.xml;\
	generate_appcast -o appcast.xml .