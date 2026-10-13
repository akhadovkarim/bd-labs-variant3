-- =====================================================================
--  Лабораторная работа №1. Вариант 3
--  «Система, описывающая порядок получения водительских прав»
--  Модель Data Vault 2.0: 14 хабов, 16 линков, 23 сателлитов
--  Хеш-ключи (_hk) — MD5 от бизнес-ключа, CHAR(32)
--  Служебные поля: load_date (дата загрузки), record_source (источник),
--  hash_diff (в сателлитах — хеш атрибутов для отслеживания изменений)
--  СУБД: MySQL 8.0 | Автор: Ахадов К.У., гр. 223-322
-- =====================================================================

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `voditelskie_prava_dv`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE `voditelskie_prava_dv`;

-- =====================================================================
-- HUBS — бизнес-сущности
-- =====================================================================

-- Курсант (БК — телефон)
CREATE TABLE IF NOT EXISTS `hub_kursant` (
  `kursant_hk` CHAR(32) NOT NULL,
  `telefon` VARCHAR(15) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`kursant_hk`),
  UNIQUE INDEX `hub_kursant_bk_UNIQUE` (`telefon` ASC) VISIBLE
) ENGINE = InnoDB;

-- Автошкола (БК — номер лицензии)
CREATE TABLE IF NOT EXISTS `hub_avtoshkola` (
  `avtoshkola_hk` CHAR(32) NOT NULL,
  `nomer_litsenzii` VARCHAR(30) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`avtoshkola_hk`),
  UNIQUE INDEX `hub_avtoshkola_bk_UNIQUE` (`nomer_litsenzii` ASC) VISIBLE
) ENGINE = InnoDB;

-- Сотрудник автошколы
CREATE TABLE IF NOT EXISTS `hub_sotrudnik` (
  `sotrudnik_hk` CHAR(32) NOT NULL,
  `telefon` VARCHAR(15) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`sotrudnik_hk`),
  UNIQUE INDEX `hub_sotrudnik_bk_UNIQUE` (`telefon` ASC) VISIBLE
) ENGINE = InnoDB;

-- Должность
CREATE TABLE IF NOT EXISTS `hub_dolzhnost` (
  `dolzhnost_hk` CHAR(32) NOT NULL,
  `nazvanie` VARCHAR(60) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`dolzhnost_hk`),
  UNIQUE INDEX `hub_dolzhnost_bk_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB;

-- Категория ТС (A, B, C ...)
CREATE TABLE IF NOT EXISTS `hub_kategoriya` (
  `kategoriya_hk` CHAR(32) NOT NULL,
  `kod` VARCHAR(5) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`kategoriya_hk`),
  UNIQUE INDEX `hub_kategoriya_bk_UNIQUE` (`kod` ASC) VISIBLE
) ENGINE = InnoDB;

-- Учебный автомобиль (БК — госномер)
CREATE TABLE IF NOT EXISTS `hub_avto` (
  `avto_hk` CHAR(32) NOT NULL,
  `gos_nomer` VARCHAR(12) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`avto_hk`),
  UNIQUE INDEX `hub_avto_bk_UNIQUE` (`gos_nomer` ASC) VISIBLE
) ENGINE = InnoDB;

-- Медучреждение
CREATE TABLE IF NOT EXISTS `hub_med_uchrezhdenie` (
  `med_uchrezhdenie_hk` CHAR(32) NOT NULL,
  `nomer_litsenzii` VARCHAR(30) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`med_uchrezhdenie_hk`),
  UNIQUE INDEX `hub_med_uchrezhdenie_bk_UNIQUE` (`nomer_litsenzii` ASC) VISIBLE
) ENGINE = InnoDB;

-- Медицинская справка
CREATE TABLE IF NOT EXISTS `hub_med_spravka` (
  `med_spravka_hk` CHAR(32) NOT NULL,
  `nomer` VARCHAR(20) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`med_spravka_hk`),
  UNIQUE INDEX `hub_med_spravka_bk_UNIQUE` (`nomer` ASC) VISIBLE
) ENGINE = InnoDB;

-- Учебная группа
CREATE TABLE IF NOT EXISTS `hub_gruppa` (
  `gruppa_hk` CHAR(32) NOT NULL,
  `nomer_gruppy` VARCHAR(15) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`gruppa_hk`),
  UNIQUE INDEX `hub_gruppa_bk_UNIQUE` (`nomer_gruppy` ASC) VISIBLE
) ENGINE = InnoDB;

-- Договор на обучение
CREATE TABLE IF NOT EXISTS `hub_dogovor` (
  `dogovor_hk` CHAR(32) NOT NULL,
  `nomer` VARCHAR(20) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`dogovor_hk`),
  UNIQUE INDEX `hub_dogovor_bk_UNIQUE` (`nomer` ASC) VISIBLE
) ENGINE = InnoDB;

-- Подразделение Госавтоинспекции
CREATE TABLE IF NOT EXISTS `hub_podrazdelenie` (
  `podrazdelenie_hk` CHAR(32) NOT NULL,
  `nazvanie` VARCHAR(100) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`podrazdelenie_hk`),
  UNIQUE INDEX `hub_podrazdelenie_bk_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB;

