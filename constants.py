import os
# Deprecated domains which we should to redirect to REDIRECT_URL.
REDIRECT_DOMAINS = [
    'apprtc.appspot.com', 'apprtc.webrtc.org', 'www.appr.tc'
]
# URL which we should redirect to if matching in REDIRECT_DOMAINS.
REDIRECT_URL = 'https://appr.tc'

ROOM_MEMCACHE_EXPIRATION_SEC = 60 * 60 * 24
MEMCACHE_RETRY_LIMIT = 100

LOOPBACK_CLIENT_ID = 'LOOPBACK_CLIENT_ID'

# Turn/Stun server override. This allows AppRTC to connect to turn servers
# directly rather than retrieving them from an ICE server provider.
#ICE_SERVER_OVERRIDE = None
# Enable by uncomment below and comment out above, then specify turn and stun
ICE_SERVER_OVERRIDE = [
    {
        "urls": "turn:server_ip:3478?transport=udp",
        "username": "user_name",
        "credential": "user_password"
    },
    {
        "urls": "turn:server_ip:3478?transport=tcp",
        "username": "user_name",
        "credential": "user_password"
    }
]

ICE_SERVER_BASE_URL = ''
ICE_SERVER_URL_TEMPLATE = ''
ICE_SERVER_API_KEY = os.environ.get('')
HEADER_MESSAGE = os.environ.get('HEADER_MESSAGE')
ICE_SERVER_URLS = [url for url in os.environ.get(
    'ICE_SERVER_URLS', '').split(',') if url]

# Dictionary keys in the collider instance info constant.
WSS_INSTANCE_HOST_KEY = 'example.com:8443'
WSS_INSTANCE_NAME_KEY = 'wsserver-std'
WSS_INSTANCE_ZONE_KEY = 'us-central1-a'
WSS_INSTANCES = [{
    WSS_INSTANCE_HOST_KEY: 'example.com:8443',
    WSS_INSTANCE_NAME_KEY: 'collinder-2',
    WSS_INSTANCE_ZONE_KEY: 'vn-nhanhoa-02'
}, {
    WSS_INSTANCE_HOST_KEY: 'example.com:8443',
    WSS_INSTANCE_NAME_KEY: 'collinder-1',
    WSS_INSTANCE_ZONE_KEY: 'vn-nhanhoa-01'
}]

WSS_HOST_PORT_PAIRS = [ins[WSS_INSTANCE_HOST_KEY] for ins in WSS_INSTANCES]

# memcache key for the active collider host.
WSS_HOST_ACTIVE_HOST_KEY = 'example.com:8443'

# Dictionary keys in the collider probing result.
WSS_HOST_IS_UP_KEY = 'is_up'
WSS_HOST_STATUS_CODE_KEY = 'status_code'
WSS_HOST_ERROR_MESSAGE_KEY = 'error_message'

RESPONSE_ERROR = 'ERROR'
RESPONSE_ROOM_FULL = 'FULL'
RESPONSE_UNKNOWN_ROOM = 'UNKNOWN_ROOM'
RESPONSE_UNKNOWN_CLIENT = 'UNKNOWN_CLIENT'
RESPONSE_DUPLICATE_CLIENT = 'DUPLICATE_CLIENT'
RESPONSE_SUCCESS = 'SUCCESS'
RESPONSE_INVALID_REQUEST = 'INVALID_REQUEST'

IS_DEV_SERVER = os.environ.get('APPLICATION_ID', '').startswith('dev')

BIGQUERY_URL = 'https://www.googleapis.com/auth/bigquery'

# Dataset used in production.
BIGQUERY_DATASET_PROD = 'prod'

# Dataset used when running locally.
BIGQUERY_DATASET_LOCAL = 'dev'

# BigQuery table within the dataset.
BIGQUERY_TABLE = 'analytics'
