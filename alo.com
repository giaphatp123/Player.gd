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
body {
    margin: 0;
    padding: 0;
    background-color: #1a1a1a;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    color: white;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    overflow: hidden;
}

#game-container {
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5);
    border-radius: 8px;
    overflow: hidden;
}
const config = {
    type: Phaser.AUTO,
    width: 800,
    height: 600,
    parent: 'game-container',
    physics: {
        default: 'arcade',
        arcade: {
            gravity: { y: 0 },
            debug: false
        }
    },
    scene: {
        preload: preload,
        create: create,
        update: update
    }
};

let game = new Phaser.Game(config);
let score = 0;
let scoreText;
let hook;
let fishes;
let isDropping = false;
let isRetracting = false;

function preload() {
    // Tải tài nguyên (nếu có hình ảnh/âm thanh sau này)
}

function create() {
    // Tạo hiệu ứng nền trời và mặt nước
    this.add.rectangle(400, 150, 800, 300, 0x87CEEB); // Bầu trời
    this.add.rectangle(400, 450, 800, 300, 0x1E90FF); // Đại dương

    // Điểm số
    scoreText = this.add.text(16, 16, 'Điểm: 0', { 
        fontSize: '24px', 
        fill: '#ffffff',
        fontStyle: 'bold',
        stroke: '#000000',
        strokeThickness: 4
    });

    // Tạo móc câu
    hook = this.add.rectangle(400, 100, 20, 20, 0x808080);
    this.physics.add.existing(hook);
    hook.body.setAllowGravity(false);

    // Nhóm chứa các con cá
    fishes = this.physics.add.group();

    // Tạo cá xuất hiện liên tục mỗi 1.5 giây
    this.time.addEvent({
        delay: 1500,
        callback: spawnFish,
        callbackScope: this,
        loop: true
    });

    // Xử lý sự kiện click chuột để thả cần câu
    this.input.on('pointerdown', (pointer) => {
        if (!isDropping && !isRetracting) {
            hook.x = pointer.x;
            isDropping = true;
        }
    });

    // Va chạm giữa móc câu và cá
    this.physics.add.overlap(hook, fishes, catchFish, null, this);
}

function update() {
    // Thả cần câu xuống
    if (isDropping) {
        hook.y += 5;
        if (hook.y >= 550) {
            isDropping = false;
            isRetracting = true;
        }
    }

    // Kéo cần câu lên
    if (isRetracting) {
        hook.y -= 5;
        if (hook.y <= 100) {
            isRetracting = false;
        }
    }
}

function spawnFish() {
    let yPos = Phaser.Math.Between(350, 550);
    let direction = Phaser.Math.Between(0, 1);
    let xPos = direction === 0 ? -50 : 850;
    let speed = direction === 0 ? Phaser.Math.Between(1, 3) : -Phaser.Math.Between(1, 3);

    // Tạo con cá hình chữ nhật màu cam
    let fish = this.add.rectangle(xPos, yPos, 40, 20, 0xff7f50);
    fishes.add(fish);
    fish.body.setVelocityX(speed * 50);
    fish.direction = direction;
}

function catchFish(hook, fish) {
    fish.destroy();
    score += 10;
    scoreText.setText('Điểm: ' + score);
    isRetracting = true;
    isDropping = false;
}
