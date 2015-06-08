MONGODB_HOST = '127.0.0.1'
MONGODB_PORT = 27017
MONGODB_DBNAME = 'fb_crawler'
MONGODB_USER_NAME = 'tachen'
MONGODB_USER_PWD = 'iscae100'

TABLE_PAGES = 'pages' # primary key: page_id
TABLE_POSTS = 'posts' # primary key: post_id
TABLE_COMMENTS = 'comments' # primary key: post_id
TABLE_LIKES = 'likes' # primary key: post_id
TABLE_USERS = 'users' # primary key: fb_id
TABLE_STATISTICS = 'statistics' # primary key: page_id+YYYY-MM

DEBUG = false
