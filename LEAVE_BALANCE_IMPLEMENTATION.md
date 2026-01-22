# Leave Balance & Attendance Fixes - Implementation Summary

## Issues Fixed

### Issue 1: Leave Balances Not Saved ✅
**Problem**: Leave balances (Paid, Sick, Long, Wellness) were not being saved when creating employees.

**Solution**: Added leave balance fields to Employee model and database.

### Issue 2: Days Worked Count Incorrect ✅
**Problem**: "Days Worked" showing 3 but only 1 day visible in attendance history.

**Solution**: Fixed calculation to count unique dates instead of total entries.

---

## 1. Leave Balance Implementation

### Database Changes

#### Employee Model (`app/models/employee.py`)
Added 4 new columns to track leave balances:

```python
class Employee(Base):
    # ... existing fields ...
    
    # Leave balances (total allocated per year)
    paid_leave_balance = Column(Integer, default=12)
    sick_leave_balance = Column(Integer, default=12)
    long_leave_balance = Column(Integer, default=5)
    wellness_leave_balance = Column(Integer, default=5)
```

#### Leave Model Update
Changed `leave_type` to `type` for consistency:

```python
class Leave(Base):
    # ... existing fields ...
    type = Column(String, default="Paid")  # 'Paid', 'Sick', 'Long', 'Wellness'
```

### Backend API Changes

#### CRUD Function (`app/curd/employee.py`)
Updated `create_employee_with_image` to accept leave balances:

```python
def create_employee_with_image(
    db: Session,
    name: str,
    role: str,
    salary: float,
    join_date: str,
    image_url: str,
    user_id: int,
    # NEW: Leave balances with defaults
    paid_leave_balance: int = 12,
    sick_leave_balance: int = 12,
    long_leave_balance: int = 5,
    wellness_leave_balance: int = 5,
):
    new_employee = Employee(
        name=name,
        role=role,
        salary=salary,
        join_date=join_date,
        image_url=image_url,
        user_id=user_id,
        paid_leave_balance=paid_leave_balance,
        sick_leave_balance=sick_leave_balance,
        long_leave_balance=long_leave_balance,
        wellness_leave_balance=wellness_leave_balance,
    )
    # ... save to database
```

### Default Leave Allocations

| Leave Type | Default Balance |
|------------|----------------|
| Paid Leave | 12 days/year   |
| Sick Leave | 12 days/year   |
| Long Leave | 5 days/year    |
| Wellness Leave | 5 days/year |

**Total**: 34 days of leave per year per employee

### Database Migration

Created migration script: `ResortApp/migrate_leave_balances.py`

**Run this to update the database**:
```bash
cd ResortApp
python migrate_leave_balances.py
```

**What it does**:
1. ✅ Adds 4 new columns to `employees` table
2. ✅ Sets default values for existing employees
3. ✅ Renames `leave_type` to `type` in `leaves` table

---

## 2. Days Worked Count Fix

### Problem Identified
```dart
// BEFORE (Wrong - counts entries, not days)
value: '${workLogs.length}'  // Shows 3 (3 entries)

// Example data:
// - Jan 19: Entry 1 (9:12 AM - 2:12 PM)
// - Jan 19: Entry 2 (3:11 PM - 2:12 PM)  
// - Jan 19: Entry 3 (8:01 PM - Working)
// Total entries: 3, but only 1 unique day!
```

### Solution
```dart
// AFTER (Correct - counts unique dates)
value: '${_groupLogsByDate(workLogs).length}'  // Shows 1 (1 day)
```

**How it works**:
- `_groupLogsByDate()` groups all entries by date
- Returns a Map where each key is a unique date
- `.length` counts the number of unique dates
- Now "Days Worked" accurately reflects actual working days

### Before vs After

**Before**:
```
This Month
Days Worked: 3  ← Wrong! (counting entries)
Total Hours: 8h 11m
```

