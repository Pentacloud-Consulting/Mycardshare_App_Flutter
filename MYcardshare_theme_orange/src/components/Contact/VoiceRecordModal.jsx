"use client";

import { useState, useRef, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Mic, MicOff, X, Loader2, CheckCircle2, Save, RefreshCw,
  User, Mail, Phone, Briefcase, Award, Globe, MapPin,
  FileText, Calendar, AlertCircle, Square, Volume2
} from "lucide-react";
import { UiloraBrandButton } from "@/components/UIComponents/Button/tsx/UiloraModernButtons";
import { authFetch } from "@/lib/api";

// Sub-component for real-time audio visualization
const AudioVisualizer = ({ stream }) => {
  const canvasRef = useRef(null);
  const animationRef = useRef(null);

  useEffect(() => {
    if (!stream) return;

    const audioContext = new (window.AudioContext || window.webkitAudioContext)();
    const source = audioContext.createMediaStreamSource(stream);
    const analyzer = audioContext.createAnalyser();
    analyzer.fftSize = 64;
    source.connect(analyzer);

    const bufferLength = analyzer.frequencyBinCount;
    const dataArray = new Uint8Array(bufferLength);
    const canvas = canvasRef.current;
    const ctx = canvas.getContext("2d");

    const draw = () => {
      animationRef.current = requestAnimationFrame(draw);
      analyzer.getByteFrequencyData(dataArray);

      ctx.clearRect(0, 0, canvas.width, canvas.height);
      const barWidth = (canvas.width / bufferLength) * 2;
      let x = 0;

      for (let i = 0; i < bufferLength; i++) {
        const barHeight = (dataArray[i] / 255) * canvas.height * 0.8;
        
        // Gradient styling
        const gradient = ctx.createLinearGradient(0, canvas.height, 0, 0);
        gradient.addColorStop(0, "rgba(212, 98, 44, 0.15)");
        gradient.addColorStop(1, "rgba(212, 98, 44, 0.85)");
        
        ctx.fillStyle = gradient;
        ctx.beginPath();
        if (ctx.roundRect) {
          ctx.roundRect(x, canvas.height / 2 - barHeight / 2, barWidth - 2, barHeight, 4);
        } else {
          ctx.rect(x, canvas.height / 2 - barHeight / 2, barWidth - 2, barHeight);
        }
        ctx.fill();

        x += barWidth;
      }
    };

    draw();

    return () => {
      cancelAnimationFrame(animationRef.current);
      audioContext.close();
    };
  }, [stream]);

  return <canvas ref={canvasRef} className="w-full h-20" width={300} height={80} />;
};

