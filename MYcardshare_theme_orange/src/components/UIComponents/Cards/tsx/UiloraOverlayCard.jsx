"use client";

import React from "react";

export const UiloraOverlayCard = ({
  image = "https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?q=80&w=1000&auto=format&fit=crop",
  footerText = "Available soon.",
  buttonText = "Notify me",
  className = "",
}) => {
  return (
    <div
      className={`relative w-80 aspect-square overflow-hidden rounded-[2.5rem] group shadow-2xl ${className}`}
    >
      <img
        src={image}
        alt="Card Media"
        className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
      />

      {/* Glass Footer */}
      <div className="absolute bottom-4 left-4 right-4 h-16 rounded-3xl bg-black/40 backdrop-blur-xl border border-white/10 flex items-center justify-between px-6 shadow-[0_8px_32px_0_rgba(0,0,0,0.37)]">
        <span className="text-white text-sm font-medium tracking-tight">
          {footerText}
        </span>
        <button className="bg-white/10 hover:bg-white/20 text-white text-xs font-semibold py-2 px-4 rounded-2xl transition-all active:scale-95 border border-white/5">
          {buttonText}
        </button>
      </div>
    </div>
  );
};