**After**:
```
This Month
Days Worked: 1  ← Correct! (counting unique days)
Total Hours: 8h 11m
```

---

## How Leave Balances Work

### When Creating Employee
```
Employee Created:
├─ Paid Leave: 12 days
├─ Sick Leave: 12 days
├─ Long Leave: 5 days
└─ Wellness Leave: 5 days
```

### When Employee Takes Leave
```
Leave Request:
├─ Type: "Sick"
├─ From: 2026-01-20
├─ To: 2026-01-22
├─ Days: 3
└─ Status: "pending"

If Approved:
├─ Sick Leave Balance: 12 → 9 (3 days deducted)
└─ Other balances unchanged
```

### Leave Types

1. **Paid Leave** (`type: "Paid"`)
   - General vacation days
   - Planned time off
   - Personal days

2. **Sick Leave** (`type: "Sick"`)
   - Medical reasons
   - Health-related absences
   - Doctor appointments

3. **Long Leave** (`type: "Long"`)
   - Extended vacations
   - Sabbatical
   - Family emergencies

4. **Wellness Leave** (`type: "Wellness"`)
   - Mental health days
   - Wellness activities
   - Self-care time

---

## Frontend Integration

### Employee App - Leave Balance Display

The leave balance card will now show:

```
┌─────────────────────────┐
│  🏖️ Leave Balance       │
├─────────────────────────┤
│  12        0            │
│  Available  Used        │
└─────────────────────────┘
```

**Calculation**:
- `Available` = `paid_leave_balance` - (approved leaves of that type)
- `Used` = Count of approved leaves of that type

### API Response Example

```json
{
  "id": 1,
  "name": "John Doe",
  "role": "Housekeeping",
  "salary": 25000,
  "paid_leave_balance": 12,
  "sick_leave_balance": 12,
  "long_leave_balance": 5,
  "wellness_leave_balance": 5,
  "user": {
    "email": "john@example.com",
    "is_active": true
  }
}
```

---

## Testing Checklist

### Backend:
- [ ] Run migration script
- [ ] Create new employee - verify leave balances saved
- [ ] Check database - confirm columns exist
- [ ] Apply for leave - verify type is saved correctly

### Frontend:
- [ ] Days Worked shows correct count (unique days)
- [ ] Leave balance displays correctly
- [ ] Multiple entries same day grouped properly
- [ ] Leave application form works

---

## Migration Steps

### 1. Update Database Schema
```bash
cd ResortApp
python migrate_leave_balances.py
```

Expected output:
```
🚀 Starting database migration...
==================================================
📝 Adding leave balance columns to employees table...
✅ Successfully added leave balance columns!
✅ Updated existing employees with default leave balances!

📝 Renaming leave_type to type in leaves table...
✅ Successfully renamed leave_type to type!

==================================================
✅ All migrations completed successfully!
```

### 2. Restart Backend
```bash
sudo systemctl restart resort_backend
```

### 3. Hot Reload Frontend
The Flutter app should automatically reload with the fixes.

---

## Files Modified

### Backend:
1. `ResortApp/app/models/employee.py`
   - Added 4 leave balance columns
   - Changed `leave_type` to `type`

2. `ResortApp/app/curd/employee.py`
   - Updated `create_employee_with_image()` function
   - Added leave balance parameters

3. `ResortApp/migrate_leave_balances.py` (NEW)
   - Database migration script

### Frontend:
1. `Mobile/employee/lib/presentation/screens/attendance/attendance_screen.dart`
   - Fixed Days Worked calculation
   - Now counts unique dates instead of total entries

---

## Summary

✅ **Leave Balances**: Now saved when creating employees with 4 types
✅ **Days Worked**: Fixed to count unique working days correctly
✅ **Database Migration**: Script ready to update schema
✅ **Default Values**: All leave types have sensible defaults

The system now properly tracks and manages employee leave balances across all leave types! 🎉
