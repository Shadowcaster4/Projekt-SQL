--Bartomiej Wojtasinski 128193 lab9 semestr IV bazy danych projekt dziennik szkolny
create table nauczyciele
(
id_nauczyciela number(4) constraint nauczyciele_pk primary key,
imie varchar(30) constraint nauczyciele_imie_nn not null,
nazwisko varchar(30) constraint nauczyciele_nazwisko_nn not null,
specjalizacja varchar(30) constraint nauczyciele_spec_ch 
check (specjalizacja in ('nauki humanistyczne','nauki przyrodnicze','nauki jezykowe','nauki matematyczne')),
mail varchar(60) constraint nauczyciele_mail_ch check (mail like '%@%') 
);

create table przedmioty
(
id_przedmiotu number(3) constraint przedmioty_pk primary key,
nazwa varchar(30) constraint przedmioty_nn not null
);

create table klasa
(
id_klasy number(4) constraint klasa_pk primary key,
nazwa_klasy varchar(50) constraint klasa_nk_nn not null,
wychowawca number(4) constraint klasa_w_nn not null,
constraint klasa_wychowawca_fk foreign key(wychowawca) references nauczyciele(id_nauczyciela)
);

create table przedmioty_klas
(
id_klasy number(4) constraint przedmioty_klas_id_k_nn not null,
id_przedmiotu number(4) constraint przedmioty_klas_id_p_nn not null,
id_nauczyciela number(4) constraint przedmioty_klas_id_n_nn not null,
liczba_godzin number (3) constraint przedmioty_klas_lg_nn not null,
constraint przedmioty_klas_idk_fk foreign key(id_klasy) references klasa(id_klasy),
constraint przedmioty_klas_idp_fk foreign key(id_przedmiotu) references przedmioty(id_przedmiotu),
constraint przemdioty_klas_idn_fk foreign key(id_nauczyciela) references nauczyciele(id_nauczyciela)
);


create table uczen
(
id_ucznia number(6) constraint uczen_pk primary key,
imie varchar(30) constraint uczen_imie_nn not null,
nazwisko varchar(30) constraint uczen_nazwisko_nn not null,
id_klasy number(4) constraint uczen_idk_nn not null,
pesel number(11) constraint uczen_psl_ch check (length(pesel)=11),
mail varchar(60) constraint uczen_mail_ch check (mail like '%@%'),
telefon_opiekuna number(9) constraint uczen_telefon_opiekuna_ch check (length(telefon_opiekuna)=9),
adres varchar(60) constraint uczen_adres_nn not null,
constraint uczen_idk_fk foreign key(id_klasy) references klasa(id_klasy)
);

create table oceny
(
id_oceny number(8) constraint oceny_pk primary key,
ocena number(3,2) constraint oceny_ocena_nn not null, 
waga number(1) constraint oceny_waga_nn not null,
informacje varchar(250),
data_wystawienia DATE constraint oceny_dw_nn not null,
id_ucznia number(6) constraint oceny_idu_nn not null,
id_nauczyciela number(4) constraint oceny_idn_nn not null,
id_przedmiotu number(3) constraint oceny_idp_nn not null,
constraint oceny_idu_fk foreign key(id_ucznia) references uczen(id_ucznia),
constraint oceny_idn_fk foreign key(id_nauczyciela) references nauczyciele(id_nauczyciela),
constraint oceny_idp_fk foreign key(id_przedmiotu) references przedmioty(id_przedmiotu)
);

create table obecnosci
(
id_ucznia number(6) constraint obecnosci_idu_nn not null,
id_przedmiotu number(3) constraint obecnosci_idp_nn not null,
data_zajec DATE constraint obecnosci_data_nn not null,
wartosc varchar(16) constraint obecnosci_wartosc_ch 
check (wartosc in('obecny','nie obecny','usprawiedliwiona','spoznienie')),
constraint obecnosci_idu_fk foreign key(id_ucznia) references uczen(id_ucznia),
constraint obecnosci_idp_fk foreign key(id_przedmiotu) references przedmioty(id_przedmiotu)
);

