-- =====================================================================
--  Лабораторная работа №1. Вариант 3
--  «Система, описывающая порядок получения водительских прав»
--  Реляционная модель в третьей нормальной форме (3НФ)
--  СУБД: MySQL 8.0 | Автор: Ахадов К.У., гр. 223-322
-- =====================================================================

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `voditelskie_prava`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE `voditelskie_prava`;

-- ---------------------------------------------------------------------
-- СПРАВОЧНИКИ
-- ---------------------------------------------------------------------

-- Категории транспортных средств (A, B, C ...)
CREATE TABLE IF NOT EXISTS `kategoriya_prav` (
  `id`          INT NOT NULL AUTO_INCREMENT,
  `kod`         VARCHAR(5)   NOT NULL,
  `nazvanie`    VARCHAR(100) NOT NULL,
  `min_vozrast` TINYINT      NOT NULL DEFAULT 18,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `kategoriya_kod_UNIQUE` (`kod` ASC) VISIBLE
) ENGINE = InnoDB;

-- Автошколы
CREATE TABLE IF NOT EXISTS `avtoshkola` (
  `id`              INT NOT NULL AUTO_INCREMENT,
  `nazvanie`        VARCHAR(100) NOT NULL,
  `adres`           VARCHAR(255) NOT NULL,
  `telefon`         VARCHAR(15)  NOT NULL,
  `nomer_litsenzii` VARCHAR(30)  NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `avtoshkola_litsenziya_UNIQUE` (`nomer_litsenzii` ASC) VISIBLE
) ENGINE = InnoDB;

