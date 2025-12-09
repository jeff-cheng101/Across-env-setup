--
-- Current Database: `adas_one`
--

USE `adas_one`;

--
-- Table structure for table `SequelizeMeta`
--

DROP TABLE IF EXISTS `SequelizeMeta`;
CREATE TABLE `SequelizeMeta` (
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`name`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Table structure for table `cato_settings`
--

DROP TABLE IF EXISTS `cato_settings`;

CREATE TABLE `cato_settings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `contractNo` varchar(20) NOT NULL,
  `name` varchar(20) NOT NULL,
  `connectionType` varchar(100) NOT NULL,
  `siteType` varchar(100) NOT NULL,
  `description` varchar(100) NOT NULL,
  `nativeNetworkRange` varchar(100) NOT NULL,
  `vlan` int(11) NOT NULL,
  `country` varchar(100) NOT NULL,
  `countryCode` varchar(100) NOT NULL,
  `city` varchar(100) NOT NULL,
  `terminatedDate` datetime DEFAULT NULL,
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `cloudflare_dns`
--

DROP TABLE IF EXISTS `cloudflare_dns`;

CREATE TABLE `cloudflare_dns` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `contractNo` varchar(20) NOT NULL,
  `domainName` varchar(100) NOT NULL,
  `content` varchar(20) NOT NULL,
  `type` varchar(20) NOT NULL,
  `proxied` tinyint(1) DEFAULT 0,
  `ttl` int(11) DEFAULT 1,
  `zone` varchar(100) NOT NULL,
  `action` varchar(10) NOT NULL DEFAULT 'pass',
  `blackIp` longtext DEFAULT NULL,
  `whiteIp` longtext DEFAULT NULL,
  `blockGeolocation` longtext DEFAULT NULL,
  `geolocationType` varchar(20) DEFAULT NULL,
  `cacheOn` tinyint(1) NOT NULL DEFAULT 1,
  `browserTtlMode` varchar(50) DEFAULT NULL,
  `browserTtlDefault` int(11) DEFAULT NULL,
  `edgeTtlMode` varchar(50) DEFAULT NULL,
  `edgeTtlDefault` int(11) DEFAULT NULL,
  `terminatedDate` datetime DEFAULT NULL,
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `cloudflare_zones`
--

DROP TABLE IF EXISTS `cloudflare_zones`;

CREATE TABLE `cloudflare_zones` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `zone` varchar(100) NOT NULL,
  `contractNo` varchar(20) NOT NULL,
  `sensitivityLevel` varchar(10) NOT NULL DEFAULT 'default',
  `terminatedDate` datetime DEFAULT NULL,
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `contract_resellers`
--

DROP TABLE IF EXISTS `contract_resellers`;

CREATE TABLE `contract_resellers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `contractNo` varchar(20) NOT NULL,
  `userId` varchar(100) NOT NULL,
  `email` varchar(200) NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `contract_resellers_contract_no` (`contractNo`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `contract_users`
--

DROP TABLE IF EXISTS `contract_users`;

CREATE TABLE `contract_users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `contractNo` varchar(20) NOT NULL,
  `userId` varchar(100) NOT NULL,
  `email` varchar(200) NOT NULL,
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `contract_users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `contracts`
--

DROP TABLE IF EXISTS `contracts`;

CREATE TABLE `contracts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `contractNo` varchar(20) NOT NULL,
  `plan` longtext NOT NULL,
  `company` varchar(200) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `serviceCount` int(11) NOT NULL DEFAULT 0,
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `contracts_contract_no` (`contractNo`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `f5_waf_settings`
--

DROP TABLE IF EXISTS `f5_waf_settings`;

CREATE TABLE `f5_waf_settings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `contractNo` varchar(20) NOT NULL,
  `domainName` varchar(100) NOT NULL,
  `virtualServerIp` varchar(100) NOT NULL,
  `nodeIp` varchar(100) NOT NULL,
  `ports` varchar(100) NOT NULL,
  `sslPorts` varchar(100) NOT NULL,
  `terminatedDate` datetime DEFAULT NULL,
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `geolocation`
--

DROP TABLE IF EXISTS `geolocation`;

CREATE TABLE `geolocation` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `country` varchar(100) NOT NULL,
  `code` varchar(10) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `opsOnlyForDisallowed` tinyint(1) NOT NULL DEFAULT 0,
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=250 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;

CREATE TABLE `logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `userId` varchar(100) NOT NULL,
  `contractNo` varchar(20) DEFAULT NULL,
  `action` varchar(20) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `track` longtext DEFAULT NULL,
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `plans`
--

DROP TABLE IF EXISTS `plans`;

CREATE TABLE `plans` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `plan_code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` longtext DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `plans_plan_code` (`plan_code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;

CREATE TABLE `reports` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `type` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `contractNo` varchar(20) DEFAULT NULL,
  `dashboardIds` longtext DEFAULT NULL,
  `to` varchar(2000) DEFAULT NULL,
  `cc` varchar(2000) DEFAULT NULL,
  `bcc` varchar(2000) DEFAULT NULL,
  `subject` varchar(200) DEFAULT NULL,
  `text` varchar(6000) DEFAULT NULL,
  `customDate` datetime DEFAULT NULL,
  `lastSent` datetime DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'active',
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `userId` varchar(100) DEFAULT NULL,
  `email` varchar(200) NOT NULL,
  `password` varchar(200) DEFAULT NULL,
  `company` varchar(200) DEFAULT NULL,
  `name` varchar(200) DEFAULT NULL,
  `phone` varchar(200) DEFAULT NULL,
  `role` varchar(20) NOT NULL,
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  `resetPasswordToken` varchar(255) DEFAULT NULL,
  `resetPasswordExpires` datetime DEFAULT NULL,
  `lastPasswordReset` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `zone_traffic`
--

DROP TABLE IF EXISTS `zone_traffic`;

CREATE TABLE `zone_traffic` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `zone` varchar(100) NOT NULL,
  `requests` int(11) DEFAULT NULL,
  `bytes` int(11) DEFAULT NULL,
  `startDate` datetime NOT NULL,
  `endDate` datetime NOT NULL,
  `creator` varchar(50) NOT NULL DEFAULT '',
  `updator` varchar(50) NOT NULL DEFAULT '',
  `deleter` varchar(50) NOT NULL DEFAULT '',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
