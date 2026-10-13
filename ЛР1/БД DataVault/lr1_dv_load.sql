-- =====================================================================
--  ЛР1. Загрузка данных из 3НФ (voditelskie_prava) в Data Vault (voditelskie_prava_dv)
--  Запускать после lr1_bd.sql, lr1_data.sql и lr1_bd_dv.sql
-- =====================================================================
USE `voditelskie_prava`;
SET NAMES utf8mb4;
SET @ld = NOW();

-- Нулевая (ghost) запись: подставляется в линки, где связь отсутствует (например, теоретический экзамен без автомобиля)
INSERT INTO voditelskie_prava_dv.hub_avto (avto_hk, gos_nomer, load_date, record_source) VALUES (REPEAT('0', 32), '-', @ld, 'SYSTEM.GHOST');
INSERT INTO voditelskie_prava_dv.hub_sotrudnik (sotrudnik_hk, telefon, load_date, record_source) VALUES (REPEAT('0', 32), '-', @ld, 'SYSTEM.GHOST');
INSERT INTO voditelskie_prava_dv.hub_inspektor (inspektor_hk, lichnyy_nomer, load_date, record_source) VALUES (REPEAT('0', 32), '-', @ld, 'SYSTEM.GHOST');

-- hub_kursant
INSERT INTO voditelskie_prava_dv.hub_kursant (kursant_hk, telefon, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(k.telefon)))), k.telefon, @ld, '3NF.voditelskie_prava.kursant'
  FROM kursant k;

-- hub_avtoshkola
INSERT INTO voditelskie_prava_dv.hub_avtoshkola (avtoshkola_hk, nomer_litsenzii, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(a.nomer_litsenzii)))), a.nomer_litsenzii, @ld, '3NF.voditelskie_prava.avtoshkola'
  FROM avtoshkola a;

-- hub_sotrudnik
INSERT INTO voditelskie_prava_dv.hub_sotrudnik (sotrudnik_hk, telefon, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(s.telefon)))), s.telefon, @ld, '3NF.voditelskie_prava.sotrudnik'
  FROM sotrudnik s;

-- hub_dolzhnost
INSERT INTO voditelskie_prava_dv.hub_dolzhnost (dolzhnost_hk, nazvanie, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(d.nazvanie)))), d.nazvanie, @ld, '3NF.voditelskie_prava.dolzhnost'
  FROM dolzhnost d;

-- hub_kategoriya
INSERT INTO voditelskie_prava_dv.hub_kategoriya (kategoriya_hk, kod, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(kp.kod)))), kp.kod, @ld, '3NF.voditelskie_prava.kategoriya_prav'
  FROM kategoriya_prav kp;

-- hub_avto
INSERT INTO voditelskie_prava_dv.hub_avto (avto_hk, gos_nomer, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(av.gos_nomer)))), av.gos_nomer, @ld, '3NF.voditelskie_prava.uchebnoe_avto'
  FROM uchebnoe_avto av;

-- hub_med_uchrezhdenie
INSERT INTO voditelskie_prava_dv.hub_med_uchrezhdenie (med_uchrezhdenie_hk, nomer_litsenzii, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(mu.nomer_litsenzii)))), mu.nomer_litsenzii, @ld, '3NF.voditelskie_prava.med_uchrezhdenie'
  FROM med_uchrezhdenie mu;

-- hub_med_spravka
INSERT INTO voditelskie_prava_dv.hub_med_spravka (med_spravka_hk, nomer, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(ms.nomer)))), ms.nomer, @ld, '3NF.voditelskie_prava.med_spravka'
  FROM med_spravka ms;

-- hub_gruppa
INSERT INTO voditelskie_prava_dv.hub_gruppa (gruppa_hk, nomer_gruppy, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(g.nomer_gruppy)))), g.nomer_gruppy, @ld, '3NF.voditelskie_prava.uchebnaya_gruppa'
  FROM uchebnaya_gruppa g;

