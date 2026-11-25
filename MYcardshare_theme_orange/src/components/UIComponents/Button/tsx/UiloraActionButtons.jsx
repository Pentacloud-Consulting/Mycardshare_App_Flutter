"use client";

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Send,
  Check,
  Loader2,
  Trash2,
  AlertCircle,
  Copy,
  Download,
  Bell,
  BellRing,
  Cloud,
  CreditCard,
  Fingerprint,
  CheckCircle2,
  Star,
  Rocket,
} from "lucide-react";

// --- 1. Morphing Submit Action ---
const MorphSubmit = () => {
  const [status, setStatus] = useState("idle");

  const handleClick = () => {
    if (status !== "idle") return;
    setStatus("loading");
    setTimeout(() => setStatus("success"), 2000);
    setTimeout(() => setStatus("idle"), 4000);
  };

  return (
    <button
      onClick={handleClick}
      disabled={status !== "idle"}
      className={`relative flex items-center justify-center h-12 rounded-xl text-sm font-medium transition-all duration-300 overflow-hidden ${
        status === "idle"
          ? "bg-white text-black w-36 hover:bg-zinc-200"
          : status === "loading"
            ? "bg-zinc-800 text-white w-12 rounded-full"
            : "bg-emerald-500 text-white w-36"
      }`}
    >
      <AnimatePresence mode="wait">
        {status === "idle" && (
          <motion.div
            key="idle"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="flex items-center gap-2"
          >
            <span>Submit</span> <Send size={16} />
          </motion.div>
        )}
        {status === "loading" && (
          <motion.div
            key="loading"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <Loader2 size={18} className="animate-spin" />
          </motion.div>
        )}
        {status === "success" && (
          <motion.div
            key="success"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="flex items-center gap-2"
          >
            <span>Sent!</span> <Check size={16} />
          </motion.div>
        )}
      </AnimatePresence>
    </button>
  );
};

// --- 2. Hold to Deploy Action ---
const HoldToDeploy = () => {
  const [progress, setProgress] = useState(0);
  const [isHolding, setIsHolding] = useState(false);
  const [isDone, setIsDone] = useState(false);

  useEffect(() => {
    let interval;
    if (isHolding && progress < 100) {
      interval = setInterval(
        () => setProgress((p) => Math.min(p + 3, 100)),
        30,
      );
    } else if (!isHolding && progress > 0 && progress < 100) {
      interval = setInterval(() => setProgress((p) => Math.max(p - 5, 0)), 30);
    }

    if (progress === 100 && !isDone) {
      setIsDone(true);
      setIsHolding(false);
      setTimeout(() => {
        setIsDone(false);
        setProgress(0);
      }, 3000);
    }
    return () => clearInterval(interval);
  }, [isHolding, progress, isDone]);

  return (
    <button
      onMouseDown={() => setIsHolding(true)}
      onMouseUp={() => setIsHolding(false)}
      onMouseLeave={() => setIsHolding(false)}
      onTouchStart={() => setIsHolding(true)}
      onTouchEnd={() => setIsHolding(false)}
      disabled={isDone}
      className="relative w-40 h-12 bg-zinc-900 rounded-xl text-white font-medium overflow-hidden border border-zinc-800 select-none"
    >
      <div
        className="absolute left-0 top-0 bottom-0 bg-indigo-600 transition-all duration-75 ease-linear"
        style={{ width: `${progress}%` }}
      />
      <div className="relative z-10 flex items-center justify-center w-full h-full gap-2">
        {isDone ? (
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            className="flex items-center gap-2"
          >
            <Rocket size={16} /> <span>Launched</span>
          </motion.div>
        ) : (
          <span className="text-[10px] uppercase tracking-widest">
            {progress > 0 ? "Hold to Deploy" : "Deploy Project"}
          </span>
        )}
      </div>
    </button>
  );
};

