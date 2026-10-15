# চিঠিবক্স (ChithiBox) Android App 📮

A Flutter application for **চিঠিবক্স (ChithiBox)** — a nostalgic, warm postal stationery experience for Android.

---

## 🌟 Features for Normal Users

1. **Authentication & Security**
   - **Dual Login Modes**:
     - Password login (Username / Mobile / Email + Password).
     - Fast OTP login (6-digit SMS verification code).
   - **Registration**:
     - Fast mobile number verification with OTP.
     - Optional Display Name and custom Password.
     - Auto-generated unique Bengali postal username (e.g. `user_k3x9a`).
   - Cookieless `Authorization: Bearer <token>` mobile session tokens with automatic persistence via `SharedPreferences`.

2. **Letters Management (Dashboard)**
   - **ইনবক্স (Inbox)**:
     - Real-time unread counter badge.
     - Letter card previews with stamps, sender name, subject, and snippet.
     - Swipe-to-delete with confirmation.
     - Star / Unstar and Archive / Recover actions.
     - Pull-to-refresh.
   - **প্রেরিত (Sent)**: Sent letters with delivery status and recipient details.
   - **তারকাচিহ্নিত (Starred)**: Quickly find favorite letters.
   - **সংরক্ষিত (Archived)**: Archived letters with one-tap restore back to Inbox.
   - **খুঁজুন (Search)**: Search across subject, body, and names.

3. **চিঠি লিখন (Letter Composer)**
   - **Recipient Verification**:
     - Live validation of `@username`, mobile number (`017...`), or email.
     - Self-delivery prevention.
   - **গোপন চিঠি (Anonymous Mode)**: Send letters without disclosing identity.
   - **Letter Structure**:
     - স্থান (Place) & তারিখ (Date).
     - সম্বোধন (Salutation, e.g. "প্রিয় সুহৃদ,").
     - বিষয় (Subject) & মূল বক্তব্য (Letter Body).
     - বিদায় সম্ভাষণ (Closing, e.g. "ইতি,") & স্বাক্ষর (Signature).
   - **Stationery Customization**:
     - **ডাক খাম (Envelopes)**: Classic Khaki, Vintage Parchment, Romantic Rose, Zamindari Royal.
     - **ডাক টিকিট (Stamps)**: National Water Lily (শাপলা), Royal Bengal Tiger, Red Postbox.
     - **গালা সিলমোহর (Wax Seals)**: Crimson Lotus (রক্তপদ্ম), Gold Royal, Heart Love.
     - **কাগজের পাতা (Paper Themes)**: Aged Parchment, Lined Notebook Diary, Burnt Manuscript.
     - **কলমের কালির রঙ (Ink Colors)**: Fountain Blue (`#1e3a8a`), Charcoal Black (`#0f172a`), Sepia Brown (`#451a03`), Alta Crimson (`#881337`), Forest Emerald (`#064e3b`).

4. **চিঠি পাঠ (Interactive Envelope & Paper Canvas)**
   - Realistic 3D-styled postal envelope with postmark stamp.
   - Flip button to view front address block or back wax seal side.
   - Interactive Wax Seal breaking interaction with tactile animation.
   - Letter unfolds smoothly into a warm parchment paper canvas.
   - Pinch-to-zoom and pan via `InteractiveViewer`.
   - "খামে ফেরত যান" button to return to envelope view.

5. **প্রোফাইল ও সেটিংস (Profile & Settings)**
   - View profile info, verified phone, and username.
   - Edit Display Name and unique Username.
   - Set or Change Password.
   - Configure Server Base URL (Emulator vs Physical WiFi IP).
   - Logout.

---

## 🚀 Running the App

### 1. Ensure the Backend Server is Running
The SvelteKit backend runs at `http://localhost:5173`.
```bash
npm run dev
```

### 2. Run the Flutter App
From the `chithi_app` folder:
```bash
cd chithi_app
flutter run
```

### 3. Server Connection Settings (Base URL)
- **Android Emulator**: Uses `http://10.0.2.2:5173` (configured by default).
- **Physical Android Phone**: Connect your phone to the same Wi-Fi network as your PC and set the Base URL in the app's settings dialog (gear icon on login screen or profile settings) to `http://<YOUR_PC_IP>:5173` (e.g. `http://192.168.0.105:5173`).

---

## 📡 Mobile REST API Specification (`/api/v1/`)

All endpoints support `Authorization: Bearer <token>` and CORS.

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/auth/login` | Login with identifier + password or phone + OTP code |
| `POST` | `/api/v1/auth/register` | Register new account with phone + OTP |
| `POST` | `/api/v1/auth/otp/send` | Request 6-digit OTP code |
| `POST` | `/api/v1/auth/otp/verify` | Verify OTP code |
| `GET` | `/api/v1/auth/me` | Fetch authenticated user profile & stats |
| `POST` | `/api/v1/auth/logout` | Invalidate mobile session |
| `GET` | `/api/v1/chithis` | List letters (`?box=inbox\|sent\|starred\|archived&search=...`) |
| `POST` | `/api/v1/chithis` | Compose and send a letter |
| `GET` | `/api/v1/chithis/:id` | Read letter details (auto-marks read) |
| `DELETE` | `/api/v1/chithis/:id` | Soft delete or permanent delete (`?permanent=true`) |
| `POST` | `/api/v1/chithis/:id/star` | Toggle star flag on letter |
| `POST` | `/api/v1/chithis/:id/archive`| Toggle or set archive status |
| `GET` | `/api/v1/recipient/check` | Validate recipient (`?query=...`) |
| `GET` | `/api/v1/catalog` | Fetch envelopes, stamps, seals, papers, fonts |
| `PATCH` | `/api/v1/user/profile` | Update username and display name |
| `POST` | `/api/v1/user/password` | Set or change password |
