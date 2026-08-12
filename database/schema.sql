-- =============================================================================
-- GoTrek — schéma PostgreSQL
--
-- Le modèle de départ (Utilisateur, Touriste, fournisseurs de services,
-- Hebergement, OffreGuidage, Circuit, Reservation) a été conçu par un membre
-- de l'équipe à partir du diagramme de classes du cahier des charges.
--
-- Cette révision aligne le schéma sur ce que l'application manipule
-- réellement, sans changer le domaine :
--   * Destinations, catégories et attractions : le feed d'accueil et l'écran
--     Explore les affichent, mais rien ne les stockait.
--   * Vols et offres de voyage : l'application vend des allers-retours ;
--     aucune table ne les représentait.
--   * Équipements d'hébergement, prix, notes et avis : affichés dans l'app,
--     auparavant codés en dur dans les widgets.
--   * Favoris, moyens de paiement et paiements : nécessaires aux parcours
--     « enregistrer » et « réserver ».
--   * Hotel / AgenceVoyage / GuideTouristique avaient exactement les mêmes
--     colonnes ; ils sont fusionnés dans fournisseur_service, le type restant
--     porté par utilisateur.type_utilisateur.
--   * circuit.destinations était un TEXT[] ; remplacé par une table de liaison.
--   * Les statuts passent de VARCHAR + CHECK à des types ENUM.
--   * SET session_replication_role (réservé au superutilisateur) supprimé :
--     les DROP sont simplement ordonnés selon les dépendances.
-- =============================================================================

BEGIN;

-- --- Suppression (ordre inverse des dépendances) -----------------------------

DROP VIEW IF EXISTS vue_note_hebergement CASCADE;

DROP TABLE IF EXISTS paiement CASCADE;
DROP TABLE IF EXISTS moyen_paiement CASCADE;
DROP TABLE IF EXISTS favori CASCADE;
DROP TABLE IF EXISTS avis CASCADE;
DROP TABLE IF EXISTS reservation CASCADE;
DROP TABLE IF EXISTS circuit_destination CASCADE;
DROP TABLE IF EXISTS circuit CASCADE;
DROP TABLE IF EXISTS offre_guidage CASCADE;
DROP TABLE IF EXISTS offre_voyage CASCADE;
DROP TABLE IF EXISTS vol CASCADE;
DROP TABLE IF EXISTS hebergement_equipement CASCADE;
DROP TABLE IF EXISTS equipement CASCADE;
DROP TABLE IF EXISTS hebergement CASCADE;
DROP TABLE IF EXISTS attraction CASCADE;
DROP TABLE IF EXISTS destination_categorie CASCADE;
DROP TABLE IF EXISTS categorie CASCADE;
DROP TABLE IF EXISTS destination CASCADE;
DROP TABLE IF EXISTS fournisseur_service CASCADE;
DROP TABLE IF EXISTS touriste CASCADE;
DROP TABLE IF EXISTS utilisateur CASCADE;

DROP TYPE IF EXISTS marque_carte CASCADE;
DROP TYPE IF EXISTS statut_paiement CASCADE;
DROP TYPE IF EXISTS statut_reservation CASCADE;
DROP TYPE IF EXISTS type_utilisateur CASCADE;

-- --- Types énumérés ----------------------------------------------------------

CREATE TYPE type_utilisateur AS ENUM (
    'touriste',
    'hotel',
    'agence_voyage',
    'guide_touristique'
);

CREATE TYPE statut_reservation AS ENUM (
    'en_attente',
    'confirmee',
    'annulee',
    'terminee'
);

CREATE TYPE statut_paiement AS ENUM (
    'en_attente',
    'regle',
    'rembourse',
    'echoue'
);

CREATE TYPE marque_carte AS ENUM ('visa', 'mastercard', 'amex', 'autre');

-- --- Comptes -----------------------------------------------------------------

