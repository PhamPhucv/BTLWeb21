<?php

/**
 * auto_setup.php - Tự động phát hiện cổng MySQL, kết nối với mật khẩu phù hợp
 * và tự động import cơ sở dữ liệu customer_db nếu chưa tồn tại.
 */

$ports = ['3306', '3307'];
$passwords = ['123456', '', 'root'];
$pdo = null;
$connectedPort = null;
$connectedPass = null;

foreach ($ports as $port) {
    foreach ($passwords as $pass) {
        try {
            $pdo = new PDO(
                "mysql:host=127.0.0.1;port={$port};charset=utf8mb4",
                'root',
                $pass,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::MYSQL_ATTR_MULTI_STATEMENTS => true
                ]
            );
            $connectedPort = $port;
            $connectedPass = $pass;
            break 2;
        } catch (PDOException $e) {
            // Thử tiếp cổng hoặc mật khẩu khác
        }
    }
}

if (!$pdo) {
    echo "[!] Khong the ket noi den MySQL tren cong 3306 hoac 3307.\n";
    echo "    Vui long kiem tra MySQL da duoc bat trong XAMPP Control Panel hoac Windows Services!\n";
    exit(1);
}

echo "[OK] Ket noi thanh cong MySQL tren cong {$connectedPort}.\n";

// Tự động đồng bộ mật khẩu kết nối vào config/database.php nếu cần
$configFile = __DIR__ . '/config/database.php';
if (file_exists($configFile) && is_writable($configFile)) {
    $configContent = file_get_contents($configFile);
    $escapedPass = addslashes($connectedPass);
    $newConfig = preg_replace(
        "/define\('DB_PASS',\s*'.*?'\);/",
        "define('DB_PASS', '{$escapedPass}');",
        $configContent
    );
    if ($newConfig !== null && $newConfig !== $configContent) {
        file_put_contents($configFile, $newConfig);
    }
}

try {
    $stmt = $pdo->query("SHOW DATABASES LIKE 'customer_db'");
    $dbExists = $stmt->fetchColumn();

    $needImport = false;
    if (!$dbExists) {
        $needImport = true;
    } else {
        $pdo->exec("USE `customer_db`");
        $stmt = $pdo->query("SHOW TABLES LIKE 'customers'");
        if (!$stmt->fetchColumn()) {
            $needImport = true;
        }
    }

    if ($needImport) {
        echo "[i] Dang tu dong import co so du lieu database.sql vao MySQL...\n";
        $sqlFile = __DIR__ . '/database.sql';
        if (file_exists($sqlFile)) {
            $sql = file_get_contents($sqlFile);
            $pdo->exec($sql);
            echo "[OK] Import co so du lieu thanh cong!\n";
        } else {
            echo "[!] Khong tim thay file database.sql.\n";
        }
    } else {
        echo "[OK] Co so du lieu customer_db da ton tai va san sang su dung.\n";
    }
} catch (Exception $e) {
    echo "[!] Loi thiet lap CSDL: " . $e->getMessage() . "\n";
}

exit(0);
