CREATE TABLE IF NOT EXISTS medicines (
    id INT PRIMARY KEY AUTO_INCREMENT,
    medicine_name VARCHAR(255) NOT NULL,
    category ENUM('处方药', '非处方药') NOT NULL,
    specification VARCHAR(255) NOT NULL,
    stock_quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    manufacturer VARCHAR(255) NOT NULL,
    expiry_date DATE NOT NULL,
    stock_warning_level INT DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);