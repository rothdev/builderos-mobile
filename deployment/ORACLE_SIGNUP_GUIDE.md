# Oracle Cloud Account Creation - Step-by-Step Guide

**Time Required:** 20-30 minutes
**Why Manual:** Phone verification, payment method, identity checks (can't automate)

## Before You Start

**Have Ready:**
- ✅ Email address (use your main email, not alias)
- ✅ Phone number (for SMS verification)
- ✅ Credit/debit card (NOT charged for free tier)
- ✅ Valid address
- ✅ SSH public key (already generated)

---

## Step 1: Start Signup (5 min)

1. **Open browser:** https://oracle.com/cloud/free

2. **Click "Start for free"** (top right)

3. **Fill in details:**
   - **Country/Region:** United States (or your country)
   - **Full Name:** Your real name
   - **Email:** Your email (NOT SimpleLogin alias)
   - **Password:** Strong password (save in Strongbox)

4. **Verify email:**
   - Check inbox for Oracle verification email
   - Click verification link
   - Returns to signup page

---

## Step 2: Account Information (5 min)

1. **Cloud Account Name:**
   - Choose unique name (e.g., `builderos-2024`)
   - This becomes your tenant name
   - Cannot be changed later

2. **Home Region:**
   - **IMPORTANT:** Choose region closest to you
   - **US East (Ashburn)** - East Coast
   - **US West (Phoenix)** - West Coast
   - **US West (San Jose)** - California
   - Cannot be changed later!

3. **Click "Continue"**

---

## Step 3: Phone Verification (3 min)

1. **Enter phone number:**
   - Use real phone number
   - Required for account security

2. **Verification method:**
   - **Text Message (SMS)** - Recommended
   - Or: **Voice Call**

3. **Enter code:**
   - Receive 6-digit code via SMS/call
   - Enter code on webpage
   - Click "Verify"

---

## Step 4: Payment Information (5 min)

**IMPORTANT:** Card is NOT charged for Always Free services!

1. **Address:**
   - Full street address
   - City, State, ZIP
   - Must match card billing address

2. **Payment Method:**
   - Credit or debit card
   - Card details securely stored
   - Used only for paid services (if you enable them)

3. **Verification:**
   - $1 authorization hold (refunded immediately)
   - Sometimes requires 3D Secure / SMS verification
   - Verify with your bank if prompted

4. **Accept Terms:**
   - Read Oracle Cloud Services Agreement
   - Check "I accept" box
   - Click "Complete Sign-Up"

---

## Step 5: Account Activation (2-10 min)

1. **Wait for provisioning:**
   - "Your account is being created"
   - Usually takes 2-5 minutes
   - Sometimes up to 10 minutes

2. **Email confirmation:**
   - "Welcome to Oracle Cloud" email
   - Contains account details
   - Save this email!

3. **Sign in:**
   - Go to https://cloud.oracle.com
   - Enter email + password
   - Access Oracle Cloud Console

---

## Step 6: Console Familiarization (2 min)

Once logged in:

1. **Dashboard view:**
   - Overview of services
   - Resource usage (should be empty)
   - Free tier status

2. **Navigation:**
   - ☰ Menu (top left) → Compute → Instances
   - This is where you'll create your VM

3. **Verify free tier:**
   - Account Settings → Tenancy
   - Should show "Always Free" resources available

---

## Next: Create VM Instance

**Once account is ready, return here - I'll automate the rest!**

You'll need:
- ✅ Oracle Cloud Console access
- ✅ Account fully activated
- ✅ Free tier resources available

**Then run:**
```bash
# I'll guide you through VM creation
# Or use Oracle CLI (can be automated)
```

---

## Troubleshooting

### "Payment verification failed"
- **Cause:** Card declined or 3D Secure issue
- **Fix:** Try different card, or contact bank

### "Account under review"
- **Cause:** Fraud detection triggered
- **Fix:** Wait 24-48 hours, check email for Oracle support
- **Alternative:** Try different email/phone

### "Region unavailable"
- **Cause:** ARM capacity full in that region
- **Fix:** Choose different region during signup

### "Phone already used"
- **Cause:** Phone used for another Oracle account
- **Fix:** Use different phone, or contact Oracle support

---

## What Happens After Signup

**Immediately:**
- ✅ Access to Oracle Cloud Console
- ✅ Always Free tier activated
- ✅ Can create ARM VM (1 OCPU, 6GB)
- ✅ Ready to deploy Rathole server

**Next Steps (I'll automate):**
1. Create ARM VM instance
2. Configure firewall rules
3. Deploy Rathole server
4. Install Mac client
5. Test tunnel

---

## Security Notes

**Oracle will:**
- ✅ Store your payment method securely
- ✅ Send alerts for resource usage
- ✅ Monitor for unusual activity
- ✅ Keep Always Free tier free (no charges)

**Oracle will NOT:**
- ❌ Charge you unless you manually upgrade
- ❌ Auto-upgrade to paid tier
- ❌ Charge for Always Free resources

**Your card is safe:**
- Only charged if you create paid resources
- Always Free resources NEVER charged
- You control billing with explicit actions

---

## After Signup Checklist

- [ ] Account created successfully
- [ ] Email verified
- [ ] Phone verified
- [ ] Payment method added
- [ ] Can access Oracle Cloud Console
- [ ] Free tier status shows "Active"

**Ready?** Let me know when you're logged into Oracle Cloud Console, and I'll guide you through VM creation!
