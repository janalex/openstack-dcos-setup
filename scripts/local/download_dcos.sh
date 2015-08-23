if [ -f "$LOCAL_DCOS_TAR_PATH" ]; then
    echo "Using local DCOS distribution in ${LOCAL_DCOS_TAR_PATH}"
else
    mkdir -p .dcos

    echo "Downloading DCOS Release tar => $(pwd)/.dcos/bootstrap.tar.xz"
    pushd .dcos > /dev/null
        curl -sOL ${DCOS_DOWNLOAD_URL}
    popd > /dev/null
    echo "Download complete"
fi
