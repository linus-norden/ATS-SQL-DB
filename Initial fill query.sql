
insert into bereich (bereich_name, bereich_aktiv_seit) values ("Bereich 1", "2024-03-06 12:12:12");
insert into bereich (bereich_name, bereich_aktiv_seit) values ("Bereich 2", "2024-03-06 12:12:12");
insert into raum (raum_name, raum_aktiv_seit, raum_bereich_id, raum_aktiv) values ("Raum 1.1", "2024-03-06 12:12:12", "1", 1);
insert into raum (raum_name, raum_aktiv_seit, raum_bereich_id, raum_aktiv) values ("Raum 1.2", "2024-03-06 12:12:12", "1", 1);
insert into raum (raum_name, raum_aktiv_seit, raum_bereich_id, raum_aktiv) values ("Raum 2.1", "2024-03-06 12:12:12", "2", 1);
insert into raum (raum_name, raum_aktiv_seit, raum_bereich_id, raum_aktiv) values ("Raum 2.2", "2024-03-06 12:12:12", "2", 1);
insert into mp_typ (mp_typ_name) values ("Patientenmonitor B450 von GE");
insert into mp_typ (mp_typ_name) values ("EKG Kabel für B450 von GE");
insert into mp_typ (mp_typ_name) values ("Manuelles RR-Gerät");
insert into mp_mapping (mp_mapping_mp_typ_id_1, mp_mapping_mp_typ_id_2) values ("1", "2");
insert into mp (mp_name, mp_SN, mp_aktiv_seit, mp_mp_typ_id, mp_beacon_id) values ("B450 Patientenmonitor", "123456", "2024-03-06 12:12:12", "1", "2");
insert into mp (mp_name, mp_SN, mp_aktiv_seit, mp_mp_typ_id, mp_beacon_id) values ("EKG Kabel", "222222", "2024-03-06 12:12:12", "2", "3");
insert into mp (mp_name, mp_SN, mp_aktiv_seit, mp_mp_typ_id, mp_beacon_id) values ("B450 Patientenmonitor", "123456", "2024-03-06 12:12:12", "1", "4");
insert into mp (mp_name, mp_SN, mp_aktiv_seit, mp_mp_typ_id, mp_beacon_id) values ("EKG Kabel", "222222", "2024-03-06 12:12:12", "2", "5");
insert into mp (mp_name, mp_SN, mp_aktiv_seit, mp_mp_typ_id, mp_beacon_id) values ("RR-Gerät", "333333", "2024-03-06 12:12:12", "3", "6");
insert into hub (hub_MAC, hub_aktiv, hub_aktiv_seit, hub_raum_id) values ("00:00:00:00:00:00", 1, "2024-03-06 12:12:12", "1");
insert into hub (hub_MAC, hub_aktiv, hub_aktiv_seit, hub_raum_id) values ("00:00:00:00:00:01", 1, "2024-03-06 12:12:12", "2");
insert into hub (hub_MAC, hub_aktiv, hub_aktiv_seit, hub_raum_id) values ("00:00:00:00:00:02", 1, "2024-03-06 12:12:12", "3");