export default function VoiceRecordModal({ isOpen, onClose, onSuccess }) {
  const [mode, setMode] = useState("idle"); // idle | listening | processing | review | error
  const [transcript, setTranscript] = useState("");
  const [interimText, setInterimText] = useState("");
  const [error, setError] = useState(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [pulseAnim, setPulseAnim] = useState(false);
  
  // Refs for audio handling
  const mediaRecorderRef = useRef(null);
  const audioChunksRef = useRef([]);
  const streamRef = useRef(null);
  const recognitionRef = useRef(null);

  // Refs to track latest transcript (avoids stale closure in mediaRecorder.onstop)
  const transcriptRef = useRef("");
  const interimRef = useRef("");
  
  const [formData, setFormData] = useState({
    fullName: "", email: "", phone: "", phone2: "",
    company: "", jobTitle: "", website: "", address: "",
    meeting: "", notes: "", raw_transcript: "",
  });

  const stopAllTracks = useCallback(() => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach(track => track.stop());
      streamRef.current = null;
    }
    if (recognitionRef.current) {
      recognitionRef.current.stop();
      recognitionRef.current = null;
    }
  }, []);

  const startListening = useCallback(async () => {
    try {
      setError(null);
      setTranscript("");
      setInterimText("");
      audioChunksRef.current = [];

      // 1. Request microphone with high-quality constraints
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        }
      });
      streamRef.current = stream;

      // 2. Setup MediaRecorder for actual audio capture
      const mediaRecorder = new MediaRecorder(stream, {
        mimeType: MediaRecorder.isTypeSupported("audio/webm") ? "audio/webm" : "audio/ogg"
      });
      
      mediaRecorder.ondataavailable = (e) => {
        if (e.data.size > 0) audioChunksRef.current.push(e.data);
      };

      mediaRecorder.onstop = () => {
        const audioBlob = new Blob(audioChunksRef.current, { type: mediaRecorder.mimeType });
        processAudio(audioBlob);
      };

      mediaRecorderRef.current = mediaRecorder;
      mediaRecorder.start();

      // 3. Setup Web Speech API for LIVE FEEDBACK only (not for final extraction)
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
      if (SpeechRecognition) {
        const recognition = new SpeechRecognition();
        recognition.continuous = true;
        recognition.interimResults = true;
        recognition.lang = "en-US"; // Better general accuracy for contact info
        
        recognition.onresult = (event) => {
          let final = "";
          let interim = "";
          for (let i = event.resultIndex; i < event.results.length; i++) {
            const result = event.results[i];
            if (result.isFinal) final += result[0].transcript + " ";
            else interim += result[0].transcript;
          }
          if (final) {
            setTranscript(prev => {
              const updated = prev + final;
              transcriptRef.current = updated; // keep ref in sync
              return updated;
            });
          }
          setInterimText(interim);
          interimRef.current = interim; // keep ref in sync
        };

        recognition.onerror = (e) => console.warn("Live transcription error:", e.error);
        recognitionRef.current = recognition;
        recognition.start();
      }

      setMode("listening");
      setPulseAnim(true);
    } catch (err) {
      console.error("Mic access error:", err);
      if (err.name === "NotAllowedError" || err.name === "PermissionDeniedError") {
        setError("Microphone permission denied. Please allow access in your browser settings.");
      } else {
        setError("Could not access microphone. Please ensure no other app is using it.");
      }
      setMode("error");
    }
  }, []);

  const stopListening = useCallback(() => {
    if (mediaRecorderRef.current && mediaRecorderRef.current.state === "recording") {
      mediaRecorderRef.current.stop();
    }
    stopAllTracks();
    setPulseAnim(false);
  }, [stopAllTracks]);

  const processAudio = async (audioBlob) => {
    setMode("processing");
    setIsProcessing(true);
    
    try {
      // Read from refs to get latest transcript (avoids stale closure)
      const currentTranscript = (transcriptRef.current + " " + interimRef.current).trim();
      console.log("📝 Transcript for extraction:", currentTranscript);
      let response;

      if (currentTranscript.length > 10) {
        // Prefer transcript-only extraction — browser STT is more accurate
        // than Gemini re-processing compressed webm audio
        response = await fetch("/api/voice-extract", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ transcript: currentTranscript }),
        });
      } else {
        // Fallback to audio if transcript is too short/empty
        const formDataToSend = new FormData();
        formDataToSend.append("audio", audioBlob, "recording.webm");
        formDataToSend.append("transcript", currentTranscript);
        response = await fetch("/api/voice-extract", {
          method: "POST",
          body: formDataToSend,
        });
      }

      if (!response.ok) {
        const errData = await response.json().catch(() => ({}));
        const serverError = errData.error?.message || errData.message || "Failed to process audio";
        throw new Error(serverError);
      }

      const result = await response.json();
      if (result.success && result.data) {
        const d = result.data;
        setFormData({
          fullName: d.fullName || "",
          email: d.email || "",
          phone: d.phone || "",
          phone2: d.phone2 || "",
          company: d.company || "",
          jobTitle: d.jobTitle || "",
          website: d.website || "",
          address: d.address || "",
          meeting: "",
          notes: d.notes || "",
          raw_transcript: d.raw_transcript || transcript,
        });
        setMode("review");
      } else {
        throw new Error("Invalid response from server");
      }
    } catch (err) {
      console.error("Voice processing error:", err);
      setError(err.message || "Failed to extract contact details");
      setMode("idle");
    } finally {
      setIsProcessing(false);
    }
  };

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
          source: "voice",
        }),
      });
      if (response.ok) {
        if (onSuccess) onSuccess();
        handleClose();
      } else {
        throw new Error("Failed to save contact");
      }
    } catch (err) {
      setError("Failed to save contact. Please try again.");
    } finally {
      setIsProcessing(false);
    }
  };

  const handleClose = () => {
    stopAllTracks();
    setMode("idle");
    setTranscript("");
    setInterimText("");
    transcriptRef.current = "";
    interimRef.current = "";
    setError(null);
    setFormData({
      fullName: "", email: "", phone: "", phone2: "",
      company: "", jobTitle: "", website: "", address: "",
      meeting: "", notes: "", raw_transcript: "",
    });
    onClose();
  };

  useEffect(() => {
    return () => stopAllTracks();
  }, [stopAllTracks]);

  if (!isOpen) return null;

  const glassCard = {
    background: "#FFFFFF",
    border: "1px solid #EAE2DB",
    boxShadow: "0 24px 60px rgba(28, 25, 23, 0.12)",
  };

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 overflow-y-auto">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={handleClose}
          className="fixed inset-0 bg-black/60 backdrop-blur-sm"
        />

        <motion.div
          initial={{ opacity: 0, scale: 0.9, y: 40 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.9, y: 40 }}
          transition={{ type: "spring", damping: 25, stiffness: 300 }}
          className="relative w-full max-w-xl rounded-[2.5rem] overflow-hidden my-auto border border-[#EAE2DB]"
          style={glassCard}
        >
          {/* Subtle Glow */}
          <div className="absolute top-0 left-1/2 -translate-x-1/2 w-1/2 h-1 bg-gradient-to-r from-transparent via-[#D4622C]/40 to-transparent" />

          {/* Header */}
          <div className="flex items-center justify-between px-8 py-6 border-b border-[#EAE2DB] bg-[#FAF6F2]/60">
            <div className="flex items-center gap-3">
              <div className="p-2.5 rounded-2xl bg-[#FCE9DF] text-[#D4622C]">
                <Mic size={20} />
              </div>
              <div>
                <h3 className="text-lg font-black text-[#191919] tracking-tight">
                  {mode === "review" ? "Intelligence Extract" : "Voice Capture"}
                </h3>
                <p className="text-[10px] font-bold text-[#77716C] uppercase tracking-widest">
                  AI-Powered Contact Entry
                </p>
              </div>
            </div>
            <button onClick={handleClose} className="w-10 h-10 rounded-xl hover:bg-[#FAF6F2] flex items-center justify-center text-[#77716C] hover:text-[#191919] transition-all">
              <X size={20} />
            </button>
          </div>

          <div className="p-8 max-h-[70vh] overflow-y-auto no-scrollbar">
            {/* Error Banner */}
            {error && (
              <motion.div 
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: "auto", opacity: 1 }}
                className="bg-red-500/10 border border-red-500/20 rounded-2xl p-4 text-xs font-bold text-red-600 mb-6 flex items-start gap-3"
              >
                <AlertCircle size={16} className="shrink-0 mt-0.5" />
                <div className="flex-1">{error}</div>
                <button onClick={() => setError(null)}><X size={14} /></button>
              </motion.div>
            )}

            {/* ── IDLE MODE ── */}
            {mode === "idle" && (
              <div className="text-center py-6">
                <div className="relative mb-10">
                   <div className="absolute inset-0 bg-[#D4622C]/10 blur-[80px] rounded-full" />
                   <motion.div
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    className="w-28 h-28 mx-auto rounded-[2rem] bg-gradient-to-br from-[#D4622C] to-[#E88C5D] p-1 cursor-pointer shadow-[0_20px_40px_-10px_rgba(212,98,44,0.35)]"
                    onClick={startListening}
                  >
                    <div className="w-full h-full rounded-[1.8rem] bg-white flex items-center justify-center">
                      <Mic size={40} className="text-[#D4622C]" />
                    </div>
                  </motion.div>
                </div>
                <h4 className="text-2xl font-black text-[#191919] mb-3 tracking-tight">Start Recording</h4>
                <p className="text-[#77716C] text-sm mb-8 leading-relaxed max-w-sm mx-auto font-medium">
                  Speak naturally about the contact. Mention their name, role, and contact details for instant extraction.
                </p>
                <UiloraBrandButton onClick={startListening} className="px-10 py-4 normal-case tracking-normal rounded-2xl shadow-sm">
                  <Mic size={18} /> Tap to Speak
                </UiloraBrandButton>
              </div>
            )}

            {/* ── LISTENING MODE ── */}
            {mode === "listening" && (
              <div className="text-center py-4 space-y-8">
                {/* Visualizer Area */}
                <div className="relative p-6 rounded-[2rem] bg-[#FAF6F2] border border-[#EAE2DB]">
                  <div className="flex items-center justify-between mb-4 px-2">
                    <div className="flex items-center gap-2">
                      <div className="w-2 h-2 rounded-full bg-[#D4622C] animate-pulse" />
                      <span className="text-[10px] font-black uppercase tracking-[0.2em] text-[#D4622C]">Live Capture</span>
                    </div>
                    <div className="flex items-center gap-1.5 text-[#77716C]">
                      <Volume2 size={12} />
                      <span className="text-[9px] font-black uppercase tracking-widest">Listening...</span>
                    </div>
                  </div>
                  
                  <AudioVisualizer stream={streamRef.current} />
                </div>

                {/* Real-time Transcript Preview */}
                <div className="text-left space-y-2">
                   <span className="text-[10px] font-black uppercase tracking-widest text-[#77716C] ml-1">Live Intelligence Preview</span>
                   <div className="rounded-[1.5rem] p-6 bg-[#FAF6F2] border border-[#EAE2DB] min-h-[120px]">
                    {transcript || interimText ? (
                      <p className="text-sm font-bold text-[#191919] leading-relaxed">
                        {transcript}
                        {interimText && <span className="text-[#D4622C] font-medium italic animate-pulse"> {interimText}</span>}
                      </p>
                    ) : (
                      <div className="flex flex-col items-center justify-center h-full py-4 text-[#77716C] gap-3">
                         <Loader2 size={24} className="animate-spin opacity-40 text-[#D4622C]" />
                         <p className="text-[11px] font-bold uppercase tracking-widest italic">Listening for your voice...</p>
                      </div>
                    )}
                  </div>
                </div>

                <button 
                  onClick={stopListening}
                  className="w-full py-4 rounded-2xl bg-white border border-[#D4622C] text-[#D4622C] font-black uppercase tracking-widest text-[11px] hover:bg-[#D4622C] hover:text-white transition-all flex items-center justify-center gap-2 group shadow-2xs"
                >
                  <Square size={14} className="group-hover:fill-current" /> Stop & Analyze
                </button>
              </div>
            )}

            {/* ── PROCESSING MODE ── */}
            {mode === "processing" && (
              <div className="text-center py-12 space-y-6">
                <div className="relative w-20 h-20 mx-auto">
                   <div className="absolute inset-0 bg-[#D4622C]/20 blur-3xl rounded-full animate-pulse" />
                   <Loader2 size={80} className="text-[#D4622C] animate-spin" />
                </div>
                <div className="space-y-2">
                  <h4 className="text-xl font-black text-[#191919] tracking-tight">Analyzing Data</h4>
                  <p className="text-[10px] font-black uppercase tracking-[0.2em] text-[#D4622C]">
                    Processing audio with Gemini 1.5 Flash
                  </p>
                </div>
                <div className="rounded-2xl p-5 mx-auto max-w-sm bg-[#FAF6F2] border border-[#EAE2DB] italic">
                  <p className="text-xs text-[#77716C] leading-relaxed">&quot;{transcript || "Audio data..."}&quot;</p>
                </div>
              </div>
            )}

            {/* ── REVIEW MODE ── */}
            {mode === "review" && (
              <div className="space-y-6">
                <div className="flex items-center justify-between px-2">
                  <span className="text-[10px] font-black uppercase tracking-[0.2em] text-emerald-700 bg-emerald-50 border border-emerald-200 px-3 py-1.5 rounded-full flex items-center gap-2">
                    <CheckCircle2 size={12} /> Data Extraction Complete
                  </span>
                  <button onClick={() => { setMode("idle"); setTranscript(""); }} className="text-[10px] font-black uppercase tracking-widest text-[#77716C] hover:text-[#191919] transition-colors">
                    Reset
                  </button>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
                  {[
                    { key: "fullName", label: "Full Name", icon: User },
                    { key: "email", label: "Email Address", icon: Mail },
                    { key: "phone", label: "Primary Phone", icon: Phone },
                    { key: "company", label: "Organization", icon: Briefcase },
                    { key: "jobTitle", label: "Designation", icon: Award },
                    { key: "website", label: "Website", icon: Globe },
                  ].map((field) => (
                    <div key={field.key} className="space-y-1.5">
                      <label className="text-[9px] font-black uppercase tracking-widest text-[#77716C] ml-1 flex items-center gap-1.5">
                        <field.icon size={10} /> {field.label}
                      </label>
                      <input
                        type="text"
                        value={formData[field.key]}
                        onChange={(e) => setFormData(f => ({ ...f, [field.key]: e.target.value }))}
                        className="w-full px-4 py-3 rounded-xl text-sm font-bold text-[#191919] border border-[#EAE2DB] bg-[#FAF6F2] focus:bg-white focus:border-[#D4622C] focus:ring-2 focus:ring-[#D4622C]/15 focus:outline-none transition-all shadow-2xs"
                      />
                    </div>
                  ))}
                  <div className="sm:col-span-2 space-y-1.5">
                    <label className="text-[9px] font-black uppercase tracking-widest text-[#77716C] ml-1 flex items-center gap-1.5">
                      <FileText size={10} /> Intelligence Summary / Notes
                    </label>
                    <textarea
                      value={formData.notes}
                      onChange={(e) => setFormData(f => ({ ...f, notes: e.target.value }))}
                      className="w-full px-4 py-3 rounded-xl text-sm font-bold text-[#191919] border border-[#EAE2DB] bg-[#FAF6F2] focus:bg-white focus:border-[#D4622C] focus:ring-2 focus:ring-[#D4622C]/15 focus:outline-none transition-all min-h-[100px] resize-none shadow-2xs"
                    />
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Footer Actions — only for review mode */}
          {mode === "review" && (
            <div className="flex gap-4 px-8 py-6 border-t border-[#EAE2DB] bg-[#FAF6F2]/60">
              <UiloraBrandButton
                onClick={handleSave}
                disabled={isProcessing}
                className="flex-[2] py-4 rounded-2xl normal-case tracking-normal text-xs font-black uppercase tracking-[0.1em]"
              >
                {isProcessing ? (
                  <><Loader2 size={16} className="animate-spin" /> Saving...</>
                ) : (
                  <><Save size={16} /> Finalize Contact</>
                )}
              </UiloraBrandButton>
              <button
                onClick={() => { setMode("idle"); setTranscript(""); setInterimText(""); }}
                className="flex-1 py-4 rounded-2xl font-black text-[10px] uppercase tracking-widest text-[#77716C] bg-white border border-[#EAE2DB] hover:bg-[#FAF6F2] hover:text-[#191919] transition-all flex items-center justify-center gap-2 shadow-2xs"
              >
                <RefreshCw size={14} /> Retry
              </button>
            </div>
          )}
        </motion.div>
      </div>
    </AnimatePresence>
  );
}