-- hub_dogovor
INSERT INTO voditelskie_prava_dv.hub_dogovor (dogovor_hk, nomer, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(dg.nomer)))), dg.nomer, @ld, '3NF.voditelskie_prava.dogovor'
  FROM dogovor dg;

-- hub_podrazdelenie
INSERT INTO voditelskie_prava_dv.hub_podrazdelenie (podrazdelenie_hk, nazvanie, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(p.nazvanie)))), p.nazvanie, @ld, '3NF.voditelskie_prava.podrazdelenie_gibdd'
  FROM podrazdelenie_gibdd p;

-- hub_inspektor
INSERT INTO voditelskie_prava_dv.hub_inspektor (inspektor_hk, lichnyy_nomer, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(i.lichnyy_nomer)))), i.lichnyy_nomer, @ld, '3NF.voditelskie_prava.inspektor'
  FROM inspektor i;

-- hub_tip_ekzamena
INSERT INTO voditelskie_prava_dv.hub_tip_ekzamena (tip_ekzamena_hk, etap, vid, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(te.etap), TRIM(te.vid)))), te.etap, te.vid, @ld, '3NF.voditelskie_prava.tip_ekzamena'
  FROM tip_ekzamena te;

-- hub_vu
INSERT INTO voditelskie_prava_dv.hub_vu (vu_hk, seriya_nomer, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(vu.seriya_nomer)))), vu.seriya_nomer, @ld, '3NF.voditelskie_prava.voditelskoe_udostoverenie'
  FROM voditelskoe_udostoverenie vu;

