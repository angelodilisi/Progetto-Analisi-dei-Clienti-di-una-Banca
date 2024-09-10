SET GLOBAL connect_timeout = 600;
SET GLOBAL wait_timeout = 600;
SET GLOBAL interactive_timeout = 600;


CREATE TEMPORARY TABLE eta AS 
SELECT DISTINCT
    cliente.id_cliente,
    cliente.nome,
    cliente.cognome,
    YEAR(CURRENT_DATE) - YEAR(cliente.data_nascita) - (DATE_FORMAT(CURRENT_DATE, '%m%d') < DATE_FORMAT(cliente.data_nascita, '%m%d')) AS eta
FROM
    banca.cliente

SELECT * FROM ETA
----------------------------------------------
CREATE TEMPORARY TABLE transazioni_uscita AS
SELECT
	cliente.id_cliente,
	COUNT(CASE WHEN transazioni.id_tipo_trans >= '3' THEN transazioni.id_conto END) AS transazioni_uscita
FROM
    banca.cliente
LEFT JOIN
    banca.conto ON cliente.id_cliente = conto.id_cliente
LEFT JOIN
    banca.transazioni ON conto.id_conto = transazioni.id_conto
GROUP BY
    cliente.id_cliente;
    

-------------------------------------------------

CREATE TEMPORARY TABLE transazioni_entrata AS
SELECT
	cliente.id_cliente,
	COUNT(CASE WHEN transazioni.id_tipo_trans <='2' THEN transazioni.id_conto END) AS transazioni_entrata
FROM
    banca.cliente
LEFT JOIN
    banca.conto ON cliente.id_cliente = conto.id_cliente
LEFT JOIN
    banca.transazioni ON conto.id_conto = transazioni.id_conto
GROUP BY
    cliente.id_cliente;
    

--------------------------------------------------

CREATE TEMPORARY TABLE importo_uscita AS
SELECT
    cliente.id_cliente,
    SUM(CASE WHEN transazioni.id_tipo_trans >= '3' THEN transazioni.importo ELSE 0 END) AS importo_uscita
FROM
    banca.cliente
LEFT JOIN
    banca.conto ON cliente.id_cliente = conto.id_cliente
LEFT JOIN
    banca.transazioni ON conto.id_conto = transazioni.id_conto
GROUP BY
    cliente.id_cliente;
    


---------------------------------------------------

CREATE TEMPORARY TABLE importo_entrata AS
SELECT
    cliente.id_cliente,
    SUM(CASE WHEN transazioni.id_tipo_trans <= '2' THEN transazioni.importo ELSE 0 END) AS importo_entrata
FROM
    banca.cliente
LEFT JOIN
    banca.conto ON cliente.id_cliente = conto.id_cliente
LEFT JOIN
    banca.transazioni ON conto.id_conto = transazioni.id_conto
GROUP BY
    cliente.id_cliente;
    


--------------------------------------------------
CREATE TEMPORARY TABLE numero_conti AS
SELECT
	cliente.id_cliente,
    COUNT(DISTINCT conto.id_conto) AS numero_conti
FROM
    banca.cliente
LEFT JOIN
    banca.conto ON cliente.id_cliente = conto.id_cliente
GROUP BY
    cliente.id_cliente;
    

-----------------------------------------------------------
CREATE TEMPORARY TABLE tipo_conti AS
SELECT
	cliente.id_cliente,
	COUNT(DISTINCT CASE WHEN conto.id_tipo_conto = '0' THEN conto.id_conto END) AS conto_base,
    COUNT(DISTINCT CASE WHEN conto.id_tipo_conto = '1' THEN conto.id_conto END) AS conto_business,
    COUNT(DISTINCT CASE WHEN conto.id_tipo_conto = '2' THEN conto.id_conto END) AS conto_privati,
    COUNT(DISTINCT CASE WHEN conto.id_tipo_conto = '3' THEN conto.id_conto END) AS conto_famiglie
FROM
    banca.cliente
