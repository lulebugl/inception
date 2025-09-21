<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

define( 'DB_NAME', 'database_name_here' );
define( 'DB_USER', 'username_here' );
define( 'DB_PASSWORD', 'password_here' );
define( 'DB_HOST', 'mariadb:3306' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'bxy_aheKZ5#DBm:JUJp:_.&&X98kRyLbUuKm}>;ZdgOWS;o[yGpk`s>p%K?}QGzF' );
define( 'SECURE_AUTH_KEY',  '%kx%9H82s|=]_le7vGdX6l3*Az) ^xmo:y5eJza  Os`NX}d[*8O0H!PM?0C?8C;' );
define( 'LOGGED_IN_KEY',    'd_nyKj.%ZbRk-f(%&!ny-8]/9gul15qTT}?<-8KVA1VN/uaenB{wF;ycj2^1xhvw' );
define( 'NONCE_KEY',        'D6Aifk%CNAY:wLnOO3o]/^C;EKB)N((<Ryzgf}R*mlMUb.&P3MmrQ:(z-W7N,OnL' );
define( 'AUTH_SALT',        '~nSrDwUkg@deh[t2!Q*oD1FVk^5-J(.EfSK$Hdv7CZ9Y9MDa$/#{I9VumIO9ZN9E' );
define( 'SECURE_AUTH_SALT', '+2oz7fG+Dtur_9.BbXXV^lfS)Aw7V/<a^|dM--=$&E[&Cj_@+3bq;q@)x,|NOW0%' );
define( 'LOGGED_IN_SALT',   'tfZWAi2M-D?zcDq@K8eg,<?}Tq{JVK%Cpy=bJT,.:K,~J >w2S[d+|*g21M](DUx' );
define( 'NONCE_SALT',       'Z?`@/N-CTL%CB:Xy]I,t;/<$SQ0+fR7[R~,f]`)?yR$z@KE/OBgEeMV|A|vF|?*d' );

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
$table_prefix = 'wp_';

define('WP_HOME', getenv('WP_URL') ?: 'https://llebugle.42.fr');
define('WP_SITEURL', getenv('WP_URL') ?: 'https://llebugle.42.fr');
define('FORCE_SSL_ADMIN', true);

define('WP_DEBUG', false);

define('WP_CACHE', true);
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
define('WP_REDIS_DATABASE', 0);

// for direct upload
// define('FS_METHOD', 'direct');

// for upload via ftp
define('FTP_BASE_DIR', '/');
define('FTP_USER', 'www-data');
define('FTP_HOST', 'ftp');
define('FTP_PORT', 21);
define('FTP_SSL', false);
define('FTP_CONTENT_DIR', '/wp-content/');
define('FTP_PLUGIN_DIR', '/wp-content/plugins/');
define('FTP_THEME_DIR', '/wp-content/themes/');
define('FTP_UPLOAD_DIR', '/wp-content/uploads/');
define('FTP_BACKUP_DIR', '/wp-content/backups/');
define('FTP_TEMP_DIR', '/wp-content/temp/');
define('FTP_LOG_DIR', '/wp-content/logs/');

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