-- link_sotrudnik_rabota
INSERT INTO voditelskie_prava_dv.link_sotrudnik_rabota (link_sotrudnik_rabota_hk, sotrudnik_hk, avtoshkola_hk, dolzhnost_hk, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', s.telefon)), TRIM(CONCAT_WS('|', a.nomer_litsenzii)), TRIM(CONCAT_WS('|', d.nazvanie))))),
       MD5(UPPER(CONCAT_WS('||', TRIM(s.telefon)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(a.nomer_litsenzii)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(d.nazvanie)))),
       @ld,
       '3NF.voditelskie_prava'
  FROM sotrudnik s JOIN avtoshkola a ON a.id = s.avtoshkola_id JOIN dolzhnost d ON d.id = s.dolzhnost_id;

-- link_avto_avtoshkola
INSERT INTO voditelskie_prava_dv.link_avto_avtoshkola (link_avto_avtoshkola_hk, avto_hk, avtoshkola_hk, kategoriya_hk, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', av.gos_nomer)), TRIM(CONCAT_WS('|', a.nomer_litsenzii)), TRIM(CONCAT_WS('|', kp.kod))))),
       MD5(UPPER(CONCAT_WS('||', TRIM(av.gos_nomer)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(a.nomer_litsenzii)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(kp.kod)))),
       @ld,
       '3NF.voditelskie_prava'
  FROM uchebnoe_avto av JOIN avtoshkola a ON a.id = av.avtoshkola_id JOIN kategoriya_prav kp ON kp.id = av.kategoriya_id;

-- link_kursant_dokument
INSERT INTO voditelskie_prava_dv.link_kursant_dokument (link_kursant_dokument_hk, kursant_hk, tip_dokumenta, seriya, nomer, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', k.telefon)), TRIM(doc.tip_dokumenta), TRIM(doc.seriya), TRIM(doc.nomer)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(k.telefon)))),
       doc.tip_dokumenta,
       doc.seriya,
       doc.nomer,
       @ld,
       '3NF.voditelskie_prava'
  FROM dokument doc JOIN kursant k ON k.id = doc.kursant_id;

-- link_med_spravka
INSERT INTO voditelskie_prava_dv.link_med_spravka (link_med_spravka_hk, med_spravka_hk, kursant_hk, med_uchrezhdenie_hk, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', ms.nomer)), TRIM(CONCAT_WS('|', k.telefon)), TRIM(CONCAT_WS('|', mu.nomer_litsenzii))))),
       MD5(UPPER(CONCAT_WS('||', TRIM(ms.nomer)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(k.telefon)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(mu.nomer_litsenzii)))),
       @ld,
       '3NF.voditelskie_prava'
  FROM med_spravka ms JOIN kursant k ON k.id = ms.kursant_id JOIN med_uchrezhdenie mu ON mu.id = ms.med_uchrezhdenie_id;

-- link_gruppa
INSERT INTO voditelskie_prava_dv.link_gruppa (link_gruppa_hk, gruppa_hk, avtoshkola_hk, kategoriya_hk, prepodavatel_hk, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', g.nomer_gruppy)), TRIM(CONCAT_WS('|', a.nomer_litsenzii)), TRIM(CONCAT_WS('|', kp.kod)), TRIM(CONCAT_WS('|', s.telefon))))),
       MD5(UPPER(CONCAT_WS('||', TRIM(g.nomer_gruppy)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(a.nomer_litsenzii)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(kp.kod)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(s.telefon)))),
       @ld,
       '3NF.voditelskie_prava'
  FROM uchebnaya_gruppa g JOIN avtoshkola a ON a.id = g.avtoshkola_id JOIN kategoriya_prav kp ON kp.id = g.kategoriya_id JOIN sotrudnik s ON s.id = g.prepodavatel_id;

-- link_dogovor
INSERT INTO voditelskie_prava_dv.link_dogovor (link_dogovor_hk, dogovor_hk, kursant_hk, gruppa_hk, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', dg.nomer)), TRIM(CONCAT_WS('|', k.telefon)), TRIM(CONCAT_WS('|', g.nomer_gruppy))))),
       MD5(UPPER(CONCAT_WS('||', TRIM(dg.nomer)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(k.telefon)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(g.nomer_gruppy)))),
       @ld,
       '3NF.voditelskie_prava'
  FROM dogovor dg JOIN kursant k ON k.id = dg.kursant_id JOIN uchebnaya_gruppa g ON g.id = dg.gruppa_id;

-- link_oplata
INSERT INTO voditelskie_prava_dv.link_oplata (link_oplata_hk, dogovor_hk, data_oplaty, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', dg.nomer)), TRIM(o.data_oplaty)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(dg.nomer)))),
       o.data_oplaty,
       @ld,
       '3NF.voditelskie_prava'
  FROM oplata_obucheniya o JOIN dogovor dg ON dg.id = o.dogovor_id;

-- link_zanyatie_teoriya
INSERT INTO voditelskie_prava_dv.link_zanyatie_teoriya (link_zanyatie_teoriya_hk, gruppa_hk, prepodavatel_hk, data_provedeniya, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', g.nomer_gruppy)), TRIM(CONCAT_WS('|', s.telefon)), TRIM(z.data_provedeniya)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(g.nomer_gruppy)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(s.telefon)))),
       z.data_provedeniya,
       @ld,
       '3NF.voditelskie_prava'
  FROM zanyatie_teoriya z JOIN uchebnaya_gruppa g ON g.id = z.gruppa_id JOIN sotrudnik s ON s.id = z.prepodavatel_id;

-- link_zanyatie_vozhdenie
INSERT INTO voditelskie_prava_dv.link_zanyatie_vozhdenie (link_zanyatie_vozhdenie_hk, kursant_hk, instruktor_hk, avto_hk, data_provedeniya, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', k.telefon)), TRIM(CONCAT_WS('|', s.telefon)), TRIM(CONCAT_WS('|', av.gos_nomer)), TRIM(z.data_provedeniya)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(k.telefon)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(s.telefon)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(av.gos_nomer)))),
       z.data_provedeniya,
       @ld,
       '3NF.voditelskie_prava'
  FROM zanyatie_vozhdenie z JOIN kursant k ON k.id = z.kursant_id JOIN sotrudnik s ON s.id = z.instruktor_id JOIN uchebnoe_avto av ON av.id = z.avto_id;

-- link_inspektor_podrazdelenie
INSERT INTO voditelskie_prava_dv.link_inspektor_podrazdelenie (link_inspektor_podrazdelenie_hk, inspektor_hk, podrazdelenie_hk, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', i.lichnyy_nomer)), TRIM(CONCAT_WS('|', p.nazvanie))))),
       MD5(UPPER(CONCAT_WS('||', TRIM(i.lichnyy_nomer)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(p.nazvanie)))),
       @ld,
       '3NF.voditelskie_prava'
  FROM inspektor i JOIN podrazdelenie_gibdd p ON p.id = i.podrazdelenie_id;

-- link_gosposhlina
INSERT INTO voditelskie_prava_dv.link_gosposhlina (link_gosposhlina_hk, kursant_hk, nomer_kvitantsii, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', k.telefon)), TRIM(gp.nomer_kvitantsii)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(k.telefon)))),
       gp.nomer_kvitantsii,
       @ld,
       '3NF.voditelskie_prava'
  FROM gosposhlina gp JOIN kursant k ON k.id = gp.kursant_id;

-- link_zayavlenie
INSERT INTO voditelskie_prava_dv.link_zayavlenie (link_zayavlenie_hk, kursant_hk, podrazdelenie_hk, kategoriya_hk, data_podachi, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', k.telefon)), TRIM(CONCAT_WS('|', p.nazvanie)), TRIM(CONCAT_WS('|', kp.kod)), TRIM(z.data_podachi)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(k.telefon)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(p.nazvanie)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(kp.kod)))),
       z.data_podachi,
       @ld,
       '3NF.voditelskie_prava'
  FROM zayavlenie z JOIN kursant k ON k.id = z.kursant_id JOIN podrazdelenie_gibdd p ON p.id = z.podrazdelenie_id JOIN kategoriya_prav kp ON kp.id = z.kategoriya_id;

-- link_ekzamen_vnutr
INSERT INTO voditelskie_prava_dv.link_ekzamen_vnutr (link_ekzamen_vnutr_hk, kursant_hk, tip_ekzamena_hk, ekzaminator_hk, avto_hk, nomer_popytki, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', k.telefon)), TRIM(CONCAT_WS('|', te.etap, te.vid)), TRIM(IFNULL(CONCAT_WS('|', s.telefon), 'GHOST')), TRIM(IFNULL(CONCAT_WS('|', av.gos_nomer), 'GHOST')), TRIM(e.nomer_popytki)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(k.telefon)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(te.etap), TRIM(te.vid)))),
       IF(s.telefon IS NULL, REPEAT('0', 32), MD5(UPPER(CONCAT_WS('||', TRIM(s.telefon))))),
       IF(av.gos_nomer IS NULL, REPEAT('0', 32), MD5(UPPER(CONCAT_WS('||', TRIM(av.gos_nomer))))),
       e.nomer_popytki,
       @ld,
       '3NF.voditelskie_prava'
  FROM ekzamen e JOIN tip_ekzamena te ON te.id = e.tip_ekzamena_id AND te.etap = 'vnutrenniy' JOIN kursant k ON k.id = e.kursant_id LEFT JOIN sotrudnik s ON s.id = e.sotrudnik_id LEFT JOIN uchebnoe_avto av ON av.id = e.avto_id;

-- link_ekzamen_gibdd
INSERT INTO voditelskie_prava_dv.link_ekzamen_gibdd (link_ekzamen_gibdd_hk, kursant_hk, tip_ekzamena_hk, inspektor_hk, avto_hk, nomer_popytki, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', k.telefon)), TRIM(CONCAT_WS('|', te.etap, te.vid)), TRIM(IFNULL(CONCAT_WS('|', i.lichnyy_nomer), 'GHOST')), TRIM(IFNULL(CONCAT_WS('|', av.gos_nomer), 'GHOST')), TRIM(e.nomer_popytki)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(k.telefon)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(te.etap), TRIM(te.vid)))),
       IF(i.lichnyy_nomer IS NULL, REPEAT('0', 32), MD5(UPPER(CONCAT_WS('||', TRIM(i.lichnyy_nomer))))),
       IF(av.gos_nomer IS NULL, REPEAT('0', 32), MD5(UPPER(CONCAT_WS('||', TRIM(av.gos_nomer))))),
       e.nomer_popytki,
       @ld,
       '3NF.voditelskie_prava'
  FROM ekzamen e JOIN tip_ekzamena te ON te.id = e.tip_ekzamena_id AND te.etap = 'gibdd' JOIN kursant k ON k.id = e.kursant_id LEFT JOIN inspektor i ON i.id = e.inspektor_id LEFT JOIN uchebnoe_avto av ON av.id = e.avto_id;

-- link_vu
INSERT INTO voditelskie_prava_dv.link_vu (link_vu_hk, vu_hk, kursant_hk, podrazdelenie_hk, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', vu.seriya_nomer)), TRIM(CONCAT_WS('|', k.telefon)), TRIM(CONCAT_WS('|', p.nazvanie))))),
       MD5(UPPER(CONCAT_WS('||', TRIM(vu.seriya_nomer)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(k.telefon)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(p.nazvanie)))),
       @ld,
       '3NF.voditelskie_prava'
  FROM voditelskoe_udostoverenie vu JOIN kursant k ON k.id = vu.kursant_id JOIN podrazdelenie_gibdd p ON p.id = vu.podrazdelenie_id;

-- link_vu_kategoriya
INSERT INTO voditelskie_prava_dv.link_vu_kategoriya (link_vu_kategoriya_hk, vu_hk, kategoriya_hk, load_date, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', vu.seriya_nomer)), TRIM(CONCAT_WS('|', kp.kod))))),
       MD5(UPPER(CONCAT_WS('||', TRIM(vu.seriya_nomer)))),
       MD5(UPPER(CONCAT_WS('||', TRIM(kp.kod)))),
       @ld,
       '3NF.voditelskie_prava'
  FROM vu_kategoriya vk JOIN voditelskoe_udostoverenie vu ON vu.id = vk.vu_id JOIN kategoriya_prav kp ON kp.id = vk.kategoriya_id;

-- sat_kursant
INSERT INTO voditelskie_prava_dv.sat_kursant (kursant_hk, load_date, hash_diff, familiya, imya, otchestvo, data_rozhdeniya, email, adres, data_registratsii, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(k.telefon)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(k.familiya), TRIM(k.imya), TRIM(k.otchestvo), TRIM(k.data_rozhdeniya), TRIM(k.email), TRIM(k.adres), TRIM(k.data_registratsii)))),
       k.familiya, k.imya, k.otchestvo, k.data_rozhdeniya, k.email, k.adres, k.data_registratsii,
       '3NF.voditelskie_prava'
  FROM kursant k;

-- sat_avtoshkola
INSERT INTO voditelskie_prava_dv.sat_avtoshkola (avtoshkola_hk, load_date, hash_diff, nazvanie, adres, telefon, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(a.nomer_litsenzii)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(a.nazvanie), TRIM(a.adres), TRIM(a.telefon)))),
       a.nazvanie, a.adres, a.telefon,
       '3NF.voditelskie_prava'
  FROM avtoshkola a;

-- sat_sotrudnik
INSERT INTO voditelskie_prava_dv.sat_sotrudnik (sotrudnik_hk, load_date, hash_diff, familiya, imya, otchestvo, stazh_let, data_priema, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(s.telefon)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(s.familiya), TRIM(s.imya), TRIM(s.otchestvo), TRIM(s.stazh_let), TRIM(s.data_priema)))),
       s.familiya, s.imya, s.otchestvo, s.stazh_let, s.data_priema,
       '3NF.voditelskie_prava'
  FROM sotrudnik s;

-- sat_dolzhnost
INSERT INTO voditelskie_prava_dv.sat_dolzhnost (dolzhnost_hk, load_date, hash_diff, oklad, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(d.nazvanie)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(d.oklad)))),
       d.oklad,
       '3NF.voditelskie_prava'
  FROM dolzhnost d;

-- sat_kategoriya
INSERT INTO voditelskie_prava_dv.sat_kategoriya (kategoriya_hk, load_date, hash_diff, nazvanie, min_vozrast, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(kp.kod)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(kp.nazvanie), TRIM(kp.min_vozrast)))),
       kp.nazvanie, kp.min_vozrast,
       '3NF.voditelskie_prava'
  FROM kategoriya_prav kp;

-- sat_avto
INSERT INTO voditelskie_prava_dv.sat_avto (avto_hk, load_date, hash_diff, marka, model, korobka, god_vypuska, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(av.gos_nomer)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(av.marka), TRIM(av.model), TRIM(av.korobka), TRIM(av.god_vypuska)))),
       av.marka, av.model, av.korobka, av.god_vypuska,
       '3NF.voditelskie_prava'
  FROM uchebnoe_avto av;

-- sat_med_uchrezhdenie
INSERT INTO voditelskie_prava_dv.sat_med_uchrezhdenie (med_uchrezhdenie_hk, load_date, hash_diff, nazvanie, adres, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(mu.nomer_litsenzii)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(mu.nazvanie), TRIM(mu.adres)))),
       mu.nazvanie, mu.adres,
       '3NF.voditelskie_prava'
  FROM med_uchrezhdenie mu;

-- sat_med_spravka
INSERT INTO voditelskie_prava_dv.sat_med_spravka (med_spravka_hk, load_date, hash_diff, data_vydachi, deystvitelna_do, zaklyuchenie, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(ms.nomer)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(ms.data_vydachi), TRIM(ms.deystvitelna_do), TRIM(ms.zaklyuchenie)))),
       ms.data_vydachi, ms.deystvitelna_do, ms.zaklyuchenie,
       '3NF.voditelskie_prava'
  FROM med_spravka ms;

