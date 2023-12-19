SELECT 'Begin executing sql script spring-session.sql' as '';

DROP TABLE IF EXISTS `SPRING_SESSION_ATTRIBUTES`;
DROP TABLE IF EXISTS `SPRING_SESSION`;

CREATE TABLE `SPRING_SESSION` (
  `PRIMARY_ID` char(36) NOT NULL,
  `SESSION_ID` char(36) NOT NULL,
  `CREATION_TIME` bigint(20) NOT NULL,
  `LAST_ACCESS_TIME` bigint(20) NOT NULL,
  `MAX_INACTIVE_INTERVAL` int(11) NOT NULL,
  `EXPIRY_TIME` bigint(20) NOT NULL,
  `PRINCIPAL_NAME` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`PRIMARY_ID`),
  UNIQUE KEY `SPRING_SESSION_IX1` (`SESSION_ID`),
  KEY `SPRING_SESSION_IX2` (`EXPIRY_TIME`),
  KEY `SPRING_SESSION_IX3` (`PRINCIPAL_NAME`)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC;

DROP INDEX IF EXISTS `SPRING_SESSION_IX1` ON `SPRING_SESSION`;
DROP INDEX IF EXISTS `SPRING_SESSION_IX2` ON `SPRING_SESSION`;
DROP INDEX IF EXISTS `SPRING_SESSION_IX3` ON `SPRING_SESSION`;

CREATE UNIQUE INDEX `SPRING_SESSION_IX1` ON `SPRING_SESSION` (SESSION_ID);
CREATE INDEX `SPRING_SESSION_IX2` ON `SPRING_SESSION` (EXPIRY_TIME);
CREATE INDEX `SPRING_SESSION_IX3` ON `SPRING_SESSION` (PRINCIPAL_NAME);

CREATE TABLE `SPRING_SESSION_ATTRIBUTES` (
  `SESSION_PRIMARY_ID` char(36) NOT NULL,
  `ATTRIBUTE_NAME` varchar(200) NOT NULL,
  `ATTRIBUTE_BYTES` blob NOT NULL,
  PRIMARY KEY (`SESSION_PRIMARY_ID`,`ATTRIBUTE_NAME`),
  CONSTRAINT `SPRING_SESSION_ATTRIBUTES_FK` FOREIGN KEY (`SESSION_PRIMARY_ID`) REFERENCES `SPRING_SESSION` (`PRIMARY_ID`) ON DELETE CASCADE
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC;

SELECT 'Finished executing sql script spring-session.sql' as '';