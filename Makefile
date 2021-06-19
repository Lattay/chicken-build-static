main:
	./build_static.sh --egg args --entrypoint src/main.scm

clean:
	rm -r _docker

wipe: clean
	rm main