// --- 3. Double Confirm Delete ---
const DoubleConfirmDelete = () => {
  const [step, setStep] = useState(0);

  const handleClick = () => {
    if (step === 0) setStep(1);
    else if (step === 1) {
      setStep(2);
      setTimeout(() => setStep(0), 3000);
    }
  };

  return (
    <button
      onClick={handleClick}
      className={`relative w-40 h-12 rounded-xl font-medium transition-all duration-300 overflow-hidden flex items-center justify-center text-sm ${
        step === 0
          ? "bg-zinc-900 text-zinc-400 hover:text-white hover:bg-zinc-800 border border-zinc-800"
          : step === 1
            ? "bg-red-500/10 text-red-500 border border-red-500/50"
            : "bg-red-500 text-white"
      }`}
    >
      <AnimatePresence mode="wait">
        {step === 0 && (
          <motion.div
            key="1"
            initial={{ y: 10, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: -10, opacity: 0 }}
            className="flex items-center gap-2"
          >
            <Trash2 size={16} /> <span>Delete</span>
          </motion.div>
        )}
        {step === 1 && (
          <motion.div
            key="2"
            initial={{ y: 10, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: -10, opacity: 0 }}
            className="flex items-center gap-2"
          >
            <AlertCircle size={16} /> <span>Confirm?</span>
          </motion.div>
        )}
        {step === 2 && (
          <motion.div
            key="3"
            initial={{ scale: 0.5, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            className="flex items-center gap-2"
          >
            <Check size={16} /> <span>Deleted</span>
          </motion.div>
        )}
      </AnimatePresence>
    </button>
  );
};

// --- 4. Magnetic Copy Action ---
const CopyAction = () => {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <button
      onClick={handleCopy}
      className="relative w-36 h-12 bg-zinc-900 border border-zinc-800 hover:border-zinc-700 rounded-xl text-zinc-300 flex items-center justify-center gap-3 transition-colors text-sm"
    >
      <div className="relative flex items-center justify-center w-4 h-4">
        <AnimatePresence mode="wait">
          {!copied ? (
            <motion.div
              key="copy"
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              exit={{ scale: 0 }}
            >
              <Copy size={16} />
            </motion.div>
          ) : (
            <motion.div
              key="check"
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              exit={{ scale: 0 }}
              className="text-emerald-500"
            >
              <Check size={16} />
            </motion.div>
          )}
        </AnimatePresence>
      </div>
      <span>{copied ? "Copied!" : "Copy Link"}</span>
    </button>
  );
};

// --- 5. Download Progress Action ---
const DownloadAction = () => {
  const [status, setStatus] = useState("idle");

  const handleDownload = () => {
    if (status !== "idle") return;
    setStatus("loading");
    setTimeout(() => setStatus("done"), 2500);
    setTimeout(() => setStatus("idle"), 4500);
  };

  return (
    <button
      onClick={handleDownload}
      className="relative w-40 h-12 bg-white text-black font-medium border border-zinc-200 rounded-xl overflow-hidden hover:bg-zinc-100 transition-colors text-sm"
    >
      <AnimatePresence>
        {status === "loading" && (
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: "100%" }}
            transition={{ duration: 2.5, ease: "linear" }}
            className="absolute left-0 top-0 bottom-0 bg-indigo-100"
          />
        )}
      </AnimatePresence>
      <div className="relative z-10 flex items-center justify-center gap-2 w-full h-full">
        <AnimatePresence mode="wait">
          {status === "idle" && (
            <motion.div
              key="i"
              initial={{ y: 10, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: -10, opacity: 0 }}
              className="flex items-center gap-2"
            >
              <Download size={16} /> Download
            </motion.div>
          )}
          {status === "loading" && (
            <motion.div
              key="l"
              initial={{ y: 10, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: -10, opacity: 0 }}
              className="flex items-center gap-2 text-indigo-700"
            >
              <Loader2 size={16} className="animate-spin" /> Downloading
            </motion.div>
          )}
          {status === "done" && (
            <motion.div
              key="d"
              initial={{ y: 10, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: -10, opacity: 0 }}
              className="flex items-center gap-2 text-emerald-600"
            >
              <CheckCircle2 size={16} /> Complete
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </button>
  );
};

// --- 6. Subscribe Bell Action ---
const SubscribeAction = () => {
  const [subbed, setSubbed] = useState(false);

  return (
    <button
      onClick={() => setSubbed(!subbed)}
      className={`relative w-40 h-12 rounded-xl font-medium text-sm transition-all duration-300 flex items-center justify-center gap-2 border ${
        subbed
          ? "bg-zinc-800 border-zinc-700 text-white"
          : "bg-red-600 border-red-500 text-white hover:bg-red-500"
      }`}
    >
      <motion.div
        animate={subbed ? { rotate: [0, -20, 20, -20, 20, 0] } : {}}
        transition={{ duration: 0.5 }}
      >
        {subbed ? (
          <BellRing size={16} className="text-yellow-400" />
        ) : (
          <Bell size={16} />
        )}
      </motion.div>
      <span>{subbed ? "Subscribed" : "Subscribe"}</span>
    </button>
  );
};

// --- 7. Cloud Sync Action ---
const SyncAction = () => {
  const [syncing, setSyncing] = useState(false);
  const [synced, setSynced] = useState(false);

  const handleSync = () => {
    if (syncing || synced) return;
    setSyncing(true);
    setTimeout(() => {
      setSyncing(false);
      setSynced(true);
      setTimeout(() => setSynced(false), 3000);
    }, 2000);
  };

  return (
    <button
      onClick={handleSync}
      className="relative w-36 h-12 bg-zinc-950 border border-zinc-800 hover:border-zinc-700 text-zinc-300 rounded-xl flex items-center justify-center gap-2 transition-all text-sm"
    >
      <AnimatePresence mode="wait">
        {!syncing && !synced && (
          <motion.div
            key="idle"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="flex items-center gap-2"
          >
            <Cloud size={16} /> Sync Data
          </motion.div>
        )}
        {syncing && (
          <motion.div
            key="sync"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="flex items-center gap-2 text-indigo-400"
          >
            <Loader2 size={16} className="animate-spin" /> Syncing
          </motion.div>
        )}
        {synced && (
          <motion.div
            key="done"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="flex items-center gap-2 text-emerald-400"
          >
            <CheckCircle2 size={16} /> Synced
          </motion.div>
        )}
      </AnimatePresence>
    </button>
  );
};

// --- 8. Payment Checkout Action ---
const PaymentAction = () => {
  const [state, setState] = useState("pay");

  const handlePay = () => {
    if (state !== "pay") return;
    setState("processing");
    setTimeout(() => setState("faceid"), 1500);
    setTimeout(() => setState("done"), 3000);
    setTimeout(() => setState("pay"), 5000);
  };

  return (
    <button
      onClick={handlePay}
      className="relative w-40 h-12 bg-indigo-600 text-white rounded-xl text-sm font-medium shadow-lg hover:shadow-indigo-500/25 transition-all overflow-hidden border border-indigo-500"
    >
      <AnimatePresence mode="wait">
        {state === "pay" && (
          <motion.div
            key="pay"
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: -20, opacity: 0 }}
            className="flex items-center justify-center gap-2"
          >
            <CreditCard size={18} /> Checkout
          </motion.div>
        )}
        {state === "processing" && (
          <motion.div
            key="proc"
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: -20, opacity: 0 }}
            className="flex items-center justify-center gap-2"
          >
            <Loader2 size={18} className="animate-spin" /> Processing
          </motion.div>
        )}
        {state === "faceid" && (
          <motion.div
            key="face"
            initial={{ scale: 0.5, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 1.5, opacity: 0 }}
            className="flex items-center justify-center text-emerald-300"
          >
            <Fingerprint size={24} className="animate-pulse" />
          </motion.div>
        )}
        {state === "done" && (
          <motion.div
            key="done"
            initial={{ scale: 0.5, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            className="flex items-center justify-center gap-2"
          >
            <Check size={18} /> Approved
          </motion.div>
        )}
      </AnimatePresence>
    </button>
  );
};

