--sql
-- ============================================
-- PERFORMANCE INDICES - BAYEURS
-- ============================================

-- Recherche rapide de propriétés par localisation
CREATE INDEX IF NOT EXISTS idx_properties_location_type 
ON properties(location, type) WHERE deleted_at IS NULL;

-- Recherche de propriétés par prix
CREATE INDEX IF NOT EXISTS idx_properties_price_range 
ON properties(rent_price, sale_price) WHERE status IN ('FOR_RENT', 'FOR_SALE');

-- Recherche de contrats actifs
CREATE INDEX IF NOT EXISTS idx_leases_active 
ON leases(status) WHERE status = 'ACTIVE';

-- Recherche rapide des paiements dus
CREATE INDEX IF NOT EXISTS idx_payments_due 
ON payments(period_end, status) WHERE status = 'PENDING';

-- Chat non lus
CREATE INDEX IF NOT EXISTS idx_messages_unread_by_receiver 
ON messages(receiver_id, read_at) WHERE read_at IS NULL;

-- Commentaires non supprimés
CREATE INDEX IF NOT EXISTS idx_comments_active 
ON comments(property_id, created_at DESC) WHERE deleted_at IS NULL;

-- Techniciens disponibles
CREATE INDEX IF NOT EXISTS idx_technicians_available_by_specialty 
ON technicians(specialty, is_available) WHERE is_available = TRUE;

-- Maintenance planifiée
CREATE INDEX IF NOT EXISTS idx_maintenances_scheduled 
ON maintenances(next_scheduled_date) WHERE status = 'SCHEDULED';

-- Demandes de maintenance urgentes
CREATE INDEX IF NOT EXISTS idx_maintenance_requests_urgent 
ON maintenance_requests(urgency) WHERE urgency = 'URGENT' AND status = 'PENDING';

-- Bills à payer
CREATE INDEX IF NOT EXISTS idx_bills_overdue 
ON bills(renewal_date, status) WHERE status IN ('PENDING', 'OVERDUE');