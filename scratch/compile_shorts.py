import base64
import os

def b64(path, mime='jpg'):
    with open(path, 'rb') as f:
        return f"data:image/{mime};base64,{base64.b64encode(f.read()).decode()}"

print("Encoding ALL Features (Recipe COGS, Stock Movement, POs, GST, Checkout, Mobile) for 9:16 Shorts...")
logo_data         = b64(r'c:\releasing\New Orchid\scratch\logo_light_mode.png', 'png')

# REAL LIVE ZEEBULL SCREENSHOTS PROVIDED BY THE USER:
shot_enterprise   = b64(r'C:\Users\pro\.gemini\antigravity-ide\brain\3ff55e3a-72f4-40a0-afce-ec5093ede170\media__1785087630767.png', 'png')
shot_admin_dash   = b64(r'C:\Users\pro\.gemini\antigravity-ide\brain\3ff55e3a-72f4-40a0-afce-ec5093ede170\media__1785087639147.png', 'png')
shot_accounts     = b64(r'C:\Users\pro\.gemini\antigravity-ide\brain\3ff55e3a-72f4-40a0-afce-ec5093ede170\media__1785087645497.png', 'png')
shot_bookings     = b64(r'C:\Users\pro\.gemini\antigravity-ide\brain\3ff55e3a-72f4-40a0-afce-ec5093ede170\media__1785087659809.png', 'png')
shot_web_console  = b64(r'C:\Users\pro\.gemini\antigravity-ide\brain\3ff55e3a-72f4-40a0-afce-ec5093ede170\media__1785087678493.png', 'png')
shot_mobile_drawer= b64(r'C:\Users\pro\.gemini\antigravity-ide\brain\3ff55e3a-72f4-40a0-afce-ec5093ede170\media__1785087759588.png', 'png')