-- sat_gruppa
INSERT INTO voditelskie_prava_dv.sat_gruppa (gruppa_hk, load_date, hash_diff, forma_obucheniya, data_nachala, data_okonchaniya, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(g.nomer_gruppy)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(g.forma_obucheniya), TRIM(g.data_nachala), TRIM(g.data_okonchaniya)))),
       g.forma_obucheniya, g.data_nachala, g.data_okonchaniya,
       '3NF.voditelskie_prava'
  FROM uchebnaya_gruppa g;

-- sat_dogovor
INSERT INTO voditelskie_prava_dv.sat_dogovor (dogovor_hk, load_date, hash_diff, data_zaklyucheniya, stoimost, status, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(dg.nomer)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(dg.data_zaklyucheniya), TRIM(dg.stoimost), TRIM(dg.status)))),
       dg.data_zaklyucheniya, dg.stoimost, dg.status,
       '3NF.voditelskie_prava'
  FROM dogovor dg;

-- sat_podrazdelenie
INSERT INTO voditelskie_prava_dv.sat_podrazdelenie (podrazdelenie_hk, load_date, hash_diff, adres, telefon, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(p.nazvanie)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(p.adres), TRIM(p.telefon)))),
       p.adres, p.telefon,
       '3NF.voditelskie_prava'
  FROM podrazdelenie_gibdd p;

