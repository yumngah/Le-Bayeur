sql
-- ============================================
-- STORED PROCEDURES & FUNCTIONS
-- ============================================

-- 1. Fonction pour calculer les revenus d'un propriétaire
CREATE OR REPLACE FUNCTION get_landlord_monthly_revenue(landlord_uuid UUID, month_date DATE)
RETURNS DECIMAL AS $$
DECLARE
  total_revenue DECIMAL;
BEGIN
  SELECT COALESCE(SUM(amount), 0)
  INTO total_revenue
  FROM payments
  WHERE landlord_id = landlord_uuid
    AND EXTRACT(MONTH FROM paid_at) = EXTRACT(MONTH FROM month_date)
    AND EXTRACT(YEAR FROM paid_at) = EXTRACT(YEAR FROM month_date)
    AND status = 'COMPLETED';
  
  RETURN total_revenue;
END;
$$ LANGUAGE plpgsql;

-- 2. Fonction pour obtenir les loyers en retard
CREATE OR REPLACE FUNCTION get_overdue_rents(tenant_uuid UUID)
RETURNS TABLE (
  lease_id UUID,
  property_name VARCHAR,
  amount DECIMAL,
  due_date DATE,
  days_overdue INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    p.name,
    l.monthly_rent,
    pa.period_end,
    EXTRACT(DAY FROM CURRENT_DATE - pa.period_end)::INTEGER
  FROM leases l
  JOIN properties p ON l.property_id = p.id
  JOIN payments pa ON l.id = pa.lease_id
  WHERE l.tenant_id = tenant_uuid
    AND pa.status = 'PENDING'
    AND pa.period_end < CURRENT_DATE
  ORDER BY pa.period_end ASC;
END;
$$ LANGUAGE plpgsql;

-- 3. Fonction pour renouveler les maintenances récurrentes
CREATE OR REPLACE FUNCTION renew_recurring_maintenance()
RETURNS TABLE (maintenance_id UUID, next_date DATE) AS $$
DECLARE
  freq VARCHAR;
  new_date DATE;
BEGIN
  FOR maintenance_id, freq IN
    SELECT m.id, m.frequency FROM maintenances m WHERE status = 'SCHEDULED' AND next_scheduled_date <= CURRENT_DATE
  LOOP
    new_date := CASE 
      WHEN freq = 'WEEKLY' THEN CURRENT_DATE + INTERVAL '7 days'
      WHEN freq = 'MONTHLY' THEN CURRENT_DATE + INTERVAL '1 month'
      WHEN freq = 'YEARLY' THEN CURRENT_DATE + INTERVAL '1 year'
      ELSE NULL
    END;
    
    IF new_date IS NOT NULL THEN
      UPDATE maintenances SET next_scheduled_date = new_date WHERE id = maintenance_id;
      RETURN QUERY SELECT maintenance_id, new_date;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;