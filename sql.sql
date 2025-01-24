CREATE TABLE IF NOT EXISTS `yrgroups_bank` (
	`org` VARCHAR(50) NULL DEFAULT NULL,
	`bank` BIGINT NULL DEFAULT 0
)COLLATE='utf8mb4_general_ci';

CREATE TABLE IF NOT EXISTS `yrgroups_set` (
	`org` VARCHAR(50) NULL DEFAULT NULL,
	`id` INT(50) NULL DEFAULT NULL,
    `cargo` VARCHAR(50) NULL DEFAULT NULL
)COLLATE='utf8mb4_general_ci';

-- INSERT INTO `complexo`.`yrgroups_bank` (`org`,`bank`) VALUES ('Vagos', 0);
-- INSERT INTO `complexo`.`yrgroups_bank` (`org`,`bank`) VALUES ('Ballas', 200);