-- Инспектор-экзаменатор
CREATE TABLE IF NOT EXISTS `hub_inspektor` (
  `inspektor_hk` CHAR(32) NOT NULL,
  `lichnyy_nomer` VARCHAR(15) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`inspektor_hk`),
  UNIQUE INDEX `hub_inspektor_bk_UNIQUE` (`lichnyy_nomer` ASC) VISIBLE
) ENGINE = InnoDB;

-- Тип экзамена
CREATE TABLE IF NOT EXISTS `hub_tip_ekzamena` (
  `tip_ekzamena_hk` CHAR(32) NOT NULL,
  `etap` VARCHAR(20) NOT NULL,
  `vid` VARCHAR(20) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`tip_ekzamena_hk`),
  UNIQUE INDEX `hub_tip_ekzamena_bk_UNIQUE` (`etap` ASC, `vid` ASC) VISIBLE
) ENGINE = InnoDB;

-- Водительское удостоверение
CREATE TABLE IF NOT EXISTS `hub_vu` (
  `vu_hk` CHAR(32) NOT NULL,
  `seriya_nomer` VARCHAR(12) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`vu_hk`),
  UNIQUE INDEX `hub_vu_bk_UNIQUE` (`seriya_nomer` ASC) VISIBLE
) ENGINE = InnoDB;

-- =====================================================================
-- LINKS — связи между хабами
-- =====================================================================

