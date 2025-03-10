const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const db = require('./js/supabase');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.static('.'));

// API Routes

// Employees
app.get('/api/employees', async (req, res) => {
    try {
        const employees = await db.getAllEmployees();
        res.json(employees);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/employees/:code', async (req, res) => {
    try {
        const employee = await db.getEmployeeByCode(req.params.code);
        if (!employee) {
            return res.status(404).json({ error: 'Employee not found' });
        }
        res.json(employee);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/employees', async (req, res) => {
    try {
        const employee = await db.createEmployee(req.body);
        res.status(201).json(employee);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Advances
app.get('/api/advances/:employeeId', async (req, res) => {
    try {
        const advances = await db.getAdvancesByEmployee(req.params.employeeId);
        res.json(advances);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/advances', async (req, res) => {
    try {
        const advance = await db.createAdvance(req.body);
        res.status(201).json(advance);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Salary Reports
app.get('/api/salary-reports/:employeeId', async (req, res) => {
    try {
        const reports = await db.getSalaryReports(req.params.employeeId);
        res.json(reports);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/salary-reports', async (req, res) => {
    try {
        const report = await db.createSalaryReport(req.body);
        res.status(201).json(report);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Backup History
app.post('/api/backup-history', async (req, res) => {
    try {
        const backup = await db.recordBackup(req.body);
        res.status(201).json(backup);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Time Entries
app.get('/api/time-entries/:employeeId', async (req, res) => {
    try {
        const startDate = req.query.startDate || null;
        const endDate = req.query.endDate || null;
        const entries = await db.getTimeEntries(req.params.employeeId, startDate, endDate);
        res.json(entries);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/time-entries', async (req, res) => {
    try {
        // If both check-in and check-out are provided
        if (req.body.checkIn && req.body.checkOut) {
            // Create a complete time entry
            const entry = {
                employee_id: req.body.employeeId,
                check_in: req.body.checkIn,
                check_out: req.body.checkOut,
                total_hours: req.body.totalHours,
                notes: req.body.notes
            };
            
            const { data, error } = await db.supabase
                .from('time_entries')
                .insert([entry])
                .select()
                .single();
                
            if (error) throw error;
            res.status(201).json(data);
        } else if (req.body.checkIn) {
            // Only check-in provided
            const entry = await db.createCheckIn(req.body.employeeId, req.body.notes);
            res.status(201).json(entry);
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put('/api/time-entries/:id/checkout', async (req, res) => {
    try {
        const entry = await db.updateCheckOut(req.params.id);
        res.json(entry);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/time-entries/:id', async (req, res) => {
    try {
        const { error } = await db.supabase
            .from('time_entries')
            .delete()
            .eq('id', req.params.id);
        
        if (error) throw error;
        res.status(200).json({ message: 'Time entry deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Tasks
app.get('/api/tasks/:employeeId', async (req, res) => {
    try {
        const tasks = await db.getTasks(req.params.employeeId);
        res.json(tasks);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/tasks', async (req, res) => {
    try {
        const task = await db.createTask(req.body);
        res.status(201).json(task);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put('/api/tasks/:id', async (req, res) => {
    try {
        const task = await db.updateTaskStatus(req.params.id, req.body.status);
        res.json(task);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});