#!/bin/sh

# Global variables
DIR_CONFIG="/etc/NENU"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write NENU configuration
cat << EOF > ${DIR_TMP}/heroku.json
{
    "inbounds": [{
        "port": ${PORT},
        "protocol": "vless",
        "settings": {
            "clients": [{
                "id": "${ID}"
            }],
            "decryption": "none"
        }
        }
    }],
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF

# Get V2Ray executable release
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip -o ${DIR_TMP}/v2ray_dist.zip
busybox unzip ${DIR_TMP}/v2ray_dist.zip -d ${DIR_TMP}

# Convert to protobuf format configuration
mkdir -p ${DIR_CONFIG}
${DIR_TMP}/v2ctl config ${DIR_TMP}/heroku.json > ${DIR_CONFIG}/config.pb

# Install NENU
install -m 755 ${DIR_TMP}/NENU ${DIR_RUNTIME}
rm -rf ${DIR_TMP}

# Run NENU
${DIR_RUNTIME}/NENU -config=${DIR_CONFIG}/config.pb