-- Сотрудник работает в автошколе на должности
CREATE TABLE IF NOT EXISTS `link_sotrudnik_rabota` (
  `link_sotrudnik_rabota_hk` CHAR(32) NOT NULL,
  `sotrudnik_hk` CHAR(32) NOT NULL,
  `avtoshkola_hk` CHAR(32) NOT NULL,
  `dolzhnost_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_sotrudnik_rabota_hk`),
  UNIQUE INDEX `link_sotrudnik_rabota_UNIQUE` (`sotrudnik_hk` ASC, `avtoshkola_hk` ASC, `dolzhnost_hk` ASC) VISIBLE,
  INDEX `fk_l_sotrudnik_rabota_sotrudnik_idx` (`sotrudnik_hk` ASC) VISIBLE,
  INDEX `fk_l_sotrudnik_rabota_avtoshkola_idx` (`avtoshkola_hk` ASC) VISIBLE,
  INDEX `fk_l_sotrudnik_rabota_dolzhnost_idx` (`dolzhnost_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_sotrudnik_rabota_sotrudnik`
    FOREIGN KEY (`sotrudnik_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_sotrudnik_rabota_avtoshkola`
    FOREIGN KEY (`avtoshkola_hk`) REFERENCES `hub_avtoshkola` (`avtoshkola_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_sotrudnik_rabota_dolzhnost`
    FOREIGN KEY (`dolzhnost_hk`) REFERENCES `hub_dolzhnost` (`dolzhnost_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Автомобиль автошколы для категории
CREATE TABLE IF NOT EXISTS `link_avto_avtoshkola` (
  `link_avto_avtoshkola_hk` CHAR(32) NOT NULL,
  `avto_hk` CHAR(32) NOT NULL,
  `avtoshkola_hk` CHAR(32) NOT NULL,
  `kategoriya_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_avto_avtoshkola_hk`),
  UNIQUE INDEX `link_avto_avtoshkola_UNIQUE` (`avto_hk` ASC, `avtoshkola_hk` ASC, `kategoriya_hk` ASC) VISIBLE,
  INDEX `fk_l_avto_avtoshkola_avto_idx` (`avto_hk` ASC) VISIBLE,
  INDEX `fk_l_avto_avtoshkola_avtoshkola_idx` (`avtoshkola_hk` ASC) VISIBLE,
  INDEX `fk_l_avto_avtoshkola_kategoriya_idx` (`kategoriya_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_avto_avtoshkola_avto`
    FOREIGN KEY (`avto_hk`) REFERENCES `hub_avto` (`avto_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_avto_avtoshkola_avtoshkola`
    FOREIGN KEY (`avtoshkola_hk`) REFERENCES `hub_avtoshkola` (`avtoshkola_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_avto_avtoshkola_kategoriya`
    FOREIGN KEY (`kategoriya_hk`) REFERENCES `hub_kategoriya` (`kategoriya_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Документы курсанта (зависимые ключи — тип, серия, номер)
CREATE TABLE IF NOT EXISTS `link_kursant_dokument` (
  `link_kursant_dokument_hk` CHAR(32) NOT NULL,
  `kursant_hk` CHAR(32) NOT NULL,
  `tip_dokumenta` VARCHAR(30) NOT NULL,
  `seriya` VARCHAR(10) NULL,
  `nomer` VARCHAR(20) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_kursant_dokument_hk`),
  UNIQUE INDEX `link_kursant_dokument_UNIQUE` (`kursant_hk` ASC, `tip_dokumenta` ASC, `seriya` ASC, `nomer` ASC) VISIBLE,
  INDEX `fk_l_kursant_dokument_kursant_idx` (`kursant_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_kursant_dokument_kursant`
    FOREIGN KEY (`kursant_hk`) REFERENCES `hub_kursant` (`kursant_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Справка выдана курсанту медучреждением
CREATE TABLE IF NOT EXISTS `link_med_spravka` (
  `link_med_spravka_hk` CHAR(32) NOT NULL,
  `med_spravka_hk` CHAR(32) NOT NULL,
  `kursant_hk` CHAR(32) NOT NULL,
  `med_uchrezhdenie_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_med_spravka_hk`),
  UNIQUE INDEX `link_med_spravka_UNIQUE` (`med_spravka_hk` ASC, `kursant_hk` ASC, `med_uchrezhdenie_hk` ASC) VISIBLE,
  INDEX `fk_l_med_spravka_med_spravka_idx` (`med_spravka_hk` ASC) VISIBLE,
  INDEX `fk_l_med_spravka_kursant_idx` (`kursant_hk` ASC) VISIBLE,
  INDEX `fk_l_med_spravka_med_uchrezhdenie_idx` (`med_uchrezhdenie_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_med_spravka_med_spravka`
    FOREIGN KEY (`med_spravka_hk`) REFERENCES `hub_med_spravka` (`med_spravka_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_med_spravka_kursant`
    FOREIGN KEY (`kursant_hk`) REFERENCES `hub_kursant` (`kursant_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_med_spravka_med_uchrezhdenie`
    FOREIGN KEY (`med_uchrezhdenie_hk`) REFERENCES `hub_med_uchrezhdenie` (`med_uchrezhdenie_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Группа автошколы по категории с преподавателем
CREATE TABLE IF NOT EXISTS `link_gruppa` (
  `link_gruppa_hk` CHAR(32) NOT NULL,
  `gruppa_hk` CHAR(32) NOT NULL,
  `avtoshkola_hk` CHAR(32) NOT NULL,
  `kategoriya_hk` CHAR(32) NOT NULL,
  `prepodavatel_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_gruppa_hk`),
  UNIQUE INDEX `link_gruppa_UNIQUE` (`gruppa_hk` ASC, `avtoshkola_hk` ASC, `kategoriya_hk` ASC, `prepodavatel_hk` ASC) VISIBLE,
  INDEX `fk_l_gruppa_gruppa_idx` (`gruppa_hk` ASC) VISIBLE,
  INDEX `fk_l_gruppa_avtoshkola_idx` (`avtoshkola_hk` ASC) VISIBLE,
  INDEX `fk_l_gruppa_kategoriya_idx` (`kategoriya_hk` ASC) VISIBLE,
  INDEX `fk_l_gruppa_prepodavatel_idx` (`prepodavatel_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_gruppa_gruppa`
    FOREIGN KEY (`gruppa_hk`) REFERENCES `hub_gruppa` (`gruppa_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_gruppa_avtoshkola`
    FOREIGN KEY (`avtoshkola_hk`) REFERENCES `hub_avtoshkola` (`avtoshkola_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_gruppa_kategoriya`
    FOREIGN KEY (`kategoriya_hk`) REFERENCES `hub_kategoriya` (`kategoriya_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_gruppa_prepodavatel`
    FOREIGN KEY (`prepodavatel_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Договор курсанта на обучение в группе
CREATE TABLE IF NOT EXISTS `link_dogovor` (
  `link_dogovor_hk` CHAR(32) NOT NULL,
  `dogovor_hk` CHAR(32) NOT NULL,
  `kursant_hk` CHAR(32) NOT NULL,
  `gruppa_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_dogovor_hk`),
  UNIQUE INDEX `link_dogovor_UNIQUE` (`dogovor_hk` ASC, `kursant_hk` ASC, `gruppa_hk` ASC) VISIBLE,
  INDEX `fk_l_dogovor_dogovor_idx` (`dogovor_hk` ASC) VISIBLE,
  INDEX `fk_l_dogovor_kursant_idx` (`kursant_hk` ASC) VISIBLE,
  INDEX `fk_l_dogovor_gruppa_idx` (`gruppa_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_dogovor_dogovor`
    FOREIGN KEY (`dogovor_hk`) REFERENCES `hub_dogovor` (`dogovor_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_dogovor_kursant`
    FOREIGN KEY (`kursant_hk`) REFERENCES `hub_kursant` (`kursant_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_dogovor_gruppa`
    FOREIGN KEY (`gruppa_hk`) REFERENCES `hub_gruppa` (`gruppa_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Платёж по договору
CREATE TABLE IF NOT EXISTS `link_oplata` (
  `link_oplata_hk` CHAR(32) NOT NULL,
  `dogovor_hk` CHAR(32) NOT NULL,
  `data_oplaty` DATETIME NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_oplata_hk`),
  UNIQUE INDEX `link_oplata_UNIQUE` (`dogovor_hk` ASC, `data_oplaty` ASC) VISIBLE,
  INDEX `fk_l_oplata_dogovor_idx` (`dogovor_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_oplata_dogovor`
    FOREIGN KEY (`dogovor_hk`) REFERENCES `hub_dogovor` (`dogovor_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Теоретическое занятие группы
CREATE TABLE IF NOT EXISTS `link_zanyatie_teoriya` (
  `link_zanyatie_teoriya_hk` CHAR(32) NOT NULL,
  `gruppa_hk` CHAR(32) NOT NULL,
  `prepodavatel_hk` CHAR(32) NOT NULL,
  `data_provedeniya` DATETIME NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_zanyatie_teoriya_hk`),
  UNIQUE INDEX `link_zanyatie_teoriya_UNIQUE` (`gruppa_hk` ASC, `prepodavatel_hk` ASC, `data_provedeniya` ASC) VISIBLE,
  INDEX `fk_l_zanyatie_teoriya_gruppa_idx` (`gruppa_hk` ASC) VISIBLE,
  INDEX `fk_l_zanyatie_teoriya_prepodavatel_idx` (`prepodavatel_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_zanyatie_teoriya_gruppa`
    FOREIGN KEY (`gruppa_hk`) REFERENCES `hub_gruppa` (`gruppa_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_zanyatie_teoriya_prepodavatel`
    FOREIGN KEY (`prepodavatel_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Занятие по вождению
CREATE TABLE IF NOT EXISTS `link_zanyatie_vozhdenie` (
  `link_zanyatie_vozhdenie_hk` CHAR(32) NOT NULL,
  `kursant_hk` CHAR(32) NOT NULL,
  `instruktor_hk` CHAR(32) NOT NULL,
  `avto_hk` CHAR(32) NOT NULL,
  `data_provedeniya` DATETIME NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_zanyatie_vozhdenie_hk`),
  UNIQUE INDEX `link_zanyatie_vozhdenie_UNIQUE` (`kursant_hk` ASC, `instruktor_hk` ASC, `avto_hk` ASC, `data_provedeniya` ASC) VISIBLE,
  INDEX `fk_l_zanyatie_vozhdenie_kursant_idx` (`kursant_hk` ASC) VISIBLE,
  INDEX `fk_l_zanyatie_vozhdenie_instruktor_idx` (`instruktor_hk` ASC) VISIBLE,
  INDEX `fk_l_zanyatie_vozhdenie_avto_idx` (`avto_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_zanyatie_vozhdenie_kursant`
    FOREIGN KEY (`kursant_hk`) REFERENCES `hub_kursant` (`kursant_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_zanyatie_vozhdenie_instruktor`
    FOREIGN KEY (`instruktor_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_zanyatie_vozhdenie_avto`
    FOREIGN KEY (`avto_hk`) REFERENCES `hub_avto` (`avto_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Инспектор служит в подразделении
CREATE TABLE IF NOT EXISTS `link_inspektor_podrazdelenie` (
  `link_inspektor_podrazdelenie_hk` CHAR(32) NOT NULL,
  `inspektor_hk` CHAR(32) NOT NULL,
  `podrazdelenie_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_inspektor_podrazdelenie_hk`),
  UNIQUE INDEX `link_inspektor_podrazdelenie_UNIQUE` (`inspektor_hk` ASC, `podrazdelenie_hk` ASC) VISIBLE,
  INDEX `fk_l_inspektor_podrazdelenie_inspektor_idx` (`inspektor_hk` ASC) VISIBLE,
  INDEX `fk_l_inspektor_podrazdelenie_podrazdelenie_idx` (`podrazdelenie_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_inspektor_podrazdelenie_inspektor`
    FOREIGN KEY (`inspektor_hk`) REFERENCES `hub_inspektor` (`inspektor_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_inspektor_podrazdelenie_podrazdelenie`
    FOREIGN KEY (`podrazdelenie_hk`) REFERENCES `hub_podrazdelenie` (`podrazdelenie_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Оплата госпошлины
CREATE TABLE IF NOT EXISTS `link_gosposhlina` (
  `link_gosposhlina_hk` CHAR(32) NOT NULL,
  `kursant_hk` CHAR(32) NOT NULL,
  `nomer_kvitantsii` VARCHAR(30) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_gosposhlina_hk`),
  UNIQUE INDEX `link_gosposhlina_UNIQUE` (`kursant_hk` ASC, `nomer_kvitantsii` ASC) VISIBLE,
  INDEX `fk_l_gosposhlina_kursant_idx` (`kursant_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_gosposhlina_kursant`
    FOREIGN KEY (`kursant_hk`) REFERENCES `hub_kursant` (`kursant_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Заявление в Госавтоинспекцию
CREATE TABLE IF NOT EXISTS `link_zayavlenie` (
  `link_zayavlenie_hk` CHAR(32) NOT NULL,
  `kursant_hk` CHAR(32) NOT NULL,
  `podrazdelenie_hk` CHAR(32) NOT NULL,
  `kategoriya_hk` CHAR(32) NOT NULL,
  `data_podachi` DATE NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_zayavlenie_hk`),
  UNIQUE INDEX `link_zayavlenie_UNIQUE` (`kursant_hk` ASC, `podrazdelenie_hk` ASC, `kategoriya_hk` ASC, `data_podachi` ASC) VISIBLE,
  INDEX `fk_l_zayavlenie_kursant_idx` (`kursant_hk` ASC) VISIBLE,
  INDEX `fk_l_zayavlenie_podrazdelenie_idx` (`podrazdelenie_hk` ASC) VISIBLE,
  INDEX `fk_l_zayavlenie_kategoriya_idx` (`kategoriya_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_zayavlenie_kursant`
    FOREIGN KEY (`kursant_hk`) REFERENCES `hub_kursant` (`kursant_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_zayavlenie_podrazdelenie`
    FOREIGN KEY (`podrazdelenie_hk`) REFERENCES `hub_podrazdelenie` (`podrazdelenie_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_zayavlenie_kategoriya`
    FOREIGN KEY (`kategoriya_hk`) REFERENCES `hub_kategoriya` (`kategoriya_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Внутренний экзамен в автошколе
CREATE TABLE IF NOT EXISTS `link_ekzamen_vnutr` (
  `link_ekzamen_vnutr_hk` CHAR(32) NOT NULL,
  `kursant_hk` CHAR(32) NOT NULL,
  `tip_ekzamena_hk` CHAR(32) NOT NULL,
  `ekzaminator_hk` CHAR(32) NOT NULL,
  `avto_hk` CHAR(32) NOT NULL,
  `nomer_popytki` TINYINT NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_ekzamen_vnutr_hk`),
  UNIQUE INDEX `link_ekzamen_vnutr_UNIQUE` (`kursant_hk` ASC, `tip_ekzamena_hk` ASC, `ekzaminator_hk` ASC, `avto_hk` ASC, `nomer_popytki` ASC) VISIBLE,
  INDEX `fk_l_ekzamen_vnutr_kursant_idx` (`kursant_hk` ASC) VISIBLE,
  INDEX `fk_l_ekzamen_vnutr_tip_ekzamena_idx` (`tip_ekzamena_hk` ASC) VISIBLE,
  INDEX `fk_l_ekzamen_vnutr_ekzaminator_idx` (`ekzaminator_hk` ASC) VISIBLE,
  INDEX `fk_l_ekzamen_vnutr_avto_idx` (`avto_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_ekzamen_vnutr_kursant`
    FOREIGN KEY (`kursant_hk`) REFERENCES `hub_kursant` (`kursant_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_ekzamen_vnutr_tip_ekzamena`
    FOREIGN KEY (`tip_ekzamena_hk`) REFERENCES `hub_tip_ekzamena` (`tip_ekzamena_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_ekzamen_vnutr_ekzaminator`
    FOREIGN KEY (`ekzaminator_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_ekzamen_vnutr_avto`
    FOREIGN KEY (`avto_hk`) REFERENCES `hub_avto` (`avto_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Экзамен в Госавтоинспекции
CREATE TABLE IF NOT EXISTS `link_ekzamen_gibdd` (
  `link_ekzamen_gibdd_hk` CHAR(32) NOT NULL,
  `kursant_hk` CHAR(32) NOT NULL,
  `tip_ekzamena_hk` CHAR(32) NOT NULL,
  `inspektor_hk` CHAR(32) NOT NULL,
  `avto_hk` CHAR(32) NOT NULL,
  `nomer_popytki` TINYINT NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_ekzamen_gibdd_hk`),
  UNIQUE INDEX `link_ekzamen_gibdd_UNIQUE` (`kursant_hk` ASC, `tip_ekzamena_hk` ASC, `inspektor_hk` ASC, `avto_hk` ASC, `nomer_popytki` ASC) VISIBLE,
  INDEX `fk_l_ekzamen_gibdd_kursant_idx` (`kursant_hk` ASC) VISIBLE,
  INDEX `fk_l_ekzamen_gibdd_tip_ekzamena_idx` (`tip_ekzamena_hk` ASC) VISIBLE,
  INDEX `fk_l_ekzamen_gibdd_inspektor_idx` (`inspektor_hk` ASC) VISIBLE,
  INDEX `fk_l_ekzamen_gibdd_avto_idx` (`avto_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_ekzamen_gibdd_kursant`
    FOREIGN KEY (`kursant_hk`) REFERENCES `hub_kursant` (`kursant_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_ekzamen_gibdd_tip_ekzamena`
    FOREIGN KEY (`tip_ekzamena_hk`) REFERENCES `hub_tip_ekzamena` (`tip_ekzamena_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_ekzamen_gibdd_inspektor`
    FOREIGN KEY (`inspektor_hk`) REFERENCES `hub_inspektor` (`inspektor_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_ekzamen_gibdd_avto`
    FOREIGN KEY (`avto_hk`) REFERENCES `hub_avto` (`avto_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Удостоверение выдано курсанту подразделением
CREATE TABLE IF NOT EXISTS `link_vu` (
  `link_vu_hk` CHAR(32) NOT NULL,
  `vu_hk` CHAR(32) NOT NULL,
  `kursant_hk` CHAR(32) NOT NULL,
  `podrazdelenie_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_vu_hk`),
  UNIQUE INDEX `link_vu_UNIQUE` (`vu_hk` ASC, `kursant_hk` ASC, `podrazdelenie_hk` ASC) VISIBLE,
  INDEX `fk_l_vu_vu_idx` (`vu_hk` ASC) VISIBLE,
  INDEX `fk_l_vu_kursant_idx` (`kursant_hk` ASC) VISIBLE,
  INDEX `fk_l_vu_podrazdelenie_idx` (`podrazdelenie_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_vu_vu`
    FOREIGN KEY (`vu_hk`) REFERENCES `hub_vu` (`vu_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_vu_kursant`
    FOREIGN KEY (`kursant_hk`) REFERENCES `hub_kursant` (`kursant_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_vu_podrazdelenie`
    FOREIGN KEY (`podrazdelenie_hk`) REFERENCES `hub_podrazdelenie` (`podrazdelenie_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Открытые категории в удостоверении
CREATE TABLE IF NOT EXISTS `link_vu_kategoriya` (
  `link_vu_kategoriya_hk` CHAR(32) NOT NULL,
  `vu_hk` CHAR(32) NOT NULL,
  `kategoriya_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_vu_kategoriya_hk`),
  UNIQUE INDEX `link_vu_kategoriya_UNIQUE` (`vu_hk` ASC, `kategoriya_hk` ASC) VISIBLE,
  INDEX `fk_l_vu_kategoriya_vu_idx` (`vu_hk` ASC) VISIBLE,
  INDEX `fk_l_vu_kategoriya_kategoriya_idx` (`kategoriya_hk` ASC) VISIBLE,
  CONSTRAINT `fk_l_vu_kategoriya_vu`
    FOREIGN KEY (`vu_hk`) REFERENCES `hub_vu` (`vu_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_l_vu_kategoriya_kategoriya`
    FOREIGN KEY (`kategoriya_hk`) REFERENCES `hub_kategoriya` (`kategoriya_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;

-- =====================================================================
-- SATELLITES — описательные атрибуты с историей
-- =====================================================================

CREATE TABLE IF NOT EXISTS `sat_kursant` (
  `kursant_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `familiya` VARCHAR(45) NULL,
  `imya` VARCHAR(45) NULL,
  `otchestvo` VARCHAR(45) NULL,
  `data_rozhdeniya` DATE NULL,
  `email` VARCHAR(60) NULL,
  `adres` VARCHAR(255) NULL,
  `data_registratsii` DATE NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`kursant_hk`, `load_date`),
  CONSTRAINT `fk_sat_kursant`
    FOREIGN KEY (`kursant_hk`) REFERENCES `hub_kursant` (`kursant_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_avtoshkola` (
  `avtoshkola_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `nazvanie` VARCHAR(100) NULL,
  `adres` VARCHAR(255) NULL,
  `telefon` VARCHAR(15) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`avtoshkola_hk`, `load_date`),
  CONSTRAINT `fk_sat_avtoshkola`
    FOREIGN KEY (`avtoshkola_hk`) REFERENCES `hub_avtoshkola` (`avtoshkola_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_sotrudnik` (
  `sotrudnik_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `familiya` VARCHAR(45) NULL,
  `imya` VARCHAR(45) NULL,
  `otchestvo` VARCHAR(45) NULL,
  `stazh_let` TINYINT NULL,
  `data_priema` DATE NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`sotrudnik_hk`, `load_date`),
  CONSTRAINT `fk_sat_sotrudnik`
    FOREIGN KEY (`sotrudnik_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_dolzhnost` (
  `dolzhnost_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `oklad` DECIMAL(10,2) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`dolzhnost_hk`, `load_date`),
  CONSTRAINT `fk_sat_dolzhnost`
    FOREIGN KEY (`dolzhnost_hk`) REFERENCES `hub_dolzhnost` (`dolzhnost_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_kategoriya` (
  `kategoriya_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `nazvanie` VARCHAR(100) NULL,
  `min_vozrast` TINYINT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`kategoriya_hk`, `load_date`),
  CONSTRAINT `fk_sat_kategoriya`
    FOREIGN KEY (`kategoriya_hk`) REFERENCES `hub_kategoriya` (`kategoriya_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_avto` (
  `avto_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `marka` VARCHAR(45) NULL,
  `model` VARCHAR(45) NULL,
  `korobka` VARCHAR(20) NULL,
  `god_vypuska` YEAR NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`avto_hk`, `load_date`),
  CONSTRAINT `fk_sat_avto`
    FOREIGN KEY (`avto_hk`) REFERENCES `hub_avto` (`avto_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_med_uchrezhdenie` (
  `med_uchrezhdenie_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `nazvanie` VARCHAR(100) NULL,
  `adres` VARCHAR(255) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`med_uchrezhdenie_hk`, `load_date`),
  CONSTRAINT `fk_sat_med_uchrezhdenie`
    FOREIGN KEY (`med_uchrezhdenie_hk`) REFERENCES `hub_med_uchrezhdenie` (`med_uchrezhdenie_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_med_spravka` (
  `med_spravka_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `data_vydachi` DATE NULL,
  `deystvitelna_do` DATE NULL,
  `zaklyuchenie` VARCHAR(20) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`med_spravka_hk`, `load_date`),
  CONSTRAINT `fk_sat_med_spravka`
    FOREIGN KEY (`med_spravka_hk`) REFERENCES `hub_med_spravka` (`med_spravka_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_gruppa` (
  `gruppa_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `forma_obucheniya` VARCHAR(20) NULL,
  `data_nachala` DATE NULL,
  `data_okonchaniya` DATE NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`gruppa_hk`, `load_date`),
  CONSTRAINT `fk_sat_gruppa`
    FOREIGN KEY (`gruppa_hk`) REFERENCES `hub_gruppa` (`gruppa_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_dogovor` (
  `dogovor_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `data_zaklyucheniya` DATE NULL,
  `stoimost` DECIMAL(10,2) NULL,
  `status` VARCHAR(20) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`dogovor_hk`, `load_date`),
  CONSTRAINT `fk_sat_dogovor`
    FOREIGN KEY (`dogovor_hk`) REFERENCES `hub_dogovor` (`dogovor_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_podrazdelenie` (
  `podrazdelenie_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `adres` VARCHAR(255) NULL,
  `telefon` VARCHAR(15) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`podrazdelenie_hk`, `load_date`),
  CONSTRAINT `fk_sat_podrazdelenie`
    FOREIGN KEY (`podrazdelenie_hk`) REFERENCES `hub_podrazdelenie` (`podrazdelenie_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_inspektor` (
  `inspektor_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `familiya` VARCHAR(45) NULL,
  `imya` VARCHAR(45) NULL,
  `otchestvo` VARCHAR(45) NULL,
  `zvanie` VARCHAR(45) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`inspektor_hk`, `load_date`),
  CONSTRAINT `fk_sat_inspektor`
    FOREIGN KEY (`inspektor_hk`) REFERENCES `hub_inspektor` (`inspektor_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_tip_ekzamena` (
  `tip_ekzamena_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `nazvanie` VARCHAR(100) NULL,
  `max_oshibok` TINYINT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`tip_ekzamena_hk`, `load_date`),
  CONSTRAINT `fk_sat_tip_ekzamena`
    FOREIGN KEY (`tip_ekzamena_hk`) REFERENCES `hub_tip_ekzamena` (`tip_ekzamena_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_vu` (
  `vu_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `data_vydachi` DATE NULL,
  `deystvitelno_do` DATE NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`vu_hk`, `load_date`),
  CONSTRAINT `fk_sat_vu`
    FOREIGN KEY (`vu_hk`) REFERENCES `hub_vu` (`vu_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_dokument` (
  `link_kursant_dokument_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `kem_vydan` VARCHAR(255) NULL,
  `data_vydachi` DATE NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_kursant_dokument_hk`, `load_date`),
  CONSTRAINT `fk_sat_dokument`
    FOREIGN KEY (`link_kursant_dokument_hk`) REFERENCES `link_kursant_dokument` (`link_kursant_dokument_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_oplata` (
  `link_oplata_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `summa` DECIMAL(10,2) NULL,
  `sposob` VARCHAR(20) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_oplata_hk`, `load_date`),
  CONSTRAINT `fk_sat_oplata`
    FOREIGN KEY (`link_oplata_hk`) REFERENCES `link_oplata` (`link_oplata_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_zanyatie_teoriya` (
  `link_zanyatie_teoriya_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `tema` VARCHAR(150) NULL,
  `kol_chasov` TINYINT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_zanyatie_teoriya_hk`, `load_date`),
  CONSTRAINT `fk_sat_zanyatie_teoriya`
    FOREIGN KEY (`link_zanyatie_teoriya_hk`) REFERENCES `link_zanyatie_teoriya` (`link_zanyatie_teoriya_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_zanyatie_vozhdenie` (
  `link_zanyatie_vozhdenie_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `kol_chasov` TINYINT NULL,
  `mesto` VARCHAR(20) NULL,
  `otsenka` TINYINT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_zanyatie_vozhdenie_hk`, `load_date`),
  CONSTRAINT `fk_sat_zanyatie_vozhdenie`
    FOREIGN KEY (`link_zanyatie_vozhdenie_hk`) REFERENCES `link_zanyatie_vozhdenie` (`link_zanyatie_vozhdenie_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_gosposhlina` (
  `link_gosposhlina_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `naznachenie` VARCHAR(100) NULL,
  `summa` DECIMAL(10,2) NULL,
  `data_oplaty` DATE NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_gosposhlina_hk`, `load_date`),
  CONSTRAINT `fk_sat_gosposhlina`
    FOREIGN KEY (`link_gosposhlina_hk`) REFERENCES `link_gosposhlina` (`link_gosposhlina_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_zayavlenie` (
  `link_zayavlenie_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `status` VARCHAR(20) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_zayavlenie_hk`, `load_date`),
  CONSTRAINT `fk_sat_zayavlenie`
    FOREIGN KEY (`link_zayavlenie_hk`) REFERENCES `link_zayavlenie` (`link_zayavlenie_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_ekzamen_vnutr` (
  `link_ekzamen_vnutr_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `data_ekzamena` DATETIME NULL,
  `rezultat` VARCHAR(20) NULL,
  `kol_oshibok` TINYINT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_ekzamen_vnutr_hk`, `load_date`),
  CONSTRAINT `fk_sat_ekzamen_vnutr`
    FOREIGN KEY (`link_ekzamen_vnutr_hk`) REFERENCES `link_ekzamen_vnutr` (`link_ekzamen_vnutr_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_ekzamen_gibdd` (
  `link_ekzamen_gibdd_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `data_ekzamena` DATETIME NULL,
  `rezultat` VARCHAR(20) NULL,
  `kol_oshibok` TINYINT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_ekzamen_gibdd_hk`, `load_date`),
  CONSTRAINT `fk_sat_ekzamen_gibdd`
    FOREIGN KEY (`link_ekzamen_gibdd_hk`) REFERENCES `link_ekzamen_gibdd` (`link_ekzamen_gibdd_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `sat_vu_kategoriya` (
  `link_vu_kategoriya_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `data_otkrytiya` DATE NULL,
  `ogranicheniya` VARCHAR(50) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_vu_kategoriya_hk`, `load_date`),
  CONSTRAINT `fk_sat_vu_kategoriya`
    FOREIGN KEY (`link_vu_kategoriya_hk`) REFERENCES `link_vu_kategoriya` (`link_vu_kategoriya_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
