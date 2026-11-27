"use client";

import React, { useCallback, useEffect, useLayoutEffect, useRef, useState } from "react";

/* ------------------------------------------------------------------ */
/*  Tunable constants                                                  */
/* ------------------------------------------------------------------ */
const W = 340; // page width
const H = 430; // page height
const GAP = 18; // distance between fanned pages
const MAXD = 7; // pages deeper than this fade out completely
const FILL = 6; // blank filler sheets on each side (keeps stacks full)
const AUTOPLAY_MS = 2800;
const DESIGN_W = 1240;
const DESIGN_H = 520;

/* ------------------------------------------------------------------ */
/*  Content                                                            */
/* ------------------------------------------------------------------ */
type IconKey = "card" | "scan" | "vault" | "chart" | "team" | "lock" | "theme" | "share";

interface Feature {
  title: string;
  desc: string;
  chips: string[];
  icon: IconKey;
}

const FEATURES: Feature[] = [
  { title: "Digital Identity Card", desc: "Stunning mobile-first card with QR code and custom link sharing.", chips: ["QR code", "Custom link", "Mobile-first"], icon: "card" },
  { title: "AI Card Scanner", desc: "Scan any physical business card with AI-powered OCR. Auto-imports to your vault.", chips: ["AI-powered OCR", "Auto-import"], icon: "scan" },
  { title: "Contact Vault", desc: "Seamless contact management. Tags, notes, search, export.", chips: ["Tags", "Notes", "Search", "Export"], icon: "vault" },
  { title: "Live Analytics", desc: "Track views, taps, saves and geographical reach in real-time.", chips: ["Views", "Taps", "Saves", "Geo reach"], icon: "chart" },
  { title: "Enterprise Portal", desc: "Deploy branded cards across your entire team. Admin controls, approval workflows.", chips: ["Admin controls", "Approval workflows"], icon: "team" },
  { title: "Enterprise-Grade Security", desc: "256-bit AES encryption and robust data protection for peace of mind.", chips: ["256-bit AES", "Data protection"], icon: "lock" },
  { title: "Custom Themes", desc: "Choose from 50+ premium themes or create your own brand identity.", chips: ["50+ premium themes", "Your own brand"], icon: "theme" },
  { title: "One-Tap Share", desc: "QR, link, AirDrop, WhatsApp, email — share anywhere.", chips: ["QR", "Link", "AirDrop", "WhatsApp", "Email"], icon: "share" },
];
const N = FEATURES.length;
const TOTAL = FILL + N + FILL;
const LAST = FILL + N; // last spread index

const ICONS: Record<IconKey, React.ReactNode> = {
  card: (
    <>
      <rect x="7" y="2.5" width="10" height="19" rx="2.2" />
      <path d="M11 18.5h2" />
    </>
  ),
  scan: (
    <>
      <path d="M4 8V5.5A1.5 1.5 0 0 1 5.5 4H8M16 4h2.5A1.5 1.5 0 0 1 20 5.5V8M20 16v2.5a1.5 1.5 0 0 1-1.5 1.5H16M8 20H5.5A1.5 1.5 0 0 1 4 18.5V16" />
      <path d="M8 12h8" />
    </>
  ),
  vault: (
    <>
      <ellipse cx="12" cy="6" rx="7" ry="3" />
      <path d="M5 6v6c0 1.7 3.1 3 7 3s7-1.3 7-3V6" />
      <path d="M5 12v6c0 1.7 3.1 3 7 3s7-1.3 7-3v-6" />
    </>
  ),
  chart: (
    <>
      <path d="M4 20h16" />
      <path d="M7 17v-5" />
      <path d="M12 17V6" />
      <path d="M17 17v-8" />
    </>
  ),
  team: (
    <>
      <circle cx="9" cy="8" r="3.2" />
      <path d="M3 20c0-3.3 2.7-5.5 6-5.5s6 2.2 6 5.5" />
      <path d="M16 5.2a3 3 0 0 1 0 5.6" />
      <path d="M18 14.8c1.8.7 3 2.4 3 5.2" />
    </>
  ),
  lock: (
    <>
      <rect x="5" y="10.5" width="14" height="10" rx="2.5" />
      <path d="M8 10.5V8a4 4 0 0 1 8 0v2.5" />
    </>
  ),
  theme: (
    <>
      <path d="M12 3a9 9 0 1 0 0 18c1.4 0 2-1 1.5-2.2-.6-1.3.2-2.8 1.7-2.8H18a3 3 0 0 0 3-3C21 7.4 17 3 12 3z" />
      <circle cx="7.8" cy="11" r="1" />
      <circle cx="10.5" cy="7.2" r="1" />
      <circle cx="15" cy="7.8" r="1" />
    </>
  ),
  share: (
    <>
      <circle cx="6" cy="12" r="2.5" />
      <circle cx="18" cy="5.5" r="2.5" />
      <circle cx="18" cy="18.5" r="2.5" />
      <path d="M8.2 10.8l7.6-4" />
      <path d="M8.2 13.2l7.6 4" />
    </>
  ),
};

