MONGODB_HOST = [ '192.168.26.180:27017' ]
#MONGODB_PORT = 27017
MONGODB_DBNAME = 'fb_rawdata'
MONGODB_USER_NAME = 'admin'
MONGODB_USER_PWD = '12345'

TABLE_PAGES = :pages#'pages' # primary key: page_id
TABLE_POSTS = :posts#'posts' # primary key: post_id
TABLE_COMMENTS = :comments#'comments' # primary key: post_id
TABLE_LIKES = :likes#'likes' # primary key: post_id
TABLE_USERS = :users#'users' # primary key: fb_id
#TABLE_STATISTICS = 'statistics' # primary key: page_id+YYYY-MM

DEBUG = false