create table adnotacje
(
id_ucznia number(6),
id_nauczyciela number(4) constraint adnotacje_idn_nn not null,
tresc varchar(500) constraint adnotacje_tresc_nn not null,
constraint adnotacje_idu_fk foreign key(id_ucznia) references uczen(id_ucznia),
constraint adnotacje_idn_fk foreign key(id_nauczyciela) references nauczyciele(id_nauczyciela)
);

CREATE SEQUENCE S_Nauczyciele_AI
START WITH 5
INCREMENT BY 1
;

CREATE OR REPLACE TRIGGER Trigger_Teacher
BEFORE INSERT
ON nauczyciele
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
SELECT S_Nauczyciele_AI.nextval INTO :NEW.id_nauczyciela FROM dual;
END;

CREATE SEQUENCE S_Przedmioty_AI
START WITH 1
INCREMENT BY 1
;

CREATE OR REPLACE TRIGGER Trigger_Subject
BEFORE INSERT
ON przedmioty
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
SELECT S_Przedmioty_AI.nextval INTO :NEW.id_przedmiotu FROM dual;
END;

CREATE  SEQUENCE S_Uczniowie_AI
START WITH 1
INCREMENT BY 1
;

CREATE OR REPLACE TRIGGER Trigger_Students
BEFORE INSERT
ON uczen
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
SELECT S_Uczniowie_AI.nextval INTO :NEW.id_ucznia FROM dual;
END;

CREATE SEQUENCE S_Klasa_AI
START WITH 7
INCREMENT BY 1
;

CREATE OR REPLACE TRIGGER Trigger_Class
BEFORE INSERT
ON klasa
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
SELECT S_Klasa_AI.nextval INTO :NEW.id_klasy FROM dual;
END;

CREATE SEQUENCE S_Oceny_AI
START WITH 1
INCREMENT BY 1
;

CREATE OR REPLACE TRIGGER Trigger_Grades
BEFORE INSERT
ON oceny
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
SELECT S_Oceny_AI.nextval INTO :NEW.id_oceny FROM dual;
case :NEW.waga
when 1 then select 'aktywnosc' INTO :NEW.informacje from dual;
when 2 then select 'odpowiedz ustna' INTO :NEW.informacje from dual;
when 3 then select 'kartkowka' INTO :NEW.informacje from dual;
when 4 then select 'test' INTO :NEW.informacje from dual;
when 5 then select 'sprawdzian' INTO :NEW.informacje from dual;
end case;
END;

create or replace TRIGGER wielkie_litery_uczen BEFORE INSERT ON uczen
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
IF lower(:new.imie)=:new.imie or lower(:new.nazwisko)=:new.nazwisko
then raise_application_error(-20001, 'Imie i nazwisko zaczynamy wielka litera');
end if;
end;


insert into nauczyciele values(0,'Danuta','Markowska','nauki humanistyczne','mowk@szkola.pl');
insert into nauczyciele values(0,'Mariusz','Chmielarek','nauki humanistyczne','mariuszchmiel@szkola.pl');
insert into nauczyciele values(0,'Oktawian','Zelmer','nauki przyrodnicze','kochamprzy@szkola.pl');
insert into nauczyciele values(0,'Monika','Chmielarek','nauki jezykowe','monikachmiel@szkola.pl');
insert into nauczyciele values(0,'Tadeusz','Nicpon','nauki matematyczne','mowmitadek@szkola.pl');
insert into nauczyciele values(0,'Adrian','Kamyk','nauki matematyczne','dek@szkola.pl');


insert into przedmioty values(0,'Matematyka');
insert into przedmioty values(0,'Polski');
insert into przedmioty values(0,'Biologia');
insert into przedmioty values(0,'Fizyka');
insert into przedmioty values(0,'Religia');
insert into przedmioty values(0,'WF');

