# Leave Application Feature - Complete Implementation

## Overview
Implemented a fully functional leave application dialog in the employee attendance screen with form validation, date pickers, and API integration.

---

## Features Implemented

### 1. Leave Type Selection ✅
**Dropdown with 4 types:**
- 🎫 **Paid Leave** - General vacation days
- 🏥 **Sick Leave** - Medical reasons
- ✈️ **Long Leave** - Extended vacations
- 🧘 **Wellness Leave** - Mental health & wellness

Each type has a unique icon for easy identification.

### 2. Date Selection ✅
**Smart Date Pickers:**
- **From Date**: Can select from today onwards
- **To Date**: Automatically restricted to be >= From Date
- **Auto-calculation**: Shows total days (e.g., "3 day(s)")
- **Validation**: To Date disabled until From Date is selected

### 3. Reason Input ✅
- Multi-line text field (3 lines)
- Placeholder text: "Enter reason for leave..."
- Required field validation

### 4. Form Validation ✅
Submit button is disabled until:
- ✅ From Date is selected
- ✅ To Date is selected
- ✅ Reason is entered (not empty)

### 5. API Integration ✅
**Connected to backend:**
```dart
await leaveProvider.applyLeave(
  employeeId: employeeId,
  fromDate: fromDate,
  toDate: toDate,
  reason: reason,
  leaveType: selectedLeaveType,
);
```

**Success handling:**
- Shows success message
- Closes dialog
- Refreshes leave list automatically

**Error handling:**
- Shows error message if API fails
- Keeps dialog open for retry

---

## User Flow

### Step 1: Open Dialog
Click "Apply for Leave" button → Dialog opens

### Step 2: Select Leave Type
Choose from dropdown:
```
┌─────────────────────────┐
│ 🎫 Paid Leave          ▼│
├─────────────────────────┤
│ 🎫 Paid Leave           │
│ 🏥 Sick Leave           │
│ ✈️ Long Leave           │
│ 🧘 Wellness Leave       │
└─────────────────────────┘
```

### Step 3: Select Dates
**From Date:**
```
┌─────────────────────────┐
│ 📅 Jan 20, 2026         │
└─────────────────────────┘
```

**To Date:**
```
┌─────────────────────────┐
│ 📅 Jan 22, 2026         │
└─────────────────────────┘
```

**Auto-calculated:**
```
┌─────────────────────────┐
│ 📝 3 day(s)             │
└─────────────────────────┘
```

### Step 4: Enter Reason
```
┌─────────────────────────┐
│ Family emergency        │
│ Need to attend to       │
│ personal matters        │
└─────────────────────────┘
```

### Step 5: Submit
```
┌─────────────────────────┐
│  Submit Application     │
└─────────────────────────┘
```

---

## UI Components

### Dialog Structure
```
┌──────────────────────────────────┐
│ 🏖️ Apply for Leave          ✕   │
├──────────────────────────────────┤
│                                  │
│ Leave Type                       │
│ [Dropdown: Paid Leave      ▼]   │
│                                  │
│ From Date                        │
│ [📅 Select start date]           │
│                                  │
│ To Date                          │
│ [📅 Select end date]             │
│                                  │
│ [📝 3 day(s)]                    │
│                                  │
│ Reason                           │
│ [Text area for reason]           │
│                                  │
│ [Submit Application]             │
│                                  │
└──────────────────────────────────┘
```

### Design Features
- ✅ Rounded corners (12px radius)
- ✅ Proper spacing and padding
- ✅ Icon indicators for each field
- ✅ Disabled state styling
- ✅ Focus states on inputs
- ✅ Scrollable for small screens
- ✅ Max width constraint (500px)

---

## Code Implementation

### Dialog Trigger
```dart
ElevatedButton.icon(
  onPressed: () => _showApplyLeaveDialog(context),
  icon: Icon(Icons.add_circle_outline),
  label: Text('Apply for Leave'),
)
```

### State Management
```dart
String selectedLeaveType = 'Paid';
DateTime? fromDate;
DateTime? toDate;
final reasonController = TextEditingController();
```

### Date Picker Example
```dart
InkWell(
  onTap: () async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        fromDate = picked;
      });
    }
  },
  child: Container(
    // Date display UI
  ),
)
```

### Submit Handler
```dart
onPressed: (fromDate == null || toDate == null || reasonController.text.trim().isEmpty)
    ? null  // Disabled
    : () async {
        try {
          await leaveProvider.applyLeave(...);
          Navigator.pop(context);
          // Show success message
          leaveProvider.fetchLeaves(employeeId);
        } catch (e) {
          // Show error message
        }
      }
```

---

## API Integration

### Request Format
```json
{
  "employee_id": 1,
  "from_date": "2026-01-20",
  "to_date": "2026-01-22",
  "reason": "Family emergency",
  "type": "Paid"
}
```

### Response Handling
**Success (200)**:
```json
{
  "id": 5,
  "employee_id": 1,
  "from_date": "2026-01-20",
  "to_date": "2026-01-22",
  "reason": "Family emergency",
  "type": "Paid",
  "status": "pending"
}
```

**Error (400/500)**:
```json
{
  "detail": "Error message"
}
```

---

## Validation Rules

### 1. Date Validation
- ✅ From Date must be today or future
- ✅ To Date must be >= From Date
- ✅ Both dates required

### 2. Reason Validation
- ✅ Cannot be empty
- ✅ Trimmed before submission

### 3. Leave Type
- ✅ Must be one of: Paid, Sick, Long, Wellness
- ✅ Defaults to "Paid"

---

## User Experience Features

### 1. Smart Defaults
- Leave type defaults to "Paid"
- Date pickers start from today
- To Date picker starts from From Date

### 2. Visual Feedback
- Disabled state for incomplete form
- Loading state during submission
- Success/error messages
- Auto-refresh after success

### 3. Error Prevention
- To Date disabled until From Date selected
- To Date automatically reset if before From Date
- Form validation before submission

---

## Testing Checklist

### UI Tests:
- [ ] Dialog opens when clicking "Apply for Leave"
- [ ] All 4 leave types appear in dropdown
- [ ] Icons display correctly for each type
- [ ] From Date picker opens and selects date
- [ ] To Date picker disabled until From Date selected
- [ ] Days calculation shows correctly
- [ ] Reason field accepts text input
- [ ] Submit button disabled when form incomplete
- [ ] Submit button enabled when form complete

### Functional Tests:
- [ ] Leave application submits successfully
- [ ] Success message appears
- [ ] Dialog closes after submission
- [ ] Leave list refreshes with new entry
- [ ] Error message shows on API failure
- [ ] Dialog stays open on error

### Edge Cases:
- [ ] Selecting same date for From and To (1 day)
- [ ] Very long reason text
- [ ] Network error handling
- [ ] Employee ID not found

---

## Summary

✅ **Complete leave application form** with all fields
✅ **4 leave types** with icons
✅ **Smart date pickers** with validation
✅ **Auto-calculation** of days
✅ **Form validation** before submission
✅ **API integration** with error handling
✅ **Success/error feedback** to user
✅ **Auto-refresh** of leave list

The Leaves tab is now fully functional! Employees can apply for leave with a beautiful, user-friendly interface. 🎉
