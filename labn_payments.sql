CREATE TABLE `labn_payments` (
  	`id` int(11) NOT NULL AUTO_INCREMENT,
  	`identifier` varchar(46) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  	`label` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  	`amount` int(11) NOT NULL,
  	`status` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  	`type` varchar(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  	PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;