insert into klasa values(0,'1a',6);
insert into klasa values(0,'1b',7);
insert into klasa values(0,'2a',8);
insert into klasa values(0,'2b',6);
insert into klasa values(0,'3a',9);
insert into klasa values(0,'3b',6);

insert into przedmioty_klas values(7,1,9,30);
insert into przedmioty_klas values(7,2,5,30);
insert into przedmioty_klas values(7,3,7,30);
insert into przedmioty_klas values(7,4,10,30);
insert into przedmioty_klas values(7,5,6,30);
insert into przedmioty_klas values(7,6,6,30);

insert into przedmioty_klas values(8,1,10,30);
insert into przedmioty_klas values(8,2,6,30);
insert into przedmioty_klas values(8,3,7,30);
insert into przedmioty_klas values(8,4,9,30);
insert into przedmioty_klas values(8,5,5,30);
insert into przedmioty_klas values(8,6,6,30);

insert into przedmioty_klas values(9,1,9,20);
insert into przedmioty_klas values(9,2,5,60);
insert into przedmioty_klas values(9,3,7,10);
insert into przedmioty_klas values(9,4,10,10);
insert into przedmioty_klas values(9,5,6,45);
insert into przedmioty_klas values(9,6,6,30);

insert into przedmioty_klas values(10,1,10,60);
insert into przedmioty_klas values(10,2,6,20);
insert into przedmioty_klas values(10,3,7,45);
insert into przedmioty_klas values(10,4,9,30);
insert into przedmioty_klas values(10,5,5,10);
insert into przedmioty_klas values(10,6,6,10);

insert into przedmioty_klas values(11,1,9,20);
insert into przedmioty_klas values(11,2,5,60);
insert into przedmioty_klas values(11,3,7,10);
insert into przedmioty_klas values(11,4,10,10);
insert into przedmioty_klas values(11,5,5,30);
insert into przedmioty_klas values(11,6,6,30);

insert into przedmioty_klas values(12,1,10,60);
insert into przedmioty_klas values(12,2,6,20);
insert into przedmioty_klas values(12,3,7,45);
insert into przedmioty_klas values(12,4,9,30);
insert into przedmioty_klas values(12,5,5,30);
insert into przedmioty_klas values(12,6,6,30);



insert into uczen values(0,'Adrian','Mazur',7,98021243568,'noliprelforte@gmail.com',765555344,'3 Maja 43 Czestochowa');
insert into uczen values(0,'Tadeusz','Zly',7,98121243568,'ewenement@gmail.com',645555444,'Psa i Kota 21 Czestochowa');
insert into uczen values(0,'Marian','Niebyt',7,98101244568,'Blair84@1984.com',644555444,'Rybacka 77 Czestochowa');
insert into uczen values(0,'Dominika','Kotarski',7,98111243368,'iwanttobelieve@ufo.com',265555444,'4 Czerwca Kielce');
insert into uczen values(0,'Alina','Szlachcic',7,98101243568,'ErickaBlair84@1984.com',456555444,'Mysliwska 67 Czestochowa');

insert into uczen values(0,'Wojciech','Killar',8,98102543568,'tredowata@1984.com',965555444,'Hollywoodzka 15 Czestochowa');
insert into uczen values(0,'Siergiej','Rachmaninow',8,98062246568,'moderato@op18.rus',777555444,'Miodowa 4 Czestochowa');
insert into uczen values(0,'Antoni','Vivaldi',8,98022243568,'cessateomaicessate@4p.com',665555444,'Kasztanowa 87 Czestochowa');
insert into uczen values(0,'Piotr','Czajkowski',8,98121243568,'sentymentalny@mail.com',635535444,'£abedzia 55 Czestochowa');
insert into uczen values(0,'Dorota','Dzien',8,98031243568,'wybitna77@gmail.com',565555444,'Goryla 4 Czestochowa');
insert into uczen values(0,'Eryk','Satie',8,98081243568,'konser34@gmail.com',695555444,'Paryska 6 Czestochowa');
insert into uczen values(0,'Rena','Rolska',8,98061243568,'renarol@gtr.com',600555444,'Poczekalni 48 Czestochowa');

