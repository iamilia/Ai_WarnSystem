CREATE TABLE IF NOT EXISTS `players_warning` (
  `identifier` varchar(60) NOT NULL,
  `warns` longtext DEFAULT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;