import base64
import os

def b64(path, mime='png'):
    with open(path, 'rb') as f:
        return f"data:image/{mime};base64,{base64.b64encode(f.read()).decode()}"

print("Encoding light theme assets with Arabic E-Commerce & Zeebull Employee/Owner App highlights...")
logo_data   = b64(r'c:\releasing\New Orchid\scratch\logo_light_mode.png', 'png')
hero_data   = b64(r'c:\releasing\New Orchid\scratch\ss_hero.png', 'png')
app_data    = b64(r'c:\releasing\New Orchid\scratch\app_kozmo_home.jpg', 'jpeg')

html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<title>TeqMates – Arabic E-Commerce &amp; Zeebull Apps Commercial</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&family=Space+Grotesk:wght@500;700;800&display=swap" rel="stylesheet"/>
<style>
*{{margin:0;padding:0;box-sizing:border-box;}}
html,body{{width:100vw;height:100vh;overflow:hidden;background:#f8faf9;font-family:'Plus Jakarta Sans',sans-serif;color:#0f172a;}}

/* ═════ 100% UNIFORM SEAMLESS LIGHT BACKGROUND ═════ */
#bg-canvas{{position:fixed;inset:0;z-index:1;pointer-events:none;}}

.beam{{position:fixed;width:900px;height:900px;border-radius:50%;filter:blur(200px);opacity:0.18;pointer-events:none;z-index:0;}}
.b1{{background:radial-gradient(circle,#bbf7d0,transparent 70%);top:-300px;left:-200px;}}
.b2{{background:radial-gradient(circle,#e0f2fe,transparent 70%);bottom:-300px;right:-200px;}}

/* ═════ TOP BRANDING BAR ═════ */
.top-nav{{
  position:fixed;top:24px;left:32px;right:32px;z-index:1000;
  display:flex;align-items:center;justify-content:space-between;
  pointer-events:none;
}}
.brand-pill{{
  display:flex;align-items:center;gap:14px;
  background:rgba(255,255,255,0.95);border:1px solid rgba(0,168,107,0.35);
  padding:10px 22px;border-radius:100px;backdrop-filter:blur(20px);
  box-shadow:0 15px 35px rgba(0,0,0,0.05), 0 0 25px rgba(0,168,107,0.12);
  pointer-events:auto;
}}
.brand-pill img{{height:32px;object-fit:contain;}}
.live-badge{{
  display:flex;align-items:center;gap:8px;background:rgba(255,255,255,0.92);
  border:1px solid rgba(0,168,107,0.3);padding:8px 18px;border-radius:100px;
  backdrop-filter:blur(12px);font-size:12px;font-weight:700;color:#0f172a;
  box-shadow:0 10px 25px rgba(0,0,0,0.04);
}}
.pulse-dot{{width:8px;height:8px;border-radius:50%;background:#00a86b;box-shadow:0 0 12px #00a86b;animation:pdot 1.5s infinite;}}
@keyframes pdot{{0%,100%{{transform:scale(1);opacity:1;}}50%{{transform:scale(1.5);opacity:0.4;}}}}

/* ═════ SCENE SYSTEM WITH PERFECT FULL-FRAME CENTERING ═════ */
.scene{{position:fixed;inset:0;display:flex;align-items:center;justify-content:center;
  opacity:0;pointer-events:none;z-index:5;background:transparent;
  transition:transform 0.95s cubic-bezier(0.16,1,0.3,1), opacity 0.75s ease, filter 0.8s ease;
  transform:scale(0.9) translateY(40px) rotateX(4deg);filter:blur(14px);}}
.scene.active{{opacity:1;pointer-events:auto;z-index:10;transform:scale(1) translateY(0) rotateX(0deg);filter:blur(0px);}}
.scene.exit{{opacity:0;transform:scale(1.08) translateY(-40px) rotateX(-4deg);filter:blur(14px);z-index:4;}}

/* ═════ KINETIC TYPOGRAPHY & CHIPS ═════ */
.eyebrow{{
  font-family:'Space Grotesk',sans-serif;font-size:13px;font-weight:800;letter-spacing:6px;
  color:#00a86b;text-transform:uppercase;margin-bottom:18px;
  display:inline-flex;align-items:center;gap:10px;
  opacity:0;transform:translateY(-18px);transition:all 0.65s cubic-bezier(0.16,1,0.3,1);transition-delay:0.25s;
}}
.eyebrow::before{{content:'';width:8px;height:8px;border-radius:50%;background:#00a86b;box-shadow:0 0 14px #00a86b;}}
.title-hero{{
  font-size:clamp(36px,4.8vw,62px);font-weight:900;line-height:1.1;letter-spacing:-2px;
  margin-bottom:22px;opacity:0;transform:translateY(32px);color:#0f172a;
  transition:all 0.85s cubic-bezier(0.16,1,0.3,1);transition-delay:0.45s;
}}
.desc-text{{
  font-size:16.5px;color:#475569;line-height:1.8;max-width:580px;
  opacity:0;transform:translateY(22px);
  transition:all 0.75s ease;transition-delay:0.68s;
}}
.chip-row{{
  display:flex;flex-wrap:wrap;gap:12px;margin-top:28px;
  opacity:0;transform:translateY(18px);
  transition:all 0.7s ease;transition-delay:0.88s;
}}
.tech-chip{{
  background:rgba(0,168,107,0.1);border:1px solid rgba(0,168,107,0.35);
  box-shadow:0 10px 20px rgba(0,168,107,0.1);
  border-radius:100px;padding:8px 22px;font-size:13px;font-weight:700;color:#00a86b;
}}
.scene.active .eyebrow,.scene.active .title-hero,.scene.active .desc-text,.scene.active .chip-row{{
  opacity:1;transform:translateY(0);
}}

.grad-txt{{
  background:linear-gradient(135deg,#0f172a 10%,#00a86b 65%,#0284c7 100%);
  -webkit-background-clip:text;-webkit-text-fill-color:transparent;
}}

/* ═════ SCENE 1: INTRO ═════ */
#s1{{}}
.s1-wrap{{text-align:center;z-index:10;max-width:900px;position:relative;}}
.s1-logo-box{{position:relative;display:inline-block;margin-bottom:30px;}}
.s1-logo-box::after{{
  content:'';position:absolute;inset:-40px;border-radius:50%;
  background:radial-gradient(circle,rgba(0,168,107,0.2),transparent 70%);
  filter:blur(30px);z-index:-1;animation:glowPulse 3s ease-in-out infinite alternate;
}}
@keyframes glowPulse{{from{{transform:scale(0.9);opacity:0.6;}}to{{transform:scale(1.15);opacity:1;}}}}
.s1-logo-img{{width:470px;opacity:0;transform:scale(0.65) rotate(-3deg);
  filter:drop-shadow(0 15px 35px rgba(0,168,107,0.2));
  transition:all 1.3s cubic-bezier(0.16,1,0.3,1);transition-delay:0.3s;}}
.s1-subtitle{{
  font-family:'Space Grotesk',sans-serif;font-size:16px;font-weight:700;letter-spacing:12px;
  color:#00a86b;text-transform:uppercase;margin-top:10px;
  opacity:0;transform:translateY(20px);transition:all 0.8s ease;transition-delay:0.85s;
}}
.s1-tagline{{
  font-size:24px;font-weight:800;color:#1e293b;margin-top:16px;letter-spacing:-0.5px;
  opacity:0;transform:translateY(20px);transition:all 0.8s ease;transition-delay:1.1s;
}}
.s1-bar{{
  width:0;height:4px;margin:28px auto 0;border-radius:2px;
  background:linear-gradient(90deg,transparent,#00a86b,#0284c7,transparent);
  transition:width 1.2s cubic-bezier(0.16,1,0.3,1);transition-delay:1.35s;
}}
#s1.active .s1-logo-img{{opacity:1;transform:scale(1) rotate(0deg);}}
#s1.active .s1-subtitle,#s1.active .s1-tagline{{opacity:1;transform:translateY(0);}}
#s1.active .s1-bar{{width:360px;}}

/* ═════ SCENE 2: WEB PLATFORM & ARABIC MULTI-LINGUAL SUPPORT ═════ */
#s2{{}}
.s2-stage{{
  display:grid;grid-template-columns:1fr 1.15fr;gap:50px;
  max-width:1240px;width:100%;padding:0 50px;align-items:center;z-index:10;
}}
.browser-mockup{{
  background:#ffffff;border:1px solid rgba(0,168,107,0.35);border-radius:20px;
  box-shadow:0 35px 90px rgba(0,0,0,0.08), 0 0 40px rgba(0,168,107,0.12);
  overflow:hidden;transform:rotateY(-12deg) rotateX(5deg);
  opacity:0;transition:all 1.1s cubic-bezier(0.16,1,0.3,1);transition-delay:0.35s;
}}
#s2.active .browser-mockup{{opacity:1;transform:rotateY(0deg) rotateX(0deg);}}
.browser-bar{{
  height:38px;background:#f1f5f9;border-bottom:1px solid #e2e8f0;
  display:flex;align-items:center;padding:0 14px;gap:8px;
}}
.bdot{{width:10px;height:10px;border-radius:50%;}}
.url-bar-mock{{
  flex:1;margin:0 16px;height:24px;background:#ffffff;border-radius:6px;border:1px solid #cbd5e1;
  display:flex;align-items:center;padding:0 12px;font-size:11px;color:#00a86b;
  font-family:'Space Grotesk',sans-serif;letter-spacing:1px;font-weight:700;
}}
.browser-content{{height:350px;overflow:hidden;position:relative;}}
.browser-content img{{
  width:100%;height:auto;object-fit:cover;object-position:top;
  animation:webAutoScroll 9s ease-in-out infinite alternate;
}}
@keyframes webAutoScroll{{0%,20%{{object-position:top;}}80%,100%{{object-position:bottom;}}}}

/* ═════ SCENE 3: DASHBOARD ═════ */
#s3{{}}
.s3-stage{{
  display:grid;grid-template-columns:1fr 1.1fr;gap:60px;
  max-width:1200px;width:100%;padding:0 50px;align-items:center;z-index:10;
}}
.dash-mock{{
  background:rgba(255,255,255,0.96);border:1px solid rgba(0,168,107,0.35);
  border-radius:24px;padding:26px;box-shadow:0 35px 90px rgba(0,0,0,0.07), 0 0 45px rgba(0,168,107,0.12);
  backdrop-filter:blur(20px);transform:rotateY(-12deg) rotateX(6deg);
  transition:all 0.95s cubic-bezier(0.16,1,0.3,1);transition-delay:0.35s;
  opacity:0;
}}
#s3.active .dash-mock{{opacity:1;transform:rotateY(0deg) rotateX(0deg);}}
.dash-topbar{{display:flex;align-items:center;gap:8px;margin-bottom:20px;border-bottom:1px solid #e2e8f0;padding-bottom:14px;}}
.tdot{{width:11px;height:11px;border-radius:50%;}}
.dash-metrics{{display:grid;grid-template-columns:repeat(3,1fr);gap:14px;margin-bottom:20px;}}
.dm-card{{background:#f8fafc;border:1px solid #e2e8f0;border-radius:14px;padding:16px 14px;box-shadow:0 6px 15px rgba(0,0,0,0.02);}}
.dm-val{{font-size:26px;font-weight:900;color:#00a86b;font-family:'Space Grotesk',sans-serif;}}
.dm-lbl{{font-size:11px;color:#64748b;text-transform:uppercase;letter-spacing:1px;margin-top:4px;font-weight:700;}}
.dash-chart{{height:120px;background:#f1f5f9;border-radius:14px;padding:14px;position:relative;display:flex;align-items:flex-end;gap:12px;}}
.cbar{{flex:1;background:linear-gradient(180deg,#00a86b,#059669);border-radius:6px 6px 0 0;height:0;transition:height 1.5s cubic-bezier(0.16,1,0.3,1);}}
#s3.active .cbar:nth-child(1){{height:55%;transition-delay:0.5s;}}
#s3.active .cbar:nth-child(2){{height:85%;transition-delay:0.65s;}}
#s3.active .cbar:nth-child(3){{height:65%;transition-delay:0.8s;}}
#s3.active .cbar:nth-child(4){{height:95%;transition-delay:0.95s;}}
#s3.active .cbar:nth-child(5){{height:75%;transition-delay:1.1s;}}
#s3.active .cbar:nth-child(6){{height:100%;transition-delay:1.25s;}}

/* ═════ SCENE 4: MOBILE APPS & ZEEBULL EMPLOYEE / OWNER APP ═════ */
#s4{{}}
.s4-stage{{
  display:grid;grid-template-columns:1fr 1.1fr;gap:50px;
  max-width:1200px;width:100%;padding:0 50px;align-items:center;z-index:10;
}}
.phone-mock-hero{{
  width:275px;height:550px;background:#ffffff;border:4px solid #00a86b;
  border-radius:46px;box-shadow:0 40px 100px rgba(0,0,0,0.08), 0 0 50px rgba(0,168,107,0.22);
  overflow:hidden;position:relative;margin:0 auto;
  transform:translateY(40px) rotateY(-15deg);opacity:0;
  transition:all 1.05s cubic-bezier(0.16,1,0.3,1);transition-delay:0.4s;
}}
#s4.active .phone-mock-hero{{opacity:1;transform:translateY(0) rotateY(0deg);}}
.phone-mock-hero img{{width:100%;height:auto;min-height:100%;object-fit:cover;object-position:top;
  animation:appScroll 10s ease-in-out infinite alternate;}}
@keyframes appScroll{{0%,15%{{object-position:top;}}85%,100%{{object-position:bottom;}}}}
.pnotch-hero{{position:absolute;top:0;left:50%;transform:translateX(-50%);width:115px;height:24px;
  background:#f1f5f9;border-bottom-left-radius:14px;border-bottom-right-radius:14px;z-index:20;}}

/* ═════ SCENE 5: INDUSTRY VERTICALS ═════ */
#s5{{}}
.s5-wrap{{z-index:10;text-align:center;max-width:1240px;width:100%;padding:0 36px;position:relative;}}
.ind-grid{{display:grid;grid-template-columns:repeat(4,1fr);gap:22px;margin-top:38px;}}
.ind-card{{
  background:rgba(255,255,255,0.96);border:1px solid rgba(0,168,107,0.35);
  border-radius:24px;padding:36px 24px;text-align:center;backdrop-filter:blur(20px);
  box-shadow:0 20px 45px rgba(0,0,0,0.05), 0 0 25px rgba(0,168,107,0.08);
  position:relative;overflow:hidden;opacity:0;transform:translateY(38px) scale(0.92) rotateX(6deg);
  transition:all 0.8s cubic-bezier(0.16,1,0.3,1);
}}
.ind-card::before{{
  content:'';position:absolute;inset:0;
  background:radial-gradient(circle at 50% 0%,rgba(0,168,107,0.16),transparent 70%);
  opacity:0;transition:opacity 0.4s;
}}
.ind-card:hover::before{{opacity:1;}}
.ind-icon-box{{
  width:72px;height:72px;margin:0 auto 22px;border-radius:22px;
  background:rgba(0,168,107,0.12);border:1px solid rgba(0,168,107,0.35);
  display:grid;place-items:center;font-size:32px;
  box-shadow:0 10px 25px rgba(0,168,107,0.18);animation:icofloat 4s ease-in-out infinite alternate;
}}
@keyframes icofloat{{from{{transform:translateY(0);}}to{{transform:translateY(-8px);}}}}
.ind-t{{font-size:18px;font-weight:800;color:#0f172a;margin-bottom:10px;}}
.ind-d{{font-size:13px;color:#475569;line-height:1.65;}}
.ind-card:nth-child(1){{transition-delay:0.4s;}}
.ind-card:nth-child(2){{transition-delay:0.55s;}}
.ind-card:nth-child(3){{transition-delay:0.7s;}}
.ind-card:nth-child(4){{transition-delay:0.85s;}}
#s5.active .ind-card{{opacity:1;transform:translateY(0) scale(1) rotateX(0deg);}}

/* ═════ SCENE 6: FEATURED CLIENTS (EXPLICIT ZEEBULL EMPLOYEE/OWNER APP & ARABIC WEBSITE) ═══ */
#s6{{}}
.s6-container{{
  z-index:10;text-align:center;max-width:1280px;width:100%;padding:0 36px;
  display:flex;flex-direction:column;align-items:center;gap:32px;
}}
.s6-top{{
  font-size:clamp(32px,4.2vw,48px);font-weight:900;letter-spacing:-1.5px;color:#0f172a;
  opacity:0;transform:translateY(-20px);transition:all 0.8s ease;transition-delay:0.3s;
}}
#s6.active .s6-top{{opacity:1;transform:translateY(0);}}
.client-grid-5{{
  display:grid;grid-template-columns:repeat(5,1fr);gap:18px;width:100%;
}}
.ccard{{
  background:rgba(255,255,255,0.96);border:1px solid rgba(0,168,107,0.35);
  border-radius:24px;padding:30px 20px;backdrop-filter:blur(20px);
  box-shadow:0 25px 50px rgba(0,0,0,0.06), 0 0 30px rgba(0,168,107,0.12);
  text-align:left;position:relative;overflow:hidden;
  opacity:0;transform:translateY(36px);transition:all 0.75s cubic-bezier(0.16,1,0.3,1);
}}
.ccard:nth-child(1){{transition-delay:0.4s;}}
.ccard:nth-child(2){{transition-delay:0.55s;border-color:rgba(0,168,107,0.5);box-shadow:0 15px 35px rgba(0,168,107,0.2);}}
.ccard:nth-child(3){{transition-delay:0.7s;border-color:rgba(0,168,107,0.5);box-shadow:0 15px 35px rgba(0,168,107,0.2);}}
.ccard:nth-child(4){{transition-delay:0.85s;}}
.ccard:nth-child(5){{transition-delay:1.0s;}}
#s6.active .ccard{{opacity:1;transform:translateY(0);}}
.cctag{{font-family:'Space Grotesk',sans-serif;font-size:10.5px;font-weight:800;letter-spacing:2.5px;color:#00a86b;text-transform:uppercase;margin-bottom:12px;}}
.ccname{{font-size:18px;font-weight:900;color:#0f172a;margin-bottom:8px;}}
.ccdesc{{font-size:12.5px;color:#475569;line-height:1.6;}}

.s6-trust-banner{{
  display:inline-flex;align-items:center;gap:16px;
  background:rgba(255,255,255,0.95);border:1px solid rgba(0,168,107,0.35);
  padding:14px 32px;border-radius:100px;box-shadow:0 10px 25px rgba(0,168,107,0.12);
  font-size:14px;font-weight:700;color:#334155;
  opacity:0;transform:translateY(20px);transition:all 0.7s ease;transition-delay:1.2s;
}}
.s6-trust-banner span{{color:#00a86b;font-weight:900;}}
#s6.active .s6-trust-banner{{opacity:1;transform:translateY(0);}}

/* ═════ SCENE 7: CTA ═════ */
#s7{{}}
.cta-stage{{text-align:center;z-index:10;max-width:900px;padding:0 40px;position:relative;}}
.cta-logo-img{{width:340px;margin:0 auto 36px;opacity:0;transform:scale(0.75);
  filter:drop-shadow(0 15px 35px rgba(0,168,107,0.25));
  transition:all 1.2s cubic-bezier(0.16,1,0.3,1);transition-delay:0.2s;}}
.cta-headline{{font-size:clamp(48px,7.5vw,88px);font-weight:900;line-height:1.02;letter-spacing:-3px;margin-bottom:24px;opacity:0;transform:translateY(30px);transition:all 0.95s cubic-bezier(0.16,1,0.3,1);transition-delay:0.65s;color:#0f172a;}}
.cta-subtext{{font-size:18px;color:#475569;max-width:540px;margin:0 auto 40px;line-height:1.75;opacity:0;transform:translateY(20px);transition:all 0.75s ease;transition-delay:0.95s;}}
.cta-button-glow{{
  display:inline-flex;align-items:center;gap:16px;
  background:rgba(0,168,107,0.12);border:2px solid rgba(0,168,107,0.5);
  border-radius:100px;padding:20px 48px;margin-bottom:20px;
  box-shadow:0 15px 35px rgba(0,168,107,0.25);
  opacity:0;transform:translateY(20px);transition:all 0.75s ease;transition-delay:1.25s;
  animation:btnPulse 2.5s ease-in-out infinite;
}}
@keyframes btnPulse{{0%,100%{{box-shadow:0 10px 25px rgba(0,168,107,0.2);}}50%{{box-shadow:0 20px 45px rgba(0,168,107,0.35);border-color:#00a86b;}}}}
.cta-phone-text{{font-family:'Space Grotesk',sans-serif;font-size:32px;font-weight:900;color:#00a86b;letter-spacing:2px;}}
.cta-website-foot{{font-size:15px;color:#64748b;margin-top:10px;letter-spacing:1px;opacity:0;transition:all 0.6s ease;transition-delay:1.5s;}}
.cta-website-foot span{{color:#00a86b;font-weight:700;}}

#s7.active .cta-logo-img{{opacity:1;transform:scale(1);}}
#s7.active .cta-headline{{opacity:1;transform:translateY(0);}}
#s7.active .cta-subtext{{opacity:1;transform:translateY(0);}}
#s7.active .cta-button-glow{{opacity:1;transform:translateY(0);}}
#s7.active .cta-website-foot{{opacity:1;}}

/* ═════ HUD PROGRESS BAR & DOTS ═════ */
.top-prog{{position:fixed;bottom:0;left:0;height:4px;background:linear-gradient(90deg,#00a86b,#0284c7,#d97706);z-index:1000;transition:width 0.1s linear;}}
.scene-dots{{position:fixed;bottom:20px;left:50%;transform:translateX(-50%);display:flex;gap:10px;z-index:1000;}}
.sdot{{width:6px;height:6px;border-radius:50%;background:rgba(15,23,42,0.2);cursor:pointer;transition:all 0.35s;}}
.sdot.active-dot{{background:#00a86b;width:24px;border-radius:4px;box-shadow:0 0 12px #00a86b;}}
.scene-timer-bar{{position:absolute;bottom:0;left:0;height:2px;background:rgba(0,168,107,0.5);z-index:20;width:0;}}
.scene.active .scene-timer-bar{{animation:tbFill var(--d,5s) linear forwards;}}
@keyframes tbFill{{to{{width:100%;}}}}
</style>
</head>
<body>

<!-- Ambient Light Orbs -->
<div class="beam b1"></div>
<div class="beam b2"></div>

<!-- Interactive Particle Physics Canvas -->
<canvas id="bg-canvas"></canvas>

<!-- TOP NAV BRANDING BAR (LIGHT MODE TRANSPARENT LOGO) -->
<div class="top-nav">
  <div class="brand-pill">
    <img src="{logo_data}" alt="TeqMates Logo"/>
  </div>
  <div class="live-badge">
    <span class="pulse-dot"></span>
    <span>Software Agency &middot; Kerala, India</span>
  </div>
</div>

<!-- HUD -->
<div class="top-prog" id="pbar"></div>
<div class="scene-dots" id="dots-wrap"></div>

<!-- ════ SCENE 1: CINEMATIC TRAILER INTRO ════ -->
<div class="scene active" id="s1" style="--d:4.5s">
  <div class="scene-timer-bar"></div>
  <div class="s1-wrap">
    <div class="s1-logo-box"><img class="s1-logo-img" src="{logo_data}" alt="TeqMates"/></div>
    <div class="s1-subtitle">Software Development Company</div>
    <div class="s1-tagline">Architecting High-Performance Digital Products</div>
    <div class="s1-bar"></div>
  </div>
</div>

<!-- ════ SCENE 2: WEB PLATFORM & ARABIC MULTI-LINGUAL SUPPORT ════ -->
<div class="scene" id="s2" style="--d:6s">
  <div class="scene-timer-bar"></div>
  <div class="s2-stage">
    <div>
      <div class="eyebrow">&#127760; teqmates.com</div>
      <div class="title-hero">Innovative <span class="grad-txt">Software Solutions</span> &amp; Portals</div>
      <div class="desc-text">Your technology partner for Custom Software, Multi-lingual Arabic &amp; English E-Commerce Portals, Mobile Apps, UI/UX Design, and Cloud Infrastructure.</div>
      <div class="chip-row">
        <span class="tech-chip">&#9889; CODE YOUR VIBE</span>
        <span class="tech-chip">&#127760; Arabic / English Multi-lingual</span>
      </div>
    </div>
    <div class="browser-mockup">
      <div class="browser-bar">
        <div class="bdot" style="background:#ff5f57"></div>
        <div class="bdot" style="background:#ffbd2e"></div>
        <div class="bdot" style="background:#28c840"></div>
        <div class="url-bar-mock">🔒 https://pommastore.com (العربية / EN)</div>
      </div>
      <div class="browser-content">
        <img src="{hero_data}" alt="Pommastore Arabic E-Commerce"/>
      </div>
    </div>
  </div>
</div>

<!-- ════ SCENE 3: DASHBOARD ════ -->
<div class="scene" id="s3" style="--d:6s">
  <div class="scene-timer-bar"></div>
  <div class="s3-stage">
    <div>
      <div class="eyebrow">&#9881;&#65039; Core Architecture</div>
      <div class="title-hero">Scalable <span class="grad-txt">Cloud Systems</span> &amp; ERP</div>
      <div class="desc-text">We build high-concurrency microservices, real-time analytics engines, and multi-tenant SaaS dashboards engineered for modern business scale.</div>
      <div class="chip-row">
        <span class="tech-chip">FastAPI / Python</span>
        <span class="tech-chip">React &amp; Next.js</span>
        <span class="tech-chip">Docker &amp; GCP</span>
      </div>
    </div>
    <div class="dash-mock">
      <div class="dash-topbar">
        <div class="tdot" style="background:#ff5f57"></div>
        <div class="tdot" style="background:#ffbd2e"></div>
        <div class="tdot" style="background:#28c840"></div>
        <span style="font-size:11px;color:#64748b;margin-left:12px;font-family:'Space Grotesk';font-weight:700">TEQMATES CLOUD PLATFORM</span>
      </div>
      <div class="dash-metrics">
        <div class="dm-card"><div class="dm-val" id="c1">0</div><div class="dm-lbl">Active Clients</div></div>
        <div class="dm-card"><div class="dm-val" id="c2" style="color:#0284c7">0%</div><div class="dm-lbl">Uptime</div></div>
        <div class="dm-card"><div class="dm-val" id="c3" style="color:#d97706">0</div><div class="dm-lbl">Projects</div></div>
      </div>
      <div class="dash-chart">
        <div class="cbar"></div><div class="cbar"></div><div class="cbar"></div>
        <div class="cbar"></div><div class="cbar"></div><div class="cbar"></div>
      </div>
    </div>
  </div>
</div>

<!-- ════ SCENE 4: MOBILE APPS & ZEEBULL EMPLOYEE / OWNER APPS ════ -->
<div class="scene" id="s4" style="--d:6.5s">
  <div class="scene-timer-bar"></div>
  <div class="s4-stage">
    <div>
      <div class="eyebrow">&#128241; Mobile First Strategy</div>
      <div class="title-hero">High Performance <span class="grad-txt">Mobile Apps</span></div>
      <div class="desc-text">We design &amp; engineer intuitive Flutter cross-platform mobile applications for iOS and Android with real-time sync, offline mode, and push notifications.</div>
      <div class="chip-row">
        <span class="tech-chip">&#127968; Zeebull Employee &amp; Owner App</span>
        <span class="tech-chip">&#128717;&#65039; Kozmocart &amp; Pommastore App</span>
      </div>
    </div>
    <div class="phone-mock-hero">
      <div class="pnotch-hero"></div>
      <img src="{app_data}" alt="Mobile App Screen"/>
    </div>
  </div>
</div>

<!-- ════ SCENE 5: INDUSTRY VERTICALS ════ -->
<div class="scene" id="s5" style="--d:6.5s">
  <div class="scene-timer-bar"></div>
  <div class="s5-wrap">
    <div class="eyebrow" style="justify-content:center">&#128736;&#65039; Industry Verticals</div>
    <div class="title-hero">Empowering Key <span class="grad-txt">Industries</span></div>
    <div class="ind-grid">
      <div class="ind-card">
        <div class="ind-icon-box">&#127968;</div>
        <div class="ind-t">Hospitality &amp; PMS</div>
        <div class="ind-d">Zeebull HMS with Guest, Employee &amp; Owner Mobile Apps &amp; Resort PMS.</div>
      </div>
      <div class="ind-card">
        <div class="ind-icon-box">&#128717;&#65039;</div>
        <div class="ind-t">Arabic E-Commerce</div>
        <div class="ind-d">Arabic &amp; English Perfume Portals (Pommastore.com &amp; Kozmocart.com) with AED currency.</div>
      </div>
      <div class="ind-card">
        <div class="ind-icon-box">&#127958;</div>
        <div class="ind-t">Travel &amp; Tourism</div>
        <div class="ind-d">Curated holiday portals, vacation package booking engines &amp; dynamic itinerary management.</div>
      </div>
      <div class="ind-card">
        <div class="ind-icon-box">&#127970;</div>
        <div class="ind-t">Enterprise ERP</div>
        <div class="ind-d">Luxury fragrance &amp; manufacturing ERP systems, GST billing, stock &amp; supply chain tracking.</div>
      </div>
    </div>
  </div>
</div>

<!-- ════ SCENE 6: FEATURED CLIENTS (EXPLICIT ZEEBULL EMPLOYEE/OWNER APP & ARABIC STORE) ═══ -->
<div class="scene" id="s6" style="--d:6.5s">
  <div class="scene-timer-bar"></div>
  <div class="s6-container">
    <div class="s6-top">&#10024; Featured Clients &amp; Trusted Platforms</div>
    <div class="client-grid-5">
      <div class="ccard"><div class="cctag">Arabic Shopping Portal</div><div class="ccname">&#128717;&#65039; Kozmocart.com</div><div class="ccdesc">Multi-brand e-commerce mobile platform with Arabic &amp; English support.</div></div>
      <div class="ccard"><div class="cctag">Arabic Fragrance Store</div><div class="ccname">&#127804; Pommastore.com</div><div class="ccdesc">Arabic luxury perfume store, mobile app &amp; AED multi-currency checkout.</div></div>
      <div class="ccard"><div class="cctag">Hospitality ERP &amp; Apps</div><div class="ccname">&#127968; Zeebull Hospitality</div><div class="ccdesc">Resort HMS with dedicated Guest, Employee &amp; Owner Mobile Apps.</div></div>
      <div class="ccard"><div class="cctag">Travel &amp; Tourism</div><div class="ccname">&#127958; Pommaholidays</div><div class="ccdesc">Premier travel &amp; holiday planning platform for curated vacations.</div></div>
      <div class="ccard"><div class="cctag">Luxury Fragrance ERP</div><div class="ccname">&#128882; Liwara Perfumes</div><div class="ccdesc">Enterprise ERP &amp; wholesale e-commerce for fragrance manufacturing.</div></div>
    </div>
    <div class="s6-trust-banner">
      <span>&#9733;&#9733;&#9733;&#9733;&#9733;</span> Trusted Partner for Arabic E-Commerce, Zeebull Hospitality &amp; Enterprise Platforms
    </div>
  </div>
</div>

<!-- ════ SCENE 7: CTA ════ -->
<div class="scene" id="s7" style="--d:8s">
  <div class="scene-timer-bar"></div>
  <div class="cta-stage">
    <img class="cta-logo-img" src="{logo_data}" alt="TeqMates"/>
    <div class="cta-headline">Let's Build<br>Something <span class="grad-txt">Amazing</span></div>
    <div class="cta-subtext">Partner with TeqMates &mdash; your dedicated technology team for custom software, mobile apps &amp; digital growth.</div>
    <div class="cta-button-glow">
      <span style="font-size:24px">&#128222;</span>
      <span class="cta-phone-text">+91 90358 10416</span>
    </div>
    <div class="cta-website-foot">&#127760; <span>teqmates.com</span> &nbsp;&middot;&nbsp; Kerala, India</div>
  </div>
</div>

<script>
/* ── ADVANCED LIGHT PLEXUS PARTICLE CANVAS ── */
const cv=document.getElementById("bg-canvas"),cx=cv.getContext("2d");
function rsz(){{cv.width=window.innerWidth;cv.height=window.innerHeight;}}
rsz();window.addEventListener("resize",rsz);

const pts=Array.from({{length:90}},()=>({{
  x:Math.random()*cv.width,y:Math.random()*cv.height,
  r:Math.random()*1.8+0.5,
  dx:(Math.random()-0.5)*0.35,dy:(Math.random()-0.5)*0.35,
  a:Math.random()*0.25+0.05
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
    if(d<135){{
      cx.beginPath();cx.moveTo(pts[i].x,pts[i].y);cx.lineTo(pts[j].x,pts[j].y);
      cx.strokeStyle=`rgba(0,168,107,${{0.06*(1-d/135)}})`;cx.lineWidth=0.8;cx.stroke();
    }}
  }}
  requestAnimationFrame(drawFrame);
}})();

const IDS=["s1","s2","s3","s4","s5","s6","s7"];
const DURS=[4500,6000,6000,6500,6500,6500,8000];
const TOTAL=DURS.reduce((a,b)=>a+b,0);
let cur=0,elapsed=0,last=performance.now();

const dtWrap=document.getElementById("dots-wrap");
IDS.forEach((_,i)=>{{
  const d=document.createElement("div");
  d.className="sdot"+(i===0?" active-dot":"");
  d.onclick=()=>jumpTo(i);
  dtWrap.appendChild(d);
}});

function animC(el,target,suffix,ms){{
  let s=null;
  (function f(ts){{
    if(!s)s=ts;const p=Math.min((ts-s)/ms,1),e=1-Math.pow(1-p,3);
    el.textContent=(suffix==='%'?(e*target).toFixed(1):Math.floor(e*target))+suffix;
    if(p<1)requestAnimationFrame(f);
  }})(performance.now());
}}

function switchScene(idx){{
  const oldEl=document.getElementById(IDS[cur]);
  oldEl.classList.remove("active");
  oldEl.classList.add("exit");
  setTimeout(()=>oldEl.classList.remove("exit"),900);
  
  dtWrap.children[cur].classList.remove("active-dot");
  cur=idx;
  const newEl=document.getElementById(IDS[cur]);
  newEl.classList.add("active");
  
  const tb=newEl.querySelector(".scene-timer-bar");
  if(tb){{tb.style.animation="none";void tb.offsetWidth;tb.style.animation="";}}
  dtWrap.children[cur].classList.add("active-dot");

  if(cur===2){{
    setTimeout(()=>{{
      animC(document.getElementById("c1"),120,"+",1400);
      animC(document.getElementById("c2"),99.9,"%",1600);
      animC(document.getElementById("c3"),150,"+",1800);
    }},400);
  }}
}}

function jumpTo(idx){{
  let acc=0;for(let i=0;i<idx;i++)acc+=DURS[i];
  elapsed=acc;switchScene(idx);
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

document.addEventListener("keydown",e=>{{
  if(e.key==="ArrowRight")jumpTo(Math.min(cur+1,IDS.length-1));
  if(e.key==="ArrowLeft")jumpTo(Math.max(cur-1,0));
}});
</script>
</body>
</html>"""

out_file = r'c:\releasing\New Orchid\scratch\teqmates_promo.html'
with open(out_file, 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f"SUCCESS: Arabic website & Zeebull Employee/Owner App trailer {out_file} compiled cleanly! File size: {len(html_content):,} bytes")
