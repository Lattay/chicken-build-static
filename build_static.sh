#!/bin/bash
dependencies=()
platform=amd64
version=5.2.0
sources=()
options=()
sources_local=()
entrypoint=main.scm
bin_name=main

make_dockerfile() {
    cat <<EOF > Dockerfile
FROM lattay/chicken:$version-$platform
COPY ${sources_local[@]} /
RUN chicken-install ${dependencies[@]}
RUN csc -static $options /$entrypoint -o /main
EOF
}

build_image() {
    tmp=$(mktemp)
    echo "docker build ."
    docker build . | tee $tmp

    image_id=$(sed -n '/Success/p' $tmp| cut -d' ' -f3)
    if [[ -z $image_id ]]
    then
        exit 1
    fi
    rm $tmp
    echo $image_id
}

extract_artifact() {
    # Instantiate image
    container_id=$(docker create $image_id)
    # Extract final file
    docker cp $container_id:/main ../$bin_name
    # Delete instance
    docker rm $container_id
}

help() {
    echo "Usage: build_static.sh OPTIONS ... [-- COMPILER_OPTIONS ...]"
    echo "Options:"
    echo "-g, --egg EGG               Add an egg to installed before building the binary"
    echo "-s, --source SRC_FILE       A source file to copy"
    echo "-e, --entrypoint FILE_NAME  Filename of the binary entrypoint"
    echo "-p, --platform PLATFORM     Platform name (amd64 or armv7)"
    echo "-v, --version VERSION       Chicken version (5.2)"
    echo "-b, --bin-name BIN_NAME     How the final binary should be called"
    echo "COMPILER_OPTIONS            Options to be directly passed to chicken compiler"

}

main () (
    while [[ -n "${1:-}" ]]
    do
        case $1 in
            -g|--egg)
                shift
                dependencies+=($1)
                ;;
            -s|--source)
                shift
                sources+=($1)
                ;;
            -e|--entrypoint)
                shift
                entrypoint="${1#*/}"
                sources+=($1)
                sources_local+=("${1#*/}")
                ;;
            -p|--platform)
                shift
                platform=$1
                ;;
            -v|--version)
                shift
                version=$1
                ;;
            -b|--bin-name)
                shift
                bin_name=$1
                ;;
            --)
                shift
                break
                ;;
            *)
                help
                exit 1
                ;;
        esac
        shift
    done

    options="$@"

    mkdir _docker
    
    cp ${sources[@]} _docker -r

    cd _docker

    make_dockerfile

    build_image

    rm Dockerfile

    extract_artifact
)

main $@