html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<title>Zeebull Hospitality – 100% Ultimate Feature Showcase 9:16 Short</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&family=Space+Grotesk:wght@500;700;800&display=swap" rel="stylesheet"/>
<style>
*{{margin:0;padding:0;box-sizing:border-box;}}
html,body{{width:1080px;height:1920px;overflow:hidden;background:#f8faf9;font-family:'Plus Jakarta Sans',sans-serif;color:#0f172a;}}

/* ═════ DYNAMIC 9:16 CLEAN LIGHTING ═════ */
#bg-canvas{{position:fixed;inset:0;z-index:1;pointer-events:none;}}
.beam{{position:fixed;width:1000px;height:1000px;border-radius:50%;filter:blur(180px);opacity:0.25;pointer-events:none;z-index:0;}}
.b1{{background:radial-gradient(circle,#bbf7d0,transparent 70%);top:-250px;left:-250px;animation:beamFloat1 10s ease-in-out infinite alternate;}}
.b2{{background:radial-gradient(circle,#e0f2fe,transparent 70%);bottom:-250px;right:-250px;animation:beamFloat2 12s ease-in-out infinite alternate;}}
@keyframes beamFloat1{{0%{{transform:translate(0,0) scale(1);}}100%{{transform:translate(60px,50px) scale(1.15);}}}}
@keyframes beamFloat2{{0%{{transform:translate(0,0) scale(1);}}100%{{transform:translate(-60px,-50px) scale(1.2);}}}}

/* ═════ TOP BRANDING BAR ═════ */
.top-nav{{
  position:fixed;top:40px;left:44px;right:44px;z-index:1000;
  display:flex;align-items:center;justify-content:space-between;
}}
.brand-pill{{
  display:flex;align-items:center;gap:18px;
  background:rgba(255,255,255,0.96);border:2px solid rgba(0,168,107,0.4);
  padding:16px 32px;border-radius:100px;backdrop-filter:blur(24px);
  box-shadow:0 20px 45px rgba(0,0,0,0.06), 0 0 35px rgba(0,168,107,0.18);
}}
.brand-pill img{{height:48px;object-fit:contain;}}
.live-badge{{
  display:flex;align-items:center;gap:12px;background:rgba(255,255,255,0.95);
  border:2px solid rgba(0,168,107,0.35);padding:14px 28px;border-radius:100px;
  font-size:19px;font-weight:800;color:#0f172a;box-shadow:0 12px 30px rgba(0,0,0,0.05);
}}
.pulse-dot{{width:14px;height:14px;border-radius:50%;background:#00a86b;box-shadow:0 0 18px #00a86b;animation:pdot 1.5s infinite;}}
@keyframes pdot{{0%,100%{{transform:scale(1);opacity:1;}}50%{{transform:scale(1.5);opacity:0.4;}}}}

/* ═════ SMOOTH SCENE-LEVEL TRANSITIONS (0.6s CUBIC-BEZIER) ═════ */
.scene{{position:fixed;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;
  opacity:0;pointer-events:none;z-index:5;padding:120px 40px 60px;text-align:center;gap:16px;
  transition:transform 0.6s cubic-bezier(0.16,1,0.3,1), opacity 0.5s ease, filter 0.5s ease;
  transform:scale(0.94) translateY(35px);filter:blur(10px);}}
.scene.active{{opacity:1;pointer-events:auto;z-index:10;transform:scale(1) translateY(0);filter:blur(0px);}}
.scene.exit{{opacity:0;transform:scale(1.05) translateY(-35px);filter:blur(10px);z-index:4;}}

/* ═════ STAGGERED WIDGET TRANSITION EFFECTS ═════ */
.header-box{{width:100%;max-width:1000px;display:flex;flex-direction:column;align-items:center;}}
.eyebrow{{
  font-family:'Space Grotesk',sans-serif;font-size:24px;font-weight:800;letter-spacing:6px;
  color:#00a86b;text-transform:uppercase;margin-bottom:12px;
  display:inline-flex;align-items:center;gap:12px;
  opacity:0;transform:translateY(-20px);transition:all 0.5s cubic-bezier(0.16,1,0.3,1);transition-delay:0.1s;
}}
.eyebrow::before{{content:'';width:12px;height:12px;border-radius:50%;background:#00a86b;box-shadow:0 0 16px #00a86b;}}
.title-hero{{
  font-size:60px;font-weight:900;line-height:1.08;letter-spacing:-2.5px;
  margin-bottom:12px;opacity:0;transform:translateY(24px);color:#0f172a;
  transition:all 0.55s cubic-bezier(0.16,1,0.3,1);transition-delay:0.18s;
}}
.scene.active .eyebrow,.scene.active .title-hero{{
  opacity:1;transform:translateY(0);
}}

.grad-txt{{
  background:linear-gradient(135deg,#0f172a 10%,#00a86b 65%,#0284c7 100%);
  -webkit-background-clip:text;-webkit-text-fill-color:transparent;
}}

/* Happy Client Card Widget Transition */
.happy-client-spotlight{{
  background:linear-gradient(135deg,rgba(255,255,255,0.98),rgba(240,253,244,0.96));
  border:3px solid #00a86b;border-radius:28px;padding:20px 28px;
  width:100%;max-width:1000px;
  box-shadow:0 20px 50px rgba(0,168,107,0.12);
  display:flex;align-items:center;justify-content:space-between;text-align:left;
  opacity:0;transform:scale(0.95) translateY(15px);
  transition:all 0.55s cubic-bezier(0.16,1,0.3,1);transition-delay:0.22s;
}}
.scene.active .happy-client-spotlight{{opacity:1;transform:scale(1) translateY(0);}}
.hc-info{{display:flex;flex-direction:column;gap:4px;}}
.hc-stars{{font-size:24px;color:#d97706;}}
.hc-title{{font-size:30px;font-weight:900;color:#0f172a;}}
.hc-sub{{font-size:15px;color:#00a86b;font-weight:800;font-family:'Space Grotesk',sans-serif;letter-spacing:2px;text-transform:uppercase;}}
.hc-badge{{
  background:rgba(0,168,107,0.12);border:2px solid #00a86b;
  border-radius:100px;padding:10px 22px;font-size:15px;font-weight:900;color:#00a86b;
  display:flex;align-items:center;gap:8px;
}}

/* Individual Feature Cards Staggered Slide In */
.feature-list-vertical{{display:flex;flex-direction:column;gap:14px;width:100%;max-width:1000px;}}
.fitem{{
  background:rgba(255,255,255,0.96);border:2.5px solid rgba(0,168,107,0.35);
  border-radius:24px;padding:20px 26px;display:flex;align-items:center;gap:22px;text-align:left;
  box-shadow:0 15px 40px rgba(0,0,0,0.04), 0 0 20px rgba(0,168,107,0.08);
  opacity:0;transition:all 0.55s cubic-bezier(0.16,1,0.3,1);
}}
.fitem:nth-child(1){{transform:translateX(-40px);transition-delay:0.25s;}}
.fitem:nth-child(2){{transform:translateX(40px);transition-delay:0.35s;}}
.fitem:nth-child(3){{transform:translateX(-40px);transition-delay:0.45s;}}
.scene.active .fitem{{opacity:1;transform:translateX(0);}}

.ficon{{width:68px;height:68px;border-radius:20px;background:rgba(0,168,107,0.12);border:2px solid rgba(0,168,107,0.35);display:grid;place-items:center;font-size:34px;flex-shrink:0;}}
.ftitle{{font-size:25px;font-weight:900;color:#0f172a;margin-bottom:4px;}}
.fsub{{font-size:18px;color:#475569;line-height:1.45;}}

/* Visual Mockup Card Smooth Slide Up */
.visual-mockup-card{{
  width:100%;max-width:1000px;background:rgba(255,255,255,0.98);
  border:3px solid rgba(0,168,107,0.4);border-radius:30px;padding:22px 26px;
  box-shadow:0 30px 80px rgba(0,0,0,0.07), 0 0 40px rgba(0,168,107,0.15);
  text-align:left;position:relative;overflow:hidden;
  opacity:0;transform:translateY(35px) scale(0.96);
  transition:all 0.6s cubic-bezier(0.16,1,0.3,1);transition-delay:0.42s;
}}
.scene.active .visual-mockup-card{{opacity:1;transform:translateY(0) scale(1);}}

/* REAL DASHBOARD SCREENSHOT DISPLAY FRAME */
.real-shot-frame{{
  width:100%;height:320px;border-radius:20px;overflow:hidden;border:2.5px solid rgba(0,168,107,0.35);
  box-shadow:0 15px 40px rgba(0,0,0,0.1);background:#ffffff;
}}
.real-shot-frame img{{width:100%;height:100%;object-fit:cover;object-position:top left;}}

/* MOCKUP UI DETAILS */
.mock-header{{display:flex;align-items:center;justify-content:space-between;border-bottom:2px solid #e2e8f0;padding-bottom:10px;margin-bottom:12px;}}
.mock-title{{font-family:'Space Grotesk',sans-serif;font-size:19px;font-weight:800;letter-spacing:2px;color:#00a86b;text-transform:uppercase;}}
.mock-badge{{background:rgba(0,168,107,0.12);color:#00a86b;padding:6px 16px;border-radius:100px;font-size:15px;font-weight:800;}}

/* Grid Rows for Room / Booking Preview */
.grid-preview-4{{display:grid;grid-template-columns:1fr 1fr;gap:14px;}}
.room-card-preview{{background:#f8fafc;border:2px solid #e2e8f0;border-radius:18px;padding:16px 18px;display:flex;flex-direction:column;gap:6px;}}
.rname{{font-size:19px;font-weight:800;color:#0f172a;}}
.rsub{{font-size:14px;color:#64748b;font-weight:600;}}
.rstatus{{display:inline-block;padding:5px 12px;border-radius:100px;font-size:13.5px;font-weight:800;width:fit-content;}}
.st-occ{{background:#fee2e2;color:#dc2626;}}
.st-vac{{background:#dcfce7;color:#16a34a;}}
.st-cln{{background:#e0f2fe;color:#0284c7;}}

/* Phone Mockup Smooth Float Entrance */
.phone-mock-short{{
  width:340px;height:520px;background:#0d1527;border:4px solid #00a86b;
  border-radius:44px;box-shadow:0 30px 80px rgba(0,0,0,0.2);
  overflow:hidden;position:relative;margin:0 auto;
  opacity:0;transform:translateY(40px) scale(0.94);
  transition:all 0.65s cubic-bezier(0.16,1,0.3,1);transition-delay:0.4s;
}}
.scene.active .phone-mock-short{{opacity:1;transform:translateY(0) scale(1);}}
.phone-mock-short img{{width:100%;height:100%;object-fit:cover;object-position:top left;}}

/* ═════ SCENE 10: HIGH IMPACT CTA CLOSER WITH STAGGERED BUTTONS ═════ */
#s10{{justify-content:center;gap:20px;}}
.cta-logo{{width:480px;margin-bottom:20px;filter:drop-shadow(0 20px 40px rgba(0,168,107,0.25));opacity:0;transform:scale(0.85);transition:all 0.6s ease;transition-delay:0.1s;}}
#s10.active .cta-logo{{opacity:1;transform:scale(1);}}
.cta-head{{font-size:72px;font-weight:900;line-height:1.05;margin-bottom:20px;opacity:0;transform:translateY(20px);transition:all 0.6s ease;transition-delay:0.2s;}}
#s10.active .cta-head{{opacity:1;transform:translateY(0);}}

.cta-dual-box{{display:flex;flex-direction:column;gap:16px;align-items:center;width:100%;max-width:920px;}}
.cta-btn{{
  display:inline-flex;align-items:center;gap:20px;
  background:rgba(0,168,107,0.12);border:3.5px solid #00a86b;
  border-radius:100px;padding:22px 50px;width:100%;justify-content:center;
  box-shadow:0 20px 50px rgba(0,168,107,0.25);
  opacity:0;transform:translateY(25px) scale(0.95);transition:all 0.5s cubic-bezier(0.16,1,0.3,1);
  animation:btnPulse 2.5s ease-in-out infinite;
}}
.cta-btn:nth-child(1){{transition-delay:0.3s;}}
.cta-btn:nth-child(2){{transition-delay:0.45s;}}
@keyframes btnPulse{{0%,100%{{box-shadow:0 15px 35px rgba(0,168,107,0.25);}}50%{{box-shadow:0 30px 70px rgba(0,168,107,0.45);border-color:#00a86b;}}}}
#s10.active .cta-btn{{opacity:1;transform:translateY(0) scale(1);}}
.cta-num{{font-family:'Space Grotesk',sans-serif;font-size:36px;font-weight:900;color:#00a86b;letter-spacing:2px;}}
.cta-foot{{font-size:26px;color:#64748b;margin-top:20px;font-weight:700;opacity:0;transition:all 0.5s ease;transition-delay:0.55s;}}
.cta-foot span{{color:#00a86b;font-weight:900;}}
#s10.active .cta-foot{{opacity:1;}}

/* ═════ HUD PROGRESS BAR ═════ */
.top-prog{{position:fixed;top:0;left:0;height:10px;background:linear-gradient(90deg,#00a86b,#0284c7,#d97706);z-index:1000;transition:width 0.1s linear;}}
.scene-timer-bar{{position:absolute;bottom:0;left:0;height:4px;background:rgba(0,168,107,0.6);z-index:20;width:0;}}
.scene.active .scene-timer-bar{{animation:tbFill var(--d,3.5s) linear forwards;}}
@keyframes tbFill{{to{{width:100%;}}}}
</style>
</head>
<body>

<!-- Ambient Light Orbs -->
<div class="beam b1"></div>
<div class="beam b2"></div>

<!-- Interactive Particle Physics Canvas -->
<canvas id="bg-canvas"></canvas>

<!-- TOP NAV BRANDING BAR -->
<div class="top-nav">
  <div class="brand-pill">
    <img src="{logo_data}" alt="TeqMates Logo"/>
  </div>
  <div class="live-badge">
    <span class="pulse-dot"></span>
    <span>Kerala, India</span>
  </div>
</div>

<div class="top-prog" id="pbar"></div>

<!-- ════ SLIDE 1: ENTERPRISE COMMAND CENTER ════ -->
<div class="scene active" id="s1" style="--d:3.5s">
  <div class="scene-timer-bar"></div>
  <div class="header-box">
    <div class="eyebrow">&#127962;&#65039; Multi-Branch ERP</div>
    <div class="title-hero">Enterprise Dashboard <span class="grad-txt">&amp; Command Center</span></div>
  </div>
  <div class="happy-client-spotlight">
    <div class="hc-info">
      <div class="hc-stars">&#9733;&#9733;&#9733;&#9733;&#9733;</div>
      <div class="hc-title">&#127968; Zeebull Hospitality</div>
      <div class="hc-sub">Happy Client &middot; Multi-Branch Resort Management</div>
    </div>
    <div class="hc-badge">
      <span>&#10004; Live System</span>
    </div>
  </div>
  <div class="feature-list-vertical">
    <div class="fitem">
      <div class="ficon">&#127962;&#65039;</div>
      <div><div class="ftitle">Multi-Resort Command Center</div><div class="fsub">Orchid Trails Resort &amp; Zeebull Wild Villa Wayanad isolation &amp; global controls.</div></div>
    </div>
  </div>
  <div class="visual-mockup-card">
    <div class="mock-header">
      <span class="mock-title">&#127968; Live Enterprise Command Center Dashboard</span>
      <span class="mock-badge">2 Active Properties</span>
    </div>
    <div class="real-shot-frame">
      <img src="{shot_enterprise}" alt="Zeebull Enterprise Command Center"/>
    </div>
  </div>
</div>

<!-- ════ SLIDE 2: FRONT DESK & BOOKINGS ════ -->
<div class="scene" id="s2" style="--d:3.5s">
  <div class="scene-timer-bar"></div>
  <div class="header-box">
    <div class="eyebrow">&#128197; Bookings &amp; Packages</div>
    <div class="title-hero">Booking Dashboard <span class="grad-txt">&amp; Packages</span></div>
  </div>
  <div class="feature-list-vertical">
    <div class="fitem">
      <div class="ficon">&#128197;</div>
      <div><div class="ftitle">Bookings Status Analytics</div><div class="fsub">Visual pie charts for active reservations, cancellations &amp; package bookings.</div></div>
    </div>
    <div class="fitem">
      <div class="ficon">&#127963;&#65039;</div>
      <div><div class="ftitle">Whole Property Package Pricing</div><div class="fsub">Orchid Trails By Zeebull Whole Property buyouts (₹75,000 package).</div></div>
    </div>
  </div>
  <div class="visual-mockup-card">
    <div class="mock-header">
      <span class="mock-title">&#128197; Live Booking Management Dashboard</span>
      <span class="mock-badge">₹75,000 Package</span>
    </div>
    <div class="real-shot-frame">
      <img src="{shot_bookings}" alt="Zeebull Booking Dashboard"/>
    </div>
  </div>
</div>

<!-- ════ SLIDE 3: GUEST CHECKOUT & FOLIO SETTLEMENT ════ -->
<div class="scene" id="s3" style="--d:3.5s">
  <div class="scene-timer-bar"></div>
  <div class="header-box">
    <div class="eyebrow">&#128682; Check-Out Service</div>
    <div class="title-hero">Guest Check-Out <span class="grad-txt">&amp; Folio Settlement</span></div>
  </div>
  <div class="feature-list-vertical">
    <div class="fitem">
      <div class="ficon">&#128682;</div>
      <div><div class="ftitle">Pre-Checkout Room Inventory Check</div><div class="fsub">Housekeeping room inspection, minibar consumable audit &amp; key card return fee.</div></div>
    </div>
    <div class="fitem">
      <div class="ficon">&#128179;</div>
      <div><div class="ftitle">Multi-Split Checkout Payment</div><div class="fsub">Cash, Card, UPI &amp; Bank Transfer settlements with instant printed invoice.</div></div>
    </div>
  </div>
  <div class="visual-mockup-card">
    <div class="mock-header">
      <span class="mock-title">&#128682; Pre-Checkout Audit &amp; Folio Settlement</span>
      <span class="mock-badge" style="background:#dcfce7;color:#16a34a">Approved</span>
    </div>
    <div class="grid-preview-4">
      <div class="room-card-preview"><div class="rname">Minibar Audit</div><div class="rsub">Consumables Verified</div><div class="rstatus st-vac">₹ 450 Charges</div></div>
      <div class="room-card-preview"><div class="rname">Key Card Return</div><div class="rsub">Digital Key Handed</div><div class="rstatus st-cln">Fee Waived</div></div>
      <div class="room-card-preview"><div class="rname">Damage Audit</div><div class="rsub">Room Inspected</div><div class="rstatus st-vac">Zero Damage</div></div>
      <div class="room-card-preview"><div class="rname">Net Bill Settlement</div><div class="rsub">UPI Payment Paid</div><div class="rstatus st-vac" style="background:#dbeafe;color:#1d4ed8">₹ 14,850</div></div>
    </div>
  </div>
</div>

<!-- ════ SLIDE 4: GST TAX & DEPARTMENTAL ACCOUNTING ════ -->
<div class="scene" id="s4" style="--d:3.5s">
  <div class="scene-timer-bar"></div>
  <div class="header-box">
    <div class="eyebrow">&#128179; GST Tax &amp; Ledgers</div>
    <div class="title-hero">Account Management <span class="grad-txt">&amp; 18% GST Engine</span></div>
  </div>
  <div class="feature-list-vertical">
    <div class="fitem">
      <div class="ficon">&#128221;</div>
      <div><div class="ftitle">Department-Wise P&amp;L Ledgers</div><div class="fsub">Hotel, Restaurant, Facility, Office, Security &amp; Fire Safety income &amp; net profit.</div></div>
    </div>
    <div class="fitem">
      <div class="ficon">&#128181;</div>
      <div><div class="ftitle">18% GST &amp; GSTR Compliance</div><div class="fsub">CGST (9%) + SGST (9%) breakdown, B2B/B2C invoicing &amp; GSTR-1 / 3B reports.</div></div>
    </div>
  </div>
  <div class="visual-mockup-card">
    <div class="mock-header">
      <span class="mock-title">&#128221; Live Account Management Dashboard</span>
      <span class="mock-badge">₹2,06,750 Profit</span>
    </div>
    <div class="real-shot-frame">
      <img src="{shot_accounts}" alt="Zeebull Account Management"/>
    </div>
  </div>
</div>

<!-- ════ SLIDE 5: VENDORS, POs & STOCK MOVEMENT ════ -->
<div class="scene" id="s5" style="--d:3.5s">
  <div class="scene-timer-bar"></div>
  <div class="header-box">
    <div class="eyebrow">&#128230; Vendor POs &amp; Stock Movement</div>
    <div class="title-hero">Purchases, Vendors <span class="grad-txt">&amp; Stock Movement</span></div>
  </div>
  <div class="feature-list-vertical">
    <div class="fitem">
      <div class="ficon">&#128230;</div>
      <div><div class="ftitle">Vendor POs &amp; GRN Goods Receipt</div><div class="fsub">Supplier GSTIN catalog, PO lifecycle (Draft ➔ Approved ➔ GRN), accounts payable.</div></div>
    </div>
    <div class="fitem">
      <div class="ficon">&#127970;</div>
      <div><div class="ftitle">Stock Movement &amp; Inter-Branch Transfers</div><div class="fsub">Inter-warehouse stock issues, department requisitions, waste write-offs &amp; audit adjustments.</div></div>
    </div>
  </div>
  <div class="visual-mockup-card">
    <div class="mock-header">
      <span class="mock-title">&#128230; Warehouse Stock Movement &amp; Vendor POs</span>
      <span class="mock-badge">Stock Active</span>
    </div>
    <div class="grid-preview-4">
      <div class="room-card-preview"><div class="rname">Purchase Receipts</div><div class="rsub">GRN Stock In From POs</div><div class="rstatus st-vac">GRN Verified</div></div>
      <div class="room-card-preview"><div class="rname">Stock Transfers</div><div class="rsub">Inter-Location Transfers</div><div class="rstatus st-cln">Transferred</div></div>
      <div class="room-card-preview"><div class="rname">Department Issues</div><div class="rsub">Kitchen &amp; HK Releases</div><div class="rstatus st-vac">Issued</div></div>
      <div class="room-card-preview"><div class="rname">Waste &amp; Audit Log</div><div class="rsub">Spoilage &amp; Adjustments</div><div class="rstatus st-vac" style="background:#fee2e2;color:#dc2626">Audited</div></div>
    </div>
  </div>
</div>

<!-- ════ SLIDE 6: FOOD POS, KOT & RECIPE COGS DEDUCTION ════ -->
<div class="scene" id="s6" style="--d:3.5s">
  <div class="scene-timer-bar"></div>
  <div class="header-box">
    <div class="eyebrow">&#127860; Food POS &amp; Recipe COGS</div>
    <div class="title-hero">Food POS &amp; Automated <span class="grad-txt">Recipe COGS</span></div>
  </div>
  <div class="feature-list-vertical">
    <div class="fitem">
      <div class="ficon">&#127859;</div>
      <div><div class="ftitle">Kitchen Order Tickets (KOT)</div><div class="fsub">Instant kitchen order routing, dining table POS &amp; 72 food menu items.</div></div>
    </div>
    <div class="fitem">
      <div class="ficon">&#129383;</div>
      <div><div class="ftitle">Automated Recipe Ingredient Deduction</div><div class="fsub">KOT orders automatically deduct raw recipe ingredients &amp; post COGS to ledgers.</div></div>
    </div>
  </div>
  <div class="visual-mockup-card">
    <div class="mock-header">
      <span class="mock-title">&#127859; Live KOT Orders &amp; Recipe Stock Deduction</span>
      <span class="mock-badge" style="background:#fef3c7;color:#d97706">COGS Active</span>
    </div>
    <div class="grid-preview-4">
      <div class="room-card-preview"><div class="rname">Grilled Lobster x2</div><div class="rsub">Recipe: 1.0kg Lobster</div><div class="rstatus st-vac">Deducted 1.0kg</div></div>
      <div class="room-card-preview"><div class="rname">Club Sandwich x1</div><div class="rsub">Recipe: Bread &amp; Butter</div><div class="rstatus st-cln">Deducted 0.1kg</div></div>
      <div class="room-card-preview"><div class="rname">Fresh Juice x3</div><div class="rsub">Recipe: Fresh Fruits</div><div class="rstatus st-vac">Deducted 0.5kg</div></div>
      <div class="room-card-preview"><div class="rname">COGS Posting</div><div class="rsub">Automatic Ledger Debit</div><div class="rstatus st-vac" style="background:#dcfce7;color:#16a34a">₹ 12,400 COGS</div></div>
    </div>
  </div>
</div>

<!-- ════ SLIDE 7: RESORT ADMIN DASHBOARD ════ -->
<div class="scene" id="s7" style="--d:3.5s">
  <div class="scene-timer-bar"></div>
  <div class="header-box">
    <div class="eyebrow">&#128104;&#8205;&#128188; Admin Command Center</div>
    <div class="title-hero">Zeebull Resort Admin <span class="grad-txt">&amp; Quick Actions</span></div>
  </div>
  <div class="feature-list-vertical">
    <div class="fitem">
      <div class="ficon">&#128084;</div>
      <div><div class="ftitle">Real-Time Revenue &amp; RevPAR</div><div class="fsub">Total revenue (₹97,920), ADR (₹2,176), RevPAR (₹6,528) &amp; 16 active staff.</div></div>
    </div>
    <div class="fitem">
      <div class="ficon">&#9889;</div>
      <div><div class="ftitle">1-Click Quick Action Controls</div><div class="fsub">Instant guest Check In, Check Out, Food Order, Assign Service &amp; Inventory.</div></div>
    </div>
  </div>
  <div class="visual-mockup-card">
    <div class="mock-header">
      <span class="mock-title">&#128104;&#8205;&#128188; Live Zeebull Resort Admin Dashboard</span>
      <span class="mock-badge">ADR ₹2,176</span>
    </div>
    <div class="real-shot-frame">
      <img src="{shot_admin_dash}" alt="Zeebull Resort Admin Dashboard"/>
    </div>
  </div>
</div>

<!-- ════ SLIDE 8: WEB MANAGEMENT CMS & QR CODE ════ -->
<div class="scene" id="s8" style="--d:3.5s">
  <div class="scene-timer-bar"></div>
  <div class="header-box">
    <div class="eyebrow">&#127760; Website Console CMS</div>
    <div class="title-hero">WEB Management <span class="grad-txt">&amp; Banners</span></div>
  </div>
  <div class="feature-list-vertical">
    <div class="fitem">
      <div class="ficon">&#127760;</div>
      <div><div class="ftitle">Resort Web Content Management</div><div class="fsub">Curate header banners, photo galleries, guest reviews, experiences &amp; weddings.</div></div>
    </div>
    <div class="fitem">
      <div class="ficon">&#128248;</div>
      <div><div class="ftitle">Live Resort Showcase CMS</div><div class="fsub">Sky view banners, Eco friendly stay packages &amp; attraction banner toggles.</div></div>
    </div>
  </div>
  <div class="visual-mockup-card">
    <div class="mock-header">
      <span class="mock-title">&#127760; Live Website Console WEB Management</span>
      <span class="mock-badge">Active Banners</span>
    </div>
    <div class="real-shot-frame">
      <img src="{shot_web_console}" alt="Zeebull Website Console CMS"/>
    </div>
  </div>
</div>

<!-- ════ SLIDE 9: NATIVE MOBILE APP DRAWER (RBAC MANAGER) ════ -->
<div class="scene" id="s9" style="--d:3.5s">
  <div class="scene-timer-bar"></div>
  <div class="header-box">
    <div class="eyebrow">&#128241; Zeebull Native Mobile App</div>
    <div class="title-hero">16-Module Manager <span class="grad-txt">Navigation Drawer</span></div>
  </div>
  <div class="feature-list-vertical">
    <div class="fitem">
      <div class="ficon">&#128241;</div>
      <div><div class="ftitle">Native Mobile App Manager Menu</div><div class="fsub">Direct access to Bookings, Check-Out, Stock, Payroll, Tasks &amp; Reports.</div></div>
    </div>
  </div>
  <div class="phone-mock-short">
    <img src="{shot_mobile_drawer}" alt="Zeebull Native Mobile App Navigation Drawer"/>
  </div>
</div>

<!-- ════ SLIDE 10: HIGH IMPACT CTA CLOSER WITH DUAL PHONE NUMBERS ════ -->
<div class="scene" id="s10" style="--d:4.5s">
  <div class="scene-timer-bar"></div>
  <img class="cta-logo" src="{logo_data}" alt="TeqMates"/>
  <div class="cta-head">Build Your Custom <span class="grad-txt">Software</span></div>
  <div class="cta-dual-box">
    <div class="cta-btn">
      <span style="font-size:36px">&#128222;</span>
      <span class="cta-num">+91 99612 39861</span>
    </div>
    <div class="cta-btn" style="margin-top:0;">
      <span style="font-size:36px">&#128241;</span>
      <span class="cta-num">+91 90358 10416</span>
    </div>
  </div>
  <div class="cta-foot">&#127760; <span>teqmates.com</span> &nbsp;&middot;&nbsp; Kerala, India</div>
</div>

<script>
/* ── ADVANCED LIGHT PLEXUS CANVAS FOR 9:16 ── */
const cv=document.getElementById("bg-canvas"),cx=cv.getContext("2d");
function rsz(){{cv.width=1080;cv.height=1920;}}
rsz();

const pts=Array.from({{length:90}},()=>({{
  x:Math.random()*cv.width,y:Math.random()*cv.height,
  r:Math.random()*2.2+0.6,
  dx:(Math.random()-0.5)*0.4,dy:(Math.random()-0.5)*0.4,
  a:Math.random()*0.25+0.06
}}));

(function drawFrame(){{
  cx.clearRect(0,0,cv.width,cv.height);
  pts.forEach(p=>{{
    cx.beginPath();cx.arc(p.x,p.y,p.r,0,Math.PI*2);
    cx.fillStyle=`rgba(0,168,107,${{p.a}})`;cx.fill();
    p.x+=p.dx;p.y+=p.dy;
    if(p.x<0||p.x>cv.width)p.dx*=-1;if(p.y<0||p.y>cv.height)p.dy*=-1;
  }});
  for(let i=0;i<pts.length;i++)for(let j=i+1;j<pts.length;j++){{
    const dx=pts[i].x-pts[j].x,dy=pts[i].y-pts[j].y,d=Math.sqrt(dx*dx+dy*dy);
    if(d<160){{
      cx.beginPath();cx.moveTo(pts[i].x,pts[i].y);cx.lineTo(pts[j].x,pts[j].y);
      cx.strokeStyle=`rgba(0,168,107,${{0.07*(1-d/160)}})`;cx.lineWidth=1.0;cx.stroke();
    }}
  }}
  requestAnimationFrame(drawFrame);
}})();

const IDS=["s1","s2","s3","s4","s5","s6","s7","s8","s9","s10"];
const DURS=[3500,3500,3500,3500,3500,3500,3500,3500,3500,4500];
const TOTAL=DURS.reduce((a,b)=>a+b,0);
let cur=0,elapsed=0,last=performance.now();

function switchScene(idx){{
  const oldEl=document.getElementById(IDS[cur]);
  oldEl.classList.remove("active");
  oldEl.classList.add("exit");
  setTimeout(()=>oldEl.classList.remove("exit"),600);
  
  cur=idx;
  const newEl=document.getElementById(IDS[cur]);
  newEl.classList.add("active");
  
  const tb=newEl.querySelector(".scene-timer-bar");
  if(tb){{tb.style.animation="none";void tb.offsetWidth;tb.style.animation="";}}
}}

function loopTick(now){{
  const dt=now-last;last=now;elapsed+=dt;
  document.getElementById("pbar").style.width=Math.min(elapsed/TOTAL*100,100)+"%";
  let acc=0;
  for(let i=0;i<DURS.length;i++){{acc+=DURS[i];if(elapsed<acc){{if(cur!==i)switchScene(i);break;}}}}
  if(elapsed>=TOTAL){{elapsed=0;switchScene(0);}}
  requestAnimationFrame(loopTick);
}}
requestAnimationFrame(loopTick);
</script>
</body>
</html>"""

out_file = r'c:\releasing\New Orchid\scratch\zeebull_shorts.html'
with open(out_file, 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f"SUCCESS: 100% Ultimate Feature Showcase 9:16 Shorts {out_file} compiled cleanly! File size: {len(html_content):,} bytes")
