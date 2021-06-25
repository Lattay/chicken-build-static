main:
	../build_static.sh --egg args src/main.scm

main_static:
	../build_static.sh --egg args src/main.scm -b main_static --static

clean:
	rm -rf _docker

wipe: clean
	rm -f main main_static 
