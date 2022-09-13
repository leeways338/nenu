#!/bin/sh

# Global variables
DIR_CONFIG="/etc/NENU"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write NENU configuration
cat << EOF > ${DIR_TMP}/heroku.json
{"inbounds": [
        {
            "port": 8080,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID",
                        "level": 0
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none"
            }
        }
        // {
        //     "port": 8082,
        //     "listen": "127.0.0.1",
        //     "protocol": "vless",
        //     "settings": {
        //         "clients": [
        //             {
        //                 "id": "$UUID",
        //                 "level": 0
        //             }
        //         ],
        //         "decryption": "none"
        //     },
        //     "streamSettings": {
        //         "security": "none",
        //         "network": "h2",
        //         "httpSettings": {
        //             "path": "/h2",
        //             "host": [
        //                 "**.herokuapp.com"
        //             ]
        //         }
        //     }
        // }
    ],
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
