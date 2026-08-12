-- Désactiver les contraintes de clés étrangères temporairement pour faciliter la création et la suppression
SET session_replication_role = 'replica';

-- Supprimer les tables existantes si elles existent, dans l'ordre inverse des dépendances
DROP TABLE IF EXISTS Reservation CASCADE;
DROP TABLE IF EXISTS Hebergement CASCADE;
DROP TABLE IF EXISTS OffreGuidage CASCADE;
DROP TABLE IF EXISTS Circuit CASCADE;
DROP TABLE IF EXISTS Touriste CASCADE;
DROP TABLE IF EXISTS Hotel CASCADE;
DROP TABLE IF EXISTS AgenceVoyage CASCADE;
DROP TABLE IF EXISTS GuideTouristique CASCADE;
DROP TABLE IF EXISTS Utilisateur CASCADE;

-- Création de la table Utilisateur (classe de base)
CREATE TABLE Utilisateur (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- Identifiant unique pour chaque utilisateur
    email VARCHAR(255) NOT NULL UNIQUE, -- Adresse email de l'utilisateur, doit être unique
    mot_de_passe VARCHAR(255) NOT NULL, -- Mot de passe haché de l'utilisateur
    type_utilisateur VARCHAR(50) NOT NULL, -- Type de l'utilisateur (touriste, hotel, agence_voyage, guide_touristique)
    CONSTRAINT chk_type_utilisateur CHECK (type_utilisateur IN ('touriste', 'hotel', 'agence_voyage', 'guide_touristique'))
);

-- Création de la table Touriste
CREATE TABLE Touriste (
    id_utilisateur UUID PRIMARY KEY, -- Clé primaire et clé étrangère vers Utilisateur
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    numero_telephone VARCHAR(50),
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id) ON DELETE CASCADE
);

-- Création des tables pour les Fournisseurs de Services
-- Note: Les attributs communs de FournisseurService sont directement inclus dans ces tables
-- car FournisseurService était une classe abstraite dans le diagramme.

CREATE TABLE Hotel (
    id_utilisateur UUID PRIMARY KEY, -- Clé primaire et clé étrangère vers Utilisateur
    emplacement TEXT,
    nom_entreprise VARCHAR(255) NOT NULL,
    pays VARCHAR(100),
    ville VARCHAR(100),
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id) ON DELETE CASCADE
);

CREATE TABLE AgenceVoyage (
    id_utilisateur UUID PRIMARY KEY, -- Clé primaire et clé étrangère vers Utilisateur
    emplacement TEXT,
    nom_entreprise VARCHAR(255) NOT NULL,
    pays VARCHAR(100),
    ville VARCHAR(100),
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id) ON DELETE CASCADE
);

CREATE TABLE GuideTouristique (
    id_utilisateur UUID PRIMARY KEY, -- Clé primaire et clé étrangère vers Utilisateur
    emplacement TEXT,
    nom_entreprise VARCHAR(255) NOT NULL,
    pays VARCHAR(100),
    ville VARCHAR(100),
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id) ON DELETE CASCADE
);

-- Création de la table Hebergement
CREATE TABLE Hebergement (
    id_hebergement UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_hotel UUID NOT NULL, -- Clé étrangère vers l'hôtel qui gère cet hébergement
    nom VARCHAR(255) NOT NULL,
    adresse TEXT,
    description TEXT,
    prix_par_nuit NUMERIC(10, 2) NOT NULL,
    capacite INTEGER NOT NULL,
    est_disponible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_hotel) REFERENCES Hotel(id_utilisateur) ON DELETE CASCADE
);

-- Création de la table OffreGuidage
CREATE TABLE OffreGuidage (
    id_offre UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_guide_touristique UUID NOT NULL, -- Clé étrangère vers le guide touristique qui propose cette offre
    titre VARCHAR(255) NOT NULL,
    description TEXT,
    prix NUMERIC(10, 2) NOT NULL,
    duree VARCHAR(100), -- Ex: "2 jours", "4 heures"
    date_disponible DATE,
    est_disponible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_guide_touristique) REFERENCES GuideTouristique(id_utilisateur) ON DELETE CASCADE
);

-- Création de la table Circuit
CREATE TABLE Circuit (
    id_circuit UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_agence_voyage UUID NOT NULL, -- Clé étrangère vers l'agence de voyage qui crée ce circuit
    nom VARCHAR(255) NOT NULL,
    description TEXT,
    duree VARCHAR(100),
    prix NUMERIC(10, 2) NOT NULL,
    destinations TEXT[], -- Tableau de chaînes de caractères pour les destinations
    FOREIGN KEY (id_agence_voyage) REFERENCES AgenceVoyage(id_utilisateur) ON DELETE CASCADE
);

-- Création de la table Reservation
CREATE TABLE Reservation (
    id_reservation UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_touriste UUID NOT NULL, -- Clé étrangère vers le touriste qui effectue la réservation
    date_creation TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    statut VARCHAR(50) NOT NULL, -- Ex: 'confirmée', 'annulée', 'en attente'
    montant_total NUMERIC(10, 2) NOT NULL,
    
    -- Clés étrangères pour le service réservé (un seul doit être non NULL)
    id_hebergement UUID,
    id_offre_guidage UUID,
    id_circuit UUID,

    FOREIGN KEY (id_touriste) REFERENCES Touriste(id_utilisateur) ON DELETE CASCADE,
    FOREIGN KEY (id_hebergement) REFERENCES Hebergement(id_hebergement) ON DELETE SET NULL,
    FOREIGN KEY (id_offre_guidage) REFERENCES OffreGuidage(id_offre) ON DELETE SET NULL,
    FOREIGN KEY (id_circuit) REFERENCES Circuit(id_circuit) ON DELETE SET NULL,

    -- Contrainte pour s'assurer qu'une seule des clés étrangères de service est non NULL
    CONSTRAINT chk_seul_service_reserve CHECK (
        (id_hebergement IS NOT NULL AND id_offre_guidage IS NULL AND id_circuit IS NULL) OR
        (id_hebergement IS NULL AND id_offre_guidage IS NOT NULL AND id_circuit IS NULL) OR
        (id_hebergement IS NULL AND id_offre_guidage IS NULL AND id_circuit IS NOT NULL)
    ),
    CONSTRAINT chk_statut_reservation CHECK (statut IN ('confirmée', 'annulée', 'en attente', 'terminée'))
);

-- Réactiver les contraintes de clés étrangères
SET session_replication_role = 'origin';

-- Index pour améliorer les performances des requêtes fréquentes
CREATE INDEX idx_utilisateur_email ON Utilisateur(email);
CREATE INDEX idx_reservation_touriste ON Reservation(id_touriste);
CREATE INDEX idx_hebergement_hotel ON Hebergement(id_hotel);
CREATE INDEX idx_offre_guidage_guide ON OffreGuidage(id_guide_touristique);
CREATE INDEX idx_circuit_agence ON Circuit(id_agence_voyage);