-- Должности сотрудников автошколы
CREATE TABLE IF NOT EXISTS `dolzhnost` (
  `id`       INT NOT NULL AUTO_INCREMENT,
  `nazvanie` VARCHAR(60)   NOT NULL,
  `oklad`    DECIMAL(10,2) NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `dolzhnost_nazvanie_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB;

-- Медицинские учреждения, выдающие справки
CREATE TABLE IF NOT EXISTS `med_uchrezhdenie` (
  `id`              INT NOT NULL AUTO_INCREMENT,
  `nazvanie`        VARCHAR(100) NOT NULL,
  `adres`           VARCHAR(255) NOT NULL,
  `nomer_litsenzii` VARCHAR(30)  NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `med_uchr_litsenziya_UNIQUE` (`nomer_litsenzii` ASC) VISIBLE
) ENGINE = InnoDB;

-- Подразделения Госавтоинспекции (МРЭО / РЭО)
CREATE TABLE IF NOT EXISTS `podrazdelenie_gibdd` (
  `id`       INT NOT NULL AUTO_INCREMENT,
  `nazvanie` VARCHAR(100) NOT NULL,
  `adres`    VARCHAR(255) NOT NULL,
  `telefon`  VARCHAR(15)  NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `podrazdelenie_nazvanie_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB;

-- Типы экзаменов (внутренние в автошколе и в ГИБДД)
CREATE TABLE IF NOT EXISTS `tip_ekzamena` (
  `id`          INT NOT NULL AUTO_INCREMENT,
  `nazvanie`    VARCHAR(100) NOT NULL,
  `etap`        ENUM('vnutrenniy','gibdd') NOT NULL,
  `vid`         ENUM('teoriya','ploshchadka','gorod') NOT NULL,
  `max_oshibok` TINYINT NOT NULL DEFAULT 2,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `tip_ekzamena_UNIQUE` (`etap` ASC, `vid` ASC) VISIBLE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- АВТОШКОЛА: СОТРУДНИКИ, АВТОМОБИЛИ, ГРУППЫ
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `sotrudnik` (
  `id`            INT NOT NULL AUTO_INCREMENT,
  `avtoshkola_id` INT NOT NULL,
  `dolzhnost_id`  INT NOT NULL,
  `familiya`      VARCHAR(45) NOT NULL,
  `imya`          VARCHAR(45) NOT NULL,
  `otchestvo`     VARCHAR(45) NULL,
  `telefon`       VARCHAR(15) NOT NULL,
  `stazh_let`     TINYINT     NULL,
  `data_priema`   DATE        NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `sotrudnik_telefon_UNIQUE` (`telefon` ASC) VISIBLE,
  INDEX `fk_sotrudnik_avtoshkola_idx` (`avtoshkola_id` ASC) VISIBLE,
  INDEX `fk_sotrudnik_dolzhnost_idx`  (`dolzhnost_id` ASC)  VISIBLE,
  CONSTRAINT `fk_sotrudnik_avtoshkola`
    FOREIGN KEY (`avtoshkola_id`) REFERENCES `avtoshkola` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_sotrudnik_dolzhnost`
    FOREIGN KEY (`dolzhnost_id`) REFERENCES `dolzhnost` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `uchebnoe_avto` (
  `id`            INT NOT NULL AUTO_INCREMENT,
  `avtoshkola_id` INT NOT NULL,
  `kategoriya_id` INT NOT NULL,
  `marka`         VARCHAR(45) NOT NULL,
  `model`         VARCHAR(45) NOT NULL,
  `gos_nomer`     VARCHAR(12) NOT NULL,
  `korobka`       ENUM('MKPP','AKPP') NOT NULL,
  `god_vypuska`   YEAR NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `avto_gos_nomer_UNIQUE` (`gos_nomer` ASC) VISIBLE,
  INDEX `fk_avto_avtoshkola_idx` (`avtoshkola_id` ASC) VISIBLE,
  INDEX `fk_avto_kategoriya_idx` (`kategoriya_id` ASC) VISIBLE,
  CONSTRAINT `fk_avto_avtoshkola`
    FOREIGN KEY (`avtoshkola_id`) REFERENCES `avtoshkola` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_avto_kategoriya`
    FOREIGN KEY (`kategoriya_id`) REFERENCES `kategoriya_prav` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `uchebnaya_gruppa` (
  `id`               INT NOT NULL AUTO_INCREMENT,
  `avtoshkola_id`    INT NOT NULL,
  `kategoriya_id`    INT NOT NULL,
  `prepodavatel_id`  INT NOT NULL,
  `nomer_gruppy`     VARCHAR(15) NOT NULL,
  `forma_obucheniya` ENUM('dnevnaya','vechernyaya','vyhodnogo_dnya') NOT NULL,
  `data_nachala`     DATE NOT NULL,
  `data_okonchaniya` DATE NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `gruppa_nomer_UNIQUE` (`nomer_gruppy` ASC) VISIBLE,
  INDEX `fk_gruppa_avtoshkola_idx`   (`avtoshkola_id` ASC)   VISIBLE,
  INDEX `fk_gruppa_kategoriya_idx`   (`kategoriya_id` ASC)   VISIBLE,
  INDEX `fk_gruppa_prepodavatel_idx` (`prepodavatel_id` ASC) VISIBLE,
  CONSTRAINT `fk_gruppa_avtoshkola`
    FOREIGN KEY (`avtoshkola_id`) REFERENCES `avtoshkola` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_gruppa_kategoriya`
    FOREIGN KEY (`kategoriya_id`) REFERENCES `kategoriya_prav` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_gruppa_prepodavatel`
    FOREIGN KEY (`prepodavatel_id`) REFERENCES `sotrudnik` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- КУРСАНТ И ЕГО ДОКУМЕНТЫ
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `kursant` (
  `id`                INT NOT NULL AUTO_INCREMENT,
  `familiya`          VARCHAR(45) NOT NULL,
  `imya`              VARCHAR(45) NOT NULL,
  `otchestvo`         VARCHAR(45) NULL,
  `data_rozhdeniya`   DATE        NOT NULL,
  `telefon`           VARCHAR(15) NOT NULL,
  `email`             VARCHAR(60) NULL,
  `adres`             VARCHAR(255) NULL,
  `data_registratsii` DATE NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `kursant_telefon_UNIQUE` (`telefon` ASC) VISIBLE,
  UNIQUE INDEX `kursant_email_UNIQUE`   (`email` ASC)   VISIBLE,
  INDEX `kursant_familiya_idx` (`familiya` ASC) VISIBLE
) ENGINE = InnoDB;

-- Паспорт, СНИЛС и т.п.
CREATE TABLE IF NOT EXISTS `dokument` (
  `id`            INT NOT NULL AUTO_INCREMENT,
  `kursant_id`    INT NOT NULL,
  `tip_dokumenta` VARCHAR(30)  NOT NULL,
  `seriya`        VARCHAR(10)  NULL,
  `nomer`         VARCHAR(20)  NOT NULL,
  `kem_vydan`     VARCHAR(255) NULL,
  `data_vydachi`  DATE NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `dokument_UNIQUE` (`tip_dokumenta` ASC, `seriya` ASC, `nomer` ASC) VISIBLE,
  INDEX `fk_dokument_kursant_idx` (`kursant_id` ASC) VISIBLE,
  CONSTRAINT `fk_dokument_kursant`
    FOREIGN KEY (`kursant_id`) REFERENCES `kursant` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Медицинская справка (форма 003-В/у)
CREATE TABLE IF NOT EXISTS `med_spravka` (
  `id`                  INT NOT NULL AUTO_INCREMENT,
  `kursant_id`          INT NOT NULL,
  `med_uchrezhdenie_id` INT NOT NULL,
  `nomer`               VARCHAR(20) NOT NULL,
  `data_vydachi`        DATE NOT NULL,
  `deystvitelna_do`     DATE NOT NULL,
  `zaklyuchenie`        ENUM('goden','ne_goden','s_ogranicheniyami') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `med_spravka_nomer_UNIQUE` (`nomer` ASC) VISIBLE,
  INDEX `fk_spravka_kursant_idx` (`kursant_id` ASC) VISIBLE,
  INDEX `fk_spravka_med_uchr_idx` (`med_uchrezhdenie_id` ASC) VISIBLE,
  CONSTRAINT `fk_spravka_kursant`
    FOREIGN KEY (`kursant_id`) REFERENCES `kursant` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_spravka_med_uchr`
    FOREIGN KEY (`med_uchrezhdenie_id`) REFERENCES `med_uchrezhdenie` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- ОБУЧЕНИЕ
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `dogovor` (
  `id`                INT NOT NULL AUTO_INCREMENT,
  `kursant_id`        INT NOT NULL,
  `gruppa_id`         INT NOT NULL,
  `nomer`             VARCHAR(20)   NOT NULL,
  `data_zaklyucheniya` DATE         NOT NULL,
  `stoimost`          DECIMAL(10,2) NOT NULL,
  `status`            ENUM('deystvuet','zavershen','rastorgnut') NOT NULL DEFAULT 'deystvuet',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `dogovor_nomer_UNIQUE` (`nomer` ASC) VISIBLE,
  UNIQUE INDEX `dogovor_kursant_gruppa_UNIQUE` (`kursant_id` ASC, `gruppa_id` ASC) VISIBLE,
  INDEX `fk_dogovor_gruppa_idx` (`gruppa_id` ASC) VISIBLE,
  CONSTRAINT `fk_dogovor_kursant`
    FOREIGN KEY (`kursant_id`) REFERENCES `kursant` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_dogovor_gruppa`
    FOREIGN KEY (`gruppa_id`) REFERENCES `uchebnaya_gruppa` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `oplata_obucheniya` (
  `id`          INT NOT NULL AUTO_INCREMENT,
  `dogovor_id`  INT NOT NULL,
  `summa`       DECIMAL(10,2) NOT NULL,
  `data_oplaty` DATETIME      NOT NULL,
  `sposob`      ENUM('nalichnye','karta','perevod') NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_oplata_dogovor_idx` (`dogovor_id` ASC) VISIBLE,
  CONSTRAINT `fk_oplata_dogovor`
    FOREIGN KEY (`dogovor_id`) REFERENCES `dogovor` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Теоретические занятия проводятся для всей группы
CREATE TABLE IF NOT EXISTS `zanyatie_teoriya` (
  `id`              INT NOT NULL AUTO_INCREMENT,
  `gruppa_id`       INT NOT NULL,
  `prepodavatel_id` INT NOT NULL,
  `tema`            VARCHAR(150) NOT NULL,
  `data_provedeniya` DATETIME    NOT NULL,
  `kol_chasov`      TINYINT      NOT NULL DEFAULT 2,
  PRIMARY KEY (`id`),
  INDEX `fk_teoriya_gruppa_idx`       (`gruppa_id` ASC)       VISIBLE,
  INDEX `fk_teoriya_prepodavatel_idx` (`prepodavatel_id` ASC) VISIBLE,
  CONSTRAINT `fk_teoriya_gruppa`
    FOREIGN KEY (`gruppa_id`) REFERENCES `uchebnaya_gruppa` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_teoriya_prepodavatel`
    FOREIGN KEY (`prepodavatel_id`) REFERENCES `sotrudnik` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Практическое вождение — индивидуально с инструктором
CREATE TABLE IF NOT EXISTS `zanyatie_vozhdenie` (
  `id`               INT NOT NULL AUTO_INCREMENT,
  `kursant_id`       INT NOT NULL,
  `instruktor_id`    INT NOT NULL,
  `avto_id`          INT NOT NULL,
  `data_provedeniya` DATETIME NOT NULL,
  `kol_chasov`       TINYINT  NOT NULL DEFAULT 2,
  `mesto`            ENUM('avtodrom','gorod') NOT NULL,
  `otsenka`          TINYINT  NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_vozhdenie_kursant_idx`    (`kursant_id` ASC)    VISIBLE,
  INDEX `fk_vozhdenie_instruktor_idx` (`instruktor_id` ASC) VISIBLE,
  INDEX `fk_vozhdenie_avto_idx`       (`avto_id` ASC)       VISIBLE,
  CONSTRAINT `fk_vozhdenie_kursant`
    FOREIGN KEY (`kursant_id`) REFERENCES `kursant` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_vozhdenie_instruktor`
    FOREIGN KEY (`instruktor_id`) REFERENCES `sotrudnik` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_vozhdenie_avto`
    FOREIGN KEY (`avto_id`) REFERENCES `uchebnoe_avto` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- ГИБДД: ИНСПЕКТОРЫ, ЗАЯВЛЕНИЯ, ПОШЛИНЫ
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `inspektor` (
  `id`               INT NOT NULL AUTO_INCREMENT,
  `podrazdelenie_id` INT NOT NULL,
  `familiya`         VARCHAR(45) NOT NULL,
  `imya`             VARCHAR(45) NOT NULL,
  `otchestvo`        VARCHAR(45) NULL,
  `zvanie`           VARCHAR(45) NOT NULL,
  `lichnyy_nomer`    VARCHAR(15) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `inspektor_lichnyy_nomer_UNIQUE` (`lichnyy_nomer` ASC) VISIBLE,
  INDEX `fk_inspektor_podrazdelenie_idx` (`podrazdelenie_id` ASC) VISIBLE,
  CONSTRAINT `fk_inspektor_podrazdelenie`
    FOREIGN KEY (`podrazdelenie_id`) REFERENCES `podrazdelenie_gibdd` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `gosposhlina` (
  `id`               INT NOT NULL AUTO_INCREMENT,
  `kursant_id`       INT NOT NULL,
  `naznachenie`      VARCHAR(100)  NOT NULL,
  `summa`            DECIMAL(10,2) NOT NULL,
  `data_oplaty`      DATE          NOT NULL,
  `nomer_kvitantsii` VARCHAR(30)   NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `gosposhlina_kvitantsiya_UNIQUE` (`nomer_kvitantsii` ASC) VISIBLE,
  INDEX `fk_gosposhlina_kursant_idx` (`kursant_id` ASC) VISIBLE,
  CONSTRAINT `fk_gosposhlina_kursant`
    FOREIGN KEY (`kursant_id`) REFERENCES `kursant` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `zayavlenie` (
  `id`               INT NOT NULL AUTO_INCREMENT,
  `kursant_id`       INT NOT NULL,
  `podrazdelenie_id` INT NOT NULL,
  `kategoriya_id`    INT NOT NULL,
  `data_podachi`     DATE NOT NULL,
  `status`           ENUM('podano','prinyato','otkazano','zakryto') NOT NULL DEFAULT 'podano',
  PRIMARY KEY (`id`),
  INDEX `fk_zayavlenie_kursant_idx`       (`kursant_id` ASC)       VISIBLE,
  INDEX `fk_zayavlenie_podrazdelenie_idx` (`podrazdelenie_id` ASC) VISIBLE,
  INDEX `fk_zayavlenie_kategoriya_idx`    (`kategoriya_id` ASC)    VISIBLE,
  CONSTRAINT `fk_zayavlenie_kursant`
    FOREIGN KEY (`kursant_id`) REFERENCES `kursant` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_zayavlenie_podrazdelenie`
    FOREIGN KEY (`podrazdelenie_id`) REFERENCES `podrazdelenie_gibdd` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_zayavlenie_kategoriya`
    FOREIGN KEY (`kategoriya_id`) REFERENCES `kategoriya_prav` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- ЭКЗАМЕНЫ (внутренние и в ГИБДД)
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `ekzamen` (
  `id`             INT NOT NULL AUTO_INCREMENT,
  `kursant_id`     INT NOT NULL,
  `tip_ekzamena_id` INT NOT NULL,
  `data_ekzamena`  DATETIME NOT NULL,
  `nomer_popytki`  TINYINT  NOT NULL DEFAULT 1,
  `rezultat`       ENUM('sdal','ne_sdal','neyavka') NOT NULL,
  `kol_oshibok`    TINYINT  NULL,
  `sotrudnik_id`   INT NULL COMMENT 'экзаменатор автошколы (внутренний экзамен)',
  `inspektor_id`   INT NULL COMMENT 'инспектор ГИБДД (государственный экзамен)',
  `avto_id`        INT NULL COMMENT 'автомобиль для практического экзамена',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `ekzamen_popytka_UNIQUE` (`kursant_id` ASC, `tip_ekzamena_id` ASC, `nomer_popytki` ASC) VISIBLE,
  INDEX `fk_ekzamen_tip_idx`       (`tip_ekzamena_id` ASC) VISIBLE,
  INDEX `fk_ekzamen_sotrudnik_idx` (`sotrudnik_id` ASC)    VISIBLE,
  INDEX `fk_ekzamen_inspektor_idx` (`inspektor_id` ASC)    VISIBLE,
  INDEX `fk_ekzamen_avto_idx`      (`avto_id` ASC)         VISIBLE,
  CONSTRAINT `fk_ekzamen_kursant`
    FOREIGN KEY (`kursant_id`) REFERENCES `kursant` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ekzamen_tip`
    FOREIGN KEY (`tip_ekzamena_id`) REFERENCES `tip_ekzamena` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_ekzamen_sotrudnik`
    FOREIGN KEY (`sotrudnik_id`) REFERENCES `sotrudnik` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ekzamen_inspektor`
    FOREIGN KEY (`inspektor_id`) REFERENCES `inspektor` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ekzamen_avto`
    FOREIGN KEY (`avto_id`) REFERENCES `uchebnoe_avto` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- РЕЗУЛЬТАТ: ВОДИТЕЛЬСКОЕ УДОСТОВЕРЕНИЕ
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `voditelskoe_udostoverenie` (
  `id`               INT NOT NULL AUTO_INCREMENT,
  `kursant_id`       INT NOT NULL,
  `podrazdelenie_id` INT NOT NULL,
  `seriya_nomer`     VARCHAR(12) NOT NULL,
  `data_vydachi`     DATE NOT NULL,
  `deystvitelno_do`  DATE NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `vu_seriya_nomer_UNIQUE` (`seriya_nomer` ASC) VISIBLE,
  INDEX `fk_vu_kursant_idx`       (`kursant_id` ASC)       VISIBLE,
  INDEX `fk_vu_podrazdelenie_idx` (`podrazdelenie_id` ASC) VISIBLE,
  CONSTRAINT `fk_vu_kursant`
    FOREIGN KEY (`kursant_id`) REFERENCES `kursant` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_vu_podrazdelenie`
    FOREIGN KEY (`podrazdelenie_id`) REFERENCES `podrazdelenie_gibdd` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Связь M:N «удостоверение — открытые категории»
CREATE TABLE IF NOT EXISTS `vu_kategoriya` (
  `vu_id`          INT NOT NULL,
  `kategoriya_id`  INT NOT NULL,
  `data_otkrytiya` DATE NOT NULL,
  `ogranicheniya`  VARCHAR(50) NULL COMMENT 'например, AT — только автомат',
  PRIMARY KEY (`vu_id`, `kategoriya_id`),
  INDEX `fk_vu_kat_kategoriya_idx` (`kategoriya_id` ASC) VISIBLE,
  CONSTRAINT `fk_vu_kat_vu`
    FOREIGN KEY (`vu_id`) REFERENCES `voditelskoe_udostoverenie` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_vu_kat_kategoriya`
    FOREIGN KEY (`kategoriya_id`) REFERENCES `kategoriya_prav` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
