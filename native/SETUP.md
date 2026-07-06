# First Word — Getting It On Your iPhone (and the App Store)

The app code + build machine are done. Apple requires one thing code can't provide:
**a developer account in Jay's name.** Everything below happens in a web browser —
no Mac, no code, no terminal. Total hands-on time: ~25 minutes across two sittings.

---

## Part 1 — Today (10 min): Enroll in the Apple Developer Program 💳 $99/year

1. On your iPhone or computer, go to: **developer.apple.com/programs/enroll**
2. Sign in with your **personal Apple ID** (the one on your iPhone).
3. Choose **Individual / Sole Proprietor**.
4. Fill in your legal name + address, verify with the code Apple texts you.
5. Pay the **$99/year** fee.
6. Wait for the "Welcome to the Apple Developer Program" email — usually minutes,
   can take up to 48 hours.

⚠️ This is the only cost in the whole pipeline. Everything else (GitHub build
minutes, TestFlight, hosting) is $0.

**Prereq check while you wait:** iPhone → Settings → General → About → iOS Version.
It must say **26.x**. If it says 18.x → Settings → General → Software Update.

---

## Part 2 — After the welcome email (15 min): Wire it up

### A. Register the app's ID
1. Go to **developer.apple.com/account/resources/identifiers** → blue **+**
2. Pick **App IDs** → Continue → **App** → Continue
3. Description: `First Word` · Bundle ID: **Explicit** → `com.trandahlmedia.firstword`
4. Don't tick any capabilities. **Register.**

### B. Create the app record
1. Go to **appstoreconnect.apple.com** → **My Apps** → blue **+** → **New App**
2. Platform **iOS** · Name **First Word: Bible Verse Alarm** (if taken, try
   "First Word — Wake Up in the Word") · Language English (U.S.)
3. Bundle ID: pick `com.trandahlmedia.firstword` · SKU: `firstword-001`
4. Full Access → **Create**

### C. Create the API key (lets GitHub build & upload for you)
1. appstoreconnect.apple.com → **Users and Access** → **Integrations** tab
   → **App Store Connect API** → **Team Keys** → blue **+**
2. Name: `GitHub CI` · Access: **Admin** → **Generate**
3. **Download the .p8 file** (one chance only — it lands in Downloads)
4. Note the **Key ID** (next to the key) and the **Issuer ID** (top of the page)

### D. Give GitHub the four secrets
1. Go to **github.com/trandahlmedia-lgtm/verse-alarm** → **Settings** →
   **Secrets and variables** → **Actions** → **New repository secret** (×4):

| Name | Value |
|---|---|
| `APPLE_TEAM_ID` | developer.apple.com/account → scroll to Membership details → Team ID (10 characters) |
| `ASC_KEY_ID` | the Key ID from step C |
| `ASC_ISSUER_ID` | the Issuer ID from step C |
| `ASC_KEY_P8` | the .p8 file as base64 — run the PowerShell below and paste |

PowerShell for the last one (fix the filename to match your download):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$HOME\Downloads\AuthKey_XXXXXXXXXX.p8")) | Set-Clipboard
```

…then just paste into the secret box (it's already on your clipboard).

### E. Fire the first build
1. Repo → **Actions** tab → **iOS · Build & TestFlight** → **Run workflow**
2. ~15 minutes later the build appears in App Store Connect → TestFlight.
   (First builds usually take 1–3 tries while compile nits get fixed — Claude
   reads the logs and patches; you don't do anything.)

---

## Part 3 — Install it (5 min)

1. iPhone → App Store → install Apple's **TestFlight** app (free).
2. appstoreconnect.apple.com → your app → **TestFlight** tab → **Internal Testing**
   → **+** create group "Team" → add yourself → you get an email → tap **View in
   TestFlight** → **Install**. Done — real app, real alarms.
3. **Partners:** External Testing group → creates a **public link** anyone can tap
   (first external build needs a ~1-day beta review by Apple). iPhone-only for now;
   Android friends use the web app: trandahlmedia-lgtm.github.io/verse-alarm

---

## Part 4 — The App Store itself (later, ~week 2)

Needs: screenshots (Claude generates), the privacy policy page (Claude hosts on the
web app site), app description + keywords (Claude writes), age rating questionnaire
(2 min of clicks). Submit → review is typically 1–2 days. First submissions
sometimes bounce once on metadata — normal, fix and resubmit.
