# 📱 Hodorak - Flutter + Supabase Integration

Hodorak is a Flutter-based employee attendance management app integrated with Supabase as its backend.  
It allows companies to manage their employees efficiently with features like location-based attendance, leave management, notifications, and real-time data sync.

---

## 🚀 Features

### 🏢 Company Creation
When a user opens the app for the first time, they can create their own company database.  
The first registered user automatically becomes the **Admin** of that company.

### 👥 Employee Management
- Add new employees and link them to the company.
- Edit or delete employees from the database.
- Reset employee passwords.

### ⏰ Attendance System
- Employees can **Check-In / Check-Out** only within the location set by the admin.
- Integrated with **Google Maps API** for location verification.

### 🗺️ Location Management
Admins can define a geofenced location where employees are allowed to mark attendance.

### 🗓️ Calendar Integration
- Employees can view their monthly schedule and attendance history.
- Admins can track employees' working hours and attendance patterns.

### 🌴 Leave Requests
- Employees can submit leave requests directly from the app.
- Admins can approve or reject requests.
- Real-time notifications are sent to the employee upon approval or rejection.

### 🔔 Notifications
- **Realtime Notifications** via Firebase Cloud Messaging (FCM).
- Instant updates for leave approvals, attendance status, and admin actions.

### 🌐 Supabase Integration
- Data stored in Supabase PostgreSQL with custom SQL tables.
- **RLS (Row Level Security)** ensures data isolation between companies.
- Supabase Auth handles user authentication securely.

### ⚙️ Two-Flow System
- **Admin Flow**: Full access to employee management, attendance tracking, and approvals.
- **User Flow**: Simplified view for attendance, leave requests, and schedules.

---

## 🧠 Why Supabase instead of Odoo?

After testing the Odoo SaaS integration, it was clear that:

❌ Odoo's SaaS environment offers limited free features.  
❌ Multi-database creation per company was restricted.  
❌ Integration with Flutter required complex API handling and wasn't stable.

By switching to **Supabase**, the app became:

✅ **Faster** — thanks to a modern and scalable PostgreSQL backend.  
✅ **Easier to develop** — direct SDK support for Flutter (`supabase_flutter`).  
✅ **More secure** — built-in authentication and RLS rules.  
✅ **Feature-rich** — with real-time updates, storage, and notifications.

**Result:** The project is now more stable, efficient, and developer-friendly. ⚡

---

## ⚙️ Tech Stack

- **Frontend**: Flutter
- **State Management**: Riverpod
- **Backend**: Supabase
- **Database**: PostgreSQL (via Supabase SQL Editor)
- **Authentication**: Supabase Auth
- **Realtime Notifications**: Firebase Cloud Messaging (FCM)
- **Maps Integration**: Google Maps API

---

## 🔗 Links

- 📂 [GitHub Repository](https://github.com/He9sham/Hodorak)
- ☁️ [Supabase](https://supabase.com/)
- 🔥 [Firebase](https://firebase.google.com/)

---

## 👨‍💻 Author

**Hesham Hamdan**

- ✉️ [Email](mailto:heshamhamdan51@gmail.com)
- 🐙 [GitHub](https://github.com/He9sham)
- 💼 [LinkedIn](https://www.linkedin.com/in/hesham-hamdan-9ab479269?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app)

---

⭐️ If you found this project useful, don't forget to give it a **star** on GitHub!