CREATE TABLE utilisateur (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email             VARCHAR(255) NOT NULL,
    mot_de_passe_hash VARCHAR(255) NOT NULL,
    type_utilisateur  type_utilisateur NOT NULL,
    est_actif         BOOLEAN NOT NULL DEFAULT TRUE,
    cree_le           TIMESTAMPTZ NOT NULL DEFAULT now(),
    maj_le            TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- L'unicité doit ignorer la casse : « Chiraz@… » et « chiraz@… » sont le
-- même compte.
CREATE UNIQUE INDEX idx_utilisateur_email ON utilisateur (lower(email));

CREATE TABLE touriste (
    id_utilisateur    UUID PRIMARY KEY
        REFERENCES utilisateur (id) ON DELETE CASCADE,
    nom               VARCHAR(100) NOT NULL,
    prenom            VARCHAR(100) NOT NULL,
    numero_telephone  VARCHAR(30),
    ville_depart      VARCHAR(100),
    photo_url         TEXT
);

-- Les trois anciennes tables de fournisseurs portaient les mêmes colonnes.
CREATE TABLE fournisseur_service (
    id_utilisateur  UUID PRIMARY KEY
        REFERENCES utilisateur (id) ON DELETE CASCADE,
    nom_entreprise  VARCHAR(255) NOT NULL,
    description     TEXT,
    emplacement     TEXT,
    ville           VARCHAR(100),
    pays            VARCHAR(100),
    est_verifie     BOOLEAN NOT NULL DEFAULT FALSE
);

-- --- Catalogue ---------------------------------------------------------------

CREATE TABLE destination (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            VARCHAR(50) NOT NULL UNIQUE,  -- 'new-york', 'tokyo', …
    ville           VARCHAR(100) NOT NULL,
    pays            VARCHAR(100) NOT NULL,
    code_aeroport   CHAR(3),
    resume          TEXT,
    image_url       TEXT,
    distance_km     NUMERIC(8, 1) CHECK (distance_km >= 0),
    latitude        NUMERIC(9, 6),
    longitude       NUMERIC(9, 6),
    est_publiee     BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE categorie (
    id       SMALLSERIAL PRIMARY KEY,
    code     VARCHAR(50) NOT NULL UNIQUE,  -- 'city', 'beach', 'mountains', …
    libelle  VARCHAR(100) NOT NULL
);

CREATE TABLE destination_categorie (
    id_destination UUID     NOT NULL
        REFERENCES destination (id) ON DELETE CASCADE,
    id_categorie   SMALLINT NOT NULL
        REFERENCES categorie (id) ON DELETE CASCADE,
    PRIMARY KEY (id_destination, id_categorie)
);

CREATE TABLE attraction (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_destination UUID NOT NULL
        REFERENCES destination (id) ON DELETE CASCADE,
    nom            VARCHAR(255) NOT NULL,
    quartier       VARCHAR(255),
    image_url      TEXT
);

-- --- Hébergements ------------------------------------------------------------

CREATE TABLE hebergement (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_fournisseur UUID NOT NULL
        REFERENCES fournisseur_service (id_utilisateur) ON DELETE CASCADE,
    id_destination UUID NOT NULL
        REFERENCES destination (id) ON DELETE RESTRICT,
    nom            VARCHAR(255) NOT NULL,
    quartier       VARCHAR(255),
    adresse        TEXT,
    description    TEXT,
    prix_par_nuit  NUMERIC(10, 2) NOT NULL CHECK (prix_par_nuit >= 0),
    capacite       INTEGER NOT NULL CHECK (capacite > 0),
    image_url      TEXT,
    est_disponible BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE equipement (
    id       SMALLSERIAL PRIMARY KEY,
    code     VARCHAR(50) NOT NULL UNIQUE,  -- 'wifi', 'pool', 'spa', …
    libelle  VARCHAR(100) NOT NULL
);

CREATE TABLE hebergement_equipement (
    id_hebergement UUID     NOT NULL
        REFERENCES hebergement (id) ON DELETE CASCADE,
    id_equipement  SMALLINT NOT NULL
        REFERENCES equipement (id) ON DELETE CASCADE,
    PRIMARY KEY (id_hebergement, id_equipement)
);

-- --- Vols et offres de voyage ------------------------------------------------

CREATE TABLE vol (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_vol     VARCHAR(10) NOT NULL,
    code_depart    CHAR(3) NOT NULL,
    ville_depart   VARCHAR(100) NOT NULL,
    code_arrivee   CHAR(3) NOT NULL,
    ville_arrivee  VARCHAR(100) NOT NULL,
    depart_le      TIMESTAMPTZ NOT NULL,
    arrivee_le     TIMESTAMPTZ NOT NULL,
    CONSTRAINT chk_vol_chronologie CHECK (arrivee_le > depart_le),
    CONSTRAINT chk_vol_aeroports   CHECK (code_depart <> code_arrivee)
);

-- Un aller-retour : deux vols et un prix.
CREATE TABLE offre_voyage (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_destination      UUID NOT NULL
        REFERENCES destination (id) ON DELETE CASCADE,
    id_vol_aller        UUID NOT NULL REFERENCES vol (id) ON DELETE RESTRICT,
    id_vol_retour       UUID NOT NULL REFERENCES vol (id) ON DELETE RESTRICT,
    prix_par_voyageur   NUMERIC(10, 2) NOT NULL CHECK (prix_par_voyageur >= 0),
    classe              VARCHAR(50) NOT NULL DEFAULT 'Economy',
    sieges_restants     INTEGER NOT NULL CHECK (sieges_restants >= 0),
    CONSTRAINT chk_offre_vols_distincts CHECK (id_vol_aller <> id_vol_retour)
);

-- --- Offres des guides et circuits -------------------------------------------

CREATE TABLE offre_guidage (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_fournisseur UUID NOT NULL
        REFERENCES fournisseur_service (id_utilisateur) ON DELETE CASCADE,
    id_destination UUID NOT NULL
        REFERENCES destination (id) ON DELETE RESTRICT,
    titre          VARCHAR(255) NOT NULL,
    description    TEXT,
    quartier       VARCHAR(255),
    prix           NUMERIC(10, 2) NOT NULL CHECK (prix >= 0),
    duree_minutes  INTEGER NOT NULL CHECK (duree_minutes > 0),
    debute_le      TIMESTAMPTZ,
    image_url      TEXT,
    est_disponible BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE circuit (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_fournisseur UUID NOT NULL
        REFERENCES fournisseur_service (id_utilisateur) ON DELETE CASCADE,
    nom            VARCHAR(255) NOT NULL,
    description    TEXT,
    duree_jours    INTEGER CHECK (duree_jours > 0),
    prix           NUMERIC(10, 2) NOT NULL CHECK (prix >= 0)
);

-- Remplace circuit.destinations TEXT[].
CREATE TABLE circuit_destination (
    id_circuit     UUID NOT NULL REFERENCES circuit (id) ON DELETE CASCADE,
    id_destination UUID NOT NULL
        REFERENCES destination (id) ON DELETE RESTRICT,
    ordre          SMALLINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id_circuit, id_destination)
);

-- --- Réservations ------------------------------------------------------------

CREATE TABLE reservation (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reference        VARCHAR(16) NOT NULL UNIQUE,  -- 'GT-7KQ4M2'
    id_touriste      UUID NOT NULL
        REFERENCES touriste (id_utilisateur) ON DELETE CASCADE,
    statut           statut_reservation NOT NULL DEFAULT 'en_attente',
    date_debut       TIMESTAMPTZ NOT NULL,
    date_fin         TIMESTAMPTZ NOT NULL,
    nb_voyageurs     INTEGER NOT NULL DEFAULT 1 CHECK (nb_voyageurs > 0),
    montant_total    NUMERIC(10, 2) NOT NULL CHECK (montant_total >= 0),
    cree_le          TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Arc exclusif : exactement un service réservé.
    id_hebergement   UUID REFERENCES hebergement (id) ON DELETE SET NULL,
    id_offre_voyage  UUID REFERENCES offre_voyage (id) ON DELETE SET NULL,
    id_offre_guidage UUID REFERENCES offre_guidage (id) ON DELETE SET NULL,
    id_circuit       UUID REFERENCES circuit (id) ON DELETE SET NULL,

    CONSTRAINT chk_reservation_dates CHECK (date_fin >= date_debut),
    CONSTRAINT chk_reservation_service_unique CHECK (
        (id_hebergement   IS NOT NULL)::int
      + (id_offre_voyage  IS NOT NULL)::int
      + (id_offre_guidage IS NOT NULL)::int
      + (id_circuit       IS NOT NULL)::int = 1
    )
);

-- --- Paiement ----------------------------------------------------------------

-- Seuls les quatre derniers chiffres sont conservés ; le numéro complet ne
-- doit jamais toucher la base.
CREATE TABLE moyen_paiement (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_touriste      UUID NOT NULL
        REFERENCES touriste (id_utilisateur) ON DELETE CASCADE,
    marque           marque_carte NOT NULL,
    quatre_derniers  CHAR(4) NOT NULL CHECK (quatre_derniers ~ '^[0-9]{4}$'),
    titulaire        VARCHAR(255) NOT NULL,
    mois_expiration  SMALLINT NOT NULL CHECK (mois_expiration BETWEEN 1 AND 12),
    annee_expiration SMALLINT NOT NULL CHECK (annee_expiration BETWEEN 2000 AND 2100),
    est_par_defaut   BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE paiement (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_reservation    UUID NOT NULL UNIQUE
        REFERENCES reservation (id) ON DELETE CASCADE,
    id_moyen_paiement UUID
        REFERENCES moyen_paiement (id) ON DELETE SET NULL,
    montant           NUMERIC(10, 2) NOT NULL CHECK (montant >= 0),
    frais_service     NUMERIC(10, 2) NOT NULL DEFAULT 0
        CHECK (frais_service >= 0),
    statut            statut_paiement NOT NULL DEFAULT 'en_attente',
    regle_le          TIMESTAMPTZ
);

-- --- Avis et favoris ---------------------------------------------------------

CREATE TABLE avis (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_touriste      UUID NOT NULL
        REFERENCES touriste (id_utilisateur) ON DELETE CASCADE,
    note             SMALLINT NOT NULL CHECK (note BETWEEN 1 AND 5),
    commentaire      TEXT,
    cree_le          TIMESTAMPTZ NOT NULL DEFAULT now(),

    id_hebergement   UUID REFERENCES hebergement (id) ON DELETE CASCADE,
    id_offre_guidage UUID REFERENCES offre_guidage (id) ON DELETE CASCADE,
    id_attraction    UUID REFERENCES attraction (id) ON DELETE CASCADE,
    id_destination   UUID REFERENCES destination (id) ON DELETE CASCADE,

    CONSTRAINT chk_avis_cible_unique CHECK (
        (id_hebergement   IS NOT NULL)::int
      + (id_offre_guidage IS NOT NULL)::int
      + (id_attraction    IS NOT NULL)::int
      + (id_destination   IS NOT NULL)::int = 1
    )
);

CREATE TABLE favori (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_touriste      UUID NOT NULL
        REFERENCES touriste (id_utilisateur) ON DELETE CASCADE,
    cree_le          TIMESTAMPTZ NOT NULL DEFAULT now(),

    id_destination   UUID REFERENCES destination (id) ON DELETE CASCADE,
    id_hebergement   UUID REFERENCES hebergement (id) ON DELETE CASCADE,
    id_offre_guidage UUID REFERENCES offre_guidage (id) ON DELETE CASCADE,
    id_attraction    UUID REFERENCES attraction (id) ON DELETE CASCADE,

    CONSTRAINT chk_favori_cible_unique CHECK (
        (id_destination   IS NOT NULL)::int
      + (id_hebergement   IS NOT NULL)::int
      + (id_offre_guidage IS NOT NULL)::int
      + (id_attraction    IS NOT NULL)::int = 1
    )
);

-- Un même élément ne peut être mis en favori qu'une fois par touriste.
-- Des index partiels sont nécessaires : un UNIQUE ordinaire laisserait passer
-- les doublons, NULL n'étant jamais égal à NULL.
CREATE UNIQUE INDEX idx_favori_destination
    ON favori (id_touriste, id_destination)   WHERE id_destination   IS NOT NULL;
CREATE UNIQUE INDEX idx_favori_hebergement
    ON favori (id_touriste, id_hebergement)   WHERE id_hebergement   IS NOT NULL;
CREATE UNIQUE INDEX idx_favori_offre_guidage
    ON favori (id_touriste, id_offre_guidage) WHERE id_offre_guidage IS NOT NULL;
CREATE UNIQUE INDEX idx_favori_attraction
    ON favori (id_touriste, id_attraction)    WHERE id_attraction    IS NOT NULL;

-- --- Index -------------------------------------------------------------------

CREATE INDEX idx_hebergement_destination  ON hebergement (id_destination);
CREATE INDEX idx_hebergement_fournisseur  ON hebergement (id_fournisseur);
CREATE INDEX idx_hebergement_prix         ON hebergement (prix_par_nuit);
CREATE INDEX idx_attraction_destination   ON attraction (id_destination);
CREATE INDEX idx_offre_guidage_destination ON offre_guidage (id_destination);
CREATE INDEX idx_offre_voyage_destination ON offre_voyage (id_destination);
CREATE INDEX idx_vol_depart               ON vol (depart_le);
CREATE INDEX idx_reservation_touriste     ON reservation (id_touriste, cree_le DESC);
CREATE INDEX idx_reservation_statut       ON reservation (statut);
CREATE INDEX idx_favori_touriste          ON favori (id_touriste);
CREATE INDEX idx_avis_hebergement         ON avis (id_hebergement)
    WHERE id_hebergement IS NOT NULL;

-- --- Vues --------------------------------------------------------------------

-- Les notes affichées dans l'application sont dérivées des avis, elles ne
-- sont pas stockées sur l'hébergement.
CREATE VIEW vue_note_hebergement AS
SELECT
    h.id                                   AS id_hebergement,
    COUNT(a.id)                            AS nombre_avis,
    ROUND(AVG(a.note)::numeric, 1)         AS note_moyenne
FROM hebergement h
LEFT JOIN avis a ON a.id_hebergement = h.id
GROUP BY h.id;

-- --- Données de référence ----------------------------------------------------

INSERT INTO categorie (code, libelle) VALUES
    ('city',      'Ville'),
    ('mountains', 'Montagnes'),
    ('beach',     'Plage'),
    ('lakes',     'Lacs'),
    ('camp',      'Camping'),
    ('forest',    'Forêt');

INSERT INTO equipement (code, libelle) VALUES
    ('wifi',             'Wi-Fi gratuit'),
    ('pool',             'Piscine'),
    ('breakfast',        'Petit-déjeuner'),
    ('gym',              'Salle de sport'),
    ('spa',              'Spa'),
    ('restaurant',       'Restaurant'),
    ('bar',              'Bar'),
    ('room_service',     'Service en chambre'),
    ('concierge',        'Conciergerie'),
    ('parking',          'Parking'),
    ('air_conditioning', 'Climatisation'),
    ('pet_friendly',     'Animaux acceptés');

COMMIT;
