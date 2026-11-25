"use client";

import { useState } from "react";
import { motion } from "framer-motion";

export default function GlassInput({
  id,
  name,
  label,
  type = "text",
  placeholder,
  value,
  onChange,
  required = true,
  suffix,
  icon: Icon,
  ...props
}) {
  const [isFocused, setIsFocused] = useState(false);
  const inputId = id || name;
  const inputName = name || id;

  return (
    <div className="flex flex-col gap-2">
      {label && (
        <label
          htmlFor={inputId}
          className="text-[11px] font-bold uppercase tracking-[0.12em] text-[#77716C] ml-1"
        >
          {label} {required && <span className="text-[#D4622C]">*</span>}
        </label>
      )}
      <div className="relative group">
        <motion.div
          animate={{
            borderColor: isFocused ? "#D4622C" : "#EAE2DB",
            backgroundColor: isFocused ? "#FFFFFF" : "#F8F4EF",
            boxShadow: isFocused
              ? "0 0 0 3px rgba(212, 98, 44, 0.12)"
              : "0 1px 2px 0 rgba(28, 25, 23, 0.02)",
          }}
          className="relative flex items-center rounded-2xl border transition-all duration-300 overflow-hidden"
        >
          {Icon && (
            <div
              className={`absolute left-4 top-1/2 -translate-y-1/2 flex items-center justify-center z-10 pointer-events-none ${
                isFocused ? "text-[#D4622C]" : "text-[#77716C]"
              } transition-colors duration-300`}
            >
              <Icon size={18} />
            </div>
          )}
          <input
            id={inputId}
            name={inputName}
            type={type}
            value={value ?? ""}
            onChange={onChange}
            onFocus={() => setIsFocused(true)}
            onBlur={() => setIsFocused(false)}
            placeholder={placeholder}
            required={required}
            className={`w-full bg-transparent border-none outline-none py-3 ${
              Icon ? "pl-11" : "pl-4"
            } pr-4 text-sm font-semibold text-[#191919] placeholder:text-[#77716C]/60 focus:ring-0 rounded-2xl`}
            {...props}
          />
          {suffix && (
            <div className="pr-4 flex items-center justify-center text-[10px] font-bold text-[#77716C] uppercase tracking-[0.14em] bg-white h-8 px-3 rounded-lg mr-2 border border-[#EAE2DB]">
              {suffix}
            </div>
          )}
        </motion.div>
      </div>
    </div>
  );
}
