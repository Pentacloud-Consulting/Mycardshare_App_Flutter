"use client";

import { useState, useCallback, useEffect } from "react";
import { useDropzone } from "react-dropzone";
import { motion, AnimatePresence } from "framer-motion";
import {
  Upload,
  File as FileIcon,
  X,
  Check,
  AlertCircle,
  Image as ImageIcon,
  Zap,
  Scan,
  Database,
  Layers,
  Hexagon,
  Cloud,
} from "lucide-react";

// --- Hook for Logic ---
const useFileUploadLogic = ({ maxFiles = 5, onUpload, disabled }) => {
  const [files, setFiles] = useState([]);
  const [globalStatus, setGlobalStatus] = useState("idle");

  const onDrop = useCallback(
    (acceptedFiles) => {
      if (disabled) return;

      const newFiles = acceptedFiles.map((file) => ({
        file,
        id: Math.random().toString(36).substring(7),
        preview: file.type.startsWith("image/")
          ? URL.createObjectURL(file)
          : undefined,
        status: "idle",
        progress: 0,
      }));

      setFiles((prev) => [...prev, ...newFiles].slice(0, maxFiles));
      setGlobalStatus("uploading");

      // Simulate Upload
      newFiles.forEach((f) => {
        let progress = 0;
        const interval = setInterval(() => {
          progress += Math.random() * 10;
          if (progress >= 100) {
            progress = 100;
            clearInterval(interval);
            setFiles((curr) =>
              curr.map((item) =>
                item.id === f.id
                  ? { ...item, status: "success", progress: 100 }
                  : item,
              ),
            );
          } else {
            setFiles((curr) =>
              curr.map((item) =>
                item.id === f.id
                  ? { ...item, status: "uploading", progress }
                  : item,
              ),
            );
          }
        }, 200);
      });

      if (onUpload) onUpload(acceptedFiles);
    },
    [maxFiles, disabled, onUpload],
  );

  const removeFile = (id) => {
    setFiles((prev) => prev.filter((f) => f.id !== id));
  };

  useEffect(() => {
    if (files.length > 0 && files.every((f) => f.status === "success")) {
      setGlobalStatus("success");
      const timer = setTimeout(() => setGlobalStatus("idle"), 3000);
      return () => clearTimeout(timer);
    }
  }, [files]);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    maxFiles,
    disabled,
    accept: {
      "image/*": [],
      "application/pdf": [],
      "video/*": [],
      "audio/*": [],
    },
  });

  return {
    files,
    globalStatus,
    removeFile,
    getRootProps,
    getInputProps,
    isDragActive,
  };
};

// 6. MINIMAL GLASS
export const MinimalGlassUpload = (props) => {
  const { files, getRootProps, getInputProps, isDragActive, removeFile } =
    useFileUploadLogic(props);

  // Default classes to avoid undefined cn errors if utilities don't exist
  const dragOverlayClass = isDragActive
    ? "bg-white/10 ring-2 ring-white/20"
    : "hover:bg-white/10";

  return (
    <div {...getRootProps()} className="w-full">
      <input {...getInputProps()} />
      <motion.div
        layout
        className={`w-full bg-white/5 backdrop-blur-xl border border-white/10 rounded-3xl p-6 transition-all ${dragOverlayClass}`}
      >
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-slate-700 to-slate-600 flex items-center justify-center">
              <Layers className="text-white w-6 h-6" />
            </div>
            <div>
              <h3 className="text-white font-medium">Assets</h3>
              <p className="text-slate-400 text-xs">PNG, JPG, SVG</p>
            </div>
          </div>
          <motion.button
            whileTap={{ scale: 0.95 }}
            className="px-4 py-2 rounded-full bg-white text-black font-semibold text-sm hover:bg-slate-200"
          >
            Browse
          </motion.button>
        </div>

        <div className="space-y-3">
          {files.map((f) => (
            <motion.div
              layout
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              key={f.id}
              className="flex items-center gap-3 p-3 rounded-xl bg-black/20"
            >
              <div className="w-10 h-10 rounded-lg bg-slate-800 flex items-center justify-center">
                {f.status === "success" ? (
                  <Check size={18} className="text-green-400" />
                ) : (
                  <div className="text-xs text-slate-300">
                    {Math.round(f.progress)}%
                  </div>
                )}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-slate-200 text-sm truncate">{f.file.name}</p>
                <div className="w-full bg-slate-700/50 h-1 mt-2 rounded-full overflow-hidden">
                  <motion.div
                    animate={{ width: `${f.progress}%` }}
                    className="h-full bg-white/80"
                  />
                </div>
              </div>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  removeFile(f.id);
                }}
                className="p-2 hover:bg-white/10 rounded-full text-slate-400"
              >
                <X size={14} />
              </button>
            </motion.div>
          ))}
          {files.length === 0 && (
            <div className="h-24 border-2 border-dashed border-white/5 rounded-xl flex items-center justify-center text-slate-500 text-sm">
              Drop files here
            </div>
          )}
        </div>
      </motion.div>
    </div>
  );
};