const Icon: React.FC<{ name: IconKey }> = ({ name }) => (
  <svg viewBox="0 0 24 24" aria-hidden="true">{ICONS[name]}</svg>
);

/* ------------------------------------------------------------------ */
/*  Page faces                                                         */
/* ------------------------------------------------------------------ */
const TextPage: React.FC<{ i: number }> = ({ i }) => {
  const f = FEATURES[i];
  return (
    <div className="fb-txt">
      <div className="fb-pn">{String(i + 1).padStart(2, "0")} / {String(N).padStart(2, "0")}</div>
      <h2>{f.title}</h2>
      <p>{f.desc}</p>
      <div className="fb-chips">
        {f.chips.map((c) => (<span className="fb-chip" key={c}>{c}</span>))}
      </div>
    </div>
  );
};

const VisualPage: React.FC<{ i: number }> = ({ i }) => (
  <div className="fb-vis">
    <div className="fb-rings" />
    <div className="fb-ico"><Icon name={FEATURES[i].icon} /></div>
    <div className="fb-cap">{FEATURES[i].title}</div>
  </div>
);

const TocPage: React.FC = () => (
  <div className="fb-toc">
    <div className="fb-mark">mycardshare</div>
    <h3>What&apos;s inside</h3>
    <ol>{FEATURES.map((f) => (<li key={f.title}>{f.title}</li>))}</ol>
  </div>
);

const CtaPage: React.FC = () => (
  <div className="fb-end">
    <div className="fb-mark">mycardshare</div>
    <h3>Your identity, ready to share</h3>
    <p>From card creation to enterprise deployment.</p>
    <button className="fb-btn" type="button">Start Now →</button>
  </div>
);

const ClosingPage: React.FC = () => (
  <div className="fb-end">
    <p className="fb-closing-title">Everything You Need</p>
    <p>One platform for every professional connection.</p>
  </div>
);

const Blank: React.FC = () => <div className="fb-blank" />;

/* ------------------------------------------------------------------ */
/*  Pose math: the single function that places every sheet            */
/*  c = current spread index, i = sheet index                          */
/* ------------------------------------------------------------------ */
function pose(i: number, c: number): { transform: string; opacity: number; fan: boolean } {
  const onRight = i >= c;
  const depth = onRight ? i - c : c - 1 - i;
  const fan = depth >= 2;
  const opacity = depth > MAXD - 1 ? 0 : fan ? Math.max(0.35, 1 - (depth - 2) * 0.12) : 1;
  const d = Math.min(depth, MAXD);

  // Always the same function list so the browser interpolates smoothly.
  let tx = 0, tz = 0, ry = 0;
  if (onRight) {
    if (d === 0) { tx = 0; tz = 0; ry = 0; }
    else if (d === 1) { tx = 0; tz = -4; ry = 0; }
    else { tx = W + (d - 2) * GAP + 10; tz = -d * 40; ry = 72; }
  } else {
    if (d === 0) { tx = 0; tz = 0; ry = -180; }
    else if (d === 1) { tx = 0; tz = -4; ry = -180; }
    else { tx = -(W + (d - 2) * GAP + 10); tz = -d * 40; ry = -252; }
  }
  return { transform: `translateX(${tx}px) translateZ(${tz}px) rotateY(${ry}deg)`, opacity, fan };
}