-- sat_inspektor
INSERT INTO voditelskie_prava_dv.sat_inspektor (inspektor_hk, load_date, hash_diff, familiya, imya, otchestvo, zvanie, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(i.lichnyy_nomer)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(i.familiya), TRIM(i.imya), TRIM(i.otchestvo), TRIM(i.zvanie)))),
       i.familiya, i.imya, i.otchestvo, i.zvanie,
       '3NF.voditelskie_prava'
  FROM inspektor i;

-- sat_tip_ekzamena
INSERT INTO voditelskie_prava_dv.sat_tip_ekzamena (tip_ekzamena_hk, load_date, hash_diff, nazvanie, max_oshibok, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(te.etap), TRIM(te.vid)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(te.nazvanie), TRIM(te.max_oshibok)))),
       te.nazvanie, te.max_oshibok,
       '3NF.voditelskie_prava'
  FROM tip_ekzamena te;

-- sat_vu
INSERT INTO voditelskie_prava_dv.sat_vu (vu_hk, load_date, hash_diff, data_vydachi, deystvitelno_do, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(vu.seriya_nomer)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(vu.data_vydachi), TRIM(vu.deystvitelno_do)))),
       vu.data_vydachi, vu.deystvitelno_do,
       '3NF.voditelskie_prava'
  FROM voditelskoe_udostoverenie vu;

