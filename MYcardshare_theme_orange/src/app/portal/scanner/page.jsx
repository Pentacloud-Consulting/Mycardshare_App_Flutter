"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import { motion } from "framer-motion";
import {
  Camera,
  Scan,
  Upload,
  Loader2,
  CheckCircle2,
  RotateCw,
  RotateCcw,
  Save,
  RefreshCw,
  Zap,
  X,
  User,
  Mail,
  Phone,
  Briefcase,
  Globe,
  MapPin,
  FileText,
  Award,
  AlertCircle,
  Smartphone,
  Shield,
  Calendar,
} from "lucide-react";
import { useAuth } from "@/lib/auth-context";
import { authFetch } from "@/lib/api";
import { UiloraBrandButton } from "@/components/UIComponents/Button/tsx/UiloraModernButtons";

/* ═══════════════════════════════════════════════════════════
   CARD SCANNER — Full Implementation
   QR auto-detect · Camera capture · AI OCR · Contact save
   ═══════════════════════════════════════════════════════════ */

export default function ScannerPage() {
  const { user } = useAuth();
  const [mode, setMode] = useState("idle"); // idle | scanning | preview | processing | review
  const [error, setError] = useState(null);
  const [capturedImage, setCapturedImage] = useState(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [ocrProgress, setOcrProgress] = useState(0);
  const [extractionSource, setExtractionSource] = useState(null);
  const [scanResult, setScanResult] = useState(null);

  const html5QrCodeRef = useRef(null);

  const [formData, setFormData] = useState({
    fullName: "",
    email: "",
    phone: "",
    phone2: "",
    company: "",
    jobTitle: "",
    website: "",
    address: "",
    meeting: "",
    notes: "",
  });

  // ── Start Camera + QR Scanner ──
  const startScanner = () => {
    setError(null);
    setMode("scanning");
  };

  useEffect(() => {
    let html5QrCode = null;

    const initScanner = async () => {
      if (mode !== "scanning") return;

      try {
        // Wait slightly longer for DOM and CSS transitions
        await new Promise((r) => setTimeout(r, 400));

        const el = document.getElementById("qr-reader");
        if (!el) {
          console.warn("⚠️ [Scanner] Container element #qr-reader not found.");
          setMode("idle");
          return;
        }

        const { Html5Qrcode } = await import("html5-qrcode");
        html5QrCode = new Html5Qrcode("qr-reader");
        html5QrCodeRef.current = html5QrCode;

        console.log("🔄 [Scanner] Requesting camera access...");
        await html5QrCode.start(
          { facingMode: "environment" },
          {
            fps: 20,
            qrbox: { width: 250, height: 250 },
            // Removed strict aspectRatio to improve compatibility across devices
          },
          (decodedText) => handleQRCodeDetected(decodedText),
          () => {}, // Suppress verbose frame logs
        );
        console.log("✅ [Scanner] Camera active");
      } catch (err) {
        console.warn("⚠️ [Scanner] Camera Start Failed:", err);
        const msg = err?.message || err || "";
        if (msg.includes("Permission") || msg.includes("NotAllowedError")) {
          setError("Camera permission denied. Please enable camera access in your browser settings.");
        } else if (msg.includes("NotFound") || msg.includes("DevicesNotFoundError")) {
          setError("No camera found on this device.");
        } else {
          setError(`Camera could not start: ${msg}. Try refreshing the page.`);
        }
        setMode("idle");
      }
    };

    initScanner();

    return () => {
      if (html5QrCode) {
        try {
          const state = html5QrCode.getState();
          if (state === 2 || state === 3) html5QrCode.stop().catch(() => {});
        } catch {}
      }
    };
  }, [mode]);

  const stopScanner = async () => {
    if (html5QrCodeRef.current) {
      try {
        const state = html5QrCodeRef.current.getState();
        if (state === 2 || state === 3) await html5QrCodeRef.current.stop();
      } catch {}
      html5QrCodeRef.current = null;
    }
  };

  // ── QR Code Detected ──
  const handleQRCodeDetected = async (text) => {
    await stopScanner();
    setMode("processing");
    setIsProcessing(true);

    try {
      if (text.toLowerCase().includes("begin:vcard")) {
        const parsed = parseVCard(text);
        setFormData((prev) => ({ ...prev, ...parsed }));
      } else if (text.startsWith("http")) {
        if (text.includes("/card/")) {
          try {
            const slug = text.split("/card/")[1];
            const res = await fetch(`/api/cards/public/${slug}`);
            if (res.ok) {
              const cardData = await res.json();
              const d = cardData.data || cardData;
              setFormData({
                fullName: d.fullName || "",
                email: d.workEmail || d.email || "",
                phone: d.workPhone || d.phoneNumber || "",
                phone2: "",
                company: d.companyName || "",
                jobTitle: d.jobTitle || "",
                website: d.website || "",
                address: d.address || "",
                notes: `Scanned from: ${text}`,
              });
            } else {
              setFormData((prev) => ({ ...prev, notes: `QR URL: ${text}` }));
            }
          } catch {
            setFormData((prev) => ({ ...prev, notes: `QR URL: ${text}` }));
          }
        } else {
          setFormData((prev) => ({
            ...prev,
            website: text,
            notes: `Scanned URL: ${text}`,
          }));
        }
      } else {
        setFormData((prev) => ({ ...prev, notes: text }));
      }

      setScanResult({ type: "qr", data: text });
      setMode("review");
    } catch (err) {
      setError("Failed to process QR code.");
      setMode("scanning");
    } finally {
      setIsProcessing(false);
    }
  };

  const parseVCard = (vcardText) => {
    const result = {};
    const lines = vcardText.split(/\r?\n/);
    lines.forEach((line) => {
      const [key, ...valueParts] = line.split(":");
      const value = valueParts.join(":");
      if (key?.toUpperCase().includes("FN")) result.fullName = value;
      else if (key?.toUpperCase().includes("EMAIL")) result.email = value;
      else if (key?.toUpperCase().includes("TEL")) result.phone = value;
      else if (key?.toUpperCase().includes("ORG")) result.company = value;
      else if (key?.toUpperCase().includes("TITLE")) result.jobTitle = value;
      else if (key?.toUpperCase().includes("URL")) result.website = value;
      else if (key?.toUpperCase().includes("ADR"))
        result.address = value.replace(/;/g, " ").trim();
    });
    return result;
  };

  // ── Capture Image from Camera ──
  const captureImage = async () => {
    if (!html5QrCodeRef.current) return;

    try {
      const videoElement = document.querySelector("#qr-reader video");
      if (!videoElement) {
        setError("Video element not found");
        return;
      }

      const vW = videoElement.videoWidth;
      const vH = videoElement.videoHeight;
      const cropScale = 0.8;
      const cropW = vW * cropScale;
      const cropH = vH * cropScale;

      const canvas = document.createElement("canvas");
      canvas.width = cropW;
      canvas.height = cropH;
      const ctx = canvas.getContext("2d");
      ctx.drawImage(
        videoElement,
        (vW - cropW) / 2,
        (vH - cropH) / 2,
        cropW,
        cropH,
        0,
        0,
        cropW,
        cropH,
      );

      const imageDataUrl = canvas.toDataURL("image/jpeg", 0.8);
      setCapturedImage(imageDataUrl);
      await stopScanner();
      setMode("preview");
    } catch (err) {
      setError("Failed to capture image.");
    }
  };

  // ── Rotate Image ──
  const rotateImage = (angle) => {
    if (!capturedImage) return;
    const img = new Image();
    img.onload = () => {
      const canvas = document.createElement("canvas");
      const ctx = canvas.getContext("2d");
      if (angle === 90 || angle === 270 || angle === -90) {
        canvas.width = img.height;
        canvas.height = img.width;
      } else {
        canvas.width = img.width;
        canvas.height = img.height;
      }
      ctx.translate(canvas.width / 2, canvas.height / 2);
      ctx.rotate((angle * Math.PI) / 180);
      ctx.drawImage(img, -img.width / 2, -img.height / 2);
      setCapturedImage(canvas.toDataURL("image/jpeg", 0.85));
    };
    img.src = capturedImage;
  };

  // ── File Upload Handler ──
  const handleFileUpload = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      setCapturedImage(reader.result);
      setMode("preview");
    };
    reader.readAsDataURL(file);
  };

  // ── Process Image with OCR ──
  const processImage = async () => {
    setMode("processing");
    setIsProcessing(true);
    setOcrProgress(10);

    try {
      // Priority 1: Backend AI OCR
      setOcrProgress(30);
      try {
        const response = await fetch("/api/ocr/extract", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ image: capturedImage }),
        });

        if (response.ok) {
          const result = await response.json();
          if (result.success && result.data) {
            setOcrProgress(90);
            const parsed = result.data;
            setFormData((prev) => ({
              ...prev,
              fullName: parsed.fullName || "",
              email: parsed.email || "",
              phone: parsed.phone || "",
              phone2: parsed.phone2 || "",
              company: parsed.company || "",
              jobTitle: parsed.jobTitle || "",
              website: parsed.website || "",
              address: parsed.address || "",
              meeting: parsed.meeting || "",
              notes: parsed.notes || "",
            }));
            setScanResult({
              type: "backend-ai",
              data: JSON.stringify(parsed, null, 2),
            });
            setExtractionSource("ai");
            setMode("review");
            return;
          }
        }
        throw new Error("Backend OCR failed");
      } catch (apiErr) {
        console.warn(
          "Backend OCR failed, trying Tesseract fallback:",
          apiErr.message,
        );
      }

      // Priority 2: Tesseract.js Fallback
      setOcrProgress(50);
      try {
        const Tesseract = (await import("tesseract.js")).default;
        setOcrProgress(60);

        const tesseractResult = await Tesseract.recognize(
          capturedImage,
          "eng",
          {
            logger: (m) => {
              if (m.status === "recognizing text") {
                setOcrProgress(60 + Math.round(m.progress * 30));
              }
            },
          },
        );

        const text = tesseractResult.data.text;
        const parsed = parseOCRText(text);
        setFormData((prev) => ({ ...prev, ...parsed }));
        setScanResult({ type: "tesseract", data: text });
        setExtractionSource("fallback");
        setMode("review");
      } catch (tessErr) {
        setError("Failed to extract text. Please try again.");
        setMode("preview");
      }
    } finally {
      setIsProcessing(false);
      setOcrProgress(0);
    }
  };

  // ── Basic OCR Text Parser (Fallback) ──
  const parseOCRText = (text) => {
    const result = {};
    const cleanText = text.replace(/\s{2,}/g, " ");
    const lines = cleanText
      .split("\n")
      .map((l) => l.trim())
      .filter((l) => l.length > 1);

    // Email
    const emailMatch = cleanText.match(
      /([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/i,
    );
    if (emailMatch) result.email = emailMatch[1].toLowerCase();

    // Phone
    const phoneMatches = cleanText.match(/\+?\d[\d\s.-]{8,}/g);
    if (phoneMatches) {
      result.phone = phoneMatches[0].trim();
      if (phoneMatches.length > 1) result.phone2 = phoneMatches[1].trim();
    }

    // Website
    const webMatch = cleanText.match(
      /((?:https?:\/\/)?(?:www\.)?[a-z0-9][a-z0-9-]*\.[a-z]{2,})/i,
    );
    if (webMatch && !webMatch[1].includes("@")) result.website = webMatch[1];

    // Keywords that indicate a line is NOT a person's name
    const nonNamePatterns = [
      /\d/,                        // Contains digits (phone, address, etc.)
      /@/,                         // Email
      /www\.|https?:/i,            // URL
      /\.(com|org|net|in|co)/i,    // Domain
    ];
    const nonNameKeywords = [
      'domestic', 'international', 'courier', 'cargo', 'service', 'available',
      'pickup', 'doorstep', 'express', 'limited', 'pvt', 'ltd', 'inc',
      'solutions', 'enterprises', 'corporation', 'technologies', 'complex',
      'road', 'street', 'nagar', 'bangalore', 'mumbai', 'delhi', 'chennai',
      'floor', 'no.', 'plot', 'sector', 'phase', 'building',
    ];

    // Name candidate — find the first line that genuinely looks like a person's name
    for (const line of lines.slice(0, 8)) {
      const clean = line.replace(/[^a-zA-Z\s.]/g, "").trim();
      const words = clean.split(/\s+/).filter(w => w.length > 0);

      // Must be 2-4 words, start with uppercase, no non-name patterns
      if (words.length < 2 || words.length > 4) continue;
      if (!/^[A-Z]/.test(clean)) continue;
      if (nonNamePatterns.some((p) => p.test(line))) continue;

      // Check if any word matches business/non-name keywords
      const lowerLine = line.toLowerCase();
      if (nonNameKeywords.some((kw) => lowerLine.includes(kw))) continue;

      // Each word should look like a name part (2+ chars, starts with uppercase)
      const allNameLike = words.every(
        (w) => w.length >= 2 && /^[A-Z]/.test(w) && /^[A-Za-z.]+$/.test(w),
      );
      if (!allNameLike) continue;

      result.fullName = clean;
      break;
    }

    // Notes — only include meaningful info, not raw OCR dump
    // Collect lines that aren't already captured in other fields
    const capturedValues = [
      result.fullName, result.email, result.phone, result.phone2, result.website,
    ].filter(Boolean).map((v) => v.toLowerCase());

    const meaningfulNotes = lines.filter((line) => {
      const lower = line.toLowerCase().trim();
      if (lower.length < 3) return false;

      // Skip lines that are already captured as a field value
      if (capturedValues.some((v) => lower.includes(v) || v.includes(lower))) return false;

      // Skip lines that are just numbers (phone-like) or just symbols
      if (/^[\d\s+\-().]+$/.test(line)) return false;
      // Skip lines that look like email addresses or URLs
      if (/@/.test(line) || /www\.|https?:/i.test(line)) return false;
      // Skip lines that look like addresses (contain pin codes, road names, etc.)
      if (/\b\d{6}\b/.test(line)) return false; // Indian PIN codes
      if (/\b\d{5}(-\d{4})?\b/.test(line)) return false; // US ZIP codes

      // Only keep lines that have meaningful words (job title, company tagline, etc.)
      const wordCount = line.replace(/[^a-zA-Z\s]/g, "").trim().split(/\s+/).filter(w => w.length > 1).length;
      return wordCount >= 2;
    });

    // Only set notes if there's genuinely meaningful content
    // Tesseract often produces noisy garbage for non-standard text.
    // It's safer to leave notes empty during a fallback than to dump raw OCR text.
    result.notes = "";

    return result;
  };

  // ── Save Contact ──
  const handleSave = async () => {
    if (!formData.fullName && !formData.email && !formData.phone) {
      setError("Please fill in at least a name, email, or phone number.");
      return;
    }

    setIsProcessing(true);
    try {
      const response = await authFetch("/api/scanned-contacts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...formData,
          cardImageUrl: capturedImage || null,
        }),
      });

      if (response.ok) {
        alert("Contact saved to vault!");
        resetScanner();
      } else {
        throw new Error("Failed to save contact");
      }
    } catch (err) {
      setError("Failed to save contact. Please try again.");
    } finally {
      setIsProcessing(false);
    }
  };

  const resetScanner = () => {
    setMode("idle");
    setScanResult(null);
    setCapturedImage(null);
    setExtractionSource(null);
    setError(null);
    setOcrProgress(0);
    setFormData({
      fullName: "",
      email: "",
      phone: "",
      phone2: "",
      company: "",
      jobTitle: "",
      website: "",
      address: "",
      meeting: "",
      notes: "",
    });
  };

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      stopScanner();
    };
  }, []);

  return (
    <div className="max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center gap-3 mb-8">
        <div
          className="w-2.5 h-2.5 rounded-full flex-shrink-0"
          style={{ background: "linear-gradient(135deg, #38bdf8, #818cf8)" }}
        />
        <h1 className="text-xl font-black text-[#0F172A] tracking-tight">
          Card Scanner
        </h1>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-start">
        {/* Left Column: Scanner */}
        <div>
          {/* Error */}
          {error && (
            <div className="flex items-center justify-between gap-2 bg-red-500/10 border border-red-500/25 rounded-xl p-3 px-4 text-sm text-red-300 mb-4">
              <div className="flex items-center gap-2">
                <AlertCircle size={16} /> {error}
              </div>
              <button
                onClick={() => setError(null)}
                className="text-red-300 hover:text-white"
              >
                <X size={16} />
              </button>
            </div>
          )}

          {/* ── IDLE MODE ── */}
          {mode === "idle" && (
            <div className="glass-premium p-6 md:p-10 text-center">
              <div className="relative inline-block mb-4 md:mb-6">
                <div className="absolute inset-[-15px] md:inset-[-20px] bg-[radial-gradient(circle,rgba(56,189,248,0.2)_0%,transparent_70%)] rounded-full" />
                <Camera
                  className="text-sky-400 relative z-10 w-12 h-12 md:w-16 md:h-16"
                  style={{
                    filter: "drop-shadow(0 0 10px rgba(56,189,248,0.5))",
                  }}
                />
              </div>
              <h3 className="text-lg md:text-xl font-bold text-[var(--color-ink-2)] mb-2 md:mb-3">
                Ready to Scan
              </h3>
              <p className="text-[var(--color-muted)] text-[13px] md:text-sm mb-6 leading-relaxed max-w-sm mx-auto">
                Point your camera at a business card or QR code to instantly
                capture contact details into your vault.
              </p>
              <div className="flex flex-col sm:flex-row gap-3 justify-center">
                <UiloraBrandButton
                  onClick={startScanner}
                  className="px-6 py-3 normal-case tracking-normal shadow-sm"
                >
                  <Scan size={18} /> Start Camera
                </UiloraBrandButton>
                <label className="px-6 py-3 rounded-full font-bold text-[var(--color-ink-2)] text-sm flex items-center justify-center gap-2 cursor-pointer glass hover:bg-white/80 transition-colors shadow-sm">
                  <Upload size={18} /> Upload Image
                  <input
                    type="file"
                    accept="image/*"
                    className="hidden"
                    onChange={handleFileUpload}
                  />
                </label>
              </div>
            </div>
          )}

          {/* ── SCANNING MODE ── */}
          {mode === "scanning" && (
            <div>
              <div
                className="rounded-2xl overflow-hidden mb-4 border border-white/10 bg-black"
                style={{ maxWidth: "500px", margin: "0 auto" }}
              >
                <div id="qr-reader" />
              </div>
              <div className="text-center">
                <div
                  className="inline-flex items-center gap-2 px-4 py-2 rounded-full text-xs font-bold mb-4"
                  style={{
                    background: "rgba(16,185,129,0.15)",
                    border: "1px solid rgba(16,185,129,0.3)",
                    color: "#34d399",
                  }}
                >
                  <Zap size={14} /> QR Codes auto-detect! Just point at a QR
                  code.
                </div>
                <p className="text-slate-400 text-xs mb-4">
                  For printed business cards (no QR), align and tap "Capture
                  Card" to use AI OCR.
                </p>
                <div className="flex gap-3 justify-center">
                  <UiloraBrandButton
                    onClick={captureImage}
                    className="px-5 py-3 normal-case tracking-normal"
                  >
                    <Camera size={16} /> Capture Card
                  </UiloraBrandButton>
                  <button
                    onClick={() => {
                      stopScanner();
                      setMode("idle");
                    }}
                    className="px-5 py-3 rounded-xl font-bold text-sm text-[#77716C] bg-white border border-[#EAE2DB] shadow-2xs hover:bg-[#FAF6F2] hover:text-[#191919] hover:border-[#D4622C]/40 cursor-pointer transition-all"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* ── PREVIEW MODE (Rotate & Confirm) ── */}
          {mode === "preview" && (
            <div className="glass-premium p-6 md:p-8">
              <h3 className="text-lg font-bold text-[var(--color-ink-2)] mb-4 flex items-center gap-2">
                <RotateCw size={20} className="text-sky-400" /> Review Image
              </h3>
              <div className="rounded-xl overflow-hidden mb-4 border border-[var(--color-glass-border)] bg-black/5">
                {capturedImage && (
                  <img
                    src={capturedImage}
                    alt="Preview"
                    className="w-full block"
                  />
                )}
              </div>
              <div className="flex gap-3 justify-center mb-4">
                <button
                  onClick={() => rotateImage(-90)}
                  className="w-10 h-10 rounded-full flex items-center justify-center glass text-[var(--color-ink-2)] hover:bg-white/80 cursor-pointer transition-colors"
                >
                  <RotateCcw size={18} />
                </button>
                <button
                  onClick={() => rotateImage(90)}
                  className="w-10 h-10 rounded-full flex items-center justify-center glass text-[var(--color-ink-2)] hover:bg-white/80 cursor-pointer transition-colors"
                >
                  <RotateCw size={18} />
                </button>
              </div>
              <div className="flex gap-3">
                <button
                  onClick={() => {
                    setCapturedImage(null);
                    setMode("idle");
                  }}
                  className="flex-1 py-3 rounded-full font-bold text-sm text-[var(--color-ink-2)] glass cursor-pointer hover:bg-white/80 transition-colors"
                >
                  Retake
                </button>
                <UiloraBrandButton
                  onClick={processImage}
                  className="flex-1 py-3 normal-case tracking-normal shadow-sm"
                >
                  <CheckCircle2 size={16} /> Extract Details
                </UiloraBrandButton>
              </div>
            </div>
          )}

          {/* ── PROCESSING MODE ── */}
          {mode === "processing" && (
            <div className="glass-premium p-10 text-center">
              <div className="relative inline-block mb-4">
                <div className="absolute inset-[-10px] bg-[radial-gradient(circle,rgba(14,165,233,0.3)_0%,transparent_70%)] rounded-full" />
                <Loader2
                  size={48}
                  className="text-sky-400 animate-spin relative z-10"
                />
              </div>
              <h3 className="text-lg font-bold text-[var(--color-ink-2)] mb-1">
                Processing...
              </h3>
              <p className="text-[var(--color-muted)] text-xs uppercase tracking-wider font-bold mb-4">
                {ocrProgress < 50
                  ? "Initializing Engine"
                  : ocrProgress < 90
                    ? "Powering up AI"
                    : "Extracting Details"}
              </p>
              {ocrProgress > 0 && (
                <div className="w-48 mx-auto h-1.5 rounded-full bg-[var(--color-glass-border)] overflow-hidden">
                  <div
                    className="h-full bg-[var(--color-indigo)] rounded-full transition-all duration-300"
                    style={{ width: `${ocrProgress}%` }}
                  />
                </div>
              )}
            </div>
          )}

          {/* ── REVIEW MODE ── */}
          {mode === "review" && (
            <div className="glass-premium p-6 md:p-8">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-lg font-bold text-[var(--color-ink-2)] flex items-center gap-2">
                  <CheckCircle2 size={20} className="text-emerald-400" /> Review
                  Contact
                </h3>
                {extractionSource && (
                  <span
                    className={`text-[10px] font-bold uppercase tracking-wider px-3 py-1.5 rounded-full ${
                      extractionSource === "ai"
                        ? "bg-[var(--color-indigo-dim)] text-[var(--color-indigo)] border border-[var(--color-glass-border)]"
                        : "bg-amber-500/15 text-amber-600 border border-amber-500/30"
                    }`}
                  >
                    {extractionSource === "ai" ? "AI Powered" : "Basic OCR"}
                  </span>
                )}
              </div>

              {capturedImage && (
                <div className="rounded-xl overflow-hidden mb-6 border border-[var(--color-glass-border)] bg-black/5">
                  <img
                    src={capturedImage}
                    alt="Card"
                    className="w-full object-contain max-h-[180px]"
                  />
                </div>
              )}

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
                {[
                  { key: "fullName", label: "Full Name", icon: User },
                  { key: "email", label: "Email", icon: Mail },
                  { key: "phone", label: "Primary Number", icon: Phone },
                  { key: "phone2", label: "Secondary Number", icon: Phone },
                  { key: "company", label: "Company", icon: Briefcase },
                  { key: "jobTitle", label: "Job Title", icon: Award },
                  { key: "website", label: "Website", icon: Globe },
                  { key: "address", label: "Address", icon: MapPin },
                ].map((field) => (
                  <div key={field.key}>
                    <label className="block text-[10px] font-bold uppercase tracking-wider text-[var(--color-muted)] mb-1.5 flex items-center gap-1">
                      <field.icon size={12} /> {field.label}
                    </label>
                    <div className="premium-input flex items-center overflow-hidden">
                      <input
                        type="text"
                        value={formData[field.key]}
                        onChange={(e) =>
                          setFormData((f) => ({
                            ...f,
                            [field.key]: e.target.value,
                          }))
                        }
                        placeholder={`Enter ${field.label.toLowerCase()}`}
                        className="w-full bg-transparent border-none px-4 py-2.5 text-sm focus:ring-0 outline-none transition-all text-[var(--color-ink-2)] placeholder-[var(--color-muted)]/50"
                      />
                    </div>
                  </div>
                ))}
                <div className="sm:col-span-2">
                  <label className="block text-[10px] font-bold uppercase tracking-wider text-[var(--color-muted)] mb-1.5 flex items-center gap-1">
                    <Calendar size={12} /> Meeting
                  </label>
                  <div className="premium-input flex items-center overflow-hidden mb-4">
                    <input
                      type="text"
                      value={formData.meeting}
                      onChange={(e) =>
                        setFormData((f) => ({ ...f, meeting: e.target.value }))
                      }
                      placeholder="Enter meeting details..."
                      className="w-full bg-transparent border-none px-4 py-2.5 text-sm focus:ring-0 outline-none transition-all text-[var(--color-ink-2)] placeholder-[var(--color-muted)]/50"
                    />
                  </div>
                </div>
                <div className="sm:col-span-2">
                  <label className="block text-[10px] font-bold uppercase tracking-wider text-[var(--color-muted)] mb-1.5 flex items-center gap-1">
                    <FileText size={12} /> Description
                  </label>
                  <div className="premium-input overflow-hidden">
                    <textarea
                      value={formData.notes}
                      onChange={(e) =>
                        setFormData((f) => ({ ...f, notes: e.target.value }))
                      }
                      placeholder="Enter any additional description..."
                      rows={3}
                      className="w-full bg-transparent border-none px-4 py-2.5 text-sm resize-none focus:ring-0 outline-none transition-all custom-scrollbar max-h-[180px] overflow-y-auto text-[var(--color-ink-2)] placeholder-[var(--color-muted)]/50"
                    />
                  </div>
                </div>
              </div>

              <div className="flex gap-3">
                <UiloraBrandButton
                  onClick={handleSave}
                  disabled={isProcessing}
                  className="flex-[3] py-3 normal-case tracking-normal disabled:opacity-50 shadow-sm"
                >
                  {isProcessing ? (
                    <>
                      <Loader2 size={16} className="animate-spin" /> Saving...
                    </>
                  ) : (
                    <>
                      <Save size={16} /> Save Contact
                    </>
                  )}
                </UiloraBrandButton>
                <button
                  onClick={resetScanner}
                  className="flex-[2] py-3 rounded-full font-bold text-sm text-[var(--color-ink-2)] glass cursor-pointer hover:bg-white/80 transition-colors flex items-center justify-center gap-2 shadow-sm"
                >
                  <RefreshCw size={14} /> Scan Again
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Right Column: Features Info */}
        <div className="glass-premium p-6 md:p-8">
          <h4 className="text-base md:text-lg font-bold text-[var(--color-ink-2)] mb-6 md:mb-8">
            Intelligent Capture
          </h4>
          {[
            {
              icon: Zap,
              color: "sky",
              title: "Lightning Fast OCR",
              desc: "AI engine instantly detects and extracts contact fields from physical business cards with high accuracy.",
            },
            {
              icon: Smartphone,
              color: "emerald",
              title: "QR Code Ready",
              desc: "Skip OCR completely by scanning vCard QR codes. The scanner auto-detects and parses them instantly.",
            },
            {
              icon: Shield,
              color: "violet",
              title: "Secure Vault Sync",
              desc: "All captured contacts are permanently saved to your encrypted vault for easy retrieval.",
            },
          ].map((feat) => (
            <div key={feat.title} className="flex items-start gap-4 mb-6">
              <div
                className={`p-3 rounded-full flex-shrink-0`}
                style={{
                  background:
                    feat.color === "sky"
                      ? "rgba(56,189,248,0.1)"
                      : feat.color === "emerald"
                        ? "rgba(16,185,129,0.1)"
                        : "rgba(139,92,246,0.1)",
                  border: `1px solid ${feat.color === "sky" ? "rgba(56,189,248,0.2)" : feat.color === "emerald" ? "rgba(16,185,129,0.2)" : "rgba(139,92,246,0.2)"}`,
                  color:
                    feat.color === "sky"
                      ? "#38bdf8"
                      : feat.color === "emerald"
                        ? "#34d399"
                        : "#c084fc",
                }}
              >
                <feat.icon size={20} />
              </div>
              <div>
                <h6 className="text-sm font-bold text-[var(--color-ink-2)] mb-1">
                  {feat.title}
                </h6>
                <p className="text-xs text-[var(--color-muted)] leading-relaxed">
                  {feat.desc}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