insert into uczen values(0,'Albert','Kolarz',10,98120243568,'mistrz@gmail.com',635555444,'Wynalazcow 4 Czestochowa');
insert into uczen values(0,'Tadeusz','Dobrotliwy',10,98121243568,'air84@14.com',665555444,'Myszkowska 4 Czestochowa');
insert into uczen values(0,'Ernest','Niebycki',10,98120143568,'Erir84@4you.com',678555444,'Konstruktorow 674 Czestochowa');

insert into uczen values(0,'Aniela','Talerz',12,98122243568,'myszolow@gmail.com',665225444,'Zgoda 18/2 Czestocohwa');
insert into uczen values(0,'Alina','Biedak',12,98121643568,'ptactwopol@ptak.com',665115444,'Mysliwych 11/2 Czestochowa ');
insert into uczen values(0,'Martyna','Jacht',12,98121843568,'myslnik@krokpa.com',685555444,'Yeti 137 Czestochowa');
insert into uczen values(0,'Agata','Lodowa',12,98101343568,'mi67@start.com',995555444,'Kuli 5 Wreczyca');

insert into uczen values(0,'Benedykt','Niezly',11,98121243568,'losowymail@gmail.com',665555444,'Kolarska 1 Cestochowa');
insert into uczen values(0,'Tadeusz','Zly',11,98121243568,'niesamowita@gmail.com',665555444,'Kolarska 2 Cestochowa');
insert into uczen values(0,'Marian','Niebyt',11,98121243568,'ErickBlair84@1984.com',665555444,'Kolarska 3 Cestochowa');
insert into uczen values(0,'Dominika','Kotarski',11,98121243568,'ustka84@onet.com',665555444,'Kolarska 41 Cestochowa');
insert into uczen values(0,'Alina','Szlachcic',11,98121243568,'ulm@HRE.aus',665555444,'Kolarska 12 Cestochowa');
insert into uczen values(0,'Martyna','Jachimek',11,98121243568,'Mitrras42@mali.com',665555444,'Kolarska 13 Cestochowa');
insert into uczen values(0,'Teodor','Lodowaty',11,98121243568,'fsafdd@4gmail.com',665555444,'Kolarska 14 Cestochowa');

insert into uczen values(0,'Roman','Grall',9,98121243568,'gagagg@rr4.com',665555444,'Zgoda 18/2 92-500 Pabianice');
insert into uczen values(0,'Edmir','Wiking',9,98121243568,'Nikodem@1tt4.com',665555444,'Doktorska 5 Czestochowa');
insert into uczen values(0,'Bernard','Wspanialy',9,98121243568,'jedenjeden@emocje.com',665555444,'Stomatologiczna 4 Czestochowa');
insert into uczen values(0,'Alfred','Swiat',9,98121243568,'motyldoktor@mistrz.com',665555444,'Krwiodawstwa 67 Cestochowa');


insert into oceny values(0,4.5,5,'Sprawdzian',sysdate,7,(select id_nauczyciela from przedmioty_klas join klasa using(id_klasy) where id_klasy=(select id_klasy from uczen where id_ucznia=7 and id_przedmiotu=1)),1);

--blok anonimowy - dodanie obecnosci uczniom 
DECLARE
h1 number:=1;
h2 number:=30;
i1 number;
i2 number;
y1 number;
y2 number;
BEGIN
select min(id_nauczyciela) into i1 from nauczyciele;
select max(id_nauczyciela) into i2 from nauczyciele;
select min(id_przedmiotu) into y1 from przedmioty;
select max(id_przedmiotu) into y2 from przedmioty;
for h in h1..h2 LOOP
for i in i1..i2   LOOP
for y in y1..y2 LOOP
insert into obecnosci (id_ucznia,id_przedmiotu,data_zajec,wartosc)
select distinct(id_ucznia),y,sysdate,
(select 
case (floor(dbms_random.value(1,10)))
when 5 then 'nie obecny'
when 1 then 'nie obecny'
when 7 then 'usprawiedliwiona'
when 6 then 'spoznienie'
else 'obecny'
end obecnosc
from   dual)
from przedmioty_klas join uczen using(id_klasy) where id_klasy=i and id_przedmiotu=y
and id_ucznia >=0  ;
end LOOP;
end LOOP;
end LOOP;
end;

