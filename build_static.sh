#!/bin/bash

set -euo pipefail

platform=linux
arch=amd64
version=5.2.0
bin_name=main
keep=no
image_id=""
entrypoint=""
sources=()
options=()
dependencies=()
sources_local=()
static_static=no

make_dockerfile() {
    if [[ $keep == yes && -e Dockerfile ]]
    then
        return 0
    fi

    if [[ $platform == linux ]]
    then
        if [[ $static_static == yes ]]
        then
            image=lattay/chicken-alpine
        else
            image=lattay/chicken
        fi
        tag=$version-$arch
        prefix=""
    else
        image=lattay/chicken-mingw
        prefix=win32-
        tag=$version
    fi

    if [[ $static_static == yes ]]
    then
        options="-L -static $options"
    fi

    if [[ "${#dependencies[@]}" != 0 ]]
    then
        echo "${#dependencies[@]}"
        install_dep="RUN ${prefix}chicken-install ${dependencies[@]}"
    else
        install_dep=""
    fi

    cat <<EOF > Dockerfile
FROM $image:$tag
COPY ${sources_local[@]} /
${install_dep}
RUN ${prefix}csc -static $options /$entrypoint -o /main
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
}

extract_artifact() {
    # Instantiate image
    container_id=$(docker create $image_id)
    # Extract final file

    if [[ $platform == linux ]]
    then
        ext=
    else
        ext=.exe
    fi
    docker cp $container_id:/main${ext} ../$bin_name
    # Delete instance
    docker rm $container_id
}

help() {
    echo "Usage: build_static.sh OPTIONS... ENTRYPOINT [-- COMPILER_OPTIONS...]"
    echo "Options:"
    echo "-g, --egg EGG            Add an egg to installed before building the binary"
    echo "-s, --source SRC_FILE    A source file to copy"
    echo "-a, --arch ARCH          Target architecture name (amd64 or armv7)"
    echo "-p, --platform PLATFORM  Target platform name (linux or mingw)"
    echo "-v, --version VERSION    Chicken version (5.2)"
    echo "-b, --bin-name BIN_NAME  How the final binary should be called"
    echo "-k, --keep               Do not overwrite the Dockerfile if it already exists"
    echo "--static                 Build a fully static binary"
    echo "ENTRYPOINT               Filename of the binary entrypoint"
    echo "COMPILER_OPTIONS         Options to be directly passed to chicken compiler"
}

help_and_abort() {
    help
    exit 1
}

assert_nz() {
    [[ -n "$1" ]] || help_and_abort
}


main () (
    while [[ -n "${1:-}" ]]
    do
        case "$1" in
            -g|--egg)
                shift; assert_nz "${1:-}"
                dependencies+=("$1")
                ;;
            -s|--source)
                shift; assert_nz "${1:-}"
                sources+=("$1")
                ;;
            -p|--platform)
                shift; assert_nz "${1:-}"
                platform="$1"
                ;;
            -a|--arch)
                shift; assert_nz "${1:-}"
                arch="$1"
                ;;
            -v|--version)
                shift; assert_nz "${1:-}"
                version="$1"
                ;;
            -b|--bin-name)
                shift; assert_nz "${1:-}"
                bin_name="$1"
                ;;
            -k|--keep)
                keep=yes
                ;;
            --static)
                static_static=yes
                ;;
            --)
                shift
                break
                ;;
            -h|--help)
                help_and_abort
                ;;
            *)
                if [[ -z "$entrypoint" ]]
                then
                    entrypoint="${1#*/}"
                    sources+=("$1")
                    sources_local+=("${1#*/}")
                else
                    help_and_abort
                fi
                ;;
        esac
        shift
    done

    if [[ $platform == mingw && "$bin_name" != *.exe ]]
    then
        bin_name=$bin_name.exe
    fi

    options="$@"

    assert_nz "$entrypoint"

    mkdir -p _docker
    
    cp ${sources[@]} _docker -r

    cd _docker

    make_dockerfile

    build_image

    extract_artifact
)

main $@
