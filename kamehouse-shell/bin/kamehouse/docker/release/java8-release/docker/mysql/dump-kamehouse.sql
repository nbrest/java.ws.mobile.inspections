DROP TABLE IF EXISTS `kamehouse_user`;
CREATE TABLE `kamehouse_user` (
  `ID` bigint(20) NOT NULL,
  `ACCOUNT_NON_EXPIRED` bit(1) DEFAULT NULL,
  `ACCOUNT_NON_LOCKED` bit(1) DEFAULT NULL,
  `CREDENTIALS_NON_EXPIRED` bit(1) DEFAULT NULL,
  `EMAIL` varchar(255) NOT NULL,
  `ENABLED` bit(1) DEFAULT NULL,
  `FIRST_NAME` varchar(255) DEFAULT NULL,
  `LAST_LOGIN` datetime DEFAULT NULL,
  `LAST_NAME` varchar(255) DEFAULT NULL,
  `PASSWORD` varchar(255) DEFAULT NULL,
  `USERNAME` varchar(255) NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UK_qs207y3hr8dp1w83npduvo8v3` (`EMAIL`),
  UNIQUE KEY `UK_g1flpfg6b2v863t5535afr494` (`USERNAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `kamehouse_user` VALUES (1,_binary '',_binary '',_binary '','seiya@saintseiya.com',_binary '','Seiya',NULL,'Saint','$2a$12$FEV4fpmaooeZOoth0v9B9OVLmMbsy0jJONtKE4Y03yOpxQ0zGAtw.','seiya'),
  (2,_binary '',_binary '',_binary '','ryoma@pot.com',_binary '','Ryoma',NULL,'Echizen','$2a$12$gZ3HukIieOPe6/zK.fEsAe8k4Y2kdeEwsiskJ21p4Ev67IxuugENe','ryoma'),
  (3,_binary '',_binary '',_binary '','vegeta@dbz.com',_binary '','Vegeta',NULL,'Prince','$2a$12$cvGXhFqnXkeE0p3KUThwmO4BIxtKXHBcmCaq/gJQO.n9pc.O7pBPi','vegeta');

DROP TABLE IF EXISTS `kamehouse_role`;
CREATE TABLE `kamehouse_role` (
  `ID` bigint(20) NOT NULL,
  `NAME` varchar(255) NOT NULL,
  `kamehouse_user_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK80l3gq9u4ggdd2qqoyl8ll1c4` (`kamehouse_user_id`),
  CONSTRAINT `FK1aug04ikis5or4g40omwb5586` FOREIGN KEY (`kamehouse_user_id`) REFERENCES `kamehouse_user` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `kamehouse_role` VALUES (1,'ROLE_SAIYAJIN',1),
  (2,'ROLE_KAMISAMA',1),
  (3,'ROLE_SAIYAJIN',2),
  (4,'ROLE_NAMEKIAN',3);

DROP TABLE IF EXISTS `vlc_player`;
CREATE TABLE `vlc_player` (
  `ID` bigint(20) NOT NULL,
  `HOSTNAME` varchar(255) NOT NULL,
  `PASSWORD` varchar(255) DEFAULT NULL,
  `PORT` int(11) DEFAULT NULL,
  `USERNAME` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UK_i5fi662e7geiplqi5dr86xk45` (`HOSTNAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `vlc_player` VALUES (10000,'localhost','1',8080,NULL);
