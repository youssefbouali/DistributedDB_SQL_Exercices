--TP2 Base de données réparties
---Fragmentation-
--Objectif : Se familiariser avec la notion de fragmentation horizontale et verticale utilisée dans le cadre des BDR sous Oracle
Environnement de travail : Oracle XE 11g & Oracle SQL Developer
--Dans ce TP, nous utiliserons une seule machine avec une base de données Oracle et 3 utilisateurs.
--Exercice 1 :
--Se connecter en tant que system/password et créer un nouvel utilisateur userDistant2/ userDistant2 et lui allouer les privilèges CREATE SESSION, CREATE PUBLIC DATABASE LINK et CREATE SYNONYM

alter session set "_ORACLE_SCRIPT"=true;
CREATE USER userDistant2 IDENTIFIED BY userDistant2;

GRANT CREATE SESSION TO userDistant2;
GRANT CREATE PUBLIC DATABASE LINK TO userDistant2;
GRANT CREATE SYNONYM TO userDistant2;

--Exercice 2 : Fragmentation Horizontale
--La table Employe (déjà créée dans le TP1) est fragmentée horizontalement en deux fragments selon la ville.
--A. En tant que userDistant1, créer le fragment EmployeDeKech contenant les employés de la ville de 'Marrakech'.


CONNECT userDistant1/userDistant1;

GRANT CREATE TABLE TO userDistant1; -(system)
ALTER USER userDistant1 DEFAULT TABLESPACE USERS;
ALTER USER userDistant1 QUOTA UNLIMITED ON USERS;

CREATE TABLE EmployeDeKech AS
SELECT * FROM Emp WHERE ville = 'Marrakech';


COMMIT;

--B. En tant que userDistant2, créer le fragment EmployeAutreVille contenant les employés des autres villes.


CONNECT userDistant2/userDistant2;

GRANT CREATE TABLE TO userDistant2; -(system)
ALTER USER userDistant2 DEFAULT TABLESPACE USERS;
ALTER USER userDistant2 QUOTA UNLIMITED ON USERS;


CREATE TABLE EmployeAutreVille AS
SELECT * FROM Emp WHERE ville <> 'Marrakech';


COMMIT;



--C. Au tant que system/password, supprimer la table Employe puis créer une vue VueEmployes qui contient l’ensemble des employes. (Pensez à créer les DATABASE LINK)



CONNECT system/password;


DROP TABLE Employe;

GRANT CREATE SESSION TO userDistant1;
	GRANT CREATE SESSION TO userDistant2;

	CREATE PUBLIC DATABASE LINK systemTouserDistant2 CONNECT TO userDistant2 IDENTIFIED BY userDistant2 USING 'XE';

CREATE VIEW VueEmployes AS
SELECT * FROM userDistant1.EmployeDeKech@systemTouserDistant1
UNION ALL
SELECT * FROM userDistant2.EmployeAutreVille@systemTouserDistant2;

COMMIT;














--Exercice 3 : Fragmentation Verticale
--A. En tant que userDistant1, créer le fragment EmployeFV1 contenant les colonnes num, nom et ville de la table system.Employe.



CONNECT userDistant1/userDistant1;


CREATE TABLE EmployeFV1 AS
SELECT num, nom, ville FROM Emp;


COMMIT;


--B. En tant que userDistant2, créer le fragment EmployeFV2 contenant les colonnes num, salaire de la table system.Employe.



CONNECT userDistant2/userDistant2;


CREATE TABLE EmployeFV2 AS
SELECT num, salaire FROM Emp;


COMMIT;


--C. En tant que system/password supprimer la table Employe puis créer une vue VueAllEmployes qui reconstitue la table Employe à partir des deux fragments EmployeFV1 et EmployeFV2.



CONNECT system/password;


DROP TABLE Employe;


CREATE VIEW VueAllEmployes AS
SELECT FV1.num, FV1.nom, FV1.ville, FV2.salaire
FROM userDistant1.EmployeFV1@systemTouserDistant1 FV1
JOIN userDistant2.EmployeFV2@systemTouserDistant2 FV2 ON FV1.num = FV2.num;


COMMIT;
