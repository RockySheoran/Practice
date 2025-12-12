-- ===== CAMPAIGNS TABLE =====
CREATE TABLE campaigns (
    campaign_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(50) DEFAULT 'ACTIVE', -- ACTIVE, INACTIVE, COMPLETED, CANCELLED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_campaigns_status ON campaigns(status);

-- ===== CAMPAIGN_TARGETS TABLE =====
CREATE TABLE campaign_targets (
    target_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    donor_segment VARCHAR(255), -- e.g., "O+ Blood Type", "Regular Donors", etc.
    target_value INTEGER NOT NULL,
    achieved_value INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_campaign_targets_campaign_id ON campaign_targets(campaign_id);

-- ===== CAMPAIGN_SCHEDULES TABLE =====
CREATE TABLE campaign_schedules (
    schedule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    scheduled_date TIMESTAMP WITH TIME ZONE NOT NULL,
    venue VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_campaign_schedules_campaign_id ON campaign_schedules(campaign_id);

-- ===== MARKETING_ASSETS TABLE =====
CREATE TABLE marketing_assets (
    asset_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    asset_type VARCHAR(50), -- POSTER, SOCIAL_MEDIA, FLYER, EMAIL_TEMPLATE, SMS_TEMPLATE
    content_url VARCHAR(500),
    title VARCHAR(255),
    description TEXT,
    format VARCHAR(50), -- PNG, JPEG, PDF, HTML, etc.
    language VARCHAR(10) DEFAULT 'EN',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255)
);

CREATE INDEX idx_marketing_assets_campaign_id ON marketing_assets(campaign_id);

-- ===== CAMPAIGN_COMMUNICATIONS TABLE =====
CREATE TABLE campaign_communications (
    communication_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    communication_type VARCHAR(100), -- EMAIL_CAMPAIGN, SMS_BLAST, PUSH_NOTIFICATION, SOCIAL_POST
    recipient_list TEXT[], -- array of donor_ids or segments
    subject VARCHAR(255),
    content TEXT,
    sent_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) DEFAULT 'DRAFT', -- DRAFT, SCHEDULED, SENT, FAILED
    open_rate DECIMAL(5, 2),
    click_rate DECIMAL(5, 2),
    response_rate DECIMAL(5, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_campaign_communications_campaign_id ON campaign_communications(campaign_id);
CREATE INDEX idx_campaign_communications_status ON campaign_communications(status);

-- ===== CAMPAIGN_ANALYTICS TABLE =====
CREATE TABLE campaign_analytics (
    analytics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    total_registrations INTEGER DEFAULT 0,
    total_donors_showed_up INTEGER DEFAULT 0,
    no_show_count INTEGER DEFAULT 0,
    total_units_collected INTEGER DEFAULT 0,
    average_hemoglobin DECIMAL(5, 2),
    blood_type_breakdown JSONB DEFAULT '{}'::jsonb,
    volunteer_satisfaction_score DECIMAL(3, 2),
    donor_satisfaction_score DECIMAL(3, 2),
    cost_per_unit DECIMAL(10, 2),
    success_rate_percentage DECIMAL(5, 2),
    repeat_donor_count INTEGER DEFAULT 0,
    new_donor_count INTEGER DEFAULT 0,
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_campaign_analytics_campaign_id ON campaign_analytics(campaign_id);

-- ===== CAMPAIGN_EXPENSES TABLE =====
CREATE TABLE campaign_expenses (
    expense_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    expense_category VARCHAR(100), -- VENUE, EQUIPMENT, SUPPLIES, TRANSPORT, STAFF, MARKETING
    amount DECIMAL(12, 2) NOT NULL,
    description TEXT,
    vendor_name VARCHAR(255),
    invoice_number VARCHAR(100),
    payment_status VARCHAR(50) DEFAULT 'PENDING', -- PENDING, PAID, CANCELLED
    paid_date DATE,
    recorded_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_campaign_expenses_campaign_id ON campaign_expenses(campaign_id);
CREATE INDEX idx_campaign_expenses_expense_category ON campaign_expenses(expense_category);

-- ===== CAMPAIGN_FEEDBACK TABLE =====
CREATE TABLE campaign_feedback (
    feedback_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    donor_id VARCHAR(255),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback_text TEXT,
    categories_rated JSONB DEFAULT '{}'::jsonb,
    would_donate_again BOOLEAN,
    submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_campaign_feedback_campaign_id ON campaign_feedback(campaign_id);
CREATE INDEX idx_campaign_feedback_donor_id ON campaign_feedback(donor_id);