-- sat_dokument
INSERT INTO voditelskie_prava_dv.sat_dokument (link_kursant_dokument_hk, load_date, hash_diff, kem_vydan, data_vydachi, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', k.telefon)), TRIM(doc.tip_dokumenta), TRIM(doc.seriya), TRIM(doc.nomer)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(doc.kem_vydan), TRIM(doc.data_vydachi)))),
       doc.kem_vydan, doc.data_vydachi,
       '3NF.voditelskie_prava'
  FROM dokument doc JOIN kursant k ON k.id = doc.kursant_id;

-- sat_oplata
INSERT INTO voditelskie_prava_dv.sat_oplata (link_oplata_hk, load_date, hash_diff, summa, sposob, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', dg.nomer)), TRIM(o.data_oplaty)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(o.summa), TRIM(o.sposob)))),
       o.summa, o.sposob,
       '3NF.voditelskie_prava'
  FROM oplata_obucheniya o JOIN dogovor dg ON dg.id = o.dogovor_id;

-- sat_zanyatie_teoriya
INSERT INTO voditelskie_prava_dv.sat_zanyatie_teoriya (link_zanyatie_teoriya_hk, load_date, hash_diff, tema, kol_chasov, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', g.nomer_gruppy)), TRIM(CONCAT_WS('|', s.telefon)), TRIM(z.data_provedeniya)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(z.tema), TRIM(z.kol_chasov)))),
       z.tema, z.kol_chasov,
       '3NF.voditelskie_prava'
  FROM zanyatie_teoriya z JOIN uchebnaya_gruppa g ON g.id = z.gruppa_id JOIN sotrudnik s ON s.id = z.prepodavatel_id;

-- sat_zanyatie_vozhdenie
INSERT INTO voditelskie_prava_dv.sat_zanyatie_vozhdenie (link_zanyatie_vozhdenie_hk, load_date, hash_diff, kol_chasov, mesto, otsenka, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', k.telefon)), TRIM(CONCAT_WS('|', s.telefon)), TRIM(CONCAT_WS('|', av.gos_nomer)), TRIM(z.data_provedeniya)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(z.kol_chasov), TRIM(z.mesto), TRIM(z.otsenka)))),
       z.kol_chasov, z.mesto, z.otsenka,
       '3NF.voditelskie_prava'
  FROM zanyatie_vozhdenie z JOIN kursant k ON k.id = z.kursant_id JOIN sotrudnik s ON s.id = z.instruktor_id JOIN uchebnoe_avto av ON av.id = z.avto_id;

-- sat_gosposhlina
INSERT INTO voditelskie_prava_dv.sat_gosposhlina (link_gosposhlina_hk, load_date, hash_diff, naznachenie, summa, data_oplaty, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', k.telefon)), TRIM(gp.nomer_kvitantsii)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(gp.naznachenie), TRIM(gp.summa), TRIM(gp.data_oplaty)))),
       gp.naznachenie, gp.summa, gp.data_oplaty,
       '3NF.voditelskie_prava'
  FROM gosposhlina gp JOIN kursant k ON k.id = gp.kursant_id;

-- sat_zayavlenie
INSERT INTO voditelskie_prava_dv.sat_zayavlenie (link_zayavlenie_hk, load_date, hash_diff, status, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', k.telefon)), TRIM(CONCAT_WS('|', p.nazvanie)), TRIM(CONCAT_WS('|', kp.kod)), TRIM(z.data_podachi)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(z.status)))),
       z.status,
       '3NF.voditelskie_prava'
  FROM zayavlenie z JOIN kursant k ON k.id = z.kursant_id JOIN podrazdelenie_gibdd p ON p.id = z.podrazdelenie_id JOIN kategoriya_prav kp ON kp.id = z.kategoriya_id;

-- sat_ekzamen_vnutr
INSERT INTO voditelskie_prava_dv.sat_ekzamen_vnutr (link_ekzamen_vnutr_hk, load_date, hash_diff, data_ekzamena, rezultat, kol_oshibok, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', k.telefon)), TRIM(CONCAT_WS('|', te.etap, te.vid)), TRIM(IFNULL(CONCAT_WS('|', s.telefon), 'GHOST')), TRIM(IFNULL(CONCAT_WS('|', av.gos_nomer), 'GHOST')), TRIM(e.nomer_popytki)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(e.data_ekzamena), TRIM(e.rezultat), TRIM(e.kol_oshibok)))),
       e.data_ekzamena, e.rezultat, e.kol_oshibok,
       '3NF.voditelskie_prava'
  FROM ekzamen e JOIN tip_ekzamena te ON te.id = e.tip_ekzamena_id AND te.etap = 'vnutrenniy' JOIN kursant k ON k.id = e.kursant_id LEFT JOIN sotrudnik s ON s.id = e.sotrudnik_id LEFT JOIN uchebnoe_avto av ON av.id = e.avto_id;

-- sat_ekzamen_gibdd
INSERT INTO voditelskie_prava_dv.sat_ekzamen_gibdd (link_ekzamen_gibdd_hk, load_date, hash_diff, data_ekzamena, rezultat, kol_oshibok, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', k.telefon)), TRIM(CONCAT_WS('|', te.etap, te.vid)), TRIM(IFNULL(CONCAT_WS('|', i.lichnyy_nomer), 'GHOST')), TRIM(IFNULL(CONCAT_WS('|', av.gos_nomer), 'GHOST')), TRIM(e.nomer_popytki)))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(e.data_ekzamena), TRIM(e.rezultat), TRIM(e.kol_oshibok)))),
       e.data_ekzamena, e.rezultat, e.kol_oshibok,
       '3NF.voditelskie_prava'
  FROM ekzamen e JOIN tip_ekzamena te ON te.id = e.tip_ekzamena_id AND te.etap = 'gibdd' JOIN kursant k ON k.id = e.kursant_id LEFT JOIN inspektor i ON i.id = e.inspektor_id LEFT JOIN uchebnoe_avto av ON av.id = e.avto_id;

-- sat_vu_kategoriya
INSERT INTO voditelskie_prava_dv.sat_vu_kategoriya (link_vu_kategoriya_hk, load_date, hash_diff, data_otkrytiya, ogranicheniya, record_source)
SELECT MD5(UPPER(CONCAT_WS('||', TRIM(CONCAT_WS('|', vu.seriya_nomer)), TRIM(CONCAT_WS('|', kp.kod))))),
       @ld,
       MD5(UPPER(CONCAT_WS('||', TRIM(vk.data_otkrytiya), TRIM(vk.ogranicheniya)))),
       vk.data_otkrytiya, vk.ogranicheniya,
       '3NF.voditelskie_prava'
  FROM vu_kategoriya vk JOIN voditelskoe_udostoverenie vu ON vu.id = vk.vu_id JOIN kategoriya_prav kp ON kp.id = vk.kategoriya_id;

-- =====================================================================
--  Проверка: сборка «курсант — экзамен в ГИБДД — инспектор» из Data Vault
-- =====================================================================
USE `voditelskie_prava_dv`;
SELECT CONCAT(sk.familiya, ' ', sk.imya) AS kursant, ste.nazvanie AS ekzamen, l.nomer_popytki,
       se.rezultat, se.kol_oshibok, si.familiya AS inspektor
  FROM link_ekzamen_gibdd l
  JOIN sat_kursant sk        ON sk.kursant_hk = l.kursant_hk
  JOIN sat_tip_ekzamena ste  ON ste.tip_ekzamena_hk = l.tip_ekzamena_hk
  JOIN sat_ekzamen_gibdd se  ON se.link_ekzamen_gibdd_hk = l.link_ekzamen_gibdd_hk
  LEFT JOIN sat_inspektor si ON si.inspektor_hk = l.inspektor_hk
 ORDER BY sk.familiya, se.data_ekzamena;
