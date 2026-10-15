<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trò Chơi Câu Cá 2D</title>
    <!-- Nhúng thư viện Phaser 3 từ CDN -->
    <script src="https://cdn.jsdelivr.net/npm/phaser@3.55.2/dist/phaser.js"></script>
    <!-- Liên kết file CSS -->
    <link rel="stylesheet" href="style.css">
</head>
<body>

    <!-- Nơi chứa game -->
    <div id="game-container"></div>

    <!-- Liên kết file JavaScript -->
    <script src="game.js"></script>
</body>
</html>
