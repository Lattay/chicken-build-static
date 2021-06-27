main:
	../build_static.sh --egg args src/main.scm

main.exe:
	../build_static.sh --platform mingw --egg args src/main.scm

main_static:
	../build_static.sh --egg args src/main.scm -b main_static --static

hello:
	../build_static.sh -b hello src/hello.scm

hello.exe:
	../build_static.sh -p mingw -b hello.exe src/hello.scm

clean:
	rm -rf _docker

wipe: clean
	rm -f main main_static hello *.exe