--blok anonimowy zapelniajacy tabele ocenami uczniow
DECLARE
k1 number;
k2 number;
p1 number;
p2 number;
BEGIN
select min(id_ucznia) into k1 from uczen;
select max(id_ucznia) into k2 from uczen;
select min(id_przedmiotu) into p1 from przedmioty;
select max(id_przedmiotu) into p2 from przedmioty;
FOR i in 1..4 LOOP
FOR k in k1..k2 LOOP
FOR l in p1..p2 LOOP 
insert into oceny values(0,
(select 
case (floor(dbms_random.value(1,10)))
when 1 then 1
when 2 then 2
when 3 then 3
when 4 then 4
when 5 then 5
when 6 then 6
when 7 then 3.5
when 8 then 1.5
when 9 then 2.5
else 4.5
end ocena
from   dual)
,
(select 
case (floor(dbms_random.value(1,5)))
when 2 then 2
when 3 then 3
when 4 then 4
when 5 then 5
else 1
end waga
from   dual)
,'',sysdate,k,(select id_nauczyciela from przedmioty_klas join klasa using(id_klasy) 
where id_klasy=(select id_klasy from uczen where id_ucznia=k and id_przedmiotu=l)),l);
end LOOP;
end LOOP;
end LOOP;
end;







--perspektywy
create or replace view podsumowanie as select (uczen.nazwisko||' '||uczen.imie)as "Personalia ucznia"
,klasa.nazwa_klasy,przedmioty.nazwa,(nauczyciele.imie||' '||nauczyciele.nazwisko)as "Personalia nauczyciela"
,wynik as "srednia wazona" 
from
(
select id_ucznia,id_przedmiotu,id_nauczyciela,round(sum(mnoznik)/sum(suma),2)wynik from
(
select id_ucznia,id_przedmiotu,id_nauczyciela, (ocena*waga)mnoznik 
,sum(waga)suma from oceny group by ocena*waga,id_ucznia,id_przedmiotu,id_nauczyciela)
group by id_ucznia,id_przedmiotu,id_nauczyciela)join uczen using(id_ucznia) 
join nauczyciele using(id_nauczyciela) join przedmioty using(id_przedmiotu) join klasa using(id_klasy)
order by nazwa_klasy,"Personalia ucznia"
;



create or replace view statystyki_nauczyciele as
select nauczyciele.imie,nauczyciele.nazwisko,nauczyciele.specjalizacja,nazwa,nazwa_klasy,srednia from
(
select nazwa_klasy,nazwa,p1.id_przedmiotu,k1.id_klasy,id_nauczyciela,
round(sum("srednia wazona")/count(nazwa_klasy),2)srednia
from podsumowanie join przedmioty p1 using(nazwa) join klasa k1 using (nazwa_klasy) join przedmioty_klas 
on(k1.id_klasy=przedmioty_klas.id_klasy and p1.id_przedmiotu=przedmioty_klas.id_przedmiotu) 
group by nazwa_klasy,nazwa,p1.id_przedmiotu,id_nauczyciela,k1.id_klasy
)join nauczyciele using(id_nauczyciela);



create or replace view koniec_roku as select "Personalia ucznia"
,nazwa_klasy,round(sum("srednia wazona")/count("Personalia ucznia"),2)as "Srednia na Swiadectwo"
,(nauczyciele.imie||' '||nauczyciele.nazwisko)as "wychowawca klasy" from podsumowanie 
join klasa using(nazwa_klasy) join nauczyciele on klasa.wychowawca=nauczyciele.id_nauczyciela
group by "Personalia ucznia",nauczyciele.imie||' '||nauczyciele.nazwisko,nazwa_klasy order by nazwa_klasy;