/* ------------------------------------------------------------------ */
/*  Component                                                          */
/* ------------------------------------------------------------------ */
export interface FlipBookFeaturesProps {
  onStart?: () => void; // called when "Start Now →" is clicked
}

const FlipBookFeatures: React.FC<FlipBookFeaturesProps> = ({ onStart }) => {
  const [c, setC] = useState(FILL);
  const [playing, setPlaying] = useState(true);
  const [hovered, setHovered] = useState(false);
  const [rewinding, setRewinding] = useState(false);
  const [scale, setScale] = useState(1);
  const [offsetX, setOffsetX] = useState(0);
  const vpRef = useRef<HTMLDivElement>(null);

  const reduceMotion =
    typeof window !== "undefined" && window.matchMedia?.("(prefers-reduced-motion: reduce)").matches;

  const go = useCallback((n: number) => setC(Math.max(FILL, Math.min(LAST, n))), []);

  // Scale the fixed-size design to fit its container.
  useLayoutEffect(() => {
    const el = vpRef.current;
    if (!el) return;
    const fit = () => {
      const w = el.clientWidth;
      const full = w > 980 ? DESIGN_W : 800;
      const s = Math.min(1, w / full);
      setScale(s);
      setOffsetX((w - DESIGN_W * s) / 2);
    };
    fit();
    const ro = new ResizeObserver(fit);
    ro.observe(el);
    return () => ro.disconnect();
  }, []);

  // Autoplay: next spread, then rewind with a staggered cascade.
  useEffect(() => {
    if (!playing || hovered || reduceMotion || rewinding) return;
    const t = window.setInterval(() => {
      setC((cur) => {
        if (cur >= LAST) { setRewinding(true); return FILL; }
        return cur + 1;
      });
    }, AUTOPLAY_MS);
    return () => window.clearInterval(t);
  }, [playing, hovered, reduceMotion, rewinding]);

  useEffect(() => {
    if (!rewinding) return;
    const t = window.setTimeout(() => setRewinding(false), 1700);
    return () => window.clearTimeout(t);
  }, [rewinding]);

  // Arrow keys
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "ArrowRight") go(c + 1);
      if (e.key === "ArrowLeft") go(c - 1);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [c, go]);

  const onNext = () => { if (!rewinding) go(c >= LAST ? FILL : c + 1); };
  const onPrev = () => go(c - 1);

  return (
    <section className="fb-root">
      <style>{CSS}</style>

      <header className="fb-head">
        <h1>Everything You Need</h1>
        <p>A complete professional identity platform. From card creation to enterprise deployment.</p>
      </header>

      <div
        className="fb-viewport"
        ref={vpRef}
        style={{ height: DESIGN_H * scale }}
        onMouseEnter={() => setHovered(true)}
        onMouseLeave={() => setHovered(false)}
      >
        <div
          className="fb-scaler"
          style={{ width: DESIGN_W, height: DESIGN_H, transform: `scale(${scale})`, marginLeft: offsetX }}
        >
          <div className="fb-stage">
            <div className="fb-floor" />
            <div className="fb-book">
              {Array.from({ length: TOTAL }, (_, j) => {
                const f = j - FILL;
                const front =
                  f >= 0 && f < N ? <TextPage i={f} /> : f === N ? <ClosingPage /> : <Blank />;
                const back =
                  j === FILL - 1 ? <TocPage />
                  : f >= 0 && f < N - 1 ? <VisualPage i={f + 1} />
                  : f === N - 1 ? <CtaPage />
                  : <Blank />;
                const p = pose(j, c);
                return (
                  <div
                    key={j}
                    className={"fb-sheet" + (p.fan ? " fan" : "")}
                    style={{
                      transform: p.transform,
                      opacity: p.opacity,
                      transitionDelay: rewinding ? `${Math.abs(j - FILL) * 55}ms` : "0ms",
                      transitionDuration: rewinding ? ".7s" : undefined,
                    }}
                    onClick={(e) => {
                      if ((e.target as HTMLElement).closest(".fb-btn")) { onStart?.(); return; }
                      go(j >= c ? j + 1 : j);
                    }}
                  >
                    <div className="fb-face fb-front">{front}</div>
                    <div className="fb-face fb-back">{back}</div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>

      <div className="fb-controls">
        <button className="fb-cb" onClick={onPrev} aria-label="Previous">
          <svg viewBox="0 0 24 24"><path d="M15 6l-6 6 6 6" /></svg>
        </button>
        <button className="fb-cb" onClick={() => setPlaying((p) => !p)} aria-label={playing ? "Pause" : "Play"}>
          <svg viewBox="0 0 24 24">{playing ? <path d="M9 6v12M15 6v12" /> : <path d="M8 5l11 7-11 7z" />}</svg>
        </button>
        <div className="fb-dots">
          {Array.from({ length: N + 1 }, (_, j) => (
            <span key={j} className={"fb-dot" + (j === c - FILL ? " on" : "")} />
          ))}
        </div>
        <button className="fb-cb" onClick={onNext} aria-label="Next">
          <svg viewBox="0 0 24 24"><path d="M9 6l6 6-6 6" /></svg>
        </button>
      </div>
    </section>
  );
};

export default FlipBookFeatures;

/* ------------------------------------------------------------------ */
/*  Styles (colors are the approved palette: white / matte orange /    */
/*  warm cream)                                                        */
/* ------------------------------------------------------------------ */
const CSS = `
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Space+Grotesk:wght@500;600;700&display=swap');

.fb-root {
  --white: #FFFFFF;
  --orange: #D4642C;
  --orange-deep: #B85222;
  --orange-soft: #F6E3D8;
  --cream: #FAF6F2;
  --cream-edge: #EFE6DD;
  --ink: #2A1E17;
  --ink-soft: #7A6A5F;
  --font-display: 'Space Grotesk', system-ui, sans-serif;
  --font-body: 'Inter', system-ui, sans-serif;
  background: var(--cream);
  color: var(--ink);
  font-family: var(--font-body);
  padding: 16px 16px 40px;
  overflow-x: hidden;
}
.fb-root *, .fb-root *::before, .fb-root *::after { box-sizing: border-box; }

.fb-head { text-align: center; max-width: 620px; margin: 0 auto 8px; }
.fb-head h1 { font-family: var(--font-display); font-weight: 700; font-size: clamp(30px, 5vw, 44px); margin: 0 0 10px; color: var(--orange); text-wrap: balance; }
.fb-head p { margin: 0; color: var(--ink-soft); font-size: 16px; line-height: 1.55; text-wrap: balance; }

.fb-viewport { width: 100%; overflow: hidden; position: relative; }
.fb-scaler { transform-origin: top left; position: relative; }
.fb-stage { position: absolute; inset: 0; perspective: 2400px; perspective-origin: 50% 40%; }
.fb-book { position: absolute; left: 50%; top: 40px; width: 0; height: ${H}px; transform-style: preserve-3d; }
.fb-floor { position: absolute; left: 50%; top: 478px; width: 760px; height: 36px; margin-left: -380px; background: radial-gradient(ellipse at center, rgba(120,70,40,.22), transparent 70%); filter: blur(6px); }

.fb-sheet { position: absolute; top: 0; left: 0; width: ${W}px; height: ${H}px; transform-style: preserve-3d; transform-origin: 0 50%; cursor: pointer; transition: transform .95s cubic-bezier(.62,0,.2,1), opacity .5s; }
.fb-face { position: absolute; inset: 0; backface-visibility: hidden; -webkit-backface-visibility: hidden; background: var(--white); border: 1px solid var(--cream-edge); overflow: hidden; display: flex; flex-direction: column; }
.fb-front { border-radius: 4px 18px 18px 4px; box-shadow: 0 10px 28px rgba(110,60,30,.12); }
.fb-back { border-radius: 18px 4px 4px 18px; transform: rotateY(180deg); background: var(--cream); box-shadow: 0 10px 28px rgba(110,60,30,.12); }
.fb-front::after, .fb-back::after { content: ""; position: absolute; top: 0; bottom: 0; width: 46px; pointer-events: none; }
.fb-front::after { left: 0; background: linear-gradient(90deg, rgba(120,70,40,.16), transparent); }
.fb-back::after { right: 0; background: linear-gradient(270deg, rgba(120,70,40,.16), transparent); }

/* side stacks: thin empty paper edges only */
.fb-face > * { transition: opacity .35s ease; }
.fb-sheet.fan .fb-face > * { opacity: 0; }
.fb-sheet.fan .fb-face { background: linear-gradient(90deg, #fff 0%, var(--cream) 100%); border-color: #E4D8CC; }
.fb-blank { height: 100%; background: linear-gradient(180deg, #fff, var(--cream)); }

.fb-txt { padding: 34px 34px 30px 44px; height: 100%; display: flex; flex-direction: column; }
.fb-pn { font-size: 12px; letter-spacing: .14em; text-transform: uppercase; color: var(--orange); font-weight: 600; display: flex; align-items: center; gap: 10px; }
.fb-pn::after { content: ""; width: 34px; height: 1.5px; background: var(--orange); }
.fb-txt h2 { font-family: var(--font-display); font-weight: 700; font-size: 30px; line-height: 1.1; margin: 18px 0 12px; text-wrap: balance; }
.fb-txt p { margin: 0; color: var(--ink-soft); font-size: 15px; line-height: 1.6; }
.fb-chips { margin-top: auto; display: flex; flex-wrap: wrap; gap: 8px; }
.fb-chip { font-size: 12.5px; font-weight: 500; color: var(--orange-deep); background: var(--orange-soft); padding: 6px 12px; border-radius: 999px; }

.fb-vis { height: 100%; display: grid; place-items: center; position: relative; }

/* Concentric background rings with gentle expanding pulse */
@keyframes ringBreathe {
  0%, 100% {
    transform: scale(1);
    opacity: 0.85;
  }
  50% {
    transform: scale(1.045);
    opacity: 1;
  }
}
.fb-rings {
  position: absolute;
  width: 330px;
  height: 330px;
  border-radius: 50%;
  border: 1.5px solid var(--cream-edge);
  box-shadow: 0 0 0 46px rgba(212,100,44,.04), 0 0 0 92px rgba(212,100,44,.03);
  left: 50%;
  top: 50%;
  margin: -165px 0 0 -165px;
  animation: ringBreathe 4s ease-in-out infinite;
}

/* Floating orange tile with subtle elevation breathing */
@keyframes icoTilePulse {
  0%, 100% {
    transform: translateY(0) scale(1);
    box-shadow: 0 18px 36px rgba(212,100,44,.32);
  }
  50% {
    transform: translateY(-3px) scale(1.02);
    box-shadow: 0 24px 44px rgba(212,100,44,.44);
  }
}
.fb-ico {
  position: relative;
  width: 132px;
  height: 132px;
  border-radius: 34px;
  background: var(--orange);
  display: grid;
  place-items: center;
  box-shadow: 0 18px 36px rgba(212,100,44,.32);
  animation: icoTilePulse 3.2s ease-in-out infinite;
}

.fb-ico::before {
  content: "";
  position: absolute;
  inset: 0;
  border-radius: 34px;
  background: linear-gradient(145deg, rgba(255,255,255,0.22) 0%, transparent 45%, rgba(0,0,0,0.06) 100%);
  pointer-events: none;
}

.fb-ico svg {
  width: 60px;
  height: 60px;
  stroke: var(--white);
  fill: none;
  stroke-width: 1.7;
  stroke-linecap: round;
  stroke-linejoin: round;
  position: relative;
  z-index: 1;
}

/* "Getting Built" SVG Path Construction Animation */
@keyframes iconStrokeBuild {
  0% {
    stroke-dashoffset: 130;
    opacity: 0;
  }
  6% {
    opacity: 1;
  }
  38% {
    stroke-dashoffset: 0;
    opacity: 1;
  }
  72% {
    stroke-dashoffset: 0;
    opacity: 1;
    filter: drop-shadow(0 0 0 rgba(255, 255, 255, 0));
  }
  78% {
    stroke-dashoffset: 0;
    opacity: 1;
    filter: drop-shadow(0 0 7px rgba(255, 255, 255, 0.8));
  }
  84% {
    stroke-dashoffset: 0;
    opacity: 1;
    filter: drop-shadow(0 0 0 rgba(255, 255, 255, 0));
  }
  92% {
    opacity: 0;
    stroke-dashoffset: 0;
  }
  96%, 100% {
    opacity: 0;
    stroke-dashoffset: 130;
  }
}

.fb-ico svg path,
.fb-ico svg rect,
.fb-ico svg circle,
.fb-ico svg ellipse {
  stroke-dasharray: 130;
  stroke-dashoffset: 130;
  animation: iconStrokeBuild 3.2s cubic-bezier(0.65, 0, 0.35, 1) infinite;
}

/* Staggered build sequence for individual strokes */
.fb-ico svg > :nth-child(1) { animation-delay: 0s; }
.fb-ico svg > :nth-child(2) { animation-delay: 0.16s; }
.fb-ico svg > :nth-child(3) { animation-delay: 0.32s; }
.fb-ico svg > :nth-child(4) { animation-delay: 0.48s; }
.fb-ico svg > :nth-child(5) { animation-delay: 0.64s; }

.fb-cap { position: absolute; bottom: 28px; left: 0; right: 0; text-align: center; font-family: var(--font-display); font-weight: 600; font-size: 15px; color: var(--ink); }

.fb-toc { padding: 34px 40px 30px 34px; height: 100%; }
.fb-toc h3 { font-family: var(--font-display); font-size: 24px; margin: 14px 0 18px; }
.fb-toc ol { list-style: none; margin: 0; padding: 0; display: grid; gap: 9px; counter-reset: t; }
.fb-toc li { counter-increment: t; display: flex; align-items: baseline; gap: 12px; font-size: 14.5px; color: var(--ink); }
.fb-toc li::before { content: counter(t, decimal-leading-zero); color: var(--orange); font-weight: 600; font-size: 12px; width: 20px; }
.fb-end { padding: 40px 34px; height: 100%; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center; gap: 18px; }
.fb-end h3 { font-family: var(--font-display); font-size: 28px; margin: 0; text-wrap: balance; }
.fb-end p { margin: 0; color: var(--ink-soft); font-size: 15px; line-height: 1.55; }
.fb-closing-title { font-family: var(--font-display); font-size: 20px !important; color: var(--ink) !important; font-weight: 600; }
.fb-btn { font-family: var(--font-body); font-weight: 600; font-size: 16px; color: var(--white); background: var(--orange); border: 0; padding: 14px 28px; border-radius: 999px; cursor: pointer; box-shadow: 0 10px 22px rgba(212,100,44,.3); }
.fb-btn:hover { background: var(--orange-deep); }
.fb-mark { font-family: var(--font-display); font-weight: 700; font-size: 22px; color: var(--orange); }

.fb-controls { display: flex; justify-content: center; align-items: center; gap: 12px; margin-top: 14px; }
.fb-cb { width: 40px; height: 40px; border-radius: 50%; border: 1px solid var(--cream-edge); background: var(--white); color: var(--ink); display: grid; place-items: center; cursor: pointer; box-shadow: 0 4px 12px rgba(110,60,30,.1); }
.fb-cb:hover { border-color: var(--orange); color: var(--orange); }
.fb-cb:focus-visible, .fb-btn:focus-visible { outline: 2px solid var(--orange); outline-offset: 3px; }
.fb-cb svg { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.fb-dots { display: flex; gap: 6px; padding: 0 6px; }
.fb-dot { width: 7px; height: 7px; border-radius: 99px; background: var(--cream-edge); transition: all .3s; }
.fb-dot.on { background: var(--orange); width: 22px; }

@media (prefers-reduced-motion: reduce) {
  .fb-sheet { transition-duration: .01s !important; }
  .fb-ico svg path,
  .fb-ico svg rect,
  .fb-ico svg circle,
  .fb-ico svg ellipse {
    animation: none !important;
    stroke-dashoffset: 0 !important;
    opacity: 1 !important;
  }
  .fb-ico, .fb-rings {
    animation: none !important;
  }
}
`;