// --- 9. AI Generate Action ---
const AIGenerateAction = () => {
  const [gen, setGen] = useState(false);
  const handleGen = () => {
    if (gen) return;
    setGen(true);
    setTimeout(() => setGen(false), 2500);
  };

  return (
    <button
      onClick={handleGen}
      className="relative w-40 h-12 bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-xl text-sm font-bold shadow-lg overflow-hidden group"
    >
      {gen && (
        <motion.div
          initial={{ left: "-20%" }}
          animate={{ left: "120%" }}
          transition={{ duration: 1.5, ease: "easeInOut", repeat: 1 }}
          className="absolute top-0 bottom-0 w-8 bg-gradient-to-r from-transparent via-white/50 to-transparent skew-x-[-20deg]"
        />
      )}
      <div className="relative z-10 flex items-center justify-center gap-2">
        {gen ? (
          <>
            <Loader2 size={16} className="animate-spin" /> Generating...
          </>
        ) : (
          <>
            <Star size={16} className="fill-white" /> AI Rewrite
          </>
        )}
      </div>
    </button>
  );
};

export default function UiloraActionButtons() {
  return (
    <div className="p-8 md:p-16 flex flex-col gap-12">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 text-white">
        {/* Row 1 */}
        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden group">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Action / Form Submit
          </div>
          <MorphSubmit />
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Action / Long Press
          </div>
          <HoldToDeploy />
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Action / Destructive
          </div>
          <DoubleConfirmDelete />
        </div>

        {/* Row 2 */}
        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Action / Copy State
          </div>
          <CopyAction />
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden group shadow-2xl">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Action / Payment
          </div>
          <PaymentAction />
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Action / Download
          </div>
          <DownloadAction />
        </div>

        {/* Row 3 */}
        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Action / Subscription
          </div>
          <SubscribeAction />
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Action / Cloud Sync
          </div>
          <SyncAction />
        </div>

        <div className="h-64 flex flex-col items-center justify-center p-12 rounded-3xl bg-zinc-900/50 border border-white/5 relative overflow-hidden">
          <div className="absolute top-4 left-4 text-[10px] font-mono text-zinc-600 uppercase tracking-widest">
            Action / AI Generate
          </div>
          <AIGenerateAction />
        </div>
      </div>
    </div>
  );
}