create or replace view dane_frekwencja as
select t1.id_ucznia,t1.id_przedmiotu,t1.liczba+t2.liczba as "obecnosci",t2.liczba as "spoznienia",
t3.liczba as "nieobecnosci usprawiedliwione",(30-t1.liczba-t2.liczba) as "nieobecnosci" from
(select id_ucznia,id_przedmiotu,count(wartosc)liczba from obecnosci 
where wartosc = 'obecny'  group by id_ucznia,id_przedmiotu)t1 
join (select id_ucznia,id_przedmiotu,count(wartosc)liczba from obecnosci 
where wartosc='spoznienie' group by id_ucznia,id_przedmiotu)t2
on (t1.id_ucznia=t2.id_ucznia and t1.id_przedmiotu=t2.id_przedmiotu) join
(select id_ucznia,id_przedmiotu,count(wartosc)liczba from obecnosci  
where wartosc = 'usprawiedliwiona' group by id_ucznia,id_przedmiotu)t3 
on (t3.id_ucznia=t2.id_ucznia and t3.id_przedmiotu=t2.id_przedmiotu);

--selecty wszystkich perspektyw
select * from podsumowanie;
select * from koniec_roku;
select * from dane_frekwencja;
select * from statystyki_nauczyciele;
--zapytania
--wyciagniecie frekwencji ucznia klasy
    
select uczen.imie,uczen.nazwisko,przedmioty.nazwa,"obecnosci",
"spoznienia","nieobecnosci usprawiedliwione","nieobecnosci",
round(("obecnosci"*100)/30,2) as "frekwencja w %" 
from dane_frekwencja join uczen using(id_ucznia) join przedmioty
using(id_przedmiotu) where uczen.id_klasy=7 and imie='Alina' ;

--wyciagniecie frekwencji klasy
select uczen.imie,uczen.nazwisko,przedmioty.nazwa,"obecnosci","spoznienia",
"nieobecnosci usprawiedliwione","nieobecnosci",
round(("obecnosci"*100)/30,2) as "frekwencja w %" 
from dane_frekwencja join uczen using(id_ucznia) join przedmioty
using(id_przedmiotu) where uczen.id_klasy=10 order by nazwisko ;

--ogolna frekwencja na ucznia
select id_ucznia,uczen.imie,uczen.nazwisko,round(sum(round(("obecnosci"*100)/30,2))/count("obecnosci"),2) as "suma" 
from dane_frekwencja join uczen using(id_ucznia) join przedmioty using(id_przedmiotu) where uczen.id_klasy=7 
group by id_ucznia,uczen.imie,uczen.nazwisko;

--ogolna frekwencja na klase
select nazwa_klasy,sum(frek)/count(id_klasy)as "srednia frekwencja klasy w %" from
(
select id_ucznia,uczen.id_klasy,uczen.imie,uczen.nazwisko,round(sum(round(("obecnosci"*100)/30,2))/count("obecnosci"),2)frek 
from dane_frekwencja join uczen using(id_ucznia) join przedmioty using(id_przedmiotu) 
group by id_ucznia,uczen.imie,uczen.nazwisko,uczen.id_klasy
) join klasa using(id_klasy) group by nazwa_klasy order by nazwa_klasy

-- statystyki nauczycieli posegreogowane po sredniej
select * from statystyki_nauczyciele order by srednia desc;

--statystyki nauczycieli z listaggiem
select imie||' '||nazwisko,specjalizacja as "Personalia nauczyciela",
listagg(nazwa||' '||nazwa_klasy||' '||srednia,' ||| ')
within group (order by srednia desc) as "Dane na temat klas nauczyciela"
from statystyki_nauczyciele group by imie||' '||nazwisko,specjalizacja;