LEFT JOIN
    banca.conto ON cliente.id_cliente = conto.id_cliente
GROUP BY
    cliente.id_cliente;
    

-------------------------------------------------------------
CREATE TEMPORARY TABLE  transazioni_entrata_per_tipologia AS
SELECT
    cliente.id_cliente,
	COUNT(CASE WHEN transazioni.id_tipo_trans = '0' THEN transazioni.id_conto END) AS transazioni_Stipendio,
    COUNT(CASE WHEN transazioni.id_tipo_trans = '1' THEN transazioni.id_conto END) AS transazioni_Pensione,
    COUNT(CASE WHEN transazioni.id_tipo_trans = '2' THEN transazioni.id_conto END) AS transazioni_Dividendi
   
FROM
    banca.cliente
LEFT JOIN
    banca.conto ON cliente.id_cliente = conto.id_cliente
LEFT JOIN
    banca.transazioni ON conto.id_conto = transazioni.id_conto
GROUP BY
    cliente.id_cliente;



-------------------------------------------------------------
CREATE TEMPORARY TABLE  transazioni_uscita_per_tipologia AS
SELECT
    cliente.id_cliente,
    COUNT(CASE WHEN transazioni.id_tipo_trans = '3' THEN transazioni.id_conto END) AS transazioni_Acquisti_Amazon,
    COUNT(CASE WHEN transazioni.id_tipo_trans = '4' THEN transazioni.id_conto END) AS transazioni_Rata_Mutuo,
    COUNT(CASE WHEN transazioni.id_tipo_trans = '5' THEN transazioni.id_conto END) AS transazioni_Hotel,
    COUNT(CASE WHEN transazioni.id_tipo_trans = '6' THEN transazioni.id_conto END) AS transazioni_Biglietto_Aereo,
    COUNT(CASE WHEN transazioni.id_tipo_trans = '7' THEN transazioni.id_conto END) AS transazioni_Supermercato
   
FROM
    banca.cliente
LEFT JOIN
    banca.conto ON cliente.id_cliente = conto.id_cliente
LEFT JOIN
    banca.transazioni ON conto.id_conto = transazioni.id_conto
GROUP BY
    cliente.id_cliente;


---------------------------------------------------------

CREATE TEMPORARY TABLE Importo_uscita_tipologia_di_conto AS
SELECT
    cliente.id_cliente,
    SUM(transazioni.importo) AS importo_uscita,
    SUM(CASE WHEN tipo_conto.id_tipo_conto = 0 THEN transazioni.importo ELSE 0 END) AS importo_uscita_conto_base,
    SUM(CASE WHEN tipo_conto.id_tipo_conto = 1 THEN transazioni.importo ELSE 0 END) AS importo_uscita_conto_business,
    SUM(CASE WHEN tipo_conto.id_tipo_conto = 2 THEN transazioni.importo ELSE 0 END) AS importo_uscita_conto_privati,
    SUM(CASE WHEN tipo_conto.id_tipo_conto = 3 THEN transazioni.importo ELSE 0 END) AS importo_uscita_conto_famiglie
FROM
    cliente
    INNER JOIN conto ON cliente.id_cliente = conto.id_cliente
    INNER JOIN transazioni ON conto.id_conto = transazioni.id_conto
    INNER JOIN tipo_conto ON conto.id_tipo_conto = tipo_conto.id_tipo_conto
    INNER JOIN tipo_transazione ON transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
WHERE
    tipo_transazione.segno = '-'
GROUP BY
    cliente.id_cliente;

-----------------------------------------------------------------------

CREATE TEMPORARY TABLE Importo_entrata_tipologia_di_conto AS
SELECT
    cliente.id_cliente,
    SUM(transazioni.importo) AS importo_entrata,
    SUM(CASE WHEN tipo_conto.id_tipo_conto = 0 THEN transazioni.importo ELSE 0 END) AS importo_entrata_conto_base,
    SUM(CASE WHEN tipo_conto.id_tipo_conto = 1 THEN transazioni.importo ELSE 0 END) AS importo_entrata_conto_business,
    SUM(CASE WHEN tipo_conto.id_tipo_conto = 2 THEN transazioni.importo ELSE 0 END) AS importo_entrata_conto_privati,
    SUM(CASE WHEN tipo_conto.id_tipo_conto = 3 THEN transazioni.importo ELSE 0 END) AS importo_entrata_conto_famiglie
