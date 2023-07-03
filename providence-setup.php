<?php
// Helper to setup Providence with environment variables.
// See Providence's setup.php-dist for variable documentation.

if (getenv('CA_DEBUG') == 'true'){
  ini_set('display_errors', 1);
  ini_set('display_startup_errors', 1);
  error_reporting(E_ALL);
}

date_default_timezone_set(getenv('TZ') ?: 'Etc/UTC');

$ENV_NAME_TO_DEFAULT_VALUE = [
  'CA_DB_HOST' => 'localhost',
  'CA_DB_USER' => 'providance',
  'CA_DB_PASSWORD' => 'providance',
  'CA_DB_DATABASE' => 'providance',
  'CA_APP_DISPLAY_NAME' => 'My dockerized CollectiveAccess system',
  'CA_ADMIN_EMAIL' => 'admin@local',
  'CA_SMTP_SERVER' => null,
  'CA_SMTP_PORT' => null,
  'CA_SMTP_AUTH' => null,
  'CA_SMTP_USER' => null,
  'CA_SMTP_PASSWORD' => null,
  'CA_SMTP_SSL' => null,
  'CA_QUEUE_ENABLED' => 0,
  'CA_DEFAULT_LOCALE' => 'en_US',
  'CA_USE_CLEAN_URLS' => 0,
  'CA_APP_NAME' => 'collectiveaccess',
  'CA_GOOGLE_MAPS_KEY' => '',
  'CA_CACHE_BACKEND' => 'file',
  'CA_CACHE_FILEPATH' => null,
  'CA_CACHE_TTL' => null,
  'CA_MEMCACHED_HOST' => null,
  'CA_MEMCACHED_PORT' => null,
  'CA_REDIS_HOST' => null,
  'CA_REDIS_PORT' => null,
  'CA_REDIS_DB' => null,
  'CA_ALLOW_INSTALLER_TO_OVERWRITE_EXISTING_INSTALLS' => false,
  'CA_STACKTRACE_ON_EXCEPTION' => true,
  'CA_OUT_OF_PROCESS_SEARCH_INDEXING_HOSTNAME' => 'localhost',
  'CA_OUT_OF_PROCESS_SEARCH_INDEXING_PROTOCOL' => 'tcp',
  'CA_OUT_OF_PROCESS_SEARCH_INDEXING_PORT' => 80,
];

foreach ($ENV_NAME_TO_DEFAULT_VALUE as $env_name => $default_value) {
  $ca_config_name = '__' . $env_name . '__';

  if (!defined($ca_config_name)) {
    $config_value = getenv($env_name);

    if ($config_value !== false) {
      define($ca_config_name, $config_value);
    }
    else if ($default_value !== null){
      define($ca_config_name, $default_value);
    }
  }
}

require(__DIR__."/app/helpers/post-setup.php");