--wypisanie uczniow nazwy ich klasy oraz danych wychowawcy danej klasy
select (uczen.imie||' '||uczen.nazwisko) as "Personalia Ucznia",nazwa_klasy as "nazwa klasy" 
,(nauczyciele.imie||' '||nauczyciele.nazwisko) as "Personalnia Wychowawcy" from uczen join klasa using(id_klasy) 
join nauczyciele on(wychowawca=id_nauczyciela) order by id_klasy  ;

--wypisanie nazw klas i ich liczebnosci
select nazwa_klasy as "Nazwa klasy",count(uczen.id_klasy) as "Liczba uczniów" 
from uczen join klasa on(uczen.id_klasy=klasa.id_klasy) group by nazwa_klasy order by nazwa_klasy ;

--wypisanie ilosci uczniow przypadajacych na nauczyciela
select (nauczyciele.imie||' '||nauczyciele.nazwisko)as "Personalia nauczyciela",
count(id_ucznia) as "Liczba uczniow" from nauczyciele join przedmioty_klas using(id_nauczyciela) 
join uczen using(id_klasy) group by (nauczyciele.imie||' '||nauczyciele.nazwisko);

--wypisanie  uczniow od najstarszego po numerach pesel
select imie,nazwisko,to_date((substr(pesel,5,2)||'-'||substr(pesel,3,2)||'-'||substr(pesel,1,2))
,'DD-MM-YY')as "Data urodzenia ucznia"
from uczen  order by "Data urodzenia ucznia"  ;

--dodawanie oceny
insert into oceny values(0,2,2,'odpowiedz',sysdate,7,
(select id_nauczyciela from przedmioty_klas join klasa using(id_klasy)
where id_klasy=(select id_klasy from uczen where id_ucznia=7 and id_przedmiotu=1)),1);

--dodawanie uwagi uczniowi
insert into adnotacje values(7,7,'zaklóca przebieg zajec',null);



--wstawienie nieobecnosci uczniowi
uptade obecnosci set wartosc='nie obecny' where id_ucznia=(select id_ucznia from uczen where id

--update
drop table adnotacje;

select * from adnotacje;

alter table adnotacje add(data_adnotacji date);
update adnotacje set data_adnotacji=sysdate where data_adnotacji is null;

update nauczyciele n2  set mail=(select imie||nazwisko||id_nauczyciela||'@szkolanr5.pl'
from nauczyciele where id_nauczyciela=n2.id_nauczyciela) ;

select * from nauczyciele;

--funckja do wywolywania do odpowiedzi
create or replace function do_odpowiedzi(fklasa in varchar)
Return varchar
is personalia varchar(100);
BEGIN
SELECT imie||' '||nazwisko
into personalia
FROM  
(SELECT imie,nazwisko FROM uczen  
where id_klasy=(select id_klasy from klasa where nazwa_klasy=fklasa) 
ORDER BY dbms_random.value)  
WHERE rownum =1 ;
return(personalia);
end do_odpowiedzi;

select do_odpowiedzi('3a') from dual;

--usuwanie tabel seqwenccji i funkcji 

BEGIN
  FOR rec IN
    (
      SELECT
        table_name
      FROM
        all_tables
      WHERE
        table_name in ('NAUCZYCIELE','KLASA','ADNOTACJE','OCENY','OBECNOSCI','PRZEDMIOTY','PRZEDMIOTY_KLAS','UCZEN') 
    )
  LOOP
    EXECUTE immediate 'DROP TABLE  '||rec.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
  
    FOR rec2 IN
    (
      SELECT
        sequence_name
      FROM
        all_sequences
      WHERE
        sequence_name in ('S_KLASA_AI','S_NAUCZYCIELE_AI','S_OCENY_AI','S_UCZNIOWIE_AI','S_PRZEDMIOTY_AI') 
    )
  LOOP
    EXECUTE immediate 'DROP SEQUENCE  '||rec2.sequence_name ;
  END LOOP;
   
END;

drop function DO_ODPOWIEDZI;

