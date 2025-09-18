<?php
// WordPress configuration template. Values come from env/secrets.

define('DB_NAME', getenv('MARIADB_DATABASE') ?: 'wordpress');
define('DB_USER', getenv('MARIADB_USER') ?: 'wp_user');
$db_pass = file_exists('/run/secrets/db_password') ? trim(file_get_contents('/run/secrets/db_password')) : '';
define('DB_PASSWORD', $db_pass);
define('DB_HOST', 'mariadb:3306');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

$table_prefix = 'wp_';

define('WP_HOME', getenv('WP_URL') ?: 'https://llebugle.42.fr');
define('WP_SITEURL', getenv('WP_URL') ?: 'https://llebugle.42.fr');
define('FORCE_SSL_ADMIN', true);

define('WP_DEBUG', false);

if (!defined('ABSPATH'))
  define('ABSPATH', __DIR__ . '/');

require_once ABSPATH . 'wp-settings.php';