FROM
    cliente
    INNER JOIN conto ON cliente.id_cliente = conto.id_cliente
    INNER JOIN transazioni ON conto.id_conto = transazioni.id_conto
    INNER JOIN tipo_conto ON conto.id_tipo_conto = tipo_conto.id_tipo_conto
    INNER JOIN tipo_transazione ON transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
WHERE
    tipo_transazione.segno = '+'
GROUP BY
    cliente.id_cliente;


-------------------------------------------------------------------------------
CREATE TEMPORARY TABLE Analisi_dei_Clienti_di_una_Banca AS
SELECT
    eta.id_cliente,
    eta.nome,
    eta.cognome,
    eta.eta,
    transazioni_uscita.transazioni_uscita,
    transazioni_entrata.transazioni_entrata,
    importo_uscita.importo_uscita,
    importo_entrata.importo_entrata,
    numero_conti.numero_conti,
    tipo_conti.conto_base,
    tipo_conti.conto_business,
    tipo_conti.conto_privati,
    tipo_conti.conto_famiglie,
    transazioni_entrata_per_tipologia.transazioni_Stipendio,
    transazioni_entrata_per_tipologia.transazioni_Pensione,
    transazioni_entrata_per_tipologia.transazioni_Dividendi,
    transazioni_uscita_per_tipologia.transazioni_Acquisti_Amazon,
    transazioni_uscita_per_tipologia.transazioni_Rata_Mutuo,
    transazioni_uscita_per_tipologia.transazioni_Hotel,
    transazioni_uscita_per_tipologia.transazioni_Biglietto_Aereo,
    transazioni_uscita_per_tipologia.transazioni_Supermercato,
    Importo_uscita_tipologia_di_conto.importo_uscita_conto_base,
    Importo_uscita_tipologia_di_conto.importo_uscita_conto_business,
    Importo_uscita_tipologia_di_conto.importo_uscita_conto_privati,
    Importo_uscita_tipologia_di_conto.importo_uscita_conto_famiglie,
    Importo_entrata_tipologia_di_conto.importo_entrata_conto_base,
    Importo_entrata_tipologia_di_conto.importo_entrata_conto_business,
    Importo_entrata_tipologia_di_conto.importo_entrata_conto_privati,
    Importo_entrata_tipologia_di_conto.importo_entrata_conto_famiglie
FROM
    eta
LEFT JOIN
    transazioni_uscita ON eta.id_cliente = transazioni_uscita.id_cliente
LEFT JOIN
    transazioni_entrata ON eta.id_cliente = transazioni_entrata.id_cliente
LEFT JOIN
    importo_uscita ON eta.id_cliente = importo_uscita.id_cliente
LEFT JOIN
    importo_entrata ON eta.id_cliente = importo_entrata.id_cliente
LEFT JOIN
    numero_conti ON eta.id_cliente = numero_conti.id_cliente
LEFT JOIN
    tipo_conti ON eta.id_cliente = tipo_conti.id_cliente
LEFT JOIN
    transazioni_entrata_per_tipologia ON eta.id_cliente = transazioni_entrata_per_tipologia.id_cliente
LEFT JOIN
    transazioni_uscita_per_tipologia ON eta.id_cliente = transazioni_uscita_per_tipologia.id_cliente
LEFT JOIN
    Importo_uscita_tipologia_di_conto ON eta.id_cliente = Importo_uscita_tipologia_di_conto.id_cliente
LEFT JOIN
    Importo_entrata_tipologia_di_conto ON eta.id_cliente = Importo_entrata_tipologia_di_conto.id_cliente;

SELECT*FROM Analisi_dei_Clienti_di_una_Banca