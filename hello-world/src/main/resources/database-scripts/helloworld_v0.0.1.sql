-- hello.`user` definition

CREATE TABLE `user` (
                        `user_id` decimal(10,0) NOT NULL,
                        `name` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;