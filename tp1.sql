
DROP TABLE Employe ;
CREATE TABLE Employe
(num NUMBER(10) PRIMARY KEY,
nom VARCHAR2(20),
ville VARCHAR2(25),
salaire NUMBER(6,2)) ;



INSERT INTO Employe VALUES (1, 'E1', 'Marrakech', 2000);
INSERT INTO Employe VALUES (2, 'E2', 'Rabat', 9000);
INSERT INTO Employe VALUES (3, 'E3', 'Agadir', 1000);
INSERT INTO Employe VALUES (4, 'E4', 'Marrakech', 5000);
SELECT * FROM Employe;

commit;


CREATE USER userDistant1 IDENTIFIED BY userDistant1;


GRANT CREATE SESSION TO userDistant1


SELECT * FROM Employe ;
SELECT * FROM system.Employe ;

--e. Entant que userDistant1, tenter de créer un lien de base de données publique vers la base
--XE en utilisant le compte system/password

CREATE PUBLIC DATABASE LINK userDistant1Tosystem CONNECT TO system IDENTIFIED BY password USING 'XE';

	CREATE DATABASE LINK userDistant1Tosystem CONNECT system/password@localhost:1521/XE;

	CONNECT system/password@localhost:1521/Employe;


--f. Donner à l’utilisateur userDistant1 le privilège system CREATE PUBLIC DATABASE LINK,
répéterlaQe.

GRANT CREATE PUBLIC DATABASE LINK TO userDistant1;

--g. Maintenant, en tant que userDistant1 afficher la table system.Employe.

SELECT * FROM system.Employe@userDistant1Tosystem;

--Exercice 4 : SYNONYM
--En tant que userDistant1, tenter de créer un synonyme Emp de la table system.Employe. Corriger
--le problème et réessayer.

GRANT CREATE SYNONYM TO userDistant1; --(par system)
CREATE SYNONYM Emp FOR system.Employe@userDistant1Tosystem;

--Afficher la table system.Employe en utilisant son synonyme Emp.

SELECT * FROM Emp ;