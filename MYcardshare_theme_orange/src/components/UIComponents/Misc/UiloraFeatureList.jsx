"use client";

import React from "react";
import { motion } from "framer-motion";
import { Zap, Link as LinkIcon, BarChart3 } from "lucide-react";

const FEATURES = [
  {
    icon: Zap,
    title: "Instant setup",
    subtitle: "Live in under 2 minutes",
    iconColor: "text-orange-400",
    bgColor: "bg-orange-500/10",
  },
  {
    icon: LinkIcon,
    title: "Share anywhere",
    subtitle: "NFC, QR, Link, Email",
    iconColor: "text-sky-400",
    bgColor: "bg-sky-500/10",
  },
  {
    icon: BarChart3,
    title: "Track engagement",
    subtitle: "Views, scans, CRM sync",
    iconColor: "text-indigo-400",
    bgColor: "bg-indigo-500/10",
  },
];

export const UiloraFeatureList = ({ className = "" }) => {
  return (
    <div className={`flex flex-col gap-6 ${className}`}>
      {FEATURES.map((feature, index) => (
        <motion.div
          key={feature.title}
          initial={{ opacity: 0, x: -20 }}
          whileInView={{ opacity: 1, x: 0 }}
          transition={{ delay: index * 0.1, duration: 0.5 }}
          className="flex items-center gap-4 group"
        >
          <div
            className={`w-12 h-12 rounded-full ${feature.bgColor} flex items-center justify-center border border-white/5 transition-transform duration-500 group-hover:scale-110`}
          >
            <feature.icon size={20} className={feature.iconColor} />
          </div>
          <div>
            <h4 className="text-[14px] font-bold text-white tracking-tight">
              {feature.title}
            </h4>
            <p className="text-[12px] text-slate-400/80 font-medium">
              {feature.subtitle}
            </p>
          </div>
        </motion.div>
      ))}
    </div>
  );
};
