-- Base tables (previously created)
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name TEXT NOT NULL,
    job_title TEXT NOT NULL,
    basic_salary NUMERIC(10,2) NOT NULL,
    work_days INTEGER DEFAULT 26,
    daily_work_hours NUMERIC(4,2) DEFAULT 8.0,
    monthly_incentives NUMERIC(10,2) DEFAULT 0,
    date_added DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS advances (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    date DATE NOT NULL,
    remaining_amount NUMERIC(10,2),
    notes TEXT,
    is_paid BOOLEAN DEFAULT FALSE,
    paid_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee
        FOREIGN KEY(employee_id)
        REFERENCES employees(id)
);

-- Additional tables for comprehensive reporting

-- Incentives table for tracking employee bonuses and rewards
CREATE TABLE IF NOT EXISTS incentives (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    type VARCHAR(50) NOT NULL, -- e.g., 'PERFORMANCE', 'ATTENDANCE', 'OVERTIME'
    description TEXT,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_incentive
        FOREIGN KEY(employee_id)
        REFERENCES employees(id)
);

-- Deductions table for tracking various deductions
CREATE TABLE IF NOT EXISTS deductions (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    type VARCHAR(50) NOT NULL, -- e.g., 'ABSENCE', 'LATE', 'TAX'
    description TEXT,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_deduction
        FOREIGN KEY(employee_id)
        REFERENCES employees(id)
);

-- Monthly Reports table (enhanced version)
CREATE TABLE IF NOT EXISTS monthly_reports (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    month DATE NOT NULL,
    basic_salary NUMERIC(10,2) NOT NULL,
    total_incentives NUMERIC(10,2) DEFAULT 0,
    overtime_amount NUMERIC(10,2) DEFAULT 0,
    advances_deduction NUMERIC(10,2) DEFAULT 0,
    other_deductions NUMERIC(10,2) DEFAULT 0,
    net_salary NUMERIC(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING', -- 'PENDING', 'APPROVED', 'PAID'
    payment_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_monthly_report
        FOREIGN KEY(employee_id)
        REFERENCES employees(id)
);

-- Yearly Reports table for aggregated yearly data
CREATE TABLE IF NOT EXISTS yearly_reports (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    total_salaries NUMERIC(10,2) NOT NULL,
    total_incentives NUMERIC(10,2) NOT NULL,
    total_advances NUMERIC(10,2) NOT NULL,
    total_deductions NUMERIC(10,2) NOT NULL,
    employee_count INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Backup History table (previously created)
CREATE TABLE IF NOT EXISTS backup_history (
    id SERIAL PRIMARY KEY,
    backup_date TIMESTAMP NOT NULL,
    backup_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    notes TEXT
);

-- Dashboard Configuration table
CREATE TABLE IF NOT EXISTS dashboard_config (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    layout JSONB,
    user_preferences JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Theme Preferences table
CREATE TABLE IF NOT EXISTS theme_preferences (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    dark_mode BOOLEAN DEFAULT FALSE,
    theme_color VARCHAR(50) DEFAULT 'blue',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Leave Requests table
CREATE TABLE IF NOT EXISTS leave_requests (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    leave_type VARCHAR(50) NOT NULL,
    reason TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    approved_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_leave
        FOREIGN KEY(employee_id)
        REFERENCES employees(id)
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    priority VARCHAR(50) DEFAULT 'medium',
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_task
        FOREIGN KEY(employee_id)
        REFERENCES employees(id)
);

-- Time Entries table
CREATE TABLE IF NOT EXISTS time_entries (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    check_in TIMESTAMP NOT NULL,
    check_out TIMESTAMP,
    total_hours NUMERIC(5,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_time
        FOREIGN KEY(employee_id)
        REFERENCES employees(id)
);

-- Analytics Data table
CREATE TABLE IF NOT EXISTS analytics_data (
    id SERIAL PRIMARY KEY,
    report_type VARCHAR(50) NOT NULL,
    report_date DATE NOT NULL,
    data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create necessary indexes
CREATE INDEX IF NOT EXISTS idx_employee_code ON employees(code);
-- Ensure date_added column exists before creating index
CREATE INDEX IF NOT EXISTS idx_employee_created_at ON employees(created_at);
CREATE INDEX IF NOT EXISTS idx_advances_employee ON advances(employee_id);
CREATE INDEX IF NOT EXISTS idx_advances_date ON advances(date);
CREATE INDEX IF NOT EXISTS idx_incentives_employee ON incentives(employee_id);
CREATE INDEX IF NOT EXISTS idx_incentives_date ON incentives(date);
CREATE INDEX IF NOT EXISTS idx_deductions_employee ON deductions(employee_id);
CREATE INDEX IF NOT EXISTS idx_deductions_date ON deductions(date);
CREATE INDEX IF NOT EXISTS idx_monthly_reports_employee ON monthly_reports(employee_id);
CREATE INDEX IF NOT EXISTS idx_monthly_reports_month ON monthly_reports(month);
CREATE INDEX IF NOT EXISTS idx_yearly_reports_year ON yearly_reports(year);
CREATE INDEX IF NOT EXISTS idx_dashboard_config_user ON dashboard_config(user_id);
CREATE INDEX IF NOT EXISTS idx_theme_preferences_user ON theme_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_employee ON leave_requests(employee_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_dates ON leave_requests(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_tasks_employee ON tasks(employee_id);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_time_entries_employee ON time_entries(employee_id);
CREATE INDEX IF NOT EXISTS idx_time_entries_check_in ON time_entries(check_in);
CREATE INDEX IF NOT EXISTS idx_analytics_data_report_type ON analytics_data(report_type);
CREATE INDEX IF NOT EXISTS idx_analytics_data_report_date ON analytics_data(report_date);

-- Create trigger for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for tables with updated_at
-- First drop existing triggers if they exist
DROP TRIGGER IF EXISTS update_employees_updated_at ON employees;
CREATE TRIGGER update_employees_updated_at
    BEFORE UPDATE ON employees
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_yearly_reports_updated_at ON yearly_reports;
CREATE TRIGGER update_yearly_reports_updated_at
    BEFORE UPDATE ON yearly_reports
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
    
DROP TRIGGER IF EXISTS update_dashboard_config_updated_at ON dashboard_config;
CREATE TRIGGER update_dashboard_config_updated_at
    BEFORE UPDATE ON dashboard_config
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
    
DROP TRIGGER IF EXISTS update_theme_preferences_updated_at ON theme_preferences;
CREATE TRIGGER update_theme_preferences_updated_at
    BEFORE UPDATE ON theme_preferences
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
    
DROP TRIGGER IF EXISTS update_leave_requests_updated_at ON leave_requests;
CREATE TRIGGER update_leave_requests_updated_at
    BEFORE UPDATE ON leave_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
    
DROP TRIGGER IF EXISTS update_tasks_updated_at ON tasks;
CREATE TRIGGER update_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
    
-- Note: We already have a trigger for tasks above, so this is redundant and removed

DROP TRIGGER IF EXISTS update_time_entries_updated_at ON time_entries;
CREATE TRIGGER update_time_entries_updated_at
    BEFORE UPDATE ON time_